<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name                                                             | Version |
| ---------------------------------------------------------------- | ------- |
| <a name="provider_template"></a> [template](#provider\_template) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                     | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [template_file.butane_snippet_install_certbot](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name                                                                                       | Description                                         | Type                                                                                                                                                                    | Default                                                                    | Required |
| ------------------------------------------------------------------------------------------ | --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | :------: |
| <a name="input_additional_domains"></a> [additional\_domains](#input\_additional\_domains) | Additional domain names                             | `list(string)`                                                                                                                                                          | `[]`                                                                       |    no    |
| <a name="input_after_units"></a> [after\_units](#input\_after\_units)                      | Units to add as "After" in install unit definition  | `list(string)`                                                                                                                                                          | `[]`                                                                       |    no    |
| <a name="input_agree_tos"></a> [agree\_tos](#input\_agree\_tos)                            | Agree to the ACME server's Subscriber Agreement     | `bool`                                                                                                                                                                  | `false`                                                                    |    no    |
| <a name="input_before_units"></a> [before\_units](#input\_before\_units)                   | Units to add as "Before" in install unit definition | `list(string)`                                                                                                                                                          | `[]`                                                                       |    no    |
| <a name="input_domain"></a> [domain](#input\_domain)                                       | Domain name                                         | `string`                                                                                                                                                                | n/a                                                                        |   yes    |
| <a name="input_email"></a> [email](#input\_email)                                          | Email                                               | `string`                                                                                                                                                                | n/a                                                                        |   yes    |
| <a name="input_http_01_port"></a> [http\_01\_port](#input\_http\_01\_port)                 | Port used in the http-01 challenge                  | `number`                                                                                                                                                                | `80`                                                                       |    no    |
| <a name="input_post_hook"></a> [post\_hook](#input\_post\_hook)                            | Post hook script                                    | <pre>object(<br>    {<br>      path    = optional(string, "")<br>      content = optional(string, "")<br>      mode    = optional(string, "0755")<br>    }<br>  )</pre> | <pre>{<br>  "content": "",<br>  "mode": "0755",<br>  "path": ""<br>}</pre> |    no    |
| <a name="input_staging"></a> [staging](#input\_staging)                                    | Obtain a test certificate from a staging server     | `bool`                                                                                                                                                                  | `true`                                                                     |    no    |

## Outputs

| Name                                                   | Description                        |
| ------------------------------------------------------ | ---------------------------------- |
| <a name="output_config"></a> [config](#output\_config) | Butante snippet to install certbot |
<!-- END_TF_DOCS -->