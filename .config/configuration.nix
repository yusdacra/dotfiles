{ config, pkgs, ... }:

let
  dotConf = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";

in
{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_testing;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "mitigations=off" ];
    tmpOnTmpfs = true;
  };

  security.allowSimultaneousMultithreading = false;

  networking = {
    hostName = "yusuf-pc";
    useDHCP = false;
    networkmanager = {
      enable = true;
      dns = "none"; # We use stubby (fuck everything else)
    };
  };

  i18n.defaultLocale = "tr_TR.UTF-8";
  console = {
    font = "7x14";
    keyMap = "trq";
  };
  time.timeZone = "Turkey";

  sound.enable = true;
  hardware = {
    pulseaudio.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau libva vulkan-loader ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      wget curl git git-lfs
      unzip mkpasswd
      kakoune htop
      ntfs3g compsize
      profile-sync-daemon
    ];
    variables = {
        EDITOR = "kak";
    };
    shellAliases = {
        config = dotConf;
        config-sync = "${dotConf} add ~/rember && ${dotConf} commit -a -m 'sync on $(date)' && ${dotConf} push";
        ydl = "youtube-dl --embed-thumbnail --extract-audio --audio-format mp3 --add-metadata";
        la = "exa --long --grid --git -a";
        ls = "exa";
        rember = "kak -e gtd-jump-today ~/rember/stuff`date '+-%m-%Y'`.gtd";
        nixos-list-generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
        nosrs = "sudo nixos-rebuild switch";
        nosrb = "sudo nixos-rebuild boot";
        noslg = "nixos-list-generations";
        tmux = "tmux new-session -d -s \>_ 2>/dev/null; tmux new-session -t \>_ \; set-option destroy-unattached";
    };
  };

  programs = {
    sway = {
      enable = true;
      extraPackages = with pkgs; [
        swaylock swayidle xwayland rofi alacritty wl-clipboard grim imv
      ];
      wrapperFeatures.base = true;
      # Needs `wrapperFeatures.base = true`
      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
      '';
    };
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "colored-man-pages" "per-directory-history" ];
        theme = "terminalparty";
      };
      interactiveShellInit = ''
      	  if [ -z "$TMUX" ]; then
              tmux
      	  fi
      '';
      loginShellInit = ''
       	  if [ "$(tty)" = "/dev/tty1" ]; then
              exec sway
          fi
      '';
    };
    tmux = {
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
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gtk2";
    };
  };

  services = {
    stubby = {
      enable = true;
      roundRobinUpstreams = false;
      upstreamServers = ''
        - address_data: 45.90.28.0
          tls_auth_name: "75e43d.dns1.nextdns.io"
        - address_data: 2a07:a8c0::0
          tls_auth_name: "75e43d.dns1.nextdns.io"
        - address_data: 45.90.30.0
          tls_auth_name: "75e43d.dns2.nextdns.io"
        - address_data: 2a07:a8c1::0
          tls_auth_name: "75e43d.dns2.nextdns.io"
      '';
    };
    psd.enable = true;
  };

  users = {
    mutableUsers = false;
    users.yusuf = {
      isNormalUser = true;
      home = "/home/yusuf";
      extraGroups = [ "wheel" ];
      packages = with pkgs; [
        exa neofetch
        firefox-wayland spectral
        musikcube ffmpeg mpv python38Packages.youtube-dl-light playerctl
        kak-lsp ripgrep bat universal-ctags
        clang_10 llvmPackages.bintools
    	lm_sensors
    	nixFlakes
    	rust-analyzer rustc cargo
    	godot
      ];
      shell = pkgs.zsh;
      hashedPassword = "$6$0L/hdI/a$KPa9Hzd/k6Z3PcIuHuseqIcUE1.YjrPk2yUOLL3HdENKt01WxRd9LBadn6P5O6nWXVCH134ur1rvHmfgou7Gl/";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
