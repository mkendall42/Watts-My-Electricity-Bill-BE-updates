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
#NOTE: this has updates (1/6/26 for database coverage and secrets...may need adjusting)
resource "aws_ecs_task_definition" "app_task" {
    family = "${var.project_name}-${var.environment}-task"
    requires_compatibilities = ["FARGATE"]      #Fargate is for serverless containers (I guess that's me)
    network_mode = "awsvpc"
    cpu = 256           # 0.25 vCPU (unclear on details, but this is 256 'units' of CPU resources, which equates to a common threshold in AWS of v0.25)
    memory = 512        # 512MB of RAM
    execution_role_arn = aws_iam_role.ecs_execution_role.arn
    #Later: will need a task role arn as well (to allow this container / service to access resources)
    #NOTE: line below may need slightly different name - check
    task_role_arn = aws_iam_role.ecs_task_db.arn

    container_definitions = jsonencode([
    {
        name  = "${var.project_name}-container"
        image = "${aws_ecr_repository.app_repo.repository_url}:latest"
    
        environment = [
            # {
            #   name = "RAILS_ENV"
            #   value = "production"
            # },
            {
              name = "DATABASE_HOST"
              value = aws_db_instance.postgres.address    #Shouldn't this be aws_db_instance.postgres.address?
              #Alternate: value = split(":", aws_db_instance.postgres.endpoint)[0]
            },
            {
              name = "DATABASE_PORT"
              value = "5432"
            },
            {
              name = "DATABASE_NAME"
              value = aws_db_instance.postgres.db_name    #Same issue here!
              #Alternate: value = aws_db_instance.postgres.db_name
            },
            {
              name = "AWS_REGION"
              value = data.aws_region.current.name    #Or could use defined var...
            }
        ]

        secrets = [
          {
            #I assume this will simply overwrite my default secret_key_base credential in production.yml.enc...
            name = "SECRET_KEY_BASE"
            valueFrom = "${aws_secretsmanager_secret.my_app.arn}:secret_key_base::"
          },
          {
              name = "RAILS_MASTER_KEY",
              valueFrom = "${aws_secretsmanager_secret.rails_master_key.arn}"
          },
          {
            name = "DATABASE_URL"
            valueFrom = "${aws_secretsmanager_secret.my_app.arn}:database_url::"
          }
          # {
          #   name = "REDIS_URL"
          #   valueFrom = "${aws_secretsmanager_secret.my_app.arn}:redis_url::"
          # }
          # {
          #   name = "STRIPE_API_KEY"
          #   valueFrom = "${aws_secretsmanager_secret.my_app.arn}:stripe_api_key::"
          # }
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

# Create an IAM role for ECS to pull images from ECR and access secrets
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
#This just takes the default AWS ECS policy (good enough for our purposes)
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#ECS task execution role for RDS IAM authorization
resource "aws_iam_role" "ecs_task_db" {
  #NOTE: this is functionally identical to the earlier role "ecs_execution_role"...merge?
    name = "${var.project_name}-${var.environment}-ecs-execution-db-role"

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

#Policy for RDS IAM DB authentication
resource "aws_iam_role_policy" "rds_connect" {
  name = "rds-iam-auth"
  role = aws_iam_role.ecs_task_db.id

  policy = jsonencode({           #Why DEcode?  Terraform docs usually show ENcode
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["rds-db:connect"]
        #NOTE: the line below needs more work (some syntax missing)!
        # Resource = "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_}"
        Resource = "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:${aws_db_instance.postgres.id}"
        #NOTE: In AWS, the resource seems to be in this syntax:
        #arn:aws:rds:us-east-1:559413641916:db:database-1 (note that 'rds' != 'rds-db', and after the ID, it is just ':db:<db_name>')
        #My best guess is "arn:aws:rds:<region>:<IAM acct ID>:db:<db_id>"
        #If I'm desperate, can use "*" to get going first
      }
    ]
  })
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
    subnets          = data.aws_subnets.default.ids     #Multiple subnets (and thus ids) are needed for ECS to run (different availability zones)
    security_groups  = [aws_security_group.app_sg.id]
    assign_public_ip = true  # Needed for Fargate tasks to pull images
  }
}

#Random password generators
resource "random_password" "db" {
  length = 32
  special = true
}

resource "random_password" "secret_key" {
  length = 128
  special = false
}

#Amazon Secrets Manager resources
#NOTE: may need to change "rails" to my app name, or another one
#NOTE: for now setting to "my_app" - ask Joe if better naming scheme
resource "aws_secretsmanager_secret" "my_app" {
  name = "production/my_app/app-secrets"
}

resource "aws_secretsmanager_secret_version" "my_app" {
  secret_id = aws_secretsmanager_secret.my_app.id
  secret_string = jsonencode({
    #NOTE: the below line got truncated...I think I figured out the syntax for the rest I hope?
    # database_url = "postgresql://rails_user:${random_password.db.result}@${aws_db_instance.postgres.address}:5432/my_app_db?sslmode=require&connect_timeout=10"
    #Or more flexibly coded:
    database_url = "postgresql://rails_user:${random_password.db.result}@${aws_db_instance.postgres.address}:5432/${aws_db_instance.postgres.db_name}?sslmode=require&connect_timeout=10"

    # rails_master_key = ""

    secret_key_base = random_password.secret_key.result
    #REDIS below - will this work?  "aws_elasticache_cluster" hasn't been setup yet...
    #Also, do I really need this anyway?  I guess Rails could take advantage of it - save as idea for later along w/ caching?
    #Don't need it for now - perhaps later
    # redis_url = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:6379/0"
    # stripe_api_key = var.stripe_api_key   #What the flying FUCK is this???  Came out of nowhere...is this a Stripe.com env var???
  })

  # sensitive = true      #Can use this to prevent printing of secrets in logs/console
}

resource "aws_secretsmanager_secret" "rails_master_key" {
  #Don't need versioning here, just keep one version of the secret
  name = "production/my_app/rails_master_key"
}

#Now that the string has been set, we don't need this anymore (was just to create the initial placeholder)
# resource "aws_secretsmanager_secret_version" "rails_master_key" {
#   secret_id = aws_secretsmanager_secret.rails_master_key.id

#   secret_string = "asdf"
# }

#Execution role with secrets access (for ECS here)
resource "aws_iam_role_policy" "execution_secrets" {
  role = aws_iam_role.ecs_execution_role.id             #Was just "ecs_execution" - undefined

  policy = jsonencode({                       #Why DEcode?  Terraform docs usually show ENcode
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["secretsmanager:GetSecretValue"]
      Resource = [aws_secretsmanager_secret.my_app.arn]
      #I think below line is correct? (Maybe needs the []'s?)
      Resource = "${aws_secretsmanager_secret.my_app.arn}"
    }]
  })
}

# ------Database (RDS) section-------

#RDS Postgres DB instance with IAM authentication
resource "aws_db_instance" "postgres" {
  identifier = "rails-postgres"
  #I THINK identifier refers to the DB instance, which can house one
  #(or maybe more?) individual DBs, given by db_name (defined below)
  engine = "postgres"
  # engine_version = "15.4"       #Could maybe use 17.6 (current in AWS)
  engine_version = "17.6"       #Could maybe use 17.6 (current in AWS)
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  max_allocated_storage = 20    #Gonna keep it basic for safety/cost for now
  storage_type = "gp2"          #This is default, but good to have for safety (save $)
  storage_encrypted = true      #Should be ok for free tier; change if needed

  db_name = "my_app_db"
  username = "postgres"
  password = random_password.db.result    #NOTE: doesn't match AI gen stuff - why?

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name = aws_db_subnet_group.main.name

  backup_retention_period = 0   #This should correspond to no backups (to save money / free tier)
  skip_final_snapshot = true    #For now, don't make snapshot upon DB deletion (I ain't doing anything fancy with the DB, let's be honest)
  # skip_final_snapshot = false
  # final_snapshot_identifier = "rails-postgres-final-snapshot"   #Rename later?

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Name = "rails-postgres"
  }
}

