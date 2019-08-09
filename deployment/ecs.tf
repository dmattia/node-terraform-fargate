locals {
    container_name = "example_app_container"
}

resource "aws_ecs_task_definition" "backend_task" {
    family = "${var.ecs_family}"

    // Fargate is a type of ECS that requires awsvpc network_mode
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"

    // Valid sizes are shown here: https://aws.amazon.com/fargate/pricing/
    memory = "512"
    cpu = "256"

    // Fargate reqjuires task definitions to have an execution role ARN to support ECR images
    execution_role_arn = "${aws_iam_policy.ecr_read.arn}"

    container_definitions = <<EOT
[
    {
        "name": "${local.container_name}",
        "image": "468964582991.dkr.ecr.eu-west-1.amazonaws.com/ecr_example_app:latest",
        "memory": 512,
        "essential": true,
        "portMappings": [
            {
                "containerPort": 3000,
                "hostPort": 3000
            }
        ]
    }
]
EOT
}

resource "aws_ecs_cluster" "backend_cluster" {
    name = "backend_cluster_example_app"
}

resource "aws_ecs_service" "backend_service" {
    name = "backend_service"

    cluster = "${aws_ecs_cluster.backend_cluster.id}"
    task_definition = "${aws_ecs_task_definition.backend_task.arn}"

    launch_type = "FARGATE"
    desired_count = 1

    network_configuration {
        subnets = ["${aws_subnet.public.id}"]
        security_groups = ["${aws_security_group.security_group_example_app.id}"]
        assign_public_ip = true
    }
}

resource "aws_iam_policy" "ecr_read" {
    name = "ecr_read_policy_example_app"
    path = "/ecr/"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "sts:AssumeRole",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  ]
}
EOF
}

/*
resource "aws_iam_role" "ecs_role" {
    name = "ecs_role"

    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
*/