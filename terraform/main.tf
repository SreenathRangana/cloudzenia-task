# module "ecs" {
#   source = "./modules/ecs"
# }

# module "rds" {
#   source = "./modules/rds"
# }

# module "alb" {
#   source = "./modules/alb"
# }

# module "secrets_manager" {
#   source = "./modules/secrets_manager"
# }


provider "aws" {
  region = "us-east-1"
}

module "ecs" {
  source             = "./modules/ecs"
  cluster_name       = "my-ecs-cluster"
  wordpress_image    = "wordpress:latest"
  db_host            = module.rds.rds_instance_endpoint
  db_user            = "wordpress_user"
  db_password        = "securepassword123"
  subnets            = ["subnet-0123456789abcdef0", "subnet-abcdef0123456789"]
  security_groups    = ["sg-0123456789abcdef0"]
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.execution_role_arn
  target_group_arn   = module.alb.alb_target_group_arn
}

module "rds" {
  source            = "./modules/rds"
  allocated_storage = 20
  instance_class    = "db.t3.micro"
  db_name           = "wordpress_db"
  username          = "wordpress_user"
  password          = "securepassword123"
  subnet_ids        = ["subnet-0123456789abcdef0", "subnet-abcdef0123456789"]
  security_groups   = ["sg-0123456789abcdef0"]
}

module "secrets_manager" {
  source      = "./modules/secrets_manager"
  secret_name = "wordpress-db-credentials"
  db_username = "wordpress_user"
  db_password = "securepassword123"
  environment = "production"
}

module "iam" {
  source      = "./modules/iam"
  environment = "production"
}

module "alb" {
  source            = "./modules/alb"
  lb_name           = "my-application-lb"
  target_group_name = "wordpress-target-group"
  security_groups   = ["sg-0123456789abcdef0"]
  subnets           = ["subnet-0123456789abcdef0", "subnet-abcdef0123456789"]
  vpc_id            = "vpc-0123456789abcdef0"
  certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/abcdef01-2345-6789-abcd-ef0123456789"
}
