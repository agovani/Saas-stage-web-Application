resource "aws_acm_certificate" "cloudflare_origin" {
  private_key      = file("${path.module}/certs/mortgageabskey.key")
  certificate_body = file("${path.module}/certs/mortgageabscerts.pem")

}
