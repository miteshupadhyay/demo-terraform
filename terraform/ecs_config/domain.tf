#--------------------------------------------------------------------------------------
# Below entire configuration is to create Domain Certificate/HTTPS Certificate.
# that'll be used for ALB/Cluster.
# Also we will be adding validation to the Domain, so that Certificates are going
# to be valid and Secure on browser , when will try to reach our services from internet.
#---------------------------------------------------------------------------------------

resource "aws_acm_certificate" "ecs_domain_certificate" {
  domain_name       = "*.${var.ecs_domain_name}"
  validation_method = "DNS"

  tags = {
    Name = "${var.ecs_cluster_name}.${"-Certificate"}"
    environment =var.env_name
  }
}

#--------------------------------------------------------------------------------------
# Below entire configuration is to get the Zone Id of the domain that we have registered
# in Route 53.
#--------------------------------------------------------------------------------------

data "aws_route53_zone" "ecs_domain"{
  name         = var.ecs_domain_name
  private_zone = false
}

#---------------------------------------
# Create a Route53 Record for the Domain.
#---------------------------------------

resource "aws_route53_record" "ecs_cert_validation_record" {
  for_each = {
  for ecs in aws_acm_certificate.ecs_domain_certificate.domain_validation_options : ecs.domain_name => {
    name   = ecs.resource_record_name
    record = ecs.resource_record_value
    type   = ecs.resource_record_type
  }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.ecs_domain.zone_id
}

resource "aws_acm_certificate_validation" "ecs_domain_certificate_validation" {
  certificate_arn         = aws_acm_certificate.ecs_domain_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.ecs_cert_validation_record : record.fqdn]
}