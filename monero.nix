{ config, pkgs, ... }:
{
  age.secrets.monero-rpc = {
    file = ./secrets/monero-rpc.age;
    mode = "0440";
    group = "monero";
  };

  services.monero = {
    enable = true;
    rpc = {
      address = "127.0.0.1";
      user = "$MONERO_RPC_USER";
      password = "$MONERO_RPC_PASSWORD";
    };
    extraConfig = ''
      prune-blockchain=1
      db-sync-mode=safe
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
          --rpc-login="$MONERO_RPC_USER:$MONERO_RPC_PASSWORD" \
          --daemon-address=127.0.0.1:18081 \
          --daemon-login="$MONERO_RPC_USER:$MONERO_RPC_PASSWORD" \
          --wallet-file=/var/lib/monero/wallet \
          --password-file=/var/lib/monero/wallet.passwd \
          --non-interactive
      '';
      Restart = "on-failure";
    };
  };
}
