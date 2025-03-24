# Testing Blockchain RPC Client in AWS CloudShell

## Prerequisites
- AWS Account with CloudShell access
- Basic familiarity with AWS and CLI tools

## Step-by-Step Testing Process

### 1. Clone the Repository
```bash
# Clone the repository
git clone https://github.com/zdjvqdb/blockchain-client.git
cd blockchain-client
```

### 2. Test Go Application Locally
```bash
# Install Go
sudo yum install -y golang
# Ensure Go is installed
go version

# Run unit tests
go test -v ./...
```

### 3. Prepare AWS Deployment

#### Create ECR Repository
```bash
# Create ECR repository
REPOSITORY_NAME=blockchain-client
AWS_REGION=eu-west-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws ecr create-repository \
    --repository-name $REPOSITORY_NAME \
    --region $AWS_REGION

# Authenticate Docker to ECR (if Docker is available)
aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin \
    $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

### 4. Terraform Deployment
```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Validate Terraform configuration
terraform validate

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Type 'yes' when prompted
```

### 5. Verify Deployment

#### Check ECS Cluster
```bash
# List ECS clusters
aws ecs list-clusters

# Describe the specific cluster
aws ecs describe-clusters --clusters <cluster-arn>

# List tasks in the cluster
aws ecs list-tasks --cluster <cluster-name>
```

#### Retrieve Task Details
```bash
# Get task definition
aws ecs describe-task-definition --task-definition blockchain-client
```

### 6. Testing Endpoints

#### If Load Balancer is Created
```bash
# Retrieve Load Balancer DNS (from AWS Console or Terraform outputs)
LOAD_BALANCER_DNS=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[0].DNSName' --output text)

# Test endpoints
curl http://$LOAD_BALANCER_DNS/block-number
curl "http://$LOAD_BALANCER_DNS/block?number=0x134e82a"
```
