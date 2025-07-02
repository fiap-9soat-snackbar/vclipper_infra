output "connection_string" {
  description = "Connection string of the MongoDB Atlas cluster"
  value       = module.mongodb-atlas.connection_string
}

output "project_id" {
  description = "ID of the MongoDB Atlas cluster"
  value       = module.mongodb-atlas.project_id
}