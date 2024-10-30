resource "aws_db_instance" "three_tier_db" {
  instance_class = var.db_instance_class
  allocated_storage = var.db_storage
  engine = "mysql"
  engine_version = var.db_engine_version
    db_name = var.db_name
    username = var.db_user
    password = var.db_passwrod
    db_subnet_group_name = var.db_subnet_group_name
    identifier = var.db_identifier
    skip_final_snapshot = var.db_skip_snapshot
    vpc_security_group_ids = [var.db_rds_sg]
    tags = {
      Name= "three_tier_db"
    }
}   