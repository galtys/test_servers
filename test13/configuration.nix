{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/profiles/minimal.nix>
    <nixpkgs/nixos/modules/virtualisation/container-config.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    ./build.nix
    ./networking.nix
  ];

  environment.systemPackages = with pkgs; [
    vim nodejs openvpn screen tmux git wget nmap
    (import  /root/emacs.nix { inherit pkgs; })
  ];

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  #users.extraUsers.root.openssh.authorizedKeys.keys =
  #  [ "..." ];

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=900s
  '';

  time.timeZone = "Europe/Prague";

  documentation.enable = true;
  documentation.nixos.enable = true;




  users.users.jan = {
     isNormalUser = true;
     home = "/home/jan";
     description = "Jan";
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     uid = 1000;
     openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGjW8vyQRsdU5yRF1Q/5CrIvxu7ga3pwGUSRd4unsZI5AQnrHvD+yjKu25Ug6ZcZtsvHM8FzgDaW26jRZ6CJ7Q/4IldnxBxDU6epFruoxegv6E/oNiAwGaj8xwdZ/g8+g5aHRbRN0PJeBQgBTKOHCZcv9DO1/dsz+eLPu1QfePsurLHWc9sI7v/iJtUPS3Lghwm/k5oYN2jDazeGcNMY0ZfGUThA2Adxx+PDgxcZ9b+zcy60nVFZwXbbWd4NUcZzBSF6WmrLVWzbcaxDTNx+qg/m9vmQdqIJYB5bfeIobPsNzMA8IhzsJxwwbPZ4KcHvWdU4LqMrBXU4owiGuqkdSf jan@galtys" ];
   };
  users.users.odoo = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGjW8vyQRsdU5yRF1Q/5CrIvxu7ga3pwGUSRd4unsZI5AQnrHvD+yjKu25Ug6ZcZtsvHM8FzgDaW26jRZ6CJ7Q/4IldnxBxDU6epFruoxegv6E/oNiAwGaj8xwdZ/g8+g5aHRbRN0PJeBQgBTKOHCZcv9DO1/dsz+eLPu1QfePsurLHWc9sI7v/iJtUPS3Lghwm/k5oYN2jDazeGcNMY0ZfGUThA2Adxx+PDgxcZ9b+zcy60nVFZwXbbWd4NUcZzBSF6WmrLVWzbcaxDTNx+qg/m9vmQdqIJYB5bfeIobPsNzMA8IhzsJxwwbPZ4KcHvWdU4LqMrBXU4owiGuqkdSf jan@galtys" ];

   };
  security.sudo.wheelNeedsPassword = false;

  environment.variables.EDITOR="emacs -nw";

  services.postgresql = {
     enable = true; 
    package = pkgs.postgresql_10;
     # dataDir = "/pg/96";
     enableTCPIP = true;
     authentication = pkgs.lib.mkOverride 10 ''
       local all all trust
       host all all ::1/128 trust
       host all all 192.168.0.0/24 trust
     '';
     initialScript = pkgs.writeText "backend-initScript" ''
       CREATE ROLE jan WITH LOGIN PASSWORD 'your-secret-password' SUPERUSER;
     '';
  };


#trace: warning: config.services.nginx.virtualHosts.<name>.enableSSL is deprecated,
#use config.services.nginx.virtualHosts.<name>.onlySSL instead.



  
  security.acme.acceptTerms = true;  
  security.acme.certs = {
    "test13.galtys.com".email = "jan.troler@galtys.com";

  };

  services.nginx = {
    enable = true;
    virtualHosts."test13.galtys.com" = {
      onlySSL  = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8070";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;" +
          "proxy_set_header Host $host;" +
          "proxy_set_header Front-End-Https On;" +            
          "proxy_set_header X-Forwarded-Host $http_host;" +
          "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;" +
          "proxy_set_header X-Forwarded-Proto https;" +
          "proxy_set_header X-Real-IP $remote_addr;"

            
          ;
      };
      
    };
  };


  
  system.stateVersion = "20.03";
}
