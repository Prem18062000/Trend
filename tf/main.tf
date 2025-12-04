terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.24.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}


resource "aws_eks_cluster" "trend-eks" {
  name     = "trend-eks"
  role_arn = "arn:aws:iam::309539410867:role/eksctl-trend-eks-cluster-ServiceRole-F6DQvVDyF8hR"

  version  = "1.29"

  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids = [
      "subnet-00575efd60467548b",
      "subnet-023b5987d82a6e277",
      "subnet-05807c99c0c96e7a6",
      "subnet-0a3994c6a2ae813e3",
      "subnet-0c9ad69d505b7a28d",
      "subnet-0ffbbd5eb0d3f1dc5",
    ]
    security_group_ids = ["sg-0c9c6febc82506c62"]
  }

  tags = {
    Name = "eksctl-trend-eks-cluster/ControlPlane"
    "alpha.eksctl.io/cluster-name" = "trend-eks"
    "alpha.eksctl.io/cluster-oidc-enabled" = "false"
    "alpha.eksctl.io/eksctl-version" = "0.220.0"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "trend-eks"
  }
}

resource "aws_eks_node_group" "trend-workers" {
  cluster_name    = "trend-eks"
  node_group_name = "trend-workers"

  node_role_arn = "arn:aws:iam::309539410867:role/eksctl-trend-eks-nodegroup-trend-w-NodeInstanceRole-jDUb4cyN9XKe"

  # Required by schema, but we won't let Terraform manage it
  subnet_ids = [
    "subnet-00575efd60467548b",
    "subnet-023b5987d82a6e277",
    "subnet-05807c99c0c96e7a6",
    "subnet-0a3994c6a2ae813e3",
    "subnet-0c9ad69d505b7a28d",
    "subnet-0ffbbd5eb0d3f1dc5",
  ]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  lifecycle {
    ignore_changes = [
      subnet_ids,          # 🔥 THIS is what you were missing
      scaling_config,
      labels,
      tags,
      update_config,
      launch_template,
      release_version,
      ami_type,
      instance_types,
      disk_size,
      capacity_type,
    ]
  }
}


