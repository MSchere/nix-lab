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
      allowedTCPPorts = [ 22 80 3000 8080 18080 18081 18082 18083 ];
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
