{ config, pkgs, ... }:

let
  appDir = "/var/lib/spending-tracker/app";
  dataDir = "/var/lib/spending-tracker";
in {
  age.secrets.spending-tracker = {
    file = ./secrets/spending-tracker.age;
    owner = "spending-tracker";
    mode = "0400";
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureDatabases = [ "spending" ];
    enableTCPIP = true;
    ensureUsers = [{
      name = "spending";
      ensureDBOwnership = true;
    }];
    authentication = ''
      local spending spending trust
      host spending spending 127.0.0.1/32 trust
      host spending spending ::1/128 trust
    '';
  };

  users.users.root.shell = pkgs.bash;

  users.users.spending-tracker = {
    isSystemUser = true;
    group = "spending-tracker";
    home = dataDir;
    createHome = true;
  };
  users.groups.spending-tracker = {};

  systemd.services.spending-tracker = {
    description = "Spending Tracker";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "postgresql.service" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      Type = "simple";
      User = "spending-tracker";
      Group = "spending-tracker";
      WorkingDirectory = appDir;
      EnvironmentFile = config.age.secrets.spending-tracker.path;
      Restart = "on-failure";
      RestartSec = 10;
    };
    environment = {
      NODE_ENV = "production";
      PORT = "3000";
      HOSTNAME = "0.0.0.0";
      NEXT_TELEMETRY_DISABLED = "1";
      DATABASE_URL = "postgresql://spending@localhost:5432/spending";
      NEXTAUTH_URL = "http://192.168.10.150";
      AUTH_TRUST_HOST = "true";
      WISE_ENVIRONMENT = "production";
    };
    script = ''
      cd ${appDir}/.next/standalone
      exec ${pkgs.nodejs_22}/bin/node server.js
    '';
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    virtualHosts."_" = {
      default = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };
  };
}
