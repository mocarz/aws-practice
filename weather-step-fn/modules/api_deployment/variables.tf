variable "rest_api_id" {
  type = string
}

variable "redeployment" {
  type = string
}

variable "variables" {
  type = object({
    arn = string
  })
}

# variable "machine_arn" {
#   type = string
# }
