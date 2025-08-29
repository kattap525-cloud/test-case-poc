#!/bin/bash

set -e

AWS_REGION=${AWS_REGION:-us-east-1}
ENVIRONMENT=${ENVIRONMENT:-prod}
SKIP_BUILD=${SKIP_BUILD:-false}
SKIP_ECR=${SKIP_ECR:-false}
SKIP_TERRAFORM=${SKIP_TERRAFORM:-false}
AUTO_APPROVE=${AUTO_APPROVE:-false}
DB_PASSWORD=${DB_PASSWORD:-""}

build_microservices() {
    if [ "$SKIP_BUILD" = "true" ]; then
        return 0
    fi
    
    cd applications
    
    cd msa1
    mvn clean package -DskipTests
    
    cd ../msa2
    mvn clean package -DskipTests
    
    cd ../msa3
    mvn clean package -DskipTests
    
    cd ../..
}

setup_web_server() {
    if [ "$SKIP_BUILD" = "true" ]; then
        return 0
    fi
    
    cd applications/web-server
    npm install
    
    cd ../..
}

build_docker_images() {
    if [ "$SKIP_BUILD" = "true" ]; then
        return 0
    fi
    
    cd applications

    cd msa1
    docker buildx build --platform linux/amd64 -t ecommerce/msa1:latest --load .

    cd ../msa2
    docker buildx build --platform linux/amd64 -t ecommerce/msa2:latest --load .

    cd ../msa3
    docker buildx build --platform linux/amd64 -t ecommerce/msa3:latest --load .

    
    cd ../web-server
    docker buildx build --platform linux/amd64 -t ecommerce/web-server:latest --load .
    
    cd ../..
}

setup_ecr_repositories() {
    if [ "$SKIP_ECR" = "true" ]; then
        return 0
    fi
    aws ecr create-repository --repository-name ecommerce/web-server --region $AWS_REGION 2>/dev/null || echo "Web server repository already exists"
    aws ecr create-repository --repository-name ecommerce/msa1 --region $AWS_REGION 2>/dev/null || echo "MSA1 repository already exists"
    aws ecr create-repository --repository-name ecommerce/msa2 --region $AWS_REGION 2>/dev/null || echo "MSA2 repository already exists"
    aws ecr create-repository --repository-name ecommerce/msa3 --region $AWS_REGION 2>/dev/null || echo "MSA3 repository already exists"
}

# Function to login to ECR and push images
push_images_to_ecr() {
    if [ "$SKIP_ECR" = "true" ]; then
        return 0
    fi
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
    
    cd applications
    
    # MSA1
    cd msa1
    docker tag ecommerce/msa1:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ecommerce/msa1:latest
    
    # MSA2
    cd ../msa2
    docker tag ecommerce/msa2:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ecommerce/msa2:latest
    
    # MSA3
    cd ../msa3
    docker tag ecommerce/msa3:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ecommerce/msa3:latest
    
    # Web server
    cd ../web-server
    docker tag ecommerce/web-server:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ecommerce/web-server:latest
    
    cd ..
    
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ecommerce/msa1:latest
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ecommerce/msa2:latest
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ecommerce/msa3:latest
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ecommerce/web-server:latest
    
    cd ..
    
}

update_terraform_vars() {
    if [ -f "terraform.tfvars" ]; then
        cp terraform.tfvars terraform.tfvars.backup.$(date +%Y%m%d_%H%M%S)
            echo "Backed up current terraform.tfvars"
    fi
    
    if [ -z "$DB_PASSWORD" ]; then
        DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
        echo "generated database password: $DB_PASSWORD"
    fi
    cat > terraform.tfvars << EOF
# AWS Configuration
aws_region = "$AWS_REGION"

# Environment Configuration
environment = "$ENVIRONMENT"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# Database Configuration
db_username = "admin"
db_password = "$DB_PASSWORD"

# Instance Types
instance_type = "t3.micro"
db_instance_class = "db.t3.micro"
redis_node_type = "cache.t3.micro"

# Docker Images - ECR URIs
web_server_image = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ecommerce/web-server:latest"
msa1_image = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ecommerce/msa1:latest"
msa2_image = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ecommerce/msa2:latest"
msa3_image = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ecommerce/msa3:latest"
EOF
    echo "Database password: $DB_PASSWORD"
}

deploy_infrastructure() {
    if [ "$SKIP_TERRAFORM" = "true" ]; then
        return 0
    fi
    
    if [ ! -f "terraform.tfvars" ]; then
        exit 1
    fi
    
    terraform init
    terraform validate
    terraform plan
    
    if [ "$AUTO_APPROVE" != "true" ]; then
        echo ""
        read -p "proceed deployment? (yes/no): " confirm
        
        if [ "$confirm" != "yes" ]; then
            echo "cancelled by user"
            exit 0
        fi
    fi
    
    terraform apply -auto-approve
}

perform_health_checks() {
    sleep 30
    
    ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "")
    
    if [ -z "$ALB_DNS" ]; then
        echo "Could not retrieve ALB DNS name"
        return 0
    fi
    
    echo "Checking web server health..."
    if curl -f -s "http://$ALB_DNS/health" > /dev/null 2>&1; then
        echo "Web server is healthy"
    else
    fi
    
    echo "Checking microservices health..."
    for service in msa1 msa2 msa3; do
        if curl -f -s "http://$ALB_DNS/api/$service/health" > /dev/null 2>&1; then
            echo "$service is healthy"
        else
            echo "$service health check failed"
        fi
    done
    
}

show_results() {
    echo "Infrastructure Outputs:"
    terraform output
    
    ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "LOADING...")
    
    echo "   Web Application: http://$ALB_DNS"
    echo "   MSA1: http://$ALB_DNS/api/msa1/*"
    echo "   MSA2: http://$ALB_DNS/api/msa2/*"
    echo "   MSA3: http://$ALB_DNS/api/msa3/*"
    echo "   DB Username: admin"
    echo "   DB Password: $DB_PASSWORD"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--region)
            AWS_REGION="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -p|--password)
            DB_PASSWORD="$2"
            shift 2
            ;;
        --skip-build)
            SKIP_BUILD="true"
            shift
            ;;
        --skip-ecr)
            SKIP_ECR="true"
            shift
            ;;
        --skip-terraform)
            SKIP_TERRAFORM="true"
            shift
            ;;
        --auto-approve)
            AUTO_APPROVE="true"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

main() {
    echo "Starting deployment process..."
    echo ""
    
    build_microservices
    setup_web_server
    build_docker_images
    
    setup_ecr_repositories
    push_images_to_ecr
    
    update_terraform_vars
    
    deploy_infrastructure
    
    perform_health_checks
    show_results
}

trap 'echo "Deployment failed. Please check the logs above."; exit 1' ERR

main "$@"
