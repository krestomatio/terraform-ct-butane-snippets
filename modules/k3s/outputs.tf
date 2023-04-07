output "config" {
  description = "Butante snippet to install k3s"
  value       = try(data.template_file.ign_snippet_install_k3s[0].rendered, "")
  sensitive   = true
}
