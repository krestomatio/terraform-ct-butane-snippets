variable "hostname" {
  type        = string
  description = "Hostname"
  default     = ""
  nullable    = false
}

variable "ssh_authorized_key" {
  type        = string
  description = "Authorized ssh key for core user"
  default     = ""
  nullable    = false
}

variable "nameservers" {
  type        = list(string)
  description = "List of nameservers for VMs"
  default     = []
  nullable    = false
}

variable "grub_password_hash" {
  type        = string
  description = "grub2-mkpasswd-pbkdf2 password hash for GRUB"
  default     = ""
  nullable    = false
}

variable "timezone" {
  type        = string
  description = "Timezone for VMs as listed by `timedatectl list-timezones`"
  default     = ""
  nullable    = false
}

variable "systemd_pager" {
  type        = string
  description = "Systemd pager"
  default     = ""
  nullable    = false
}

variable "do_not_countme" {
  type        = bool
  description = "Disable Fedora CoreOS infrastructure count me feature"
  default     = true
  nullable    = false
}

variable "rollout_wariness" {
  type        = string
  description = "Wariness to update, 1.0 (very cautious) to 0.0 (very eager)"
  default     = ""
  nullable    = false
}

variable "periodic_updates" {
  type = object(
    {
      time_zone = optional(string, "")
      windows = list(
        object(
          {
            days           = list(string)
            start_time     = string
            length_minutes = string
          }
        )
      )
    }
  )
  description = <<-TEMPLATE
    Only reboot for updates during certain timeframes
    {
      time_zone = "localtime"
      windows = [
        {
          days           = ["Sat"],
          start_time     = "23:30",
          length_minutes = "60"
        },
        {
          days           = ["Sun"],
          start_time     = "00:30",
          length_minutes = "60"
        }
      ]
    }
  TEMPLATE
  default     = null
}

variable "cidr_ip_address" {
  type        = string
  description = "CIDR IP Address. Ex: 192.168.1.101/24"
  validation {
    condition     = var.cidr_ip_address == null || can(cidrhost(var.cidr_ip_address, 1))
    error_message = "Check cidr_ip_address format"
  }
  default = null
}

variable "interface_name" {
  type        = string
  description = "Network interface name"
  default     = "ens3"
  nullable    = false
}

variable "keymap" {
  type        = string
  description = "Keymap"
  default     = ""
  nullable    = false
}

variable "sync_time_with_host" {
  type        = bool
  description = "Sync guest time with the kvm host"
  default     = false
  nullable    = false
}

variable "etc_hosts" {
  type = list(
    object(
      {
        ip       = string
        hostname = string
        fqdn     = string
      }
    )
  )
  description = "/etc/host list"
  default     = []
  nullable    = false
}

variable "etc_hosts_extra" {
  type        = string
  description = "/etc/host extra block"
  default     = ""
  nullable    = false
}

variable "disks" {
  type = list(
    object(
      {
        device     = string
        wipe_table = optional(bool, false)
        partitions = optional(
          list(
            object(
              {
                resize               = optional(bool)
                label                = optional(string)
                number               = optional(number)
                size_mib             = optional(number)
                start_mib            = optional(number)
                type_guid            = optional(string)
                guid                 = optional(string)
                wipe_partition_entry = optional(bool)
                should_exist         = optional(bool, true)
              }
            )
          )
        )
      }
    )
  )
  description = "Disks list"
  default     = []
  nullable    = false
}

variable "filesystems" {
  type = list(
    object(
      {
        device          = string
        format          = string
        path            = optional(string)
        with_mount_unit = optional(bool)
        wipe_filesystem = optional(bool)
        label           = optional(string)
        uuid            = optional(string)
        options         = optional(string)
        mount_options   = optional(list(string))
      }
    )
  )
  description = "Filesystems list"
  default     = []
  nullable    = false
}

variable "additional_rpms" {
  type = object(
    {
      cmd_pre  = optional(list(string), [])
      list     = optional(list(string), [])
      cmd_post = optional(list(string), [])
    }
  )
  description = "Additional rpms to install during boot using rpm-ostree, along with any pre or post command"
  default = {
    cmd_pre  = []
    list     = []
    cmd_post = []
  }
  nullable = false
}

variable "sysctl" {
  description = "Additional kernel tuning in sysctl.d"
  type        = map(string)
  default     = null
}

variable "init_config_script" {
  type        = string
  description = "Content to include in a init config script. It runs after additional rpms are installed"
  default     = ""
  nullable    = false
}

variable "disable_zincati" {
  type        = bool
  description = "Disable zincati systemd service"
  default     = false
  nullable    = false
}
