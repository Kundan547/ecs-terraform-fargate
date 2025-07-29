# modules/rds-aurora/main.tf
resource "aws_db_subnet_group" "aurora" {
  name       = "${var.project_name}-aurora-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-aurora-subnet-group"
    Environment = var.environment
  }
}

resource "aws_security_group" "aurora" {
  name_prefix = "${var.project_name}-aurora-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-aurora-sg"
    Environment = var.environment
  }
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  family = "aurora-postgresql15"
  name   = "${var.project_name}-aurora-cluster-pg"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = {
    Name        = "${var.project_name}-aurora-cluster-pg"
    Environment = var.environment
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier              = "${var.project_name}-aurora-cluster"
  engine                          = "aurora-postgresql"
  engine_version                  = var.engine_version
  database_name                   = var.database_name
  master_username                 = var.master_username
  master_password                 = var.master_password
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.backup_window
  preferred_maintenance_window    = var.maintenance_window
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name
  db_subnet_group_name            = aws_db_subnet_group.aurora.name
  vpc_security_group_ids          = [aws_security_group.aurora.id]
  storage_encrypted               = true
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${var.project_name}-aurora-final-snapshot"
  deletion_protection             = var.deletion_protection

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name        = "${var.project_name}-aurora-cluster"
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count              = var.instance_count
  identifier         = "${var.project_name}-aurora-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval         = var.monitoring_interval
  monitoring_role_arn         = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null

  tags = {
    Name        = "${var.project_name}-aurora-instance-${count.index}"
    Environment = var.environment
  }
}

# IAM role for enhanced monitoring
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.project_name}-rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-rds-enhanced-monitoring-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

