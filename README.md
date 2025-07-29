# Terraform Infrastructure for Containerized Web Application

This repository contains a complete Terraform infrastructure setup for deploying a containerized web application on AWS, following the architecture diagram provided. The infrastructure supports multiple environments (dev, staging, prod) with S3 backend state management.

## Architecture Overview

The infrastructure includes:
- **VPC** with public and private subnets across multiple AZs
- **NAT Gateways** for outbound internet access from private subnets
- **Application Load Balancer (ALB)** for load balancing
- **ECS Fargate** for containerized application hosting
- **Aurora PostgreSQL** for database (multi-AZ)
- **ECR** for container image storage
- **Route53** for DNS management
- **ACM** for SSL certificates
- **S3** for static assets and Terraform state

## Directory Structure

```
terraform-infrastructure/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── terraform.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── staging/
│   │   ├── main.tf
│   │   ├── terraform.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── prod/
│       ├── main.tf
│       ├── terraform.tf
│       ├── variables.tf
│       └── outputs.tf
├── modules/
│   ├── vpc/
│   ├── ecs/
│   ├── alb/
│   ├── rds-aurora/
│   ├── route53/
│   ├── acm/
│   ├── nat-gateway/
│   ├── ecr/
│   └── s3/
└── README.md
```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **S3 bucket** for Terraform state storage
4. **DynamoDB table** for state locking
5. **Domain name** (optional, for custom domain setup)

## Initial Setup

### 1. Create S3 Bucket for Terraform State

```bash
# Create S3 bucket for state storage
aws s3 mb s3://your-terraform-state-bucket --region us-west-2

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket your-terraform-state-bucket \
    --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
    --bucket your-terraform-state-bucket \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'
```

### 2. Create DynamoDB Table for State Locking

```bash
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-west-2
```

### 3. Update Backend Configuration

Update the S3 bucket name in each environment's `terraform.tf` file:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-actual-terraform-state-bucket"
    key            = "dev/terraform.tfstate"  # Change per environment
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## Deployment Instructions

### Development Environment

1. **Navigate to dev environment:**
   ```bash
   cd environments/dev
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Create terraform.tfvars file:**
   ```hcl
   # terraform.tfvars
   project_name = "myapp"
   aws_region   = "us-west-2"
   
   # Database password (use AWS Secrets Manager in production)
   database_password = "your-secure-password"
   
   # Optional: Domain configuration
   domain_name = "example.com"
   subdomain   = "dev"
   
   # ECS Configuration
   ecs_app_count = 1
   ecs_fargate_cpu = "256"
   ecs_fargate_memory = "512"
   
   # Aurora Configuration (minimal for dev)
   aurora_instance_class = "db.t4g.medium"
   aurora_instance_count = 1
   aurora_deletion_protection = false
   aurora_skip_final_snapshot = true
   ```

4. **Plan and Apply:**
   ```bash
   terraform plan
   terraform apply
   ```

### Staging Environment

1. **Navigate to staging environment:**
   ```bash
   cd environments/staging
   ```

2. **Initialize and configure:**
   ```bash
   terraform init
   ```

3. **Create terraform.tfvars file:**
   ```hcl
   # terraform.tfvars
   project_name = "myapp"
   aws_region   = "us-west-2"
   
   database_password = "your-secure-password"
   
   # Domain configuration
   domain_name = "example.com"
   subdomain   = "staging"
   
   # ECS Configuration (higher capacity)
   ecs_app_count = 2
   ecs_fargate_cpu = "512"
   ecs_fargate_memory = "1024"
   
   # Aurora Configuration
   aurora_instance_class = "db.r6g.large"
   aurora_instance_count = 2
   ```

4. **Deploy:**
   ```bash
   terraform plan
   terraform apply
   ```

### Production Environment

1. **Navigate to prod environment:**
   ```bash
   cd environments/prod
   ```

2. **Initialize and configure:**
   ```bash
   terraform init
   ```

3. **Create terraform.tfvars file:**
   ```hcl
   # terraform.tfvars
   project_name = "myapp"
   aws_region   = "us-west-2"
   
   # Use AWS Secrets Manager for production passwords
   database_password = "your-very-secure-password"
   
   # Domain configuration
   domain_name = "example.com"
   
   # Production ECS Configuration
   ecs_app_count = 3
   ecs_fargate_cpu = "1024"
   ecs_fargate_memory = "2048"
   
   # Production Aurora Configuration
   aurora_instance_class = "db.r6g.xlarge"
   aurora_instance_count = 3
   aurora_backup_retention_period = 30
   
   # Enable health checks and monitoring
   enable_health_check = true
   ```

4. **Deploy:**
   ```bash
   terraform plan
   terraform apply
   ```

## Application Deployment

### 1. Build and Push Docker Image

```bash
# Get ECR login token
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-2.amazonaws.com

# Build your application image
docker build -t myapp .

# Tag for ECR
docker tag myapp:latest <ecr-repository-url>:latest

# Push to ECR
docker push <ecr-repository-url>:latest
```

### 2. Update ECS Service

```bash
# Force new deployment to pull latest image
aws ecs update-service \
    --cluster myapp-dev-cluster \
    --service myapp-dev-service \
    --force-new-deployment
```

## Environment Variables Configuration

Set environment variables for your application in the terraform.tfvars file:

```hcl
ecs_environment_variables = [
  {
    name  = "NODE_ENV"
    value = "production"
  },
  {
    name  = "DATABASE_URL"
    value = "postgresql://username:password@endpoint:5432/dbname"
  },
  {
    name  = "REDIS_URL"
    value = "redis://redis-endpoint:6379"
  }
]
```

## DNS Configuration

If using a custom domain:

1. **Update nameservers** in your domain registrar to point to the Route53 hosted zone nameservers
2. **Wait for DNS propagation** (can take up to 48 hours)
3. **Verify SSL certificate** is issued and validated

## Monitoring and Logging

### CloudWatch Logs
- ECS task logs are automatically sent to CloudWatch
- Log groups are created per environment
- Retention periods are configurable per environment

### Health Checks
- ALB health checks monitor application health
- Route53 health checks (production only) monitor external availability

## Security Best Practices

1. **Database passwords**: Use AWS Secrets Manager in production
2. **IAM roles**: Principle of least privilege applied
3. **Security groups**: Restrictive rules, only necessary ports open
4. **Encryption**: Enabled for Aurora, S3, and ECS logs
5. **VPC**: Private subnets for application and database tiers

## Backup Strategy

### Aurora Backups
- **Automated backups**: Configured per environment
- **Point-in-time recovery**: Available within retention period
- **Final snapshots**: Disabled for dev, enabled for staging/prod

### Application Data
- **ECR images**: Lifecycle policies prevent storage bloat
- **S3 assets**: Versioning and lifecycle policies configured

## Disaster Recovery

1. **Multi-AZ deployment**: Aurora and ECS across multiple availability zones
2. **Automated backups**: Database backups with configurable retention
3. **Infrastructure as Code**: Complete infrastructure can be recreated from Terraform

## Cost Optimization

### Development
- Single AZ deployment
- Smaller instance sizes
- Shorter backup retention
- No NAT Gateway in some cases

### Production
- Multi-AZ for high availability
- Larger instances for performance
- Extended backup retention
- Enhanced monitoring enabled

## Troubleshooting

### Common Issues

1. **ECS tasks not starting**:
   ```bash
   # Check ECS service events
   aws ecs describe-services --cluster <cluster-name> --services <service-name>
   
   # Check task definition
   aws ecs describe-task-definition --task-definition <task-definition-arn>
   ```

2. **Database connection issues**:
   ```bash
   # Verify security group rules
   aws ec2 describe-security-groups --group-ids <security-group-id>
   ```

3. **Domain/SSL issues**:
   ```bash
   # Check certificate status
   aws acm describe-certificate --certificate-arn <certificate-arn>
   
   # Verify DNS records
   nslookup <domain-name>
   ```

### Terraform State Issues

```bash
# Force unlock state (use with caution)
terraform force-unlock <lock-id>

# Import existing resources
terraform import <resource-type>.<resource-name> <resource-id>
```

## Cleanup

To destroy environments:

```bash
cd environments/<environment>
terraform destroy
```

**Warning**: This will delete all resources including databases. Ensure backups are taken before destroying production environments.

## Contributing

1. Create feature branches for infrastructure changes
2. Test changes in development environment first
3. Use `terraform plan` to review changes before applying
4. Update documentation for any new modules or features

## Support

For infrastructure issues:
1. Check Terraform state and AWS CloudFormation events
2. Review CloudWatch logs for application issues
3. Verify security group and network connectivity
4. Check AWS service limits and quotas