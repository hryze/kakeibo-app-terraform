resource "aws_secretsmanager_secret" "rds_secret" {
  name                    = "rds-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds_secret" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode(var.rds_secret)

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret" "user_db_dsn" {
  name                    = "user-db-dsn-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "user_db_dsn" {
  secret_id     = aws_secretsmanager_secret.user_db_dsn.id
  secret_string = jsonencode(var.user_db_dsn)

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret" "account_db_dsn" {
  name                    = "account-db-dsn-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "account_db_dsn" {
  secret_id     = aws_secretsmanager_secret.account_db_dsn.id
  secret_string = jsonencode(var.account_db_dsn)

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret" "todo_db_dsn" {
  name                    = "todo-db-dsn-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "todo_db_dsn" {
  secret_id     = aws_secretsmanager_secret.todo_db_dsn.id
  secret_string = jsonencode(var.todo_db_dsn)

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret" "argocd" {
  name                    = "argocd-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "argocd" {
  secret_id     = aws_secretsmanager_secret.argocd.id
  secret_string = jsonencode(var.argocd_secret)

  lifecycle {
    ignore_changes = [secret_string]
  }
}
