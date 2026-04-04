{ config, pkgs, ... }:
{
  age.secrets.cloudflare-tunnel = {
    file = ./secrets/cloudflare-tunnel.age;
    owner = "cloudflared";
    mode = "0400";
  };

  users.users.cloudflared = {
    isSystemUser = true;
    group = "cloudflared";
    home = "/var/lib/cloudflared";
    createHome = true;
  };
  users.groups.cloudflared = {};

  services.cloudflared = {
    enable = true;
    tunnels."e3e7192f-71e9-4a8b-b8f4-106860c4feed" = {
      credentialsFile = config.age.secrets.cloudflare-tunnel.path;
      ingress = {
        "demo.tiponero.org" = "http://127.0.0.1:3001";
      };
      default = "http_status:404";
    };
  };
}
