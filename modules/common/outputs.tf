output "core_authorized_key" {
  description = "Butane snipped to set an authorized key for core user"
  value       = try(data.template_file.butane_snippet_core_authorized_key[0].rendered, "")
}

output "static_interface" {
  description = "Butane snipped to set the static interface"
  value       = try(data.template_file.butane_snippet_static_interface[0].rendered, "")
}

output "etc_hosts" {
  description = "Butane snipped to append to /etc/hosts"
  value       = try(data.template_file.butane_snippet_etc_hosts[0].rendered, "")
}

output "do_not_countme" {
  description = "Butane snipped to disable Fedora count me feature"
  value       = try(data.template_file.butane_snippet_do_not_countme[0].rendered, "")
}

output "grub_password_hash" {
  description = "Butane snipped to set a grub2 password"
  value       = try(data.template_file.butane_snippet_grub_password_hash[0].rendered, "")
}

output "timezone" {
  description = "Butane snipped to set the timezone"
  value       = try(data.template_file.butane_snippet_timezone[0].rendered, "")
}

output "rollout_wariness" {
  description = "Butane snipped to set rollout wariness"
  value       = try(data.template_file.butane_snippet_rollout_wariness[0].rendered, "")
}

output "periodic_updates" {
  description = "Butante snippet to set updates periodic window"
  value       = try(data.template_file.butane_snippet_periodic_updates[0].rendered, "")
}

output "keymap" {
  description = "Butante snippet to set keymap"
  value       = try(data.template_file.butane_snippet_keymap[0].rendered, "")
}

output "hostname" {
  description = "Butante snippet to set hostname"
  value       = try(data.template_file.butane_snippet_hostname[0].rendered, "")
}

output "disks" {
  description = "Butante snippet to set storage disks"
  value       = try(data.template_file.butane_snippet_disks[0].rendered, "")
}

output "filesystems" {
  description = "Butante snippet to set storage filesystems"
  value       = try(data.template_file.butane_snippet_filesystems[0].rendered, "")
}

output "additional_rpms" {
  description = "Butante snippet to install additional rpms unsing rpm-ostree"
  value       = try(data.template_file.butane_snippet_additional_rpms[0].rendered, "")
}

output "sync_time_with_host" {
  description = "Butante snippet to sync guest time with the kvm host"
  value       = try(data.template_file.butane_snippet_sync_time_with_host[0].rendered, "")
}

output "systemd_pager" {
  description = "Butante snippet to set systemd pager"
  value       = try(data.template_file.butane_snippet_systemd_pager[0].rendered, "")
}

output "sysctl" {
  description = "Butante snippet to tuning kernel adding to sysctl.d"
  value       = try(data.template_file.butane_snippet_sysctl[0].rendered, "")
}
