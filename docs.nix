{ config, pkgs, ... }:
{
  systemd.services.tiponero-docs = {
    description = "Tiponero docs deployment";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      NEEDS_BUILD=0

      if [ -d /var/lib/tiponero-docs/.git ]; then
        BEFORE=$(${pkgs.git}/bin/git -C /var/lib/tiponero-docs rev-parse HEAD)
        ${pkgs.git}/bin/git -C /var/lib/tiponero-docs pull --ff-only
        AFTER=$(${pkgs.git}/bin/git -C /var/lib/tiponero-docs rev-parse HEAD)
        if [ "$BEFORE" != "$AFTER" ]; then
          NEEDS_BUILD=1
        fi
      else
        ${pkgs.git}/bin/git clone https://github.com/tiponero/tiponero-docs /var/lib/tiponero-docs
        NEEDS_BUILD=1
      fi

      # Also build if the build output doesn't exist yet
      if [ ! -d /var/lib/tiponero-docs/build ]; then
        NEEDS_BUILD=1
      fi

      if [ "$NEEDS_BUILD" = "1" ]; then
        cd /var/lib/tiponero-docs
        ${pkgs.nodejs_24}/bin/npm install
        ${pkgs.nodejs_24}/bin/npm run build
      fi
    '';
  };

  services.nginx.virtualHosts."docs.tiponero.org" = {
    root = "/var/lib/tiponero-docs/build";
    locations."/" = {
      tryFiles = "$uri $uri/ =404";
    };
  };
}
