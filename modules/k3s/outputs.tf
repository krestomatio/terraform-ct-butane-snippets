output "config" {
  description = "Butante snippet to install k3s"
  value       = data.template_file.butane_snippet_install_k3s.rendered
  sensitive   = true
}
