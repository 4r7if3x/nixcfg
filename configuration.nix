{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable NTFS file-system
  boot.supportedFilesystems = [ "ntfs" ];

  # Register AppImage binaries
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  # Enable networking
  networking.hostName = "sam-laptop";
  networking.networkmanager.enable = true;

  # Enable Containerizers
  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    podman = {
      enable = true;
      dockerCompat = false;
      defaultNetwork.settings.dns_enabled = true;
    };
    libvirtd.enable = true;
  };
  programs.virt-manager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sam = {
    isNormalUser = true;
    description = "Sam Ariafar";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
      chromium
      cloudflare-warp
      cryptomator
      firefox
      firefox-devedition-bin
      gitkraken
      jetbrains-toolbox
      kleopatra
      metadata-cleaner
      popcorntime
      rustup
      vlc
      xarchiver
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    appimage-run
    aria
    bc
    bore-cli
    btop
    distrobox
    eyedropper
    fish
    freerdp
    git
    gnome.dconf-editor
    gnome.gnome-terminal
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.hide-activities-button
    gnomeExtensions.night-theme-switcher
    gnomeExtensions.top-bar-organizer
    gnomeExtensions.tophat
    htop
    kitty
    magic-wormhole
    man
    mr
    ncdu
    neofetch
    ntfs3g
    nushell
    tldr
    wget
    zellij
    zsh-powerlevel10k
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-console
    gnome-tour
    gnome.epiphany
    gnome.geary
    gnome.gnome-contacts
    gnome.gnome-maps
    gnome.yelp
  ];

  # Some programs need SUID wrappers, can be configured further or are started in user sessions.

  # Enable Flatpak
  services.flatpak.enable = true;

  # Setting default shell
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  # Enable MTR
  programs.mtr.enable = true;

  # Enable GnuPG
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Enable Auto-upgrade
  system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = true;
  # system.autoUpgrade.channel  = https://nixos.org/channels/nixos-23.05;

  # Register WARP service
  systemd.services = {
    warp-svc = {
      description = "Cloudflare WARP Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
        Restart = "always";
        User = "root";
      };
    };
    # aria2 = {
    #   description = "Aria2 Service";
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.aria}/bin/aria2c";
    #     Restart = "always";
    #     User = "sam";
    #   };
    # };
  };

  environment.sessionVariables = rec {
    XDG_DATA_DIRS = [
      "/var/lib/flatpak/exports/share"
    ];
    PATH = [
      "$HOME/.local/share/JetBrains/Toolbox/scripts"
    ];
    LIBVIRT_DEFAULT_URI = "qemu:///system";
  };
}
