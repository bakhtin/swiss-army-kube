module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "v12.0.0"
  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name
  subnets         = var.subnets
  vpc_id          = var.vpc_id

  map_users = var.admin_arns

  tags = {
    Environment = var.environment
    Project     = var.project
  }

  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53AutoNamingFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
  ]

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    additional_userdata = "sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm && sudo systemctl enable amazon-ssm-agent && sudo systemctl start amazon-ssm-agent"
  }

  # Note:
  #   If you add here worker groups with GPUs or some other custom resources make sure 
  #   to start the node in ASG manually once or cluster autoscaler doesn't find the resources.
  #
  #   After that autoscaler is able to see the resources on that ASG.
  #
  node_groups = {
    common = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_type = "m5.large"
      k8s_labels = {
        Environment = var.environment
        Project     = var.project
        role        = "compute-common"
      }
      additional_tags = {
        role = "compute-common"
      }
    }
    compute-cpu = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_type = "c5n.large"
      k8s_labels = {
        Environment = var.environment
        Project     = var.project
        role        = "compute-cpu"
      }
      additional_tags = {
        role = "compute-cpu"
      }
    }
    compute-gpu = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      ami_type      = "AL2_x86_64_GPU"
      instance_type = "g2.2xlarge"
      k8s_labels = {
        Environment                   = var.environment
        Project                       = var.project
        role                          = "compute-gpu"
        k8s.amazonaws.com/accelerator = "nvidia-tesla-k80"
        
      }
      additional_tags = {
        role = "compute-gpu"
      }
    }        
  }
}
