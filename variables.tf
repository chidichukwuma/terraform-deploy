variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnet for VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnet for VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  description = "AZs for VPC"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "vpn_gateway_availability_zone" {
  description = "AZs for VPN Gateway"
  type        = string
  default     = "us-west-2a"
}