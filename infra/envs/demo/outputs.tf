output "alb_url" {
  value = "http://${module.alb.alb_dns_name}"
}

output "amplify_domain" {
  value = "https://${module.amplify.default_domain}"
}

output "pipeline_name" {
  value = module.cicd_backend.pipeline_name
}

output "codestar_connection_arn" {
  value = module.cicd_backend.codestar_connection_arn
}
output "amplify_id" {
  value = module.amplify.app_id
}
output "api_base_url" {
  value = module.api_edge.api_base_url
}