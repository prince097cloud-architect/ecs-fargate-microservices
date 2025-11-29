variable "region" {
type = string
default = "ap-south-1"
}


# variable "vpc_id" {
# type = string
# }


# variable "private_subnet_ids" {
# type = list(string)
# }


# variable "public_subnet_ids" {
# type = list(string)
# }
variable private_route_table_ids{
type = list(string)
}

variable "service_a_image" {
type = string
}


variable "service_b_image" {
type = string
}


variable "ecs_task_cpu" {
type = number
default = 512
}


variable "ecs_task_memory" {
type = number
default = 1024
}