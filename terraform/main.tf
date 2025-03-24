provider "aws" {
  region = "eu-west-1"
}

resource "aws_ecs_cluster" "main" {
  name = "blockchain-client-cluster"
}

resource "aws_ecs_task_definition" "blockchain_client" {
  family                   = "blockchain-client"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([{
    name  = "blockchain-client"
    image = "blockchain-client:latest"
    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
    }]
  }])
}