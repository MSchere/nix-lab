{ config, pkgs, ... }:
{
  age.secrets.monero-rpc = {
    file = ./secrets/monero-rpc.age;
    mode = "0440";
    group = "monero";
  };

  age.secrets.wallet-password = {
    file = ./secrets/wallet-password.age;
    mode = "0400";
    owner = "monero";
  };

  services.monero = {
    enable = true;
    rpc = {
      address = "127.0.0.1";
      user = "$MONERO_RPC_USER";
      password = "$MONERO_RPC_PASSWORD";
    };
    extraConfig = ''
      db-sync-mode=safe
      prune-blockchain=1
    '';
    # envsubst replaces $MONERO_RPC_USER / $MONERO_RPC_PASSWORD at service start
    environmentFile = config.age.secrets.monero-rpc.path;
  };

  systemd.services.monero-wallet-rpc = {
    description = "Monero Wallet RPC";
    after = [ "monero.service" ];
    wants = [ "monero.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "monero";
      WorkingDirectory = "/var/lib/monero";
      EnvironmentFile = config.age.secrets.monero-rpc.path;
      ExecStart = pkgs.writeShellScript "monero-wallet-rpc-start" ''
        exec ${pkgs.monero-cli}/bin/monero-wallet-rpc \
          --rpc-bind-ip=127.0.0.1 \
          --rpc-bind-port=18083 \
	  --rpc-login "$MONERO_RPC_USER:$MONERO_RPC_PASSWORD" \
	  --daemon-login "$MONERO_RPC_USER:$MONERO_RPC_PASSWORD" \
          --daemon-address=127.0.0.1:18081 \
          --wallet-file=/var/lib/monero/wallet \
	  --password-file ${config.age.secrets.wallet-password.path} \
          --non-interactive
      '';
      Restart = "on-failure";
    };
  };
}
