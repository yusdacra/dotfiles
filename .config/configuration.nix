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
    networkmanager = {
      enable = true;
      dns = "none"; # We use stubby
    };
    useDHCP = false;
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

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  environment = {
    systemPackages = with pkgs; [
      curl git git-lfs
      mkpasswd
      kakoune htop
      ntfs3g
      profile-sync-daemon
      lm_sensors
    ];
    variables = {
      EDITOR = "kak";
    };
    shellAliases = {
      cat = "bat";
      config = dotConf;
      config-sync = "${dotConf} add ~/rember && ${dotConf} commit -a -m \"sync on `date`\" && ${dotConf} push";
      nixos-conf = "sudo kak /etc/nixos/configuration.nix";
      nosce = "nixos-conf";
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
        swaylock swayidle xwayland rofi wl-clipboard grim imv
      ];
    };
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      enableCompletion = true;
      enableGlobalCompInit = true;
      syntaxHighlighting.enable = true;
      histFile = "~/.zsh_history";
      histSize = 10000;
      ohMyZsh = {
        enable = true;
        plugins = [ "colored-man-pages" "per-directory-history" ];
        theme = "terminalparty";
      };
      interactiveShellInit = ''
      	  if [ -z "$TMUX" ]; then
              tmux
      	  fi

	  # ffmpeg-cut INPUT OUTPUT START_TIME DURATION
      	  ffmpeg-cut () {
              ffmpeg -ss $3 -i $1 -t $4 -c copy $2
          }
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
    	  set -g default-terminal 'xterm-256color'
    	  set -ga terminal-overrides ',*256col*:Tc'
    	  set -g status off
      ";
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "tty";
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
        alacritty
        exa neofetch
        firefox-wayland chromium spectral
        musikcube ffmpeg mpv python38Packages.youtube-dl-light playerctl lmms krita
        kak-lsp ripgrep bat universal-ctags
        clang_10 llvmPackages.bintools
    	# nixFlakes
    	rust-analyzer rustc cargo clippy rustfmt cargo-watch hyperfine
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
