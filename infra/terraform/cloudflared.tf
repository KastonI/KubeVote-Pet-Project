resource "cloudflare_zero_trust_tunnel_cloudflared" "cloudflared_tunnel" {
  account_id = var.cloudflare_account_id
  name = local.name
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id

  config = {
    ingress = [{
      hostname = "voting.${var.domain}"
      service  = "http://kubevote-vote:80"
    }, {
      hostname = "result.${var.domain}"
      service  = "http://kubevote-result:80"
    },
    {
      service = "http_status:404"
    }
    ]
  }
}

resource "cloudflare_dns_record" "result_dns_record" {
  zone_id = "b1342eb18ae18cbe51d45a932df4f4c1"
  name = "result.${var.domain}"
  ttl = 1
  type = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id}.cfargotunnel.com"
  proxied = true
}

resource "cloudflare_dns_record" "vote_dns_record" {
  zone_id = "b1342eb18ae18cbe51d45a932df4f4c1"
  name = "voting.${var.domain}"
  ttl = 1
  type = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id}.cfargotunnel.com"
  proxied = true
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "example_zero_trust_tunnel_cloudflared_token" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id
}

resource "kubernetes_secret_v1" "cloudflared" {
  metadata {
    name      = "tunnel-token"
  }
  data = {
    token = data.cloudflare_zero_trust_tunnel_cloudflared_token.example_zero_trust_tunnel_cloudflared_token.token
  }
}
