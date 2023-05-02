######################### values #########################
locals {
  http_01_port       = 8888
  domain             = "example.com"
  additional_domains = ["www.example.com"]
  post_hook = {
    path    = "/usr/local/bin/example-com-post-hook.sh"
    content = <<-TEMPLATE
        #!/bin/bash -e
        echo "Running example-com-post-hook.sh..."
      TEMPLATE
  }
  agree_tos    = true
  staging      = true
  email        = "admin@example.com"
  before_units = []
  after_units  = []
}

######################## module #########################
module "butane_snippet_install_certbot" {
  source = "../../modules/certbot"

  http_01_port       = local.http_01_port
  domain             = local.domain
  additional_domains = local.additional_domains
  post_hook          = local.post_hook
  agree_tos          = local.agree_tos
  staging            = local.staging
  email              = local.email
  before_units       = local.before_units
  after_units        = local.after_units
}

data "ct_config" "node" {
  strict       = true
  pretty_print = true

  content = <<-TEMPLATE
    ---
    variant: fcos
    version: 1.4.0
  TEMPLATE

  snippets = [
    module.butane_snippet_install_certbot.config
  ]
}

######################### outputs #########################
output "ignition" {
  value       = data.ct_config.node.rendered
  description = "Ignition config"
}
