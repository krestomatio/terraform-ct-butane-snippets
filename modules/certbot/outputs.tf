output "config" {
  description = "Butante snippet to install certbot"
  value       = data.template_file.butane_snippet_install_certbot.rendered
  sensitive   = true
}
