module "mongodb-atlas" {
  source  = "terraform-mongodbatlas-modules/atlas-basic/mongodbatlas"
  org_id = var.org_id
  project_name = "vclipper"
  use_existing_project = true
  cluster_name = var.mongodb_cluster_name
  provider_name = data.terraform_remote_state.global.outputs.mongodb_provider_name
  backing_provider_name = data.terraform_remote_state.global.outputs.mongodb_backing_provider_name
  region_name = "US_EAST_1"
  ip_addresses = [var.aws_nat_gateway]

  electable_specs = {
      instance_size = data.terraform_remote_state.global.outputs.mongodb_instance_size
  }

  database_users = [
      {
        username = var.mongodbatlas_username
        password = var.mongodbatlas_password
        roles = [
            {
                role = "atlasAdmin"
                database = "admin"
            }
        ]
        scopes = [
            {
                #name = data.terraform_remote_state.global.outputs.mongodb_cluster_name
                name= var.mongodb_cluster_name
                type = "CLUSTER"
            }
        ]
    },
    {
        username = var.MONGODB_USER
        password = var.MONGODB_PASSWORD
        roles = [
          for db in local.databases : {
            role     = "readWrite"
            database = db
          }
      ]
        scopes = [
            {
                #name = data.terraform_remote_state.global.outputs.mongodb_cluster_name
                name= var.mongodb_cluster_name
                type = "CLUSTER"
            }
        ]
    }
  ]
  
}

#resource "null_resource" "run_mongo_script_products" {
#  provisioner "local-exec" {
#    command = <<EOT
#      mongosh "${module.mongodb-atlas.connection_string}" --username ${var.mongodbatlas_username} --password ${var.mongodbatlas_password} --eval "load('02-products-restore.js')"
#    EOT
#  }
#  depends_on = [module.mongodb-atlas]
#}
#resource "null_resource" "run_mongo_script_orders" {
#  provisioner "local-exec" {
#    command = <<EOT
#      mongosh "${module.mongodb-atlas.connection_string}" --username ${var.mongodbatlas_username} --password ${var.mongodbatlas_password} --eval "load('03-orders-restore.js')"
#    EOT
#  }
#  depends_on = [module.mongodb-atlas, null_resource.run_mongo_script_products]
#}