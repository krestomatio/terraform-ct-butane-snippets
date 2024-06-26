######################### values #########################
locals {
  hostname            = "server-01.example.com"
  ssh_authorized_key  = file(pathexpand("~/.ssh/id_rsa.pub"))
  nameservers         = ["8.8.8.8"]
  timezone            = "America/Costa_Rica"
  keymap              = "latam"
  rollout_wariness    = "0.5"
  cidr_ip_address     = "192.168.0.10/24"
  systemd_pager       = "cat"
  sync_time_with_host = true
  do_not_countme      = true
  sysctl = {
    "vm.swappiness"      = "0"
    "net.core.somaxconn" = "32768"
  }
  additional_rpms = {
    list = ["qemu-guest-agent"]
  }
  etc_hosts = [
    {
      ip       = "192.168.0.10"
      hostname = "server-01"
      fqdn     = "server-01.example.com"
    }
  ]
  etc_hosts_extra = <<-TEMPLATE
    192.168.0.20 server-11.example.com
    192.168.0.30 server-21.example.com
  TEMPLATE
  periodic_updates = {
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
  disks = [
    {
      device     = "/dev/vdb"
      wipe_table = true
      partitions = [
        {
          resize    = true
          label     = "log"
          number    = 1
          size_mib  = 0
          start_mib = 0
        }
      ]
    }
  ]
  filesystems = [
    {
      device          = "/dev/disk/by-partlabel/log"
      path            = "/var/log"
      format          = "xfs"
      label           = "log"
      with_mount_unit = true
    }
  ]
}

######################## module #########################
module "butane_snippets_common" {
  source = "../../modules/common"

  hostname            = local.hostname
  ssh_authorized_key  = local.ssh_authorized_key
  nameservers         = local.nameservers
  timezone            = local.timezone
  keymap              = local.keymap
  rollout_wariness    = local.rollout_wariness
  cidr_ip_address     = local.cidr_ip_address
  additional_rpms     = local.additional_rpms
  systemd_pager       = local.systemd_pager
  sysctl              = local.sysctl
  sync_time_with_host = local.sync_time_with_host
  do_not_countme      = local.do_not_countme
  etc_hosts           = local.etc_hosts
  etc_hosts_extra     = local.etc_hosts_extra
  periodic_updates    = local.periodic_updates
  disks               = local.disks
  filesystems         = local.filesystems
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
    module.butane_snippets_common.hostname,
    module.butane_snippets_common.keymap,
    module.butane_snippets_common.timezone,
    module.butane_snippets_common.periodic_updates,
    module.butane_snippets_common.rollout_wariness,
    module.butane_snippets_common.core_authorized_key,
    module.butane_snippets_common.static_interface,
    module.butane_snippets_common.etc_hosts,
    module.butane_snippets_common.disks,
    module.butane_snippets_common.filesystems,
    module.butane_snippets_common.additional_rpms,
    module.butane_snippets_common.sync_time_with_host,
    module.butane_snippets_common.systemd_pager,
    module.butane_snippets_common.sysctl,
    module.butane_snippets_common.do_not_countme
  ]
}

######################### outputs #########################
output "ignition" {
  value       = data.ct_config.node.rendered
  description = "Ignition config"
}
