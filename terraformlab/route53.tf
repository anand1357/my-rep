resource "aws_route53_zone" "route53" {
  name = "vanand7531.tk"

  tags = {
    Environment = "dev"
  }
}

resource "aws_route53_record" "route53" {
  zone_id = aws_route53_zone.route53.zone_id
  name    = "vanand7531.tk"
  type    = "A"
  ttl     = "60"
  records = [aws_eip.eip.public_ip]
} 

output "name_servers" {
  value = aws_route53_zone.route53.name_servers   
}
resource "aws_route53_health_check" "example" {
  fqdn              = "vanand.tk"
  port              = 80
  type              = "HTTP"
  resource_path     = "/index.html"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "tf-test-health-check"
  }
}