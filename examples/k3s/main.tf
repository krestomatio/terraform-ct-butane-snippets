######################### values #########################
locals {
  config = {

    envvars = [
      # In fedora coreos, /usr/local is a symlink to /var/usrlocal
      "INSTALL_K3S_BIN_DIR=/var/usrlocal/bin"
    ]
    parameters = [
      "--secrets-encryption"
    ]
  }
  mode        = "bootstrap"
  token       = "secret_token"
  agent_token = "secret_agent_token"
  channel     = "stable"
  fleetlock = {
    version = "v0.4.0"
  }
  kubelet_config = {
    content = <<-TEMPLATE
      shutdownGracePeriod: 30s
      shutdownGracePeriodCriticalPods: 10s
    TEMPLATE
  }
}

######################## module #########################
module "butane_k3s_snippets" {
  source = "../../modules/k3s"

  config         = local.config
  mode           = local.mode
  token          = local.token
  agent_token    = local.agent_token
  channel        = local.channel
  fleetlock      = local.fleetlock
  kubelet_config = local.kubelet_config
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

output "butane" {
  value       = module.butane_k3s_snippets.config
  description = "Butane config"
  sensitive   = true
}