#ECS task execution role in order to pull images and secrets
#NOTE: I have much of this already above - integrated it up there (keeping this as placeholder for now)
# resource "aws_iam_role" "ecs_task_execution" {
#   name = "rails-ecs-task-execution-role"

#   assume_role_policy = jsonencode({

#   })
# }

#Security group for RDS (just make this general - could of course give more granularity based on specific DBs)
resource "aws_security_group" "rds" {
  name = "rds-postgres-sg"
  description = "Security group for all RDS Postgres"
  vpc_id = data.aws_vpc.default.id          #Should this just be aws_vpc.default.id?

  ingress {
    description = "From ECS to Postgres"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    # security_groups = [aws_security_group.ecs_task_db.id]   #This isn't defined
    security_groups = [aws_security_group.app_sg.id]   #Should it be this?  Don't think it would be aws_security_group.rds
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"               #All permitted
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Is this line needed?
  tags = {
    Name = "rds-postgres-sg"
  }
}

#Database subnet group
#NOTE: why is this necessary for us right now?
#We can experiment with private subnets later
resource "aws_db_subnet_group" "main" {
  name = "my-app-db-subnet-group"
  # subnet_ids = aws_subnet.private[*].id     #This isn't defined.  Maybe aws_subnets.private[*].id?
  # subnet_ids = [data.aws_subnet.main.id]
  subnet_ids = [data.aws_subnets.default.ids[0], data.aws_subnets.default.ids[1]]

  tags = {
    Name = "my-app-db-subnet-group"
  }
}

#Data sources
#NOTE: arguments are optional / not needed for my purposes here.  Again, ask Joe
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
# data "aws_subnet" "main" {
#   vpc_id = data.aws_vpc.default.id
#   availability_zone = "us-east-1a"
#   # availability_zone_id = "use1-az1"

#   tags = {
#     Tier = "Not private yet!"
#   }
# }
