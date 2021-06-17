
# This should not be a variable, move it to local
variable "instance_type" {
  description = "Add a description"
  default = "t2.micro"
  type = string
}

# What is it?
variable "ssh_key_name" {
}


variable "instance_name" {
  default = "Im alive baby"
}

# If it's a variable, why you put here a default value?, if you are using default value it should be on local on main.tf
variable "region_name" {
  default = "us-east-2"
}

