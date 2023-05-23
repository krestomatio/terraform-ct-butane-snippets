A basic example to generate butane snippets to configure k3s clusters for then using them as ignition configuration. 
## Usage

To run this example you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_ct"></a> [ct](#requirement\_ct) | 0.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ct"></a> [ct](#provider\_ct) | 0.11.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_butane_k3s_snippets"></a> [butane\_k3s\_snippets](#module\_butane\_k3s\_snippets) | ../../modules/k3s | n/a |

## Resources

| Name | Type |
|------|------|
| [ct_config.node](https://registry.terraform.io/providers/poseidon/ct/0.11.0/docs/data-sources/config) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_butane"></a> [butane](#output\_butane) | Butane config |
| <a name="output_ignition"></a> [ignition](#output\_ignition) | Ignition config |
<!-- END_TF_DOCS -->