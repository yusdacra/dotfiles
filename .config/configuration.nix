# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  ########################################

  # Allow unfree
  nixpkgs.config.allowUnfree = true;
  ########################################

  # Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_5_6;
  security.allowSimultaneousMultithreading = false;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "mitigations=off" ];
  ########################################

  networking.hostName = "yusuf-pc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp6s0.useDHCP = true;
  ########################################

  # Select internationalisation properties.
  i18n.defaultLocale = "tr_TR.UTF-8";
  console = {
    font = "7x14";
    keyMap = "trq";
  };
  time.timeZone = "Turkey";
  ########################################

  # caching dns server
  services.dnsmasq = {
    enable = true;
    servers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
   };

  services.earlyoom.enable = true;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemuPackage = pkgs.qemu_kvm;
    };
  };
  
  ########################################

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  # 32bit for steam
  hardware.pulseaudio.support32Bit = true;

  # OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau libva vulkan-loader ];
    # 32bit for steam
    driSupport32Bit = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libvdpau-va-gl vaapiVdpau libva vulkan-loader ];
  };
  ########################################

  # Enable xorg
  #services.xserver.enable = true;
  
  # Do NOT enable xdg.portal, causes gnome to freeze at startup for a while.
  #services.xserver.desktopManager.gnome3.enable = true;
  #environment.gnome3.excludePackages = with pkgs.gnome3; [
  #  cheese empathy evolution gnome-maps gnome-music gnome-online-accounts gnome-software
  #  gnome-photos gnome-contacts gnome-calendar gnome-characters gnome-clocks gnome-bluetooth
  #  folks epiphany geary totem gnome-weather gnome-terminal
  #];
  #services.xserver.displayManager.gdm = {
  #  enable = true;
  #  autoLogin = {
  #    enable = true;
  #    user = "yusuf";
  #  };
  #};

  # sway
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
        swaylock swayidle xwayland rofi alacritty wl-clipboard grim imv
    ];
    extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        # needs qt5.qtwayland in systemPackages
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
        # Arch wiki says so
        export BEMENU_BACKEND=wayland
        export MOZ_ENABLE_WAYLAND=1
    '';
    wrapperFeatures = {
      base = true;
      gtk = false;
    };
  };
  
  ########################################

  # Enable zsh
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "colored-man-pages" "per-directory-history" ];
      theme = "terminalparty";
    };
  };

  # Enable tmux
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    newSession = true;
    shortcut = "a";
    extraConfig = "
    	set -g default-terminal 'tmux-256color'
    	set -ga terminal-overrides ',*256col*:Tc'
    	set -g status off
    ";
  };

  # Enable java jdk and jre
  programs.java.enable = true;


  # Enable gnupg
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "tty";
  };

  # "force" disable geary & gnome-terminal
  # only relevant when gnome de is enabled
  programs.geary.enable = false;
  programs.gnome-terminal.enable = false;
 
  ########################################

  # Pin stuff that can break quick
  nixpkgs.overlays = [
    # Pinning individual packages that break on unstable.  Note we use an
    # overlay rather than updating the package in systemPackages so that the
    # configuration propogates to all options.
    (self: super: let
      nixosstable = import <nixos-stable> {
        config.allowUnfree = true;
      };
    in {
      steam = nixosstable.pkgs.steam;
      steam-run = nixosstable.pkgs.steam-run;
      lutris = nixosstable.pkgs.lutris;
    })
  ];
  #########################################

  # Packages that will be installed in system profile.
  environment = {
    systemPackages = with pkgs; [
      wget curl git git-lfs
      unzip unrar mkpasswd
      kakoune most htop
      ntfs3g
    ];
    variables = {
        EDITOR = "kak";
        PAGER = "most";
    };
  };
  #########################################

  # Turn off useradd etc. to gain better control
  users.mutableUsers = false;
  users.users.yusuf = {
    isNormalUser = true;
    home = "/home/yusuf";
    extraGroups = [ "wheel" "kvm" "docker" ];
    packages = with pkgs; [
        lutris steam steam-run wineWowPackages.staging # gaym shit
        exa neofetch
        firefox-wayland
        rustup
	cmus ffmpeg mpv python38Packages.youtube-dl-light playerctl
	kak-lsp ripgrep bat shellcheck fzf universal-ctags socat gdb perl clang_10 # kide dependency stuff
        lm_sensors virt-manager
    ];
    shell = pkgs.zsh;
    hashedPassword = "$6$0L/hdI/a$KPa9Hzd/k6Z3PcIuHuseqIcUE1.YjrPk2yUOLL3HdENKt01WxRd9LBadn6P5O6nWXVCH134ur1rvHmfgou7Gl/";
  };
  #########################################

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

