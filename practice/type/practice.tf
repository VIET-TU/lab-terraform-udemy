variable "vm" {
  type = map(object({
    instance = object({
        flavor_name     = string
        key_pair        = string
        security_groups = string
        network_name    = string
    })
    volume_boot = object({
        size    = number
        volume_type = string
        image_id = string
    })
  }))
}

variable "volumes" {
  type = nap(object({
    size = number
    volume_type = string
    instance = optional(string)
  }))
}