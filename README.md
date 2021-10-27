# Terraform Intersight Server Profile Templates Module
This module helps create Intersight Server Profile Templates for common use-cases.  This module is a work in progress and currently supports the following template use cases:

- ESX
  * `esx7_bfs_4nic_mlom` - ESX 7 configured for boot from SAN with 4 vNICs and 2 vHBAs using the `MLOM` adapter


The main purpose of this module is to get up and running very quickly with server profile templates in Intersight.  More use cases and configuration options will be added in the future.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | >=1.0.16 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_intersight"></a> [intersight](#provider\_intersight) | 1.0.16 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [intersight_access_policy.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/access_policy) | resource |
| [intersight_bios_policy.m6](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/bios_policy) | resource |
| [intersight_boot_precision_policy.bfs](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/boot_precision_policy) | resource |
| [intersight_fabric_eth_network_control_policy.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fabric_eth_network_control_policy) | resource |
| [intersight_fcpool_pool.esx_nwwn](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fcpool_pool) | resource |
| [intersight_fcpool_pool.esx_pwwn_a](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fcpool_pool) | resource |
| [intersight_fcpool_pool.esx_pwwn_b](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fcpool_pool) | resource |
| [intersight_iam_end_point_user.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iam_end_point_user) | resource |
| [intersight_iam_end_point_user_policy.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iam_end_point_user_policy) | resource |
| [intersight_iam_end_point_user_role.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iam_end_point_user_role) | resource |
| [intersight_ippool_pool.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/ippool_pool) | resource |
| [intersight_kvm_policy.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/kvm_policy) | resource |
| [intersight_macpool_pool.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/macpool_pool) | resource |
| [intersight_server_profile_template.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/server_profile_template) | resource |
| [intersight_vmedia_policy.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vmedia_policy) | resource |
| [intersight_vnic_eth_adapter_policy.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_eth_adapter_policy) | resource |
| [intersight_vnic_eth_if.esx_4nic_mgmt_a](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_eth_if) | resource |
| [intersight_vnic_eth_if.esx_4nic_mgmt_b](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_eth_if) | resource |
| [intersight_vnic_eth_if.esx_4nic_vm_a](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_eth_if) | resource |
| [intersight_vnic_eth_if.esx_4nic_vm_b](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_eth_if) | resource |
| [intersight_vnic_eth_network_policy.esx_4nic_mgmt](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_eth_network_policy) | resource |
| [intersight_vnic_eth_network_policy.esx_4nic_vm](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_eth_network_policy) | resource |
| [intersight_vnic_eth_qos_policy.esx_mgmt](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_eth_qos_policy) | resource |
| [intersight_vnic_eth_qos_policy.esx_vms](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_eth_qos_policy) | resource |
| [intersight_vnic_fc_adapter_policy.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_fc_adapter_policy) | resource |
| [intersight_vnic_fc_if.esx_hba_a](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_fc_if) | resource |
| [intersight_vnic_fc_if.esx_hba_b](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_fc_if) | resource |
| [intersight_vnic_fc_network_policy.esx_fc_net_a](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_fc_network_policy) | resource |
| [intersight_vnic_fc_network_policy.esx_fc_net_b](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_fc_network_policy) | resource |
| [intersight_vnic_fc_qos_policy.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_fc_qos_policy) | resource |
| [intersight_vnic_lan_connectivity_policy.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_lan_connectivity_policy) | resource |
| [intersight_vnic_san_connectivity_policy.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_san_connectivity_policy) | resource |
| [intersight_iam_end_point_role.esx](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/iam_end_point_role) | data source |
| [intersight_organization_organization.target](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/organization_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_imc_access"></a> [imc\_access](#input\_imc\_access) | IMC Access details | <pre>object({<br>    vlan_id            = number<br>    ipv4_start_address = string<br>    ipv4_end_address   = string<br>    ipv4_gateway       = string<br>    ipv4_netmask       = string<br>    ipv4_dns           = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_lan_connectivity"></a> [lan\_connectivity](#input\_lan\_connectivity) | LAN connectivity details | <pre>object({<br>    mgmt_interface_mode = string<br>    default_vlan        = number<br>    mgmt_vlan           = string<br>    vm_vlans            = string<br>    mac_pool_start      = string<br>    mac_pool_end        = string<br>  })</pre> | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | Intersight Organization name | `string` | `"default"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used for objects created in Intersight | `string` | n/a | yes |
| <a name="input_san_boot_targets"></a> [san\_boot\_targets](#input\_san\_boot\_targets) | Boot from SAN settings | <pre>list(object({<br>    lun_id      = number<br>    switch_id   = string<br>    pwwn        = string<br>    device_name = string<br>  }))</pre> | `[]` | no |
| <a name="input_san_connectivity"></a> [san\_connectivity](#input\_san\_connectivity) | SAN connectivity details | <pre>object({<br>    wwnn_pool_start   = string<br>    wwnn_pool_end     = string<br>    vsan_a_id         = number<br>    vsan_b_id         = number<br>    vsan_a_vlan       = number<br>    vsan_b_vlan       = number<br>    pwwn_pool_a_start = string<br>    pwwn_pool_a_end   = string<br>    pwwn_pool_b_start = string<br>    pwwn_pool_b_end   = string<br>  })</pre> | n/a | yes |
| <a name="input_secure_boot"></a> [secure\_boot](#input\_secure\_boot) | Whether to enfore uefi secure boot | `bool` | `false` | no |
| <a name="input_server_model"></a> [server\_model](#input\_server\_model) | UCS server model | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to Intersight objects | `map(string)` | n/a | yes |
| <a name="input_template_name"></a> [template\_name](#input\_template\_name) | The template name describing the desired server layout | `string` | n/a | yes |
| <a name="input_user_password"></a> [user\_password](#input\_user\_password) | Local user password for IMC | `string` | n/a | yes |

## Outputs

No outputs.
