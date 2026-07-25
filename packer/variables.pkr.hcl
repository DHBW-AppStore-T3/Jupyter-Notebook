########################################
# Platform Contract Variables (set by Worker/Platform)
########################################

variable "image_name" {
  type        = string
  description = "Glance image name – set by the worker at build time. @platform:internal"
}

variable "networks" {
  type        = list(string)
  description = "Network UUIDs for the build VM @openstack:network:id:list"
  default     = ["4971e080-966d-485e-a161-3e2b7fefad53"]
}

variable "security_groups" {
  type        = list(string)
  description = "Security groups for the build VM @openstack:security_group:id:list"
  default     = ["4ffaf007-df66-4250-9118-1bd99378d34a"]
}
