module "albc" {
    source = "../modules/albc"
    albc_values = local.albc_values
    cluster_oidc_issuer_url = local.cluster_oidc_issuer_url
}

