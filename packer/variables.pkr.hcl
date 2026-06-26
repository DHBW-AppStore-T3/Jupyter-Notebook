########################################
# Platform-Contract-Variablen (vom Worker/Platform gesetzt)
########################################

variable "image_name" {
  type        = string
  description = "Glance-Image-Name – vom Worker zur Build-Zeit gesetzt. @platform:internal"
}

variable "networks" {
  type        = list(string)
  description = "Netzwerk-UUIDs für Build-VM @openstack:network:id:list"
  default     = ["4971e080-966d-485e-a161-3e2b7fefad53"]
}

variable "security_groups" {
  type        = list(string)
  description = "Security Groups für Build-VM @openstack:security_group:id:list"
  default     = ["4ffaf007-df66-4250-9118-1bd99378d34a"]
}
