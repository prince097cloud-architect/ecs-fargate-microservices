provider "aws" {
region = var.region
}


# VPC configuration (updated with your actual VPC ID and CIDR)
# Provided VPC: vpc-05172adce96edf32c, CIDR: 10.0.0.0/16


variable "vpc_id" {
type = string
default = "vpc-05172adce96edf32c"
}


variable "vpc_cidr" {
type = string
default = "10.0.0.0/16"
}


# Subnets (replace YOUR_SUBNET_IDS with actual subnet IDs)
variable "private_subnet_ids" {
type = list(string)
default = [
"subnet-003ce1e2dc92eaae4", # replace
"subnet-0ce58b2e7acbeafd0", # replace
"subnet-0347005957612f5c2" # replace
]
}


variable "public_subnet_ids" {
type = list(string)
default = [
"subnet-055c7fd0a25c334cf", # replace
"subnet-0f838be41e48183a9", # replace
"subnet-08781efa3646caa0c" # replace
]
}