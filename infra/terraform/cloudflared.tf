data "cloudflare_zones" "my_zone" {
  name = var.domain
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "cloudflared_tunnel" {
  account_id = one(data.cloudflare_zones.my_zone.result).account.id
  name       = local.name
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "config" {
  account_id = one(data.cloudflare_zones.my_zone.result).account.id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id

  config = {
    ingress = [{
      hostname = "voting.${var.domain}"
      service  = "http://kubevote-vote:80"
      }, {
      hostname = "result.${var.domain}"
      service  = "http://kubevote-result:80"
      }, {
      hostname = "argocd.${var.domain}"
      service = "https://argocd-server.argocd.svc.cluster.local"
      }, {
        service = "http_status:404"
      }
    ]
  }
}

resource "cloudflare_dns_record" "result_dns_record" {
  zone_id = one(data.cloudflare_zones.my_zone.result).id
  name    = "result.${var.domain}"
  ttl     = 1
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id}.cfargotunnel.com"
  proxied = true
}

resource "cloudflare_dns_record" "vote_dns_record" {
  zone_id = one(data.cloudflare_zones.my_zone.result).id
  name    = "voting.${var.domain}"
  ttl     = 1
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id}.cfargotunnel.com"
  proxied = true
}

resource "cloudflare_dns_record" "argocd_dns_record" {
  zone_id = one(data.cloudflare_zones.my_zone.result).id
  name    = "argocd.${var.domain}"
  ttl     = 1
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id}.cfargotunnel.com"
  proxied = true
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "example_zero_trust_tunnel_cloudflared_token" {
  account_id = one(data.cloudflare_zones.my_zone.result).account.id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id
}

resource "kubernetes_secret_v1" "cloudflared" {
  metadata {
    name = "tunnel-token"
  }
  data = {
    token = data.cloudflare_zero_trust_tunnel_cloudflared_token.example_zero_trust_tunnel_cloudflared_token.token
  }
}
