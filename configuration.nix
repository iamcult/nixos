# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];

  boot.kernelPackages = # idk how this works
    with builtins; with lib; let
      latestCompatibleVersion = config.boot.zfs.package.latestCompatibleLinuxPackages.kernel.version;
      zenPackages = filterAttrs (name: packages: hasSuffix "_zen" name && (tryEval packages).success) pkgs.linuxKernel.packages;
      compatiblePackages = filter (packages: compareVersions packages.kernel.version latestCompatibleVersion <= 0) (attrValues zenPackages);
      orderedCompatiblePackages = sort (x: y: compareVersions x.kernel.version y.kernel.version > 0) compatiblePackages;
    in head orderedCompatiblePackages;

  networking.hostId = "e5a29261";
  
  nixpkgs.config.allowUnfree = true;

  environment.persistence."/persist" = {
    hideMounts = true;
    files = [
      "/etc/machine-id"
    ];
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/fprint"
      #"/var/lib/sddm"
      "/etc/NetworkManager/system-connections"
      "/etc/secureboot"
      "/etc/mullvad-vpn"
    ];
  };

  zramSwap.enable = true;

  networking.hostName = "thing"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "America/New_York";

  age.secrets.password.file = ./secrets/password.age;

  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = false;
  security.pam.services.gdm-fingerprint.fprintAuth = true;

  users.mutableUsers = false;
  users.users.cult = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    hashedPasswordFile = config.age.secrets.password.path;
  };
  programs.fish.enable = true;

  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [{
    groups = ["wheel"];
    keepEnv = true;  # Optional, retains environment variables while running commands
    persist = true;  # Optional, only require password verification a single time
  }];

  environment.systemPackages = with pkgs; [
    git
    sbctl
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true;
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    desktopManager.plasma6.enable = true;

    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    printing.enable = true;
    xserver.xkb.variant = "colemak";
  };


  console = {
    earlySetup = true;
    keyMap = "colemak";
  };

  programs.kdeconnect.enable = true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 30d";
  };

  services.openssh.enable = true;
  system.stateVersion = "24.05"; # Did you read the comment?
}
