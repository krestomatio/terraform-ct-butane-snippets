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
| [template_file.butane_snippet_install_k3s](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_after_units"></a> [after\_units](#input\_after\_units) | Units to add as "After" in K3s install unit definition | `list(string)` | `[]` | no |
| <a name="input_agent_token"></a> [agent\_token](#input\_agent\_token) | K3s token for agents to join the cluster | `string` | `""` | no |
| <a name="input_before_units"></a> [before\_units](#input\_before\_units) | Units to add as "Before" in K3s install unit definition | `list(string)` | `[]` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | K3s installation channel | `string` | `"stable"` | no |
| <a name="input_config"></a> [config](#input\_config) | K3s configuration | <pre>object(<br>    {<br>      envvars          = optional(list(string), [])<br>      parameters       = optional(list(string), [])<br>      selinux          = optional(bool, true)<br>      data_dir         = optional(string, "/var/lib/rancher/k3s")<br>      script_url       = optional(string, "https://raw.githubusercontent.com/k3s-io/k3s/7e59376bb91d451d3eaf16b9a3f80ae4d711b2bc/install.sh")<br>      script_sha256sum = optional(string, "88152dfac36254d75dd814d52960fd61574e35bc47d8c61f377496a7580414f3")<br>      repo_baseurl     = optional(string, "https://rpm.rancher.io/k3s/stable/common/centos/8/noarch/")<br>      repo_gpgkey      = optional(string, "https://rpm.rancher.io/public.key")<br>    }<br>  )</pre> | <pre>{<br>  "data_dir": "/var/lib/rancher/k3s",<br>  "envvars": [],<br>  "parameters": [],<br>  "repo_baseurl": "https://rpm.rancher.io/k3s/stable/common/centos/8/noarch/",<br>  "repo_gpgkey": "https://rpm.rancher.io/public.key",<br>  "script_sha256sum": "88152dfac36254d75dd814d52960fd61574e35bc47d8c61f377496a7580414f3",<br>  "script_url": "https://raw.githubusercontent.com/k3s-io/k3s/7e59376bb91d451d3eaf16b9a3f80ae4d711b2bc/install.sh",<br>  "selinux": true<br>}</pre> | no |
| <a name="input_mode"></a> [mode](#input\_mode) | K3s installation mode:<br>"bootstrap": bootstrap a cluster, then be a server<br>"server": start a server<br>"agent": start an agent | `string` | `"bootstrap"` | no |
| <a name="input_origin_server"></a> [origin\_server](#input\_origin\_server) | Server host to connect nodes to (ex: https://example:6443) | `string` | `""` | no |
| <a name="input_secret_encryption"></a> [secret\_encryption](#input\_secret\_encryption) | Set an specific secret encryption (inteneded only for bootstrap) | <pre>object(<br>    {<br>      key  = optional(string)<br>      path = optional(string, "/var/lib/rancher/k3s/server/cred/encryption-config.json")<br>    }<br>  )</pre> | <pre>{<br>  "key": null,<br>  "path": "/var/lib/rancher/k3s/server/cred/encryption-config.json"<br>}</pre> | no |
| <a name="input_token"></a> [token](#input\_token) | K3s token for servers to join the cluster, ang agents if `agent_token` is not set | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config"></a> [config](#output\_config) | Butante snippet to install k3s |
<!-- END_TF_DOCS -->