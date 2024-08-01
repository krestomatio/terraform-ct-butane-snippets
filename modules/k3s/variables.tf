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

variable "install_script" {
  type = object(
    {
      url       = string
      sha256sum = string
    }
  )
  description = "K3s script URL"
  default = {
    url       = "https://raw.githubusercontent.com/k3s-io/k3s/b4b156d9d14eeb475e789718b3a6b78aba00019e/install.sh"
    sha256sum = "3ce239d57d43b2d836d2b561043433e6decae8b9dc41f5d13908c0fafb0340cd"
  }
  nullable = false
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
      affinity          = optional(string, "")
      tolerations = optional(
        list(
          object(
            {
              key      = optional(string, "")
              operator = optional(string, "Equal")
              value    = optional(string, "")
              effect   = optional(string, "")
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

variable "oidc_sc" {
  type = object(
    {
      issuer        = string
      jwks_uri      = optional(string, "")
      signing_key   = string
      api_audiences = optional(string, "https://kubernetes.default.svc.cluster.local,k3s")
    }
  )
  description = "OIDC provider config for generating service accounts"
  sensitive   = true
  default     = null
}
