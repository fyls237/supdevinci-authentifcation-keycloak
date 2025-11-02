# AWS Secrets Manager Secret
resource "aws_secretsmanager_secret" "secret" {
  name_prefix             = var.secret_name_prefix
  description             = var.description
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-secret"
    }
  )
}

# Secret Version (optional - if secret_string is provided)
resource "aws_secretsmanager_secret_version" "secret" {
  count = var.secret_string != "" || var.secret_json != "" ? 1 : 0

  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.secret_json != "" ? var.secret_json : var.secret_string

  lifecycle {
    create_before_destroy = true

    ignore_changes = [ 
      version_stages,
    ]
  }
}

# Secret Rotation (optional)
resource "aws_secretsmanager_secret_rotation" "secret" {
  count = var.enable_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.secret.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}

# Secret Policy (optional)
resource "aws_secretsmanager_secret_policy" "secret" {
  count = var.secret_policy != "" ? 1 : 0

  secret_arn = aws_secretsmanager_secret.secret.arn
  policy     = var.secret_policy
}
