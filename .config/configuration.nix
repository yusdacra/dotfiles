{ config, pkgs, ... }:

let
  # Functions used in config
  addIf = x: y: if x then y else null;
  dotConf = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";

  # Personal data
  userName = "yusuf";
  userRealName = "Yusuf Bera Ertan";
  userEmail = "y.bera003.06@protonmail.com";

  # Options
  enable32Bit = false;
  
  useXorg = false; # False means wayland
  
  useKakoune = true; # Implies useCliTools
  useCliTools = useKakoune || true;

  useMediaProd = true;
  useAudioProd = useMediaProd && true;
  useVideoProd = useMediaProd && true;
  useMultimedia = true;

  useNextDns = true;
  nextDnsId = "75e43d";

  useRust = true;
in

{
  nix.trustedUsers = [ "@wheel" ]; # wheel can already edit this file so...
    
  nixpkgs.config = {
    firefox.enablePlasmaBrowserIntegration = true;
  };
    
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_5_7;
    kernelParams = [ "mitigations=off" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    tmpOnTmpfs = true;
  };

  # Set this to true for CPUs with hyperthreading (so anything that's not poor)
  security.allowSimultaneousMultithreading = false;

  networking = {
    hostName = "yusuf-pc";
    networkmanager = {
      enable = true;
      dns = if useNextDns then "none" else "internal"; # We use stubby
    };
    useDHCP = false;
  };

  i18n = {
    defaultLocale = "tr_TR.UTF-8";
  };
  
  console = {
    font = "7x14";
    keyMap = "trq";
  };

  time.timeZone = "Turkey";

  sound.enable = true;
  hardware = {
    opengl = {
      driSupport = true;
      driSupport32Bit = enable32Bit;
      enable = true;
      extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau libva vulkan-loader ];
      extraPackages32 = addIf enable32Bit (with pkgs.pkgsi686Linux; [ libvdpau-va-gl vaapiVdpau libva vulkan-loader ]);
    };
    pulseaudio = {
      enable = true;
      support32Bit = enable32Bit;
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  environment = {
    homeBinInPath = true;
    systemPackages = with pkgs; [
      curl git git-lfs
      mkpasswd
      htop
      ntfs3g
      profile-sync-daemon
      lm_sensors
    ];
    shellAliases = {
      cat = "bat"; # The cat died :cry:
      la = "exa --long --grid --git -a";
      ls = "exa";
      l = "ls";
      ydl-music = "youtube-dl --embed-thumbnail --extract-audio --audio-format ogg --add-metadata";

      config = dotConf;
      config-sync = "${dotConf} add ~/rember && ${dotConf} commit -a -m \"sync on `date`\" && ${dotConf} push";
      rember = "kak -e gtd-jump-today ~/rember/stuff`date '+-%m-%Y'`.gtd";
      
      nixos-conf = "sudo kak /etc/nixos/configuration.nix";
      nixos-list-generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      nosrs = "sudo nixos-rebuild switch";
      nosrb = "sudo nixos-rebuild boot";
      noslg = "nixos-list-generations";
      nosce = "nixos-conf";

      tmux = "tmux new-session -d -s \>_ 2>/dev/null; tmux new-session -t \>_ \; set-option destroy-unattached";
    };
    variables = {
      EDITOR = "kak";
    };
  };

  services.xserver = {
    desktopManager.plasma5.enable = useXorg;
    displayManager.sddm = {
        autoLogin = { enable = true; user = "yusuf"; };
        enable = useXorg;
    };
    enable = useXorg;
    layout = "tr";
    videoDrivers = [ "amdgpu" ];
  };

  programs = {
    sway = {
      enable = !useXorg;
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
              exec ${if useXorg then "startplasma-x11" else "sway"}
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
      extraConfig = ''
    	  set -g default-terminal 'xterm-256color'
    	  set -ga terminal-overrides ',*256col*:Tc'
    	  set -g status off
      '';
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = if useXorg then "qt" else "tty";
    };
  };

  services = {
    stubby = {
      enable = useNextDns;
      roundRobinUpstreams = false;
      upstreamServers = ''
          - address_data: 45.90.28.0
            tls_auth_name: "${nextDnsId}.dns1.nextdns.io"
          - address_data: 2a07:a8c0::0
            tls_auth_name: "${nextDnsId}.dns1.nextdns.io"
          - address_data: 45.90.30.0
            tls_auth_name: "${nextDnsId}.dns2.nextdns.io"
          - address_data: 2a07:a8c1::0
            tls_auth_name: "${nextDnsId}.dns2.nextdns.io"
      '';
    };
    psd.enable = true;
  };

  users = with pkgs; {
    mutableUsers = false;
    users.yusuf = {
      isNormalUser = true;
      home = "/home/yusuf";
      extraGroups = [ "wheel" ];
      packages =
        addIf useAudioProd [lmms audacity] ++
        addIf useCliTools [alacritty exa neofetch hyperfine ripgrep bat] ++
        [(firefox.overrideAttrs (oldAttrs: rec {
          enableOfficialBranding = false;
          gssSupport = false;
          privacySupport = true;
        }))] ++
        addIf useKakoune [kakoune kak-lsp universal-ctags] ++
        addIf useMediaProd [ffmpeg youtube-dl] ++
        addIf useMultimedia [mpv musikcube playerctl] ++
    	addIf useRust [rust-analyzer rustc cargo clippy rustfmt cargo-watch] ++
        addIf useVideoProd [kdenlive];
      shell = zsh;
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
