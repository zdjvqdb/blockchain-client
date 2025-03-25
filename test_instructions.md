{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww37900\viewh19680\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 # Testing Blockchain RPC Client in AWS CloudShell\
\
## Prerequisites\
- AWS Account with CloudShell access\
- Basic familiarity with AWS and CLI tools\
\
## Step-by-Step Testing Process\
\
### 1. Clone the Repository\
```bash\
# Clone the repository\
git clone https://github.com/zdjvqdb/blockchain-client.git\
cd blockchain-client\
```\
\
### 2. Test Go Application Locally\
```bash\
# Install Go\
sudo yum install -y golang\
# Ensure Go is installed\
go version\
\
# Run unit tests\
go test -v ./...\
\
\
### 3. Terraform Deployment\
```bash\
# Install terraform\
sudo yum install -y yum-utils\
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo\
sudo yum -y install terraform\
\
# Navigate to terraform directory\
cd terraform\
\
# Initialize Terraform\
terraform init\
\
# Validate Terraform configuration\
terraform validate\
\
# Plan the deployment\
terraform plan\
\
# Apply the configuration\
terraform apply\
\
# Type 'yes' when prompted\
```\
\
### 4. Verify Deployment\
# Get the ECS task ARN\
CLUSTER_NAME=$(terraform output -raw ecs_cluster_name)\
TASK_ARN=$(aws ecs list-tasks --cluster $CLUSTER_NAME --query 'taskArns[0]' --output text)\
\
# Get the task's public IP\
TASK_ENI=$(aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks $TASK_ARN --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)\
PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids $TASK_ENI --query 'NetworkInterfaces[0].Association.PublicIp' --output text)\
\
# Test endpoints\
curl http://$PUBLIC_IP:8080/block-number\
curl "http://$PUBLIC_IP:8080/block?number=0x134e82a"```\
\
### 5. Cleanup\
# Destroy resources when done\
terraform destroy}