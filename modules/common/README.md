<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [template_file.butane_snippet_additional_rpms](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_core_authorized_key](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_disks](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_do_not_countme](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_etc_hosts](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_filesystems](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_grub_password_hash](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_hostname](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_keymap](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_periodic_updates](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_rollout_wariness](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_static_interface](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_sync_time_with_host](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_systemd_pager](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.butane_snippet_timezone](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_rpms"></a> [additional\_rpms](#input\_additional\_rpms) | Additional rpms to install during boot using rpm-ostree, along with any pre or post command | <pre>object(<br>    {<br>      cmd_pre  = optional(list(string), [])<br>      list     = optional(list(string), [])<br>      cmd_post = optional(list(string), [])<br>    }<br>  )</pre> | <pre>{<br>  "cmd_post": [],<br>  "cmd_pre": [],<br>  "list": []<br>}</pre> | no |
| <a name="input_cidr_ip_address"></a> [cidr\_ip\_address](#input\_cidr\_ip\_address) | CIDR IP Address. Ex: 192.168.1.101/24 | `string` | `null` | no |
| <a name="input_disks"></a> [disks](#input\_disks) | Disks list | <pre>list(<br>    object(<br>      {<br>        device     = string<br>        wipe_table = optional(bool, false)<br>        partitions = optional(<br>          list(<br>            object(<br>              {<br>                resize               = optional(bool)<br>                label                = optional(string)<br>                number               = optional(number)<br>                size_mib             = optional(number)<br>                start_mib            = optional(number)<br>                type_guid            = optional(string)<br>                guid                 = optional(string)<br>                wipe_partition_entry = optional(bool)<br>                should_exist         = optional(bool, true)<br>              }<br>            )<br>          )<br>        )<br>      }<br>    )<br>  )</pre> | `[]` | no |
| <a name="input_do_not_countme"></a> [do\_not\_countme](#input\_do\_not\_countme) | Disable Fedora CoreOS infrastructure count me feature | `bool` | `true` | no |
| <a name="input_etc_hosts"></a> [etc\_hosts](#input\_etc\_hosts) | /etc/host list | <pre>list(<br>    object(<br>      {<br>        ip       = string<br>        hostname = string<br>        fqdn     = string<br>      }<br>    )<br>  )</pre> | `[]` | no |
| <a name="input_etc_hosts_extra"></a> [etc\_hosts\_extra](#input\_etc\_hosts\_extra) | /etc/host extra block | `string` | `""` | no |
| <a name="input_filesystems"></a> [filesystems](#input\_filesystems) | Filesystems list | <pre>list(<br>    object(<br>      {<br>        device          = string<br>        path            = string<br>        format          = string<br>        with_mount_unit = optional(bool)<br>        wipe_filesystem = optional(bool)<br>        label           = optional(string)<br>        uuid            = optional(string)<br>        options         = optional(string)<br>        mount_options   = optional(list(string))<br>      }<br>    )<br>  )</pre> | `[]` | no |
| <a name="input_grub_password_hash"></a> [grub\_password\_hash](#input\_grub\_password\_hash) | grub2-mkpasswd-pbkdf2 password hash for GRUB | `string` | `""` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname | `string` | `""` | no |
| <a name="input_interface_name"></a> [interface\_name](#input\_interface\_name) | Network interface name | `string` | `"ens3"` | no |
| <a name="input_keymap"></a> [keymap](#input\_keymap) | Keymap | `string` | `""` | no |
| <a name="input_nameservers"></a> [nameservers](#input\_nameservers) | List of nameservers for VMs | `list(string)` | `[]` | no |
| <a name="input_periodic_updates"></a> [periodic\_updates](#input\_periodic\_updates) | Only reboot for updates during certain timeframes<br>{<br>  time\_zone = "localtime"<br>  windows = [<br>    {<br>      days           = ["Sat"],<br>      start\_time     = "23:30",<br>      length\_minutes = "60"<br>    },<br>    {<br>      days           = ["Sun"],<br>      start\_time     = "00:30",<br>      length\_minutes = "60"<br>    }<br>  ]<br>} | <pre>object(<br>    {<br>      time_zone = optional(string, "")<br>      windows = list(<br>        object(<br>          {<br>            days           = list(string)<br>            start_time     = string<br>            length_minutes = string<br>          }<br>        )<br>      )<br>    }<br>  )</pre> | `null` | no |
| <a name="input_rollout_wariness"></a> [rollout\_wariness](#input\_rollout\_wariness) | Wariness to update, 1.0 (very cautious) to 0.0 (very eager) | `string` | `""` | no |
| <a name="input_ssh_authorized_key"></a> [ssh\_authorized\_key](#input\_ssh\_authorized\_key) | Authorized ssh key for core user | `string` | `""` | no |
| <a name="input_sync_time_with_host"></a> [sync\_time\_with\_host](#input\_sync\_time\_with\_host) | Sync guest time with the kvm host | `bool` | `false` | no |
| <a name="input_systemd_pager"></a> [systemd\_pager](#input\_systemd\_pager) | Systemd pager | `string` | `""` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone for VMs as listed by `timedatectl list-timezones` | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_additional_rpms"></a> [additional\_rpms](#output\_additional\_rpms) | Butante snippet to install additional rpms unsing rpm-ostree |
| <a name="output_core_authorized_key"></a> [core\_authorized\_key](#output\_core\_authorized\_key) | Butane snipped to set an authorized key for core user |
| <a name="output_disks"></a> [disks](#output\_disks) | Butante snippet to set storage disks |
| <a name="output_do_not_countme"></a> [do\_not\_countme](#output\_do\_not\_countme) | Butane snipped to disable Fedora count me feature |
| <a name="output_etc_hosts"></a> [etc\_hosts](#output\_etc\_hosts) | Butane snipped to append to /etc/hosts |
| <a name="output_filesystems"></a> [filesystems](#output\_filesystems) | Butante snippet to set storage filesystems |
| <a name="output_grub_password_hash"></a> [grub\_password\_hash](#output\_grub\_password\_hash) | Butane snipped to set a grub2 password |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Butante snippet to set hostname |
| <a name="output_keymap"></a> [keymap](#output\_keymap) | Butante snippet to set keymap |
| <a name="output_periodic_updates"></a> [periodic\_updates](#output\_periodic\_updates) | Butante snippet to set updates periodic window |
| <a name="output_rollout_wariness"></a> [rollout\_wariness](#output\_rollout\_wariness) | Butane snipped to set rollout wariness |
| <a name="output_static_interface"></a> [static\_interface](#output\_static\_interface) | Butane snipped to set the static interface |
| <a name="output_sync_time_with_host"></a> [sync\_time\_with\_host](#output\_sync\_time\_with\_host) | Butante snippet to sync guest time with the kvm host |
| <a name="output_systemd_pager"></a> [systemd\_pager](#output\_systemd\_pager) | Butante snippet to set systemd pager |
| <a name="output_timezone"></a> [timezone](#output\_timezone) | Butane snipped to set the timezone |
<!-- END_TF_DOCS -->