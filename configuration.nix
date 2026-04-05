{ config, pkgs, lib, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./spending-tracker.nix
    ./monero.nix
    ./tiponero.nix
    ./cloudflared.nix
    ./landing.nix
  ];

  time.timeZone = "Europe/Madrid";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    vim htop git curl wget nodejs_22 pnpm openssl python3
  ];

  system.stateVersion = "24.11";
}
