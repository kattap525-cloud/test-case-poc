#!/bin/bash

set -e

check_prerequisites() {
    if [ ! -f "main.tf" ] || [ ! -f "variables.tf" ]; then
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install jq
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y jq
        else
            exit 1
        fi
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        exit 1
    fi
    
    AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    AWS_REGION=$(aws configure get region)
}

init_terraform() {
    terraform init
}

plan_deployment() {
    terraform plan -out=tfplan
}

apply_deployment() {
    terraform apply tfplan
}

show_outputs() {
    if terraform output vpc_id &> /dev/null; then
        VPC_ID=$(terraform output -raw vpc_id)
    fi
    
    if terraform output public_subnet_ids &> /dev/null; then
        PUBLIC_SUBNET_IDS=$(terraform output -json public_subnet_ids | jq -r '.[]' | tr '\n' ' ')
    fi
    
    if terraform output private_subnet_id &> /dev/null; then
        PRIVATE_SUBNET_ID=$(terraform output -raw private_subnet_id)
    fi
    
    if terraform output ec2_instance_id &> /dev/null; then
        EC2_INSTANCE_ID=$(terraform output -raw ec2_instance_id)
    fi
    
    if terraform output ec2_private_ip &> /dev/null; then
        EC2_PRIVATE_IP=$(terraform output -raw ec2_private_ip)
    fi
    
    if terraform output load_balancer_dns &> /dev/null; then
        ALB_DNS=$(terraform output -raw load_balancer_dns)
    fi
}

cleanup() {
    if [ -f "tfplan" ]; then
        rm tfplan
    fi
}

main() {
    check_prerequisites
    
    init_terraform
    
    plan_deployment
    
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        apply_deployment
        
        show_outputs
    else
        cleanup
        exit 0
    fi
    
    cleanup
}

trap 'cleanup; exit 1' INT TERM

main "$@"
