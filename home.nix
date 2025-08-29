{ config, pkgs, ... }:
{
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Neueste Versionen, direkt von Nix
    vscode
    neovim
    git
    gh
    ripgrep
  ];

  programs.git = {
    enable = true;
    userName = "Bach Le Viet";
    userEmail = "bleviet@email.com";
  };

  # Weitere Konfigurationen...
}