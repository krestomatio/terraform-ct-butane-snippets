######################### values #########################
locals {
  config = {

    envvars = [
      "INSTALL_K3S_BIN_DIR=/usr/local/bin"
    ]
    parameters = [
      "--secrets-encryption"
    ]
  }
  mode        = "bootstrap"
  token       = "secret_token"
  agent_token = "secret_agent_token"
  channel     = "stable"
}

######################## module #########################
module "butane_k3s_snippets" {
  source = "../../modules/k3s"

  config      = local.config
  mode        = local.mode
  token       = local.token
  agent_token = local.agent_token
  channel     = local.channel
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
    module.butane_k3s_snippets.config
  ]
}

######################### outputs #########################
output "ignition" {
  value       = data.ct_config.node.rendered
  description = "Ignition config"
}
