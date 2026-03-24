{ lib, pkgs }:

pkgs.caddy.withPlugins {
  plugins = [
    "github.com/RussellLuo/caddy-ext/ratelimit@v0.3.0"
    "github.com/RussellLuo/caddy-ext/requestbodyvar@v0.1.0"
    "github.com/WingLim/caddy-webhook@v1.0.8"
    "github.com/aksdb/caddy-cgi/v2@v2.2.7"
    "github.com/caddyserver/replace-response@v0.0.0-20250618171559-80962887e4c6"
    "github.com/caddyserver/transform-encoder@v0.0.0-20260219205817-c7997996a425"
    "github.com/corazawaf/coraza-caddy/v2@v2.2.0"
    "github.com/cubic3d/caddy-quantity-limiter@v1.0.0"
    "github.com/greenpau/caddy-security@v1.1.45"
    "github.com/mholt/caddy-hitcounter@v1.0.0"
    "github.com/mholt/caddy-l4@v0.1.0"
    "github.com/shift72/caddy-geo-ip@v0.6.0"
    "github.com/ueffel/caddy-basic-auth-filter@v1.0.1"
    "pkg.jsn.cam/caddy-defender@v0.10.0"
  ];
  hash = "sha256-smkuDJTQs8vIUJ/5e3A4rEcEcF/jZyrInnQ/8YL1PXo=";
}
