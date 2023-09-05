output "public_SG_id" {
  value = aws_security_group.public_SG.id
}

output "application_SG_id" {
  value = aws_security_group.application_SG.id
}

output "database_SG_id" {
  value = aws_security_group.database_SG.id
}

output "middleware_SG_id" {
  value = aws_security_group.middleware_SG.id
}