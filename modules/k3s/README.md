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
| <a name="input_data_dir"></a> [data\_dir](#input\_data\_dir) | K3s data directory | `string` | `"/var/lib/rancher/k3s"` | no |
| <a name="input_fleetlock"></a> [fleetlock](#input\_fleetlock) | Fleetlock addon for zincati upgrade orchestration | <pre>object(<br>    {<br>      version           = optional(string, "v0.4.0")<br>      namespace         = optional(string, "fleetlock")<br>      cluster_ip        = optional(string, "10.43.0.15")<br>      group             = optional(string)<br>      node_selectors    = optional(list(map(string)), [])<br>      kustomize_version = optional(string, "5.4.2")<br>      affinity          = optional(string, "")<br>      resources         = optional(string, "")<br>      tolerations = optional(<br>        list(<br>          object(<br>            {<br>              key      = optional(string, "")<br>              operator = optional(string, "Equal")<br>              value    = optional(string, "")<br>              effect   = optional(string, "")<br>            }<br>          )<br>        ), []<br>      )<br>    }<br>  )</pre> | `null` | no |
| <a name="input_install_script"></a> [install\_script](#input\_install\_script) | K3s script URL | <pre>object(<br>    {<br>      url       = string<br>      sha256sum = string<br>    }<br>  )</pre> | <pre>{<br>  "sha256sum": "3ce239d57d43b2d836d2b561043433e6decae8b9dc41f5d13908c0fafb0340cd",<br>  "url": "https://raw.githubusercontent.com/k3s-io/k3s/b4b156d9d14eeb475e789718b3a6b78aba00019e/install.sh"<br>}</pre> | no |
| <a name="input_install_script_snippet"></a> [install\_script\_snippet](#input\_install\_script\_snippet) | Snippet to add to the install script | `string` | `""` | no |
| <a name="input_install_service_name"></a> [install\_service\_name](#input\_install\_service\_name) | Name of the K3s install service | `string` | `"install-k3s.service"` | no |
| <a name="input_kubelet_config"></a> [kubelet\_config](#input\_kubelet\_config) | Contains the configuration for the Kubelet | <pre>object(<br>    {<br>      version = optional(string, "v1beta1")<br>      content = optional(string, "")<br>    }<br>  )</pre> | <pre>{<br>  "content": "",<br>  "version": "v1beta1"<br>}</pre> | no |
| <a name="input_mode"></a> [mode](#input\_mode) | K3s installation mode:<br>"bootstrap": bootstrap a cluster, then be a server<br>"server": start a server<br>"agent": start an agent | `string` | `"bootstrap"` | no |
| <a name="input_oidc_sc"></a> [oidc\_sc](#input\_oidc\_sc) | OIDC provider config for generating service accounts | <pre>object(<br>    {<br>      issuer        = string<br>      jwks_uri      = optional(string, "")<br>      signing_key   = string<br>      api_audiences = optional(string, "https://kubernetes.default.svc.cluster.local,k3s")<br>    }<br>  )</pre> | `null` | no |
| <a name="input_origin_server"></a> [origin\_server](#input\_origin\_server) | Server host to connect nodes to (ex: https://example:6443) | `string` | `""` | no |
| <a name="input_post_install_script_snippet"></a> [post\_install\_script\_snippet](#input\_post\_install\_script\_snippet) | Snippet to add to the post-install script | `string` | `""` | no |
| <a name="input_pre_install_script_snippet"></a> [pre\_install\_script\_snippet](#input\_pre\_install\_script\_snippet) | Snippet to add to the pre-install script | `string` | `""` | no |
| <a name="input_repo_baseurl"></a> [repo\_baseurl](#input\_repo\_baseurl) | K3s repository base URL | `string` | `"https://rpm.rancher.io/k3s/stable/common/coreos/noarch/"` | no |
| <a name="input_repo_gpgkey"></a> [repo\_gpgkey](#input\_repo\_gpgkey) | K3s repository GPG key | `string` | `"https://rpm.rancher.io/public.key"` | no |
| <a name="input_script_envvars"></a> [script\_envvars](#input\_script\_envvars) | K3s script environment variables | `list(string)` | `[]` | no |
| <a name="input_script_parameters"></a> [script\_parameters](#input\_script\_parameters) | K3s script install parameters | `list(string)` | `[]` | no |
| <a name="input_secret_encryption_key"></a> [secret\_encryption\_key](#input\_secret\_encryption\_key) | Set an specific secret encryption key (inteneded only for bootstrap and without base64 encoding) | `string` | `""` | no |
| <a name="input_selinux"></a> [selinux](#input\_selinux) | K3s install with selinux enabled | `bool` | `true` | no |
| <a name="input_shutdown"></a> [shutdown](#input\_shutdown) | Shutdown systemd service options | <pre>object(<br>    {<br>      service                            = optional(bool, true)<br>      drain                              = optional(bool, true)<br>      drain_request_timeout              = optional(string, "0")<br>      drain_timeout                      = optional(string, "0")<br>      drain_grace_period                 = optional(number, -1)<br>      drain_skip_wait_for_delete_timeout = optional(number, 0)<br>      killall_script                     = optional(bool, true)<br>    }<br>  )</pre> | <pre>{<br>  "drain": true,<br>  "drain_grace_period": -1,<br>  "drain_request_timeout": "0",<br>  "drain_skip_wait_for_delete_timeout": 0,<br>  "drain_timeout": "0",<br>  "killall_script": true,<br>  "service": true<br>}</pre> | no |
| <a name="input_testing_repo"></a> [testing\_repo](#input\_testing\_repo) | K3s Enable testing repository | `bool` | `false` | no |
| <a name="input_testing_repo_baseurl"></a> [testing\_repo\_baseurl](#input\_testing\_repo\_baseurl) | Testing repository base URL | `string` | `"https://rpm-testing.rancher.io/k3s/testing/common/coreos/noarch/"` | no |
| <a name="input_testing_repo_gpgkey"></a> [testing\_repo\_gpgkey](#input\_testing\_repo\_gpgkey) | Testing repository GPG key | `string` | `"https://rpm-testing.rancher.io/public.key"` | no |
| <a name="input_token"></a> [token](#input\_token) | K3s token for servers to join the cluster, and agents if `agent_token` is not set | `string` | `""` | no |
| <a name="input_unit_dropin_install_k3s"></a> [unit\_dropin\_install\_k3s](#input\_unit\_dropin\_install\_k3s) | Dropin for the install-k3s unit | `string` | `""` | no |
| <a name="input_unit_dropin_k3s"></a> [unit\_dropin\_k3s](#input\_unit\_dropin\_k3s) | Dropin for the k3s unit | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config"></a> [config](#output\_config) | Butante snippet to install k3s |
<!-- END_TF_DOCS -->
