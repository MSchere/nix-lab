{ config, pkgs, lib, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./spending-tracker.nix
    ./monero.nix
    ./tiponero.nix
    ./cloudflared.nix
    ./landing.nix
    ./docs.nix
  ];

  time.timeZone = "Europe/Madrid";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    vim htop git curl wget nodejs_24 pnpm openssl python3
  ];

  users.users.root.shell = pkgs.bash;

  system.stateVersion = "24.11";
}
