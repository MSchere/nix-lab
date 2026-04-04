{ config, pkgs, tiponero, ... }:

let
  tiponeroPkg = tiponero.packages.${pkgs.system}.default;
in {
  age.secrets.tiponero = {
    file = ./secrets/tiponero.age;
    owner = "tiponero";
    mode = "0400";
  };

  users.users.tiponero = {
    isSystemUser = true;
    group = "tiponero";
    home = "/var/lib/tiponero";
    createHome = true;
  };
  users.groups.tiponero = {};

  systemd.services.tiponero = {
    description = "Tiponero - Monero donation platform";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "monero-wallet-rpc.service" ];
    wants = [ "monero-wallet-rpc.service" ];
    serviceConfig = {
      Type = "simple";
      User = "tiponero";
      Group = "tiponero";
      WorkingDirectory = "/var/lib/tiponero";
      EnvironmentFile = config.age.secrets.tiponero.path;
      ExecStart = "${tiponeroPkg}/bin/tiponero";
      Restart = "on-failure";
      RestartSec = 10;
    };
    environment = {
      PORT = "3001";
      DATABASE_PATH = "/var/lib/tiponero/tiponero.db";
      MONERO_RPC_URL = "http://127.0.0.1:18083/json_rpc";
      FIAT_CURRENCY = "USD";
      REQUIRED_CONFIRMATIONS = "5";
      BASE_URL = "https://demo.tiponero.org";
    };
  };

  # No nginx vhost — cloudflared connects directly to port 3001
}
