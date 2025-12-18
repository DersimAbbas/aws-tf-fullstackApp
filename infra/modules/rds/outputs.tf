output "db_address" {
  value = aws_db_instance.this.address
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "db_identifier" {
  value = aws_db_instance.this.id
}

output "db_subnet_group" {
  value = aws_db_subnet_group.this.name
}
