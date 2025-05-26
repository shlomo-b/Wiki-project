#---------------region-------------------#

variable "aws_region" {
  default = ["eu-central-1", "us-east-1"]
  type    = list(string)
}

#---------------vpcs------------------#

variable "vpcs" {
  type = map(object({
    cidr            = string
    private_subnets = list(string)
    public_subnets  = list(string)
    azs             = list(string)
    tags            = map(string)
  }))
}

#---------------sgs------------------#

variable "sgs" {
  type = map(object({
    tags = map(string)
    vpc_key                   = string
    description               = string
    ingress_cidr_blocks       = list(string)
    ingress_with_cidr_blocks = map(object({
      from_port   = number
      to_port     = number
      protocol    = string
      description = string
      cidr_blocks = string
    }))
  }))
}


#---------------acm------------------#

variable "acm" {
  type = map(object({
    domain_name     = list(string)
    tags            = map(string)
  }))
}

#---------------route53------------------#

variable "route53" {
  type = map(object({
    name    = list(string)
    type    = string
    records = list(string)
    ttl     = number
    tags    = map(string)
  }))
}

#---------------cluster-eks------------------#

variable "cluster_name" {
  default = "my-cluster"
  type = string
}

variable "cluster_version" {
  default = "1.32"
  type = string
}

variable "cluster_service_ipv4_cidr" {
  default = "10.200.0.0/16"
  type = string
}

variable "instance_types" {
  default = ["m5.large"]
  type = list(string)
}

variable "min_size" {
  default = 1
  type = number
}

variable "max_size" {
  default = 5
  type = number
}

variable "desired_size" {
  default = 1
  type = number
  
}
#----------------DB CREDENTIALS------------------#

# variable "MONGO_INITDB_ROOT_USERNAME" {
#   description = "Database root username"
#   type        = string
#   default = "value"
#   sensitive = true
# }

# variable "MONGO_INITDB_ROOT_PASSWORD" {
#   description = "Database root password"
#   type        = string
#   sensitive   = true
#   default = "value"
# }