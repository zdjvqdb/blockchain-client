provider "aws" {
  region = "eu-west-1"
}

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
