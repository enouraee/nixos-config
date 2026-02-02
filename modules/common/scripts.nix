# modules/common/scripts.nix
# Custom scripts available in PATH
{ pkgs, ... }:

let
  # Health check script wrapper
  health-check = pkgs.writeShellScriptBin "health-check" ''
    exec ${pkgs.bash}/bin/bash /etc/nixos/scripts/health-check.sh "$@"
  '';
in
{
  environment.systemPackages = [
    health-check
  ];

  # Ensure scripts directory is copied to /etc/nixos
  # (This happens automatically when you copy your config during install)
}
