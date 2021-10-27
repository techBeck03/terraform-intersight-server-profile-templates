# ESX 7 boot from SAN with 4 vNICs and 2 vHBAs (MLOM)

This example builds a server profile template for ESX servers designed with 4 vNICs (2 for management and 2 for everything else), 2 vHBAs, and a boot from san boot policy.  This example also assumes the adapter slot id is `MLOM`

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | >=1.0.16 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_esx7_bfs_4nic_mlom"></a> [esx7\_bfs\_4nic\_mlom](#module\_esx7\_bfs\_4nic\_mlom) | terraform-cisco-modules/server-profile-templates/intersight | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_intersight_apikey"></a> [intersight\_apikey](#input\_intersight\_apikey) | Intersight API Key | `string` | n/a | yes |
| <a name="input_intersight_endpoint"></a> [intersight\_endpoint](#input\_intersight\_endpoint) | Intersight API endpoint | `string` | `"https://www.intersight.com"` | no |
| <a name="input_intersight_secretkey"></a> [intersight\_secretkey](#input\_intersight\_secretkey) | Intersight API Secret | `string` | n/a | yes |

## Outputs

No outputs.

