variable "intersight_apikey" {
  description = "Intersight API Key"
  type        = string
}

variable "intersight_secretkey" {
  description = "Intersight API Secret"
  type        = string
}

variable "intersight_endpoint" {
  description = "Intersight API endpoint"
  type        = string
  default     = "https://www.intersight.com"
}

variable "organization" {
  type        = string
  description = "Intersight Organization name"
  default     = "default"
}

variable "prefix" {
  type        = string
  description = "Prefix used for objects created in Intersight"
}

variable "template_name" {
  type        = string
  description = "The template name describing the desired server layout"
  validation {
    condition     = contains(["esx7_bfs_4nic_mlom"], var.template_name)
    error_message = "Variable `template_name` must be one of [\"esx7_bfs_4nic_mlom\"]."
  }
}

variable "server_model" {
  type        = string
  description = "UCS server model"
  validation {
    condition     = contains(["m5", "m6"], var.server_model)
    error_message = "Variable `server_model` must be one of [\"m5\", \"m6\"]."
  }
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to Intersight objects"
}

variable "secure_boot" {
  type        = bool
  description = "Whether to enfore uefi secure boot"
  default     = false
}

variable "san_boot_targets" {
  description = "Boot from SAN settings"
  type = list(object({
    lun_id      = number
    switch_id   = string
    pwwn        = string
    device_name = string
  }))
  default = []
}

variable "imc_access" {
  description = "IMC Access details"
  type = object({
    vlan_id            = number
    ipv4_start_address = string
    ipv4_end_address   = string
    ipv4_gateway       = string
    ipv4_netmask       = string
    ipv4_dns           = list(string)
  })
  validation {
    condition     = length(var.imc_access.ipv4_dns) > 0 && length(var.imc_access.ipv4_dns) < 3
    error_message = "Attribute `ipv4_dns` must be between 1 and 2 entries."
  }
}

variable "user_password" {
  description = "Local user password for IMC"
  type        = string
  sensitive   = true
}

variable "lan_connectivity" {
  description = "LAN connectivity details"
  type = object({
    mgmt_interface_mode = string
    default_vlan        = number
    mgmt_vlan           = string
    vm_vlans            = string
    mac_pool_start      = string
    mac_pool_end        = string
  })
  validation {
    condition     = contains(["access", "trunk"], lower(var.lan_connectivity.mgmt_interface_mode))
    error_message = "Attribute `lan_connectivity` must be one of [\"access\", \"trunk\"]."
  }
}

variable "san_connectivity" {
  description = "SAN connectivity details"
  type = object({
    wwnn_pool_start   = string
    wwnn_pool_end     = string
    vsan_a_id         = number
    vsan_b_id         = number
    vsan_a_vlan       = number
    vsan_b_vlan       = number
    pwwn_pool_a_start = string
    pwwn_pool_a_end   = string
    pwwn_pool_b_start = string
    pwwn_pool_b_end   = string
  })
}
