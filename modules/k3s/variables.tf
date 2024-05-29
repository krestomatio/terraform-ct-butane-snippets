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

variable "config" {
  type = object(
    {
      envvars          = optional(list(string), [])
      parameters       = optional(list(string), [])
      selinux          = optional(bool, true)
      data_dir         = optional(string, "/var/lib/rancher/k3s")
      script_url       = optional(string, "https://raw.githubusercontent.com/k3s-io/k3s/7e59376bb91d451d3eaf16b9a3f80ae4d711b2bc/install.sh")
      script_sha256sum = optional(string, "88152dfac36254d75dd814d52960fd61574e35bc47d8c61f377496a7580414f3")
      repo_baseurl     = optional(string, "https://rpm.rancher.io/k3s/stable/common/coreos/noarch/")
      repo_gpgkey      = optional(string, "https://rpm.rancher.io/public.key")
      # TODO: change to false afet bug fixed:
      # https://github.com/k3s-io/k3s/issues/6814
      testing_repo         = optional(bool, true)
      testing_repo_baseurl = optional(string, "https://rpm-testing.rancher.io/k3s/testing/common/coreos/noarch/")
      testing_repo_gpgkey  = optional(string, "https://rpm-testing.rancher.io/public.key")
    }
  )
  description = "K3s configuration"
  default = {
    envvars          = []
    parameters       = []
    data_dir         = "/var/lib/rancher/k3s"
    selinux          = true
    script_url       = "https://raw.githubusercontent.com/k3s-io/k3s/7e59376bb91d451d3eaf16b9a3f80ae4d711b2bc/install.sh"
    script_sha256sum = "88152dfac36254d75dd814d52960fd61574e35bc47d8c61f377496a7580414f3"
    repo_baseurl     = "https://rpm.rancher.io/k3s/stable/common/coreos/noarch/"
    repo_gpgkey      = "https://rpm.rancher.io/public.key"
    # TODO: change to false afet bug fixed:
    # https://github.com/k3s-io/k3s/issues/6814
    testing_repo         = true
    testing_repo_baseurl = "https://rpm-testing.rancher.io/k3s/testing/common/coreos/noarch/"
    testing_repo_gpgkey  = "https://rpm-testing.rancher.io/public.key"
  }
  nullable = false
  validation {
    condition     = var.config.selinux ? can(regex("^/var/lib/rancher/k3s$", var.config.data_dir)) : true
    error_message = "Using a custom --data-dir under SELinux is not supported"
  }
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

variable "secret_encryption" {
  type = object(
    {
      key  = optional(string)
      path = optional(string, "/var/lib/rancher/k3s/server/cred/encryption-config.json")
    }
  )
  default = {
    key  = null
    path = "/var/lib/rancher/k3s/server/cred/encryption-config.json"
  }
  sensitive   = true
  description = "Set an specific secret encryption (inteneded only for bootstrap)"
  nullable    = false
}

variable "token" {
  type        = string
  sensitive   = true
  default     = ""
  description = "K3s token for servers to join the cluster, ang agents if `agent_token` is not set"
  nullable    = false
}

variable "agent_token" {
  type        = string
  default     = ""
  sensitive   = true
  description = "K3s token for agents to join the cluster"
  nullable    = false
}
