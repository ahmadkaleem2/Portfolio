
provider "aws" {
  region = "us-east-1"
}


data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    CLUSTER_NAME         = "default-Ahmad-EKS"
    BOOTSTRAP_ARGS       = ""
    ADDITIONAL_USER_DATA = base64decode(filebase64("${path.module}/additional.tpl"))
  }
}

resource "aws_launch_template" "eks_ng_template" {
  # count       = var.use_spot_instances ? 0 : 1
  # name_prefix = var.ng_name == "" ? "${var.cluster_name}-ng-template-" : null
  name          = "AHMAD-SB-template"
  key_name = "AHMADKALEEM_PACKER"
  vpc_security_group_ids = ["sg-07824cdcced57a5c7", "sg-02b29445fadda8b9d", "sg-027e359cf772067f4"]
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      # volume_size           = var.volume_size
      delete_on_termination = true
      # encrypted             = var.encrypt_volume
      # kms_key_id            = var.encrypt_volume == true ? data.aws_kms_key.eks_ng_key.arn : null
      # volume_type           = var.volume_type
      # iops                  = var.volume_type == "io1" ? var.iops : null
    }
  }

  iam_instance_profile {
    name = "eks-4ecc1ba8-dbea-bae5-b699-0b0b58d18db6"
  }
  

  # image_id               = var.ami_id
  # instance_type          = var.instance_type
  # key_name               = var.ssh_key_name == "" ? null : var.ssh_key_name
  # vpc_security_group_ids = var.ng_sg_ids

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2

  }
  update_default_version = true
  user_data = base64encode(data.template_file.user_data.rendered)
  image_id = "ami-0f30ac3b3957f0a39"
  lifecycle {
    create_before_destroy = true
  }
  instance_type = "t3.large"

  # tags = var.tags
}



resource "aws_autoscaling_group" "eks_ng_asg" {
  # name_prefix      = "custom-ami-ng-asg-"
  name             = "custom-ami123"
  max_size         = 1
  min_size         = 1
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.eks_ng_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = ["subnet-05bf774d1a4306fba"]

}





# module "eks_managed_node_group" {
#   source = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"
#   depends_on = [ aws_launch_template.eks_ng_template ]
#   name            = "custom-ami"
#   cluster_name    = "default-Ahmad-EKS"
#   cluster_version = "1.32"
#   cluster_service_cidr = "172.20.0.0/16"
#   launch_template_id = aws_launch_template.eks_ng_template.id
#   launch_template_version = "$Latest"
#   subnet_ids = ["subnet-04f3d0212abb4e55b", "subnet-07afbe9f149884035", "subnet-0f8847aca1325a5f3"]
#   key_name = "AhmadKaleem_packer"
#   launch_template_name = "AHMAD-SB-template"
#   # use_custom_launch_template = true
#   create_launch_template = false
#   // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
#   // Without it, the security groups of the nodes are empty and thus won't join the cluster.
#   # cluster_primary_security_group_id = "sg-071faa84e87222a37"
#   # sg-071faa84e87222a37
#   vpc_security_group_ids = ["sg-071faa84e87222a37"]
# #   vpc_security_group_ids            = ["module.eks.node_security_group_id"]
#   # ami_id                            = "ami-06970396654832eb6"

#   // Note: `disk_size`, and `remote_access` can only be set when using the EKS managed node group default launch template
#   // This module defaults to providing a custom launch template to allow for custom security groups, tag propagation, etc.
#   // use_custom_launch_template = false
#   // disk_size = 50
#   //
#   //  # Remote access cannot be specified with a launch template
#   //  remote_access = {
#   //    ec2_ssh_key               = module.key_pair.key_pair_name
#   //    source_security_group_ids = [aws_security_group.remote_access.id]
#   //  }
#   # instance_type          = "t3.small"

#   min_size     = 1
#   max_size     = 2
#   desired_size = 1

#   # instance_types = ["t3.large"]
#   # capacity_type  = "SPOT"

#   # labels = {
#   #   Environment = "test"
#   #   GithubRepo  = "terraform-aws-eks"
#   #   GithubOrg   = "terraform-aws-modules"
#   # }

#   # taints = {
#   #   dedicated = {
#   #     key    = "dedicated"
#   #     value  = "gpuGroup"
#   #     effect = "NO_SCHEDULE"
#   #   }
#   # }

#   tags = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }