{ config, pkgs, ... }:
{
  systemd.services.tiponero-landing = {
    description = "Tiponero landing page deployment";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.git ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ -d /var/lib/tiponero-landing/.git ]; then
        ${pkgs.git}/bin/git -C /var/lib/tiponero-landing pull --ff-only
      else
        ${pkgs.git}/bin/git clone https://github.com/tiponero/tiponero-landing /var/lib/tiponero-landing
      fi
    '';
  };

  services.nginx.virtualHosts."tiponero.org" = {
    serverAliases = [ "www.tiponero.org" ];
    root = "/var/lib/tiponero-landing";
    locations."/" = {
      tryFiles = "$uri $uri/ =404";
    };
  };
}
