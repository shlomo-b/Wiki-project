#---------------security_group-------------------#

module "sgs" {
  for_each = var.sgs
  source   = "terraform-aws-modules/security-group/aws"
  version  = "5.3.0"

  name        = each.key
  description = each.value.description
  vpc_id      = module.vpc[each.value.vpc_key].vpc_id # retune the value of the vpss , and take the vpc_id

  ingress_cidr_blocks = each.value.ingress_cidr_blocks
  ingress_with_cidr_blocks = [
    for rule in each.value.ingress_with_cidr_blocks : # for each all the values in ingress_with_cidr_blocks from file tfvars
    {
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      description = rule.description
      cidr_blocks = rule.cidr_blocks
    }
  ]
  # egress default rule
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "default egress"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}