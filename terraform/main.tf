# NOTE: the line 'hcl' was at top...is this just HashiCorp Language???

# Configure Terraform, loop in AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

# Configure AWS Provider
provider "aws" {
  profile = "terraform_admin"
  region  = var.aws_region      # I manually set us-east-1 also...
}

# Create an ECR repository for your Docker images
resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECR lifecycle policy to manage image retention
# This implements simple static number of images
resource "aws_ecr_lifecycle_policy" "app_repo_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 4 images"     #Keep basic for now (esp if money could get involved)
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 4
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Create an ECS cluster (logical grouping of tasks)
resource "aws_ecs_cluster" "app_cluster" {
    name = "${var.project_name}-${var.environment}-cluster"
}

# Create an ECS task definition (tells ECS how to run container)
resource "aws_ecs_task_definition" "app_task" {
    family = "${var.project_name}-${var.environment}-task"
    requires_compatibilities = ["FARGATE"]      #Fargate is for serverless containers (I guess that's me)
    network_mode = "awsvpc"
    cpu = 256           # 0.25 vCPU (unclear on details, but this is 256 'units' of CPU resources, which equates to a common threshold in AWS of v0.25)
    memory = 512        # 512MB of RAM
    execution_role_arn = aws_iam_role.ecs_execution_role.arn

    container_definitions = jsonencode([
    {
        name  = "${var.project_name}-container"
        image = "${aws_ecr_repository.app_repo.repository_url}:latest"
    
        environment = [
            {
                name: "SECRET_KEY_BASE",
                value: "684972d49701a23ea0df8d987878ca48"       #At least try to get this to 'cat' the file or something...
            }
        ]
        #Later: add AWS secrets (via AWS secrets manager).  Syntax is:
        # secrets = [
        #   {
        #     name: "SUPER SECRET DAWG",
        #     valueFrom: "arn:aws:secretsmanager:REGION:ACCOUNT_ID:secret:SECRET_NAME"
        #   }
        # ]

        portMappings = [
            {
            containerPort = 3000  # Port your app listens on
            hostPort      = 3000    #Not sure how this differs from containerPort...
            protocol      = "tcp"
            }
        ]
    
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group"         = aws_cloudwatch_log_group.app_logs.name
                "awslogs-region"        = var.aws_region
                "awslogs-stream-prefix" = "ecs"
            }
        }
      
        essential = true
    }
  ])
}

# Create an IAM role for ECS to pull images from ECR
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"              #This sure doesn't seem recent...?
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

# Attach the AWS managed policy for ECS task execution
#I assume these are relatively default settings?  There's a lot...
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create a CloudWatch log group for your application logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 14  # Keep logs for 14 days, since I might not look that often
}

# Get the default VPC (every AWS account has one)
# VPC = Virtual Private Cloud: Think of it as your own private section of AWS
# where all your resources live. It's like having your own private network in the cloud.
data "aws_vpc" "default" {
  default = true                #Maybe I'll try something fancier down the road...
}

# Get the default subnets in the VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]      #I assume 'id' is set by AWS upon starting up VPC...
    #This is defined as 'vpc_id' below...
  }
}

# Create a security group that allows inbound traffic on port 3000
#NOTE: sg = security group
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for ${var.project_name} application"
  vpc_id      = data.aws_vpc.default.id

  # Allow inbound traffic on port 3000 from anywhere
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Note: In production, restrict this, it allows any inbound traffic to your container!
    #Makes sense, but how should it be restricted?  I don't have specific IP ranges at this point, except perhaps once I get FE up as well, could associate its VPC IP...
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]     #I assume this specifies the outbound destination address (range)?
  }
}

# Create an ECS service to run and maintain your task
resource "aws_ecs_service" "app_service" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn    #NOTE: arn = Amazon Resource Name (unique ID for each one)
  desired_count   = 1  # Run 1 instance of your container
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids     #Is 'ids' seriously different from 'id', or is this a typo?
    security_groups  = [aws_security_group.app_sg.id]
    assign_public_ip = true  # Needed for Fargate tasks to pull images
  }
}
