output "default_domain" {
  value       = aws_amplify_app.this.default_domain
  description = "Amplify default domain (without https://)."
}
output "app_id" {
  value = aws_amplify_app.this.id
}