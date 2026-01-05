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
      hostname = "vote.kastonl.live"
      service  = "http://localhost:8080"
    },
    {
      service = "http_status:404"
    }
    ]
  }
}
