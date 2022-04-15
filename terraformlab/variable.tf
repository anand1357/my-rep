variable "region" {
    default = "us-east-1"
}
variable "vpc_cidr" {
  default = "192.172.0.0/16"
}    
variable "subnet_cidr" {
  default = "192.172.1.0/24"  
}
variable "azs" {
  default = "us-east-1a"
}
