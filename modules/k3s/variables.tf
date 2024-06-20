variable "mode" {
  type        = string
  default     = "bootstrap"
  nullable    = false
  description = <<-TEMPLATE
    K3s installation mode:
    "bootstrap": bootstrap a cluster, then be a server
    "server": start a server
    "agent": start an agent
  TEMPLATE
  validation {
    condition     = contains(["bootstrap", "server", "agent"], var.mode)
    error_message = <<-TEMPLATE
      "Invalid input, options: "bootstrap", "server", "agent":"
      "bootstrap": bootstrap a cluster, then be a server
      "server": start a server
      "agent": start an agent
    TEMPLATE
  }
}

variable "selinux" {
  type        = bool
  description = "K3s install with selinux enabled"
  default     = true
  nullable    = false
}

variable "data_dir" {
  type        = string
  description = "K3s data directory"
  default     = "/var/lib/rancher/k3s"
  nullable    = false
}

variable "script_url" {
  type        = string
  description = "K3s script URL"
  default     = "https://raw.githubusercontent.com/k3s-io/k3s/7e59376bb91d451d3eaf16b9a3f80ae4d711b2bc/install.sh"
  nullable    = false
}

variable "script_sha256sum" {
  type        = string
  description = "K3s script SHA256 sum"
  default     = "88152dfac36254d75dd814d52960fd61574e35bc47d8c61f377496a7580414f3"
  nullable    = false
}

variable "script_envvars" {
  type        = list(string)
  description = "K3s script environment variables"
  default     = []
  nullable    = false
}

variable "script_parameters" {
  type        = list(string)
  description = "K3s script install parameters"
  default     = []
  nullable    = false
}

variable "repo_baseurl" {
  type        = string
  description = "K3s repository base URL"
  default     = "https://rpm.rancher.io/k3s/stable/common/coreos/noarch/"
  nullable    = false
}

variable "repo_gpgkey" {
  type        = string
  description = "K3s repository GPG key"
  default     = "https://rpm.rancher.io/public.key"
  nullable    = false
}

variable "testing_repo" {
  type        = bool
  description = "K3s Enable testing repository"
  default     = false
  nullable    = false
}

variable "testing_repo_baseurl" {
  type        = string
  description = "Testing repository base URL"
  default     = "https://rpm-testing.rancher.io/k3s/testing/common/coreos/noarch/"
  nullable    = false
}

variable "testing_repo_gpgkey" {
  type        = string
  description = "Testing repository GPG key"
  default     = "https://rpm-testing.rancher.io/public.key"
  nullable    = false
}

variable "fleetlock" {
  type = object(
    {
      version           = optional(string, "v0.4.0")
      namespace         = optional(string, "fleetlock")
      cluster_ip        = optional(string, "10.43.0.15")
      group             = optional(string)
      node_selectors    = optional(list(map(string)), [])
      kustomize_version = optional(string, "5.4.2")
      tolerations = optional(
        list(
          object(
            {
              key      = string
              operator = string
              value    = optional(string)
              effect   = string
            }
          )
        ), []
      )
    }
  )
  description = "Fleetlock addon for zincati upgrade orchestration"
  default     = null
}

variable "kubelet_config" {
  type = object(
    {
      version = optional(string, "v1beta1")
      content = optional(string, "")
    }
  )
  description = "Contains the configuration for the Kubelet"
  default = {
    version = "v1beta1"
    content = ""
  }
  nullable = false
}

variable "before_units" {
  type        = list(string)
  default     = []
  description = "Units to add as \"Before\" in K3s install unit definition"
  nullable    = false
}

variable "after_units" {
  type        = list(string)
  default     = []
  description = "Units to add as \"After\" in K3s install unit definition"
  nullable    = false
}

variable "unit_dropin_install_k3s" {
  type        = string
  default     = ""
  description = "Dropin for the install-k3s unit"
  nullable    = false
}

variable "unit_dropin_k3s" {
  type        = string
  default     = ""
  description = "Dropin for the k3s unit"
  nullable    = false
}

variable "install_service_name" {
  type        = string
  default     = "install-k3s.service"
  description = "Name of the K3s install service"
  nullable    = false
}

variable "channel" {
  type        = string
  default     = "stable"
  description = "K3s installation channel"
  nullable    = false
}

variable "origin_server" {
  type        = string
  default     = ""
  description = "Server host to connect nodes to (ex: https://example:6443)"
  nullable    = false
}

variable "secret_encryption_key" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Set an specific secret encryption key (inteneded only for bootstrap and without base64 encoding)"
  nullable    = false
}

variable "token" {
  type        = string
  sensitive   = true
  default     = ""
  description = "K3s token for servers to join the cluster, and agents if `agent_token` is not set"
  nullable    = false
}

variable "agent_token" {
  type        = string
  default     = ""
  sensitive   = true
  description = "K3s token for agents to join the cluster"
  nullable    = false
}

variable "shutdown" {
  type = object(
    {
      service                            = optional(bool, true)
      drain                              = optional(bool, true)
      drain_request_timeout              = optional(string, "0")
      drain_timeout                      = optional(string, "0")
      drain_grace_period                 = optional(number, -1)
      drain_skip_wait_for_delete_timeout = optional(number, 0)
      killall_script                     = optional(bool, true)
    }
  )
  default = {
    service                            = true
    drain                              = true
    drain_request_timeout              = "0"
    drain_timeout                      = "0"
    drain_grace_period                 = -1
    drain_skip_wait_for_delete_timeout = 0
    killall_script                     = true
  }
  description = "Shutdown systemd service options"
  nullable    = false
}

variable "pre_install_script_snippet" {
  type        = string
  default     = ""
  description = "Snippet to add to the pre-install script"
  nullable    = false
}

variable "install_script_snippet" {
  type        = string
  default     = ""
  description = "Snippet to add to the install script"
  nullable    = false
}

variable "post_install_script_snippet" {
  type        = string
  default     = ""
  description = "Snippet to add to the post-install script"
  nullable    = false

}
