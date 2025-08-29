#!/bin/bash

# Update system packages
yum update -y

# Install Apache
yum install -y httpd

# Start Apache service
systemctl start httpd
systemctl enable httpd

# Create a simple index.html file
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to ${environment} Environment</title>
</head>
<body>
    <div>
        <h1>Welcome!</h1>
        <p>Your EC2 instance is running successfully!</p>
        <p>Environment: <strong>${environment}</strong></p>
        <div>Apache Web Server Active</div>
    </div>
</body>
</html>
EOF

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Configure firewall (if using firewalld)
if systemctl is-active --quiet firewalld; then
    firewall-cmd --permanent --add-service=http
    firewall-cmd --reload
fi

# Create a health check endpoint
cat > /var/www/html/health << 'EOF'
OK
EOF

# Log the deployment
echo "Apache web server deployed successfully on $(date)" >> /var/log/apache-deployment.log

# Optional: Install additional tools
yum install -y curl wget unzip

echo "User data script completed successfully!"
