module "esx7_bfs_4nic_mlom" {
  source        = "terraform-cisco-modules/server-profile-templates/intersight"

  organization  = "default"
  template_name = "esx7_bfs_4nic_mlom"
  server_model  = "m6"
  prefix        = "demo"
  tags = {
    "orchestrator" = "terraform"
    "owner"        = "dmeouser"
  }
  san_boot_targets = [
    {
      lun_id      = 1
      switch_id   = "A"
      pwwn        = "52:4a:93:7c:ff:ff:ff:10"
      device_name = "Pure_Loki_CT1_FC0"
    },
    {
      lun_id      = 1
      switch_id   = "B"
      pwwn        = "52:4a:93:7c:ff:ff:ff:00"
      device_name = "Pure_Loki_CT0_FC0"
    }
  ]

  imc_access = {
    ipv4_dns           = ["172.16.1.98"]
    ipv4_end_address   = "172.18.64.45"
    ipv4_gateway       = "172.18.64.1"
    ipv4_netmask       = "255.255.192.0"
    ipv4_start_address = "172.18.64.26"
    vlan_id            = 1030
  }

  user_password = "!IntersightRocks"

  lan_connectivity = {
    default_vlan        = 1
    mgmt_vlan           = 1030
    mgmt_interface_mode = "access"
    vm_vlans            = "1030-1033"
    mac_pool_start      = "00:25:B5:63:00:01"
    mac_pool_end        = "00:25:B5:63:00:FF"
  }

  san_connectivity = {
    pwwn_pool_a_end   = "20:00:00:25:B5:63:A0:FE"
    pwwn_pool_a_start = "20:00:00:25:B5:63:A0:01"
    pwwn_pool_b_end   = "20:00:00:25:B5:63:B0:FE"
    pwwn_pool_b_start = "20:00:00:25:B5:63:B0:01"
    vsan_a_id         = 10
    vsan_a_vlan       = 1991
    vsan_b_id         = 20
    vsan_b_vlan       = 1992
    wwnn_pool_end     = "20:00:00:25:B5:63:00:FE"
    wwnn_pool_start   = "20:00:00:25:B5:63:00:01"
  }
}
