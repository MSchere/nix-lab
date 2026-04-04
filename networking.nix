{ config, pkgs, ... }: {
  networking = {
    hostName = "nix-lab";
    useDHCP = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.10.150";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.10.1";
    nameservers = [ "192.168.10.176" "10.64.0.1" ];
    firewall = {
      enable = true;
      # 22    = SSH
      # 80    = spending-tracker (nginx)
      # 3000  = spending-tracker (direct)
      # 18080 = monerod P2P (blockchain sync)
      # Removed: 8080 (tiponero nginx), 18081-18083 (monero RPC — loopback only)
      # Cloudflare tunnel is outbound-only, no inbound port needed
      allowedTCPPorts = [ 22 80 3000 18080 ];
    };
  };
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
