output "VMs" {
  description = "The vm module object"
  value       = module.VMs
  sensitive   = true
}

output "availability_set" {
  description = "The availability_set object"
  value       = azurerm_availability_set.availability_set
  sensitive   = true
}
