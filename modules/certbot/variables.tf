# certbot
variable "http_01_port" {
  type        = number
  default     = 80
  description = "Port used in the http-01 challenge"
  nullable    = false
}

variable "domain" {
  type        = string
  description = "Domain name"
  nullable    = false
}

variable "additional_domains" {
  type        = list(string)
  default     = []
  description = "Additional domain names"
  nullable    = false
}

variable "post_hook" {
  type = object(
    {
      path    = optional(string, "")
      content = optional(string, "")
      mode    = optional(string, "0755")
    }
  )
  description = "Post hook script"
  default = {
    path    = ""
    content = ""
    mode    = "0755"
  }
  nullable = false
}

variable "agree_tos" {
  type        = bool
  default     = false
  description = "Agree to the ACME server's Subscriber Agreement"
  nullable    = false
}

variable "staging" {
  type        = bool
  default     = true
  description = "Obtain a test certificate from a staging server"
  nullable    = false
}

variable "email" {
  type        = string
  description = "Email"
  nullable    = false
}

variable "before_units" {
  type        = list(string)
  default     = []
  description = "Units to add as \"Before\" in install unit definition"
  nullable    = false
}

variable "after_units" {
  type        = list(string)
  default     = []
  description = "Units to add as \"After\" in install unit definition"
  nullable    = false
}
