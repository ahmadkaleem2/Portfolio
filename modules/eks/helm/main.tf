resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace = "aws-load-balancer-controller"
  create_namespace = false
  cleanup_on_fail = true
  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name = "clusterName"
    value = var.eks_cluster_name
  }
  set {
    name = "region"
    value = var.AWS_REGION
  }
  set {
    name = "vpcId"
    value = var.vpc_id
  }
  depends_on = [ kubernetes_service_account.aws_load_balancer_controller ]
}

# resource "helm_release" "cluster_autoscaler" {
#   name       = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"

#   set {
#     name  = "autoDiscovery.clusterName"
#     value = var.eks_cluster_name
#   }

#   set {
#     name  = "awsRegion"
#     value = var.AWS_REGION
#   }

#   set {
#     name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.cluster_autoscaler_iam_role.arn
#   }

#   set {
#     name  = "rbac.serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "rbac.serviceAccount.name"
#     value = "cluster-autoscaler"
#   }
# }

# resource "helm_release" "karpenter" {
#   name       = "karpenter"
#   namespace  = "karpenter"
#   create_namespace = false

#   chart      = "oci://public.ecr.aws/karpenter/karpenter"
#   # version    = var.karpenter_version
#   timeout = 600
#   set {
#     name  = "settings.clusterName"
#     value = var.eks_cluster_name
#   }

#   set {
#     name  = "settings.interruptionQueue"
#     # value = var.eks_cluster_name
#     value = ""

#   }

#   set {
#     name  = "controller.resources.requests.cpu"
#     value = "1"
#   }

#   set {
#     name  = "controller.resources.requests.memory"
#     value = "1Gi"
#   }

#   set {
#     name  = "controller.resources.limits.cpu"
#     value = "1"
#   }

#   set {
#     name  = "controller.resources.limits.memory"
#     value = "1Gi"
#   }
#   set {
#     name  = "serviceAccount.create"
#     value = "false"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "karpenter-sa"
#   }
#   set {
#     name = "controller.clusterEndpoint"
#     value = var.eks_cluster_endpoint
#   }

#   wait = true

#   depends_on = [ kubernetes_namespace.karpenter_ns, kubernetes_service_account.karpenter ]
# }

# resource "kub${terraform.workspace}-${var.identifier}ernetes_namespace" "karpenter_ns" {
#   metadata {
#     name = "karpenter"
#   }
  
# }

# resource "kubernetes_service_account" "karpenter" {
#   metadata {
#     name      = "karpenter-sa"
#     namespace = "karpenter"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = "arn:aws:iam::680688655542:role/cluster_karpenter"
#     }
#   }
#   depends_on = [ kubernetes_namespace.karpenter_ns ]
# }

# resource "helm_release" "external_dns" {
#   name       = "external-dns"
#   repository = "https://kubernetes-sigs.github.io/external-dns/"
#   chart      = "external-dns"
#   namespace = "external-dns"
#   # version = "1.14.5"
#   create_namespace = false
#   cleanup_on_fail = true

#   set {
#     name = "serviceAccount.create"
#     value = "false"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "external-dns"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.external_dns_iam_role.arn
#   }
#   set {
#     name  = "source"
#     value = "ingress"
#   }

#   set {
#     name  = "domain-filter"
#     # value = "ahmadkaleem2.link"
#     value = "ahmadkaleem2.link"

#   }

#   set {
#     name = "provider"
#     value = "aws"
#   }
#   set {
#     name = "policy"
#     value = "upsert-only"
#   }
#   set {
#     name = "aws-zone-type"
#     value = "public"
#   }
#   set {
#     name = "registry"
#     value = "txt"
#   }
#   set {
#     name = "txt-owner-id"
#     value = "asdasd"
#   }

#   depends_on = [ kubernetes_namespace.external-dns ]
# }

# resource "helm_release" "cert-manager" {
#   name       = "cert-manager"
#   repository = "https://charts.jetstack.io/"
#   chart      = "cert-manager"
#   namespace = "cert-manager"
#   version = "1.15.3"
#   create_namespace = false
#   cleanup_on_fail = true

#   set {
#     name = "crds.enabled"
#     value = true
#   }

#   set {
#     name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.cert_manager_iam_role.arn
#   }


#   depends_on = [ kubernetes_namespace.cert-manager ]

# }




# resource "kubernetes_manifest" "certmanager_cluster_issuer" {
#   manifest = yamldecode(data.template_file.init.rendered)
#   depends_on = [ helm_release.cert-manager ]
# }

# data "template_file" "init" {
#   template = "${file("./kubernetes/certificate_manager.tpl")}"
#   vars = {
#     role = "arn:aws:iam::680688655542:role/cert-manager"
#     hostedZoneID = "Z06136533TBVAXK89FVB5"

#   }
# }




# resource "helm_release" "metrics_server" {
#   name       = "metrics-server"
#   namespace  = "kube-system"
#   chart      = "metrics-server"
#   repository = "https://kubernetes-sigs.github.io/metrics-server/"

# }