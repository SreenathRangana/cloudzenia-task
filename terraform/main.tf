module "ecs" {
  source = "./modules/ecs"
}

module "rds" {
  source = "./modules/rds"
}

module "alb" {
  source = "./modules/alb"
}

module "secrets_manager" {
  source = "./modules/secrets_manager"
}
