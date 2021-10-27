# =============================================================================
# Server Profile Template
# -----------------------------------------------------------------------------
resource "intersight_server_profile_template" "esx" {
  count           = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name            = "${var.prefix}_esx_template"
  description     = "Server profile template for ESX servers"
  target_platform = "FIAttached"
  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
}

# =============================================================================
# BIOS Policy
# -----------------------------------------------------------------------------
resource "intersight_bios_policy" "m6" {
  count                = var.server_model == "m6" && length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name                 = "${var.prefix}_esx_m6_bios"
  description          = "ESX optimized BIOS for M6 servers"
  cpu_perf_enhancement = "Auto"
  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
  profiles {
    moid        = intersight_server_profile_template.esx[0].moid
    object_type = "server.ProfileTemplate"
  }
}

# =============================================================================
# Boot Policy
# -----------------------------------------------------------------------------
resource "intersight_boot_precision_policy" "bfs" {
  count                    = length(regexall("bfs", var.template_name)) > 0 && length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name                     = "${var.prefix}_esx_bfs_boot"
  description              = "Boot from SAN for ESX"
  class_id                 = "boot.PrecisionPolicy"
  object_type              = "boot.PrecisionPolicy"
  configured_boot_mode     = "Uefi"
  enforce_uefi_secure_boot = var.secure_boot

  boot_devices {
    enabled     = true
    name        = "iso"
    class_id    = "boot.VirtualMedia"
    object_type = "boot.VirtualMedia"
    additional_properties = jsonencode({
      Subtype = "cimc-mapped-dvd"
    })
  }

  dynamic "boot_devices" {
    for_each = { for idx, b in var.san_boot_targets : idx => b }
    content {
      enabled     = true
      name        = boot_devices.value.device_name
      object_type = "boot.San"
      class_id    = "boot.San"
      additional_properties = jsonencode({
        InterfaceName = "hba_${lower(boot_devices.value.switch_id)}",
        Lun           = boot_devices.value.lun_id,
        Slot          = "MLOM",
        Wwpn          = boot_devices.value.pwwn,
        Bootloader = {
          ClassId     = "boot.Bootloader",
          Description = "",
          Name        = "",
          ObjectType  = "boot.Bootloader",
          Path        = ""
        }
      })
    }
  }

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
  profiles {
    moid        = intersight_server_profile_template.esx[0].moid
    object_type = "server.ProfileTemplate"
  }
}

# =============================================================================
# vMedia Policy
# -----------------------------------------------------------------------------
resource "intersight_vmedia_policy" "esx" {
  count       = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name        = "${var.prefix}_esx_vmedia"
  description = "vMedia policy for esx installs"
  enabled     = true
  encryption  = true

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
  profiles {
    moid        = intersight_server_profile_template.esx[0].moid
    object_type = "server.ProfileTemplate"
  }
}

