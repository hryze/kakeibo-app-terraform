resource "aws_ecr_repository" "user_rest_service_ecr_repository" {
  name                 = "user-rest-service"
  image_tag_mutability = "MUTABLE"
  tags                 = merge(local.default_tags, map("Name", "user-rest-service-ecr-repository"))

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "user_rest_service_lifecycle_policy" {
  repository = aws_ecr_repository.user_rest_service_ecr_repository.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 10,
            "description": "Keep last 30 release tagged images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["release"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 20,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository" "account_rest_service_ecr_repository" {
  name                 = "account-rest-service"
  image_tag_mutability = "MUTABLE"
  tags                 = merge(local.default_tags, map("Name", "account-rest-service-ecr-repository"))

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "account_rest_service_lifecycle_policy" {
  repository = aws_ecr_repository.account_rest_service_ecr_repository.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 10,
            "description": "Keep last 30 release tagged images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["release"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 20,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository" "todo_rest_service_ecr_repository" {
  name                 = "todo-rest-service"
  image_tag_mutability = "MUTABLE"
  tags                 = merge(local.default_tags, map("Name", "todo-rest-service-ecr-repository"))

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "todo_rest_service_lifecycle_policy" {
  repository = aws_ecr_repository.todo_rest_service_ecr_repository.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 10,
            "description": "Keep last 30 release tagged images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["release"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 20,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
