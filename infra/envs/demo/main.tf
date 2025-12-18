locals {
  name = "${var.project}-demo"
  tags = {
    Project = var.project
    Env     = "demo"
  }
}

module "network" {
  source     = "../../modules/network"
  name       = local.name
  cidr_block = "10.10.0.0/16"
  az_count   = 2
  tags       = local.tags
}

module "security" {
  source   = "../../modules/security"
  name     = local.name
  vpc_id   = module.network.vpc_id
  app_port = var.app_port
  tags     = local.tags
}

module "rds" {
  source             = "../../modules/rds"
  name               = local.name
  private_subnet_ids = module.network.private_subnet_ids
  rds_sg_id          = module.security.rds_sg_id

  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password

  tags = local.tags
}

module "ecr" {
  source = "../../modules/ecr"
  name   = local.name
  tags   = local.tags
}

module "alb" {
  source               = "../../modules/alb"
  name                 = local.name
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  alb_sg_id            = module.security.alb_sg_id
  app_port             = var.app_port
  health_path          = "/swagger/index.html"
  enable_test_listener = true

  tags = local.tags
}

module "ecs" {
  source             = "../../modules/ecs"
  name               = local.name
  subnets_public_ids = module.network.public_subnet_ids
  ecs_sg_id          = module.security.ecs_sg_id
  app_port           = var.app_port
  desired_count     = 1
  ecr_image = "${module.ecr.repository_url}:latest"

  db_host     = module.rds.db_address
  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
  db_port     = module.rds.db_port

  blue_target_group_arn = module.alb.tg_blue_arn

  tags = local.tags
}

module "codedeploy" {
  source = "../../modules/codedeploy"

  name         = local.name
  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name

  prod_listener_arn = module.alb.prod_listener_arn
  test_listener_arn = module.alb.test_listener_arn

  tg_blue_name  = module.alb.tg_blue_name
  tg_green_name = module.alb.tg_green_name

  tags = local.tags
}

module "cicd_backend" {
  source = "../../modules/cicd_backend"

  name = local.name
  tags = local.tags
  

  github_repo_full_name = "${var.backend_repo_owner}/${var.backend_repo_name}"
  github_branch         = var.backend_repo_branch
  
  ecr_repo_url = module.ecr.repository_url
  codestar_connection_arn = var.codestarconnection_arn
  codedeploy_app_name              = module.codedeploy.codedeploy_app_name
  codedeploy_deployment_group_name = module.codedeploy.deployment_group_name

  task_family        = module.ecs.task_family
  task_exec_role_arn = module.ecs.task_exec_role_arn

  container_name = "backend"
  container_port = var.app_port

  db_host     = module.rds.db_address
  db_port     = module.rds.db_port
  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
}

module "amplify" {
  source = "../../modules/amplify"

  name         = local.name
  repo_url     = var.frontend_repo_url
  github_token = var.github_token
  branch       = "main"

  app_environment_variables = {
    REACT_APP_API_URL = module.api_edge.api_base_url
  }

  tags = local.tags
} 

module "api_edge" {
  source       = "../../modules/cloudfront"
  name         = var.name
  alb_dns_name  = module.alb.alb_dns_name

}
