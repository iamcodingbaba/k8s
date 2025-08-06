module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-cluster"
  kubernetes_version = "1.33"

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni    = {
      before_compute = true
    }
  }

  endpoint_public_access                    = true
  enable_cluster_creator_admin_permissions  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1],
    module.vpc.private_subnets[0]
  ]

  eks_managed_node_groups = {
    example = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.small"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      labels = {
        node-type = "worker"
        environment = "dev"
      }

      taints = [
        {
          key    = "dedicated"
          value  = "gpu-workloads"
          effect = "NoSchedule"
        },
        {
          key    = "special"
          value  = "true"
          effect = "PreferNoSchedule"
        }
      ]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
