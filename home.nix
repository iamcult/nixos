{ config, pkgs, inputs, ... }:

{
  home.username = "cult";
  home.homeDirectory = "/home/cult";

  programs = {
    neovim = {
      enable = true;
    };

    git = {
      enable = true;
      userName = "iamcult";
      userEmail = "101368650+iamcult@users.noreply.github.com";
      extraConfig = {
        # Sign all commits using ssh key
        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingkey = "~/.ssh/id_ed25519.pub";
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    starship.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        alias nixos-version="nix profile history --profile /nix/var/nix/profiles/system | tail -2 | grep Version | rev | cut -c 20- | rev"
        alias commit-os="pushd ~/nixos; nixos-version | ansi2txt | git commit -a -F - ; popd"
        alias rebuild-os="doas nixos-rebuild switch --flake ~/nixos#thing && commit-os"
        alias update-os="if git diff-index --quiet HEAD -- ; echo "Nothing to do."; else; nix flake update ~/nixos && doas nixos-rebuild switch --flake ~/nixos#thing && commit-os; end"
        alias push-os="pushd ~/nixos; git push; popd"
        alias clear="clear && pfetch"
        pfetch
        starship init fish | source
      '';
    };

    vscode = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    firefox
    pfetch
    vesktop
    spotify
    prismlauncher
    thunderbird

    via
    nix-index
    xorg.setxkbmap
    python3
    catppuccin-papirus-folders
    colorized-logs
    kdePackages.qtmultimedia
  ];

  home.stateVersion = "23.11";
}
