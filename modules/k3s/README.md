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
| <a name="input_config"></a> [config](#input\_config) | K3s configuration | <pre>object(<br>    {<br>      envvars          = optional(list(string), [])<br>      parameters       = optional(list(string), [])<br>      selinux          = optional(bool, true)<br>      data_dir         = optional(string, "/var/lib/rancher/k3s")<br>      script_url       = optional(string, "https://raw.githubusercontent.com/k3s-io/k3s/7e59376bb91d451d3eaf16b9a3f80ae4d711b2bc/install.sh")<br>      script_sha256sum = optional(string, "88152dfac36254d75dd814d52960fd61574e35bc47d8c61f377496a7580414f3")<br>      repo_baseurl     = optional(string, "https://rpm.rancher.io/k3s/stable/common/coreos/noarch/")<br>      repo_gpgkey      = optional(string, "https://rpm.rancher.io/public.key")<br>      # TODO: change to false afet bug fixed:<br>      # https://github.com/k3s-io/k3s/issues/6814<br>      testing_repo         = optional(bool, true)<br>      testing_repo_baseurl = optional(string, "https://rpm-testing.rancher.io/k3s/testing/common/coreos/noarch/")<br>      testing_repo_gpgkey  = optional(string, "https://rpm-testing.rancher.io/public.key")<br>    }<br>  )</pre> | <pre>{<br>  "data_dir": "/var/lib/rancher/k3s",<br>  "envvars": [],<br>  "parameters": [],<br>  "repo_baseurl": "https://rpm.rancher.io/k3s/stable/common/coreos/noarch/",<br>  "repo_gpgkey": "https://rpm.rancher.io/public.key",<br>  "script_sha256sum": "88152dfac36254d75dd814d52960fd61574e35bc47d8c61f377496a7580414f3",<br>  "script_url": "https://raw.githubusercontent.com/k3s-io/k3s/7e59376bb91d451d3eaf16b9a3f80ae4d711b2bc/install.sh",<br>  "selinux": true,<br>  "testing_repo": true,<br>  "testing_repo_baseurl": "https://rpm-testing.rancher.io/k3s/testing/common/coreos/noarch/",<br>  "testing_repo_gpgkey": "https://rpm-testing.rancher.io/public.key"<br>}</pre> | no |
| <a name="input_fleetlock"></a> [fleetlock](#input\_fleetlock) | Fleetlock addon for zincati upgrade orchestration | <pre>object(<br>    {<br>      version           = optional(string, "v0.4.0")<br>      namespace         = optional(string, "fleetlock")<br>      cluster_ip        = optional(string, "10.43.0.15")<br>      group             = optional(string)<br>      node_selectors    = optional(list(map(string)), [])<br>      kustomize_version = optional(string, "5.4.2")<br>      tolerations = optional(<br>        list(<br>          object(<br>            {<br>              key      = string<br>              operator = string<br>              value    = optional(string)<br>              effect   = string<br>            }<br>          )<br>        ), []<br>      )<br>    }<br>  )</pre> | `null` | no |
| <a name="input_kubelet_config"></a> [kubelet\_config](#input\_kubelet\_config) | Contains the configuration for the Kubelet | <pre>object(<br>    {<br>      version = optional(string, "v1beta1")<br>      content = optional(string, "")<br>    }<br>  )</pre> | <pre>{<br>  "content": "",<br>  "version": "v1beta1"<br>}</pre> | no |
| <a name="input_mode"></a> [mode](#input\_mode) | K3s installation mode:<br>"bootstrap": bootstrap a cluster, then be a server<br>"server": start a server<br>"agent": start an agent | `string` | `"bootstrap"` | no |
| <a name="input_origin_server"></a> [origin\_server](#input\_origin\_server) | Server host to connect nodes to (ex: https://example:6443) | `string` | `""` | no |
| <a name="input_secret_encryption"></a> [secret\_encryption](#input\_secret\_encryption) | Set an specific secret encryption (inteneded only for bootstrap) | <pre>object(<br>    {<br>      key  = optional(string)<br>      path = optional(string, "/var/lib/rancher/k3s/server/cred/encryption-config.json")<br>    }<br>  )</pre> | <pre>{<br>  "key": null,<br>  "path": "/var/lib/rancher/k3s/server/cred/encryption-config.json"<br>}</pre> | no |
| <a name="input_token"></a> [token](#input\_token) | K3s token for servers to join the cluster, ang agents if `agent_token` is not set | `string` | `""` | no |
| <a name="input_unit_dropin_install_k3s"></a> [unit\_dropin\_install\_k3s](#input\_unit\_dropin\_install\_k3s) | Dropin for the install-k3s unit | `string` | `""` | no |
| <a name="input_unit_dropin_k3s"></a> [unit\_dropin\_k3s](#input\_unit\_dropin\_k3s) | Dropin for the k3s unit | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config"></a> [config](#output\_config) | Butante snippet to install k3s |
<!-- END_TF_DOCS -->