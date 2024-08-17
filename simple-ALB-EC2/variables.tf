variable "ami_id" {}
variable "instance_type" {}


variable "public_subnet_cidrs" {
  type = list(string)

}


variable "private_subnet_cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}