# =============================================================================
# IMC Access
# -----------------------------------------------------------------------------
resource "intersight_ippool_pool" "esx" {
  count            = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name             = "${var.prefix}_esx_ip_pool"
  description      = "IP Pool for ESX Servers"
  assignment_order = "sequential"
  ip_v4_config {
    object_type   = "ippool.IpV4Config"
    gateway       = var.imc_access.ipv4_gateway
    netmask       = var.imc_access.ipv4_netmask
    primary_dns   = var.imc_access.ipv4_dns[0]
    secondary_dns = length(var.imc_access.ipv4_dns) > 1 ? var.imc_access.ipv4_dns[1] : ""
  }
  ip_v4_blocks {
    from        = var.imc_access.ipv4_start_address
    object_type = "value"
    to          = var.imc_access.ipv4_end_address
  }

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

resource "intersight_access_policy" "esx" {
  count       = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name        = "${var.prefix}_esx_imc_access"
  description = "IMC Access policy for ESX servers"
  inband_vlan = var.imc_access.vlan_id
  inband_ip_pool {
    object_type = "ippool.Pool"
    moid        = intersight_ippool_pool.esx[0].moid
  }

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
  profiles {
    moid        = intersight_server_profile_template.esx[0].moid
    object_type = "server.ProfileTemplate"
  }
}

# =============================================================================
# Local users
# -----------------------------------------------------------------------------
resource "intersight_iam_end_point_user_policy" "esx" {
  count       = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name        = "${var.prefix}_esx_local_user"
  description = "Local user policy for ESX servers"

  password_properties {
    enforce_strong_password  = true
    enable_password_expiry   = false
    password_expiry_duration = 50
    password_history         = 5
    notification_period      = 1
    grace_period             = 2
    force_send_password      = true
  }

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
  profiles {
    moid        = intersight_server_profile_template.esx[0].moid
    object_type = "server.ProfileTemplate"
  }
}

# Mapping of endpoint user to endpoint roles.
resource "intersight_iam_end_point_user_role" "esx" {
  count    = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  enabled  = true
  password = var.user_password
  end_point_role {
    moid        = data.intersight_iam_end_point_role.esx[0].results[0].moid
    object_type = data.intersight_iam_end_point_role.esx[0].results[0].object_type
  }
  end_point_user {
    moid        = intersight_iam_end_point_user.esx[0].moid
    object_type = intersight_iam_end_point_user.esx[0].object_type
  }
  end_point_user_policy {
    moid        = intersight_iam_end_point_user_policy.esx[0].moid
    object_type = intersight_iam_end_point_user_policy.esx[0].object_type
  }
}

resource "intersight_iam_end_point_user" "esx" {
  count = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name  = "${var.prefix}_esx_user"

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

# get the IMC role named admin
data "intersight_iam_end_point_role" "esx" {
  count = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name  = "admin"
  type  = "IMC"
}

# =============================================================================
# KVM Policy
# -----------------------------------------------------------------------------
resource "intersight_kvm_policy" "esx" {
  count                     = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name                      = "${var.prefix}_esx_kvm_enabled"
  description               = "KVM policy for ESX servers"
  enable_local_server_video = true
  enable_video_encryption   = true
  enabled                   = true
  maximum_sessions          = 4
  remote_port               = 2068

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
  profiles {
    moid        = intersight_server_profile_template.esx[0].moid
    object_type = "server.ProfileTemplate"
  }
}

# =============================================================================
# Ethernet Network Policies
# -----------------------------------------------------------------------------
resource "intersight_vnic_eth_network_policy" "esx_4nic_mgmt" {
  count = length(regexall("esx", var.template_name)) > 0 && length(regexall("4nic", var.template_name)) > 0 ? 1 : 0
  name  = "${var.prefix}_esx_net_policy_mgmt"
  vlan_settings {
    object_type   = "vnic.VlanSettings"
    default_vlan  = var.lan_connectivity.mgmt_vlan
    mode          = upper(var.lan_connectivity.mgmt_interface_mode)
    allowed_vlans = var.lan_connectivity.default_vlan
  }

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

resource "intersight_vnic_eth_network_policy" "esx_4nic_vm" {
  count = length(regexall("esx", var.template_name)) > 0 && length(regexall("4nic", var.template_name)) > 0 ? 1 : 0
  name  = "${var.prefix}_esx_net_policy_vm"
  vlan_settings {
    object_type   = "vnic.VlanSettings"
    default_vlan  = var.lan_connectivity.default_vlan
    mode          = "TRUNK"
    allowed_vlans = var.lan_connectivity.vm_vlans
  }

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

# =============================================================================
# Ethernet Network Control Policy
# -----------------------------------------------------------------------------
resource "intersight_fabric_eth_network_control_policy" "esx" {
  count       = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name        = "${var.prefix}_esx_net_control_policy"
  description = "Network Control policy for ESX servers"
  cdp_enabled = false
  forge_mac   = "allow"
  lldp_settings {
    receive_enabled  = true
    transmit_enabled = true
  }
  mac_registration_mode = "allVlans"
  uplink_fail_action    = "linkDown"

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}


# =============================================================================
# Ethernet QoS Policies
# -----------------------------------------------------------------------------
resource "intersight_vnic_eth_qos_policy" "esx_mgmt" {
  count          = length(regexall("esx", var.template_name)) > 0 && length(regexall("4nic", var.template_name)) > 0 ? 1 : 0
  name           = "${var.prefix}_esx_eth_qos_mgmt"
  description    = "QoS policy for ESX servers mgmt interfaces"
  mtu            = 9000
  rate_limit     = 0
  cos            = 0
  burst          = 10240
  priority       = "Silver"
  trust_host_cos = false

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

resource "intersight_vnic_eth_qos_policy" "esx_vms" {
  count          = length(regexall("esx", var.template_name)) > 0 && length(regexall("4nic", var.template_name)) > 0 ? 1 : 0
  name           = "${var.prefix}_esx_eth_qos_vms"
  description    = "QoS policy for ESX servers vm interfaces"
  mtu            = 9000
  rate_limit     = 0
  cos            = 0
  burst          = 10240
  priority       = "Gold"
  trust_host_cos = false

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

# =============================================================================
# Ethernet Adapter
# -----------------------------------------------------------------------------
resource "intersight_vnic_eth_adapter_policy" "esx" {
  count                   = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name                    = "${var.prefix}_esx_eth_adapter_policy"
  rss_settings            = false
  uplink_failback_timeout = 5
  vxlan_settings {
    enabled = false
  }

  nvgre_settings {
    enabled = false
  }

  arfs_settings {
    enabled = false
  }

  geneve_enabled = false

  interrupt_settings {
    coalescing_time = 125
    coalescing_type = "MIN"
    nr_count        = 4
    mode            = "MSIx"
  }
  completion_queue_settings {
    nr_count  = 2
    ring_size = 1
  }
  rx_queue_settings {
    nr_count  = 1
    ring_size = 512
  }
  tx_queue_settings {
    nr_count  = 1
    ring_size = 256
  }
  tcp_offload_settings {
    large_receive = true
    large_send    = true
    rx_checksum   = true
    tx_checksum   = true
  }

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}
# =============================================================================
# LAN Connectivity
# -----------------------------------------------------------------------------
resource "intersight_vnic_lan_connectivity_policy" "esx" {
  count               = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name                = "${var.prefix}_esx_lan_connectivity"
  description         = "LAN Connectivity for ESX servers"
  iqn_allocation_type = "None"
  placement_mode      = "custom"
  target_platform     = "FIAttached"

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
  profiles {
    moid        = intersight_server_profile_template.esx[0].moid
    object_type = "server.ProfileTemplate"
  }
}
# =============================================================================
# MAC Pool
# -----------------------------------------------------------------------------
resource "intersight_macpool_pool" "esx" {
  count            = length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name             = "${var.prefix}_esx_mac_pool_a"
  assignment_order = "sequential"
  description      = "MAC Pool for ESX A side interfaces"
  mac_blocks {
    object_type = "macpool.Block"
    from        = var.lan_connectivity.mac_pool_start
    to          = var.lan_connectivity.mac_pool_end
  }

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

# =============================================================================
# Virtual NICs
# -----------------------------------------------------------------------------
resource "intersight_vnic_eth_if" "esx_4nic_mgmt_a" {
  count = length(regexall("esx", var.template_name)) > 0 && length(regexall("4nic", var.template_name)) > 0 ? 1 : 0
  name  = "mgmt_a"
  order = 0
  placement {
    id        = "MLOM"
    pci_link  = 0
    switch_id = "A"
  }
  cdn {
    value     = "mgmt_a"
    nr_source = "vnic"
  }
  usnic_settings {
    cos      = 5
    nr_count = 0
  }
  vmq_settings {
    enabled             = false
    multi_queue_support = false
    num_interrupts      = 16
    num_vmqs            = 4
    num_sub_vnics       = 64
  }

  mac_address_type = "POOL"
  mac_pool {
    moid = intersight_macpool_pool.esx[0].id
  }

  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.esx_4nic_mgmt[0].id
  }
  fabric_eth_network_control_policy {
    moid = intersight_fabric_eth_network_control_policy.esx[0].moid
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.esx[0].id
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.esx_mgmt[0].id
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.esx[0].id
    object_type = "vnic.LanConnectivityPolicy"
  }

  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

resource "intersight_vnic_eth_if" "esx_4nic_mgmt_b" {
  count = length(regexall("esx", var.template_name)) > 0 && length(regexall("4nic", var.template_name)) > 0 ? 1 : 0
  name  = "mgmt_b"
  order = 1
  placement {
    id        = "MLOM"
    pci_link  = 0
    switch_id = "B"
  }
  cdn {
    value     = "mgmt_b"
    nr_source = "vnic"
  }
  usnic_settings {
    cos      = 5
    nr_count = 0
  }
  vmq_settings {
    enabled             = false
    multi_queue_support = false
    num_interrupts      = 16
    num_vmqs            = 4
    num_sub_vnics       = 64
  }

  mac_address_type = "POOL"
  mac_pool {
    moid = intersight_macpool_pool.esx[0].id
  }

  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.esx_4nic_mgmt[0].id
  }
  fabric_eth_network_control_policy {
    moid = intersight_fabric_eth_network_control_policy.esx[0].moid
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.esx[0].id
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.esx_mgmt[0].id
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.esx[0].id
    object_type = "vnic.LanConnectivityPolicy"
  }

  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

resource "intersight_vnic_eth_if" "esx_4nic_vm_a" {
  count = length(regexall("esx", var.template_name)) > 0 && length(regexall("4nic", var.template_name)) > 0 ? 1 : 0
  name  = "vm_a"
  order = 2
  placement {
    id        = "MLOM"
    pci_link  = 0
    switch_id = "A"
  }
  cdn {
    value     = "vm_a"
    nr_source = "vnic"
  }
  usnic_settings {
    cos      = 5
    nr_count = 0
  }
  vmq_settings {
    enabled             = false
    multi_queue_support = false
    num_interrupts      = 16
    num_vmqs            = 4
    num_sub_vnics       = 64
  }

  mac_address_type = "POOL"
  mac_pool {
    moid = intersight_macpool_pool.esx[0].id
  }

  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.esx_4nic_vm[0].id
  }
  fabric_eth_network_control_policy {
    moid = intersight_fabric_eth_network_control_policy.esx[0].moid
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.esx[0].id
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.esx_vms[0].id
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.esx[0].id
    object_type = "vnic.LanConnectivityPolicy"
  }

  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

resource "intersight_vnic_eth_if" "esx_4nic_vm_b" {
  count = length(regexall("esx", var.template_name)) > 0 && length(regexall("4nic", var.template_name)) > 0 ? 1 : 0
  name  = "vm_b"
  order = 3
  placement {
    id        = "MLOM"
    pci_link  = 0
    switch_id = "B"
  }
  cdn {
    value     = "vm_b"
    nr_source = "vnic"
  }
  usnic_settings {
    cos      = 5
    nr_count = 0
  }
  vmq_settings {
    enabled             = false
    multi_queue_support = false
    num_interrupts      = 16
    num_vmqs            = 4
    num_sub_vnics       = 64
  }

  mac_address_type = "POOL"
  mac_pool {
    moid = intersight_macpool_pool.esx[0].id
  }

  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.esx_4nic_vm[0].id
  }
  fabric_eth_network_control_policy {
    moid = intersight_fabric_eth_network_control_policy.esx[0].moid
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.esx[0].id
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.esx_vms[0].id
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.esx[0].id
    object_type = "vnic.LanConnectivityPolicy"
  }

  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

# =============================================================================
# SAN Connectivity
# -----------------------------------------------------------------------------
resource "intersight_vnic_san_connectivity_policy" "esx" {
  count             = length(regexall("bfs", var.template_name)) > 0 && length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name              = "${var.prefix}_esx_san_connectivity"
  description       = "SAN Connectivity for ESX servers"
  placement_mode    = "custom"
  target_platform   = "FIAttached"
  wwnn_address_type = "POOL"
  wwnn_pool {
    moid = intersight_fcpool_pool.esx_nwwn[0].id
  }

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
  profiles {
    moid        = intersight_server_profile_template.esx[0].moid
    object_type = "server.ProfileTemplate"
  }
}

# =============================================================================
# WWNN Address Pool
# -----------------------------------------------------------------------------
resource "intersight_fcpool_pool" "esx_nwwn" {
  count            = length(regexall("bfs", var.template_name)) > 0 && length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name             = "${var.prefix}_esx_nwwn_pool"
  description      = "WWNN address pool for ESX servers"
  assignment_order = "sequential"
  id_blocks {
    object_type = "fcpool.Block"
    from        = var.san_connectivity.wwnn_pool_start
    to          = var.san_connectivity.wwnn_pool_end
  }
  pool_purpose = "WWNN"

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

# =============================================================================
# PWWN A Address Pool
# -----------------------------------------------------------------------------
resource "intersight_fcpool_pool" "esx_pwwn_a" {
  count            = length(regexall("bfs", var.template_name)) > 0 && length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name             = "${var.prefix}_esx_pwwn_a_pool"
  description      = "A side PWWN address pool for ESX servers"
  assignment_order = "sequential"
  id_blocks {
    object_type = "fcpool.Block"
    from        = var.san_connectivity.pwwn_pool_a_start
    to          = var.san_connectivity.pwwn_pool_a_end
  }
  pool_purpose = "WWPN"

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

# =============================================================================
# PWWN B Address Pool
# -----------------------------------------------------------------------------
resource "intersight_fcpool_pool" "esx_pwwn_b" {
  count            = length(regexall("bfs", var.template_name)) > 0 && length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name             = "${var.prefix}_esx_pwwn_b_pool"
  description      = "B side PWWN address pool for ESX servers"
  assignment_order = "sequential"
  id_blocks {
    object_type = "fcpool.Block"
    from        = var.san_connectivity.pwwn_pool_b_start
    to          = var.san_connectivity.pwwn_pool_b_end
  }
  pool_purpose = "WWPN"

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

# =============================================================================
# FC Network Policy (A-Side)
# -----------------------------------------------------------------------------
resource "intersight_vnic_fc_network_policy" "esx_fc_net_a" {
  count = length(regexall("bfs", var.template_name)) > 0 && length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name  = "${var.prefix}_esx_fc_net_policy_a"
  vsan_settings {
    id = var.san_connectivity.vsan_a_id
  }

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

# =============================================================================
# FC Network Policy (B-Side)
# -----------------------------------------------------------------------------
resource "intersight_vnic_fc_network_policy" "esx_fc_net_b" {
  count = length(regexall("bfs", var.template_name)) > 0 && length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name  = "${var.prefix}_esx_fc_net_policy_b"
  vsan_settings {
    id = var.san_connectivity.vsan_b_id
  }

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

# =============================================================================
# FC QoS Policy
# -----------------------------------------------------------------------------
resource "intersight_vnic_fc_qos_policy" "esx" {
  count               = length(regexall("bfs", var.template_name)) > 0 && length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name                = "${var.prefix}_esx_fc_qos"
  rate_limit          = 0
  cos                 = 3
  max_data_field_size = 2112
  burst               = 10240
  priority            = "FC"

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

# =============================================================================
# FC Adapter Policy
# -----------------------------------------------------------------------------
resource "intersight_vnic_fc_adapter_policy" "esx" {
  count                   = length(regexall("bfs", var.template_name)) > 0 && length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name                    = "${var.prefix}_esx_fc_adapter_policy"
  error_detection_timeout = 100000
  error_recovery_settings {
    enabled           = false
    io_retry_count    = 30
    io_retry_timeout  = 5
    link_down_timeout = 30000
    port_down_timeout = 10000
  }

  flogi_settings {
    retries = 8
    timeout = 4000
  }

  interrupt_settings {
    mode = "MSIx"
  }

  io_throttle_count = 256
  lun_count         = 1024
  lun_queue_depth   = 20

  plogi_settings {
    retries = 8
    timeout = 20000
  }
  resource_allocation_timeout = 100000

  rx_queue_settings {
    nr_count  = 1
    ring_size = 64
  }
  tx_queue_settings {
    nr_count  = 1
    ring_size = 64
  }
  scsi_queue_settings {
    nr_count  = 1
    ring_size = 152
  }

  organization {
    moid        = data.intersight_organization_organization.target.results[0].moid
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

# =============================================================================
# Virtual HBAs
# -----------------------------------------------------------------------------
resource "intersight_vnic_fc_if" "esx_hba_a" {
  count = length(regexall("bfs", var.template_name)) > 0 && length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name  = "hba_a"
  order = 4
  placement {
    id        = "MLOM"
    pci_link  = 0
    switch_id = "A"
  }
  persistent_bindings = true
  wwpn_address_type   = "POOL"
  wwpn_pool {
    moid = intersight_fcpool_pool.esx_pwwn_a[0].id
  }

  san_connectivity_policy {
    moid        = intersight_vnic_san_connectivity_policy.esx[0].id
    object_type = "vnic.SanConnectivityPolicy"
  }
  fc_network_policy {
    moid = intersight_vnic_fc_network_policy.esx_fc_net_a[0].id
  }
  fc_adapter_policy {
    moid = intersight_vnic_fc_adapter_policy.esx[0].id
  }
  fc_qos_policy {
    moid = intersight_vnic_fc_qos_policy.esx[0].id
  }
}

resource "intersight_vnic_fc_if" "esx_hba_b" {
  count = length(regexall("bfs", var.template_name)) > 0 && length(regexall("esx", var.template_name)) > 0 ? 1 : 0
  name  = "hba_b"
  order = 5
  placement {
    id        = "MLOM"
    pci_link  = 0
    switch_id = "B"
  }
  persistent_bindings = true
  wwpn_address_type   = "POOL"
  wwpn_pool {
    moid = intersight_fcpool_pool.esx_pwwn_b[0].id
  }

  san_connectivity_policy {
    moid        = intersight_vnic_san_connectivity_policy.esx[0].id
    object_type = "vnic.SanConnectivityPolicy"
  }
  fc_network_policy {
    moid = intersight_vnic_fc_network_policy.esx_fc_net_b[0].id
  }
  fc_adapter_policy {
    moid = intersight_vnic_fc_adapter_policy.esx[0].id
  }
  fc_qos_policy {
    moid = intersight_vnic_fc_qos_policy.esx[0].id
  }
}
