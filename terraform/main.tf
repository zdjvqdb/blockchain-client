{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 Monaco;}
{\colortbl;\red255\green255\blue255;\red81\green100\blue100;}
{\*\expandedcolortbl;;\cssrgb\c38824\c46667\c46667;}
\paperw11900\paperh16840\margl1440\margr1440\vieww37900\viewh19680\viewkind0
\deftab720
\pard\pardeftab720\partightenfactor0

<<<<<<< HEAD
\f0\fs24 \cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 # main.tf\
\
provider "aws" \{\
  region = "eu-west-1"\
\}\
\
variable "image_tag" \{\
  description = "Docker image tag"\
  default     = "latest"\
\}\
\
# Get default VPC\
data "aws_vpc" "default" \{\
  default = true\
\}\
\
# Get default subnets\
data "aws_subnets" "default" \{\
  filter \{\
    name   = "vpc-id"\
    values = [data.aws_vpc.default.id]\
  \}\
\
  filter \{\
    name   = "default-for-az"\
    values = [true]\
  \}\
\}\
\
# Security Group\
resource "aws_security_group" "blockchain_client" \{\
  name        = "blockchain-client-sg"\
  description = "Security group for blockchain client"\
  vpc_id      = data.aws_vpc.default.id\
\
  ingress \{\
    from_port   = 8080\
    to_port     = 8080\
    protocol    = "tcp"\
    cidr_blocks = ["0.0.0.0/0"]\
  \}\
\
  egress \{\
    from_port   = 0\
    to_port     = 0\
    protocol    = "-1"\
    cidr_blocks = ["0.0.0.0/0"]\
  \}\
\}\
\
# ECR Repository\
resource "aws_ecr_repository" "blockchain_client" \{\
  name         = "blockchain-client"\
  force_delete = true  # Add this line\
  \
  image_scanning_configuration \{\
    scan_on_push = true\
  \}\
\}\
\
# Docker build and push\
resource "null_resource" "docker_build_push" \{\
  triggers = \{\
    always_run = timestamp()\
  \}\
\
  provisioner "local-exec" \{\
    command = <<EOT\
      aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $\{aws_ecr_repository.blockchain_client.repository_url\}\
      cd ..\
      docker build -t blockchain-client:$\{var.image_tag\} .\
      docker tag blockchain-client:$\{var.image_tag\} $\{aws_ecr_repository.blockchain_client.repository_url\}:$\{var.image_tag\}\
      docker push $\{aws_ecr_repository.blockchain_client.repository_url\}:$\{var.image_tag\}\
    EOT\
  \}\
\}\
\
# ECS Cluster\
resource "aws_ecs_cluster" "main" \{\
  name = "blockchain-client-cluster"\
\}\
\
# CloudWatch Log Group\
resource "aws_cloudwatch_log_group" "blockchain_client" \{\
  name              = "/ecs/blockchain-client"\
  retention_in_days = 30\
\}\
\
# IAM Roles\
resource "aws_iam_role" "ecs_task_execution_role" \{\
  name = "blockchain-client-execution-role"\
\
  assume_role_policy = jsonencode(\{\
    Version = "2012-10-17"\
    Statement = [\{\
      Action = "sts:AssumeRole"\
      Effect = "Allow"\
      Principal = \{\
        Service = "ecs-tasks.amazonaws.com"\
      \}\
    \}]\
  \})\
\}\
\
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" \{\
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"\
  role       = aws_iam_role.ecs_task_execution_role.name\
\}\
\
# Task Definition\
resource "aws_ecs_task_definition" "blockchain_client" \{\
  family                   = "blockchain-client"\
  requires_compatibilities = ["FARGATE"]\
  network_mode            = "awsvpc"\
  cpu                     = 256\
  memory                  = 512\
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn\
\
  container_definitions = jsonencode([\{\
    name  = "blockchain-client"\
    image = "$\{aws_ecr_repository.blockchain_client.repository_url\}:$\{var.image_tag\}"\
    portMappings = [\{\
      containerPort = 8080\
      hostPort      = 8080\
      protocol      = "tcp"\
    \}]\
    logConfiguration = \{\
      logDriver = "awslogs"\
      options = \{\
        "awslogs-group"         = aws_cloudwatch_log_group.blockchain_client.name\
        "awslogs-region"        = "eu-west-1"\
        "awslogs-stream-prefix" = "ecs"\
      \}\
    \}\
  \}])\
\}\
\
# ECS Service\
resource "aws_ecs_service" "blockchain_client" \{\
  name            = "blockchain-client-service"\
  cluster         = aws_ecs_cluster.main.id\
  task_definition = aws_ecs_task_definition.blockchain_client.arn\
  launch_type     = "FARGATE"\
  desired_count   = 1\
\
  network_configuration \{\
    subnets          = data.aws_subnets.default.ids\
    security_groups  = [aws_security_group.blockchain_client.id]\
    assign_public_ip = true\
  \}\
\}\
\
# Outputs\
output "vpc_id" \{\
  value = data.aws_vpc.default.id\
\}\
\
output "subnet_ids" \{\
  value = data.aws_subnets.default.ids\
\}\
\
output "ecr_repository_url" \{\
  value = aws_ecr_repository.blockchain_client.repository_url\
\}\
\
output "ecs_cluster_name" \{\
  value = aws_ecs_cluster.main.name\
\}\
\
output "ecs_service_name" \{\
  value = aws_ecs_service.blockchain_client.name\
\}\
}
=======
# VPC and Networking
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "blockchain-client-vpc"
  }
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = "eu-west-1${count.index == 0 ? "a" : "b"}"
  
  tags = {
    Name = "blockchain-client-public-subnet-${count.index + 1}"
  }
}

# Security Group
resource "aws_security_group" "blockchain_client" {
  name        = "blockchain-client-sg"
  description = "Security group for blockchain client"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECR Repository
resource "aws_ecr_repository" "blockchain_client" {
  name = "blockchain-client"
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "blockchain-client-cluster"
}

# Task Definition
resource "aws_ecs_task_definition" "blockchain_client" {
  family                   = "blockchain-client"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([{
    name  = "blockchain-client"
    image = "${aws_ecr_repository.blockchain_client.repository_url}:latest"
    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
    }]
  }])

  # IAM role for ECS task execution
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach standard ECS Task Execution Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}

# ECS Service
resource "aws_ecs_service" "blockchain_client" {
  name            = "blockchain-client-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.blockchain_client.arn
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.blockchain_client.id]
    assign_public_ip = true
  }
}
>>>>>>> 574d82b33bebfd5f838cb837d34cc29e933f70c0
