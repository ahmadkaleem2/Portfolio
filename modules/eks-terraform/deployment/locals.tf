data "aws_secretsmanager_secret" "example" {
  name = "ahmad-testing"
}

data "aws_secretsmanager_secret_version" "example" {
  secret_id = data.aws_secretsmanager_secret.example.id
}


locals {


  sensitive_env_variables = {
    feature-store-secrets = {
      type = "Opaque"
      data = {  
      "username" = "asd"
      }
    }


    feature-store-secrets1 = {
      type = "Opaque"
      data = {  
      "username" = "user"
      "password" = jsondecode(data.aws_secretsmanager_secret_version.example.secret_string)["password"]
      #jsonencode(data.aws_secretsmanager_secret_version.example.secret_string.)
      }
    }
  }


#   secret_keys = flatten([
#     for secret_object_key, secret_object_value in local.sensitive_env_variables : [
#       for secret_name, secret_value in secret_object_value :
#       {
#         secret_key            = secret_object_key
#         name_in_secret_object = secret_name
#       }
#     ]
#   ])


}

output "secret_key" {
  value = null

}