{ config, pkgs, ... }:

let
  # Functions used in config
  addIf = x: y: if x then y else null;
  dotConf = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";

  # Import sources
  sources = import ./nix/sources.nix { };
  crate2nix = import sources.crate2nix { };
  nur = import sources.nur { inherit pkgs; };

  # Personal data
  userName = "yusuf";
  userRealName = "Yusuf Bera Ertan";
  userEmail = "y.bera003.06@protonmail.com";
  nivGithubToken = builtins.readFile ./nix/token;

  # Options
  enable32Bit = false;
  useNextDns = true;
  nextDnsId = "75e43d";

in {
  nix.trustedUsers = [ "@wheel" ]; # wheel can already edit this file so...

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: { inherit nur; };
  };

  imports =
    [ "${sources.homeManager}/nixos/default.nix" ./hardware-configuration.nix ];

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
      dns = if useNextDns then
        "none"
      else
        "internal"; # We use stubby (expect when we dont)
    };
    useDHCP = false;
  };

  i18n = { defaultLocale = "tr_TR.UTF-8"; };

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
      extraPackages = with pkgs; [
        libvdpau-va-gl
        vaapiVdpau
        libva
        vulkan-loader
      ];
      extraPackages32 = addIf enable32Bit (with pkgs.pkgsi686Linux; [
        libvdpau-va-gl
        vaapiVdpau
        libva
        vulkan-loader
      ]);
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
    systemPackages = with pkgs; [
      curl
      mkpasswd
      htop
      ntfs3g
      profile-sync-daemon
      lm_sensors
    ];
    variables = {
      EDITOR = "kak";
      GITHUB_TOKEN = nivGithubToken;
    };
  };

  programs = {
    zsh = {
      shellAliases = {
        cat = "bat"; # The cat died :cry:
        la = "exa --long --grid --git -a";
        ls = "exa";
        l = "ls";
        ydl = "youtube-dl -x --embed-metadata";

        config = dotConf;
        config-sync = ''
          ${dotConf} add ~/rember && ${dotConf} commit -a -m "sync on `date`" && ${dotConf} push'';
        rember = "kak -e gtd-jump-today ~/rember/stuff`date '+-%m-%Y'`.gtd";

        nixos-conf = "$EDITOR /etc/nixos/configuration.nix";
        nixos-list-generations =
          "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
        nosrs = "sudo nixos-rebuild switch";
        nosrb = "sudo nixos-rebuild boot";
        noslg = "nixos-list-generations";
        nosce = "nixos-conf";
      };
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "colored-man-pages" "per-directory-history" ];
        theme = "terminalparty";
      };
      shellInit = ''
        # ffmpeg-cut INPUT OUTPUT START_TIME DURATION
        ffmpeg-cut () {
            ffmpeg -ss $3 -i $1 -t $4 -c copy $2
        }
      '';
      loginShellInit = ''
        if [ "$(tty)" = "/dev/tty1" ]; then
            exec "sway"
        fi
      '';
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "tty";
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
    users."${userName}" = {
      isNormalUser = true;
      home = "/home/${userName}";
      extraGroups = [ "wheel" ];
      shell = zsh;
      hashedPassword =
        "$6$0L/hdI/a$KPa9Hzd/k6Z3PcIuHuseqIcUE1.YjrPk2yUOLL3HdENKt01WxRd9LBadn6P5O6nWXVCH134ur1rvHmfgou7Gl/";
    };
    users."root".hashedPassword =
      "$6$qhmuKlM.q$FT7QhaddjAmHLcNcTJS2mFnWjK68G1c6S2PsB3959mcjV66tdBFQVjLgud13FPDLaCswtUBfRko6TWHcE.Yqg1";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${userName}" = { pkgs, ... }:
      let
        withDef = x: pkgs.lib.mkOptionDefault { } // x;

        githubUsername = "yusdacra";

        font = "Monoid Tight";
        fontSrc = pkgs.fetchzip {
          url =
            "https://raw.githubusercontent.com/larsenwork/monoid/2db2d289f4e61010dd3f44e09918d9bb32fb96fd/Monoid-Tight-NoCalt.zip";
          sha256 = "1j70gnj26zyy96ng65sfj25n90kfm3jh9m4knbdxrs1g736rghng";
          stripRoot = false;
        };

        wallpaper = pkgs.fetchurl {
          url =
            "https://initiate.alphacoders.com/download/wallpaper/1041382/images2/png/876092917964492";
          sha256 =
            "f315e6086da7462ef81712f88cdbc60b2328f5aa80310d2b126ffe69d37be463";
        };

        vomsColor = x: y: z: {
          main = x;
          sub = y;
          accent = z;
        };

        pikameeColors = vomsColor "ffeeb2" "273846" "40bcaf";
        tomoshikaColors = vomsColor "ff807e" "bcecf1" "ffe47a";
        monoeColors = vomsColor "3e4f65" "dae1ea" "ee707d";

        bgColor = pikameeColors.sub;
        fgColor = monoeColors.sub;
        acColor = pikameeColors.main;
        acColor2 = tomoshikaColors.main;

        # sway attrs reused
        focusedWorkspace = {
          background = "#${acColor}";
          border = "#${acColor}";
          text = "#${bgColor}";
        };
        activeWorkspace = {
          background = "#${bgColor}";
          border = "#${bgColor}";
          text = "#${fgColor}";
        };
        inactiveWorkspace = {
          background = "#${bgColor}";
          border = "#${bgColor}";
          text = "#${fgColor}";
        };
        urgentWorkspace = {
          background = "#${acColor2}";
          border = "#${acColor2}";
          text = "#${bgColor}";
        };
        fonts = [ "${font} 9" ];
      in {
        wayland.windowManager.sway = {
          enable = true;
          config = {
            inherit fonts;
            bars = [{
              colors = {
                background = "#${bgColor}";
                statusline = "#${fgColor}";
                inherit focusedWorkspace activeWorkspace inactiveWorkspace
                  urgentWorkspace;
              };
              command = "swaybar";
              inherit fonts;
              position = "top";
              extraConfig =
                "status_command while date +'%H:%M'; do sleep 1m; done";
            }];
            colors = {
              background = "#${bgColor}";
              focused = withDef focusedWorkspace;
              focusedInactive = withDef inactiveWorkspace;
              unfocused = withDef activeWorkspace;
              urgent = withDef urgentWorkspace;
            };
            menu = "${pkgs.rofi}/bin/rofi -show drun | swaymsg --";
            modifier = "Mod4";
            terminal = "${pkgs.alacritty}/bin/alacritty";
            keybindings = (let modifier = "Mod4";
            in pkgs.lib.mkOptionDefault {
              "${modifier}+q" = "kill";
              "Print" = ''
                exec --no-startup-id ${pkgs.grim}/bin/grim "$HOME/Resimler/shot_$(date '+%F-%T' | sed -e 's/[-:]/_/g').png"'';
              "XF86AudioRaiseVolume" =
                "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 +5%";
              "XF86AudioLowerVolume" =
                "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 -5%";
              "XF86AudioMute" =
                "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle";
              "XF86AudioPlay" =
                "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl play-pause";
              "XF86AudioPrev" =
                "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl previous";
              "XF86AudioNext" =
                "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl next";
              "XF86AudioStop" =
                "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl stop";
            });
            input = {
              "*" = {
                xkb_layout = "tr";
                accel_profile = "flat";
              };
            };
            output = {
              "*" = { bg = "/home/${userName}/.local/share/wallpaper fill"; };
            };
          };
        };

        home.packages = with pkgs; [
          (pkgs.steam.override { nativeOnly = true; }).run
          ripcord
          imv
          wl-clipboard
          lmms
          audacity
          kdenlive
          ffmpeg
          youtube-dl
          mpv
          musikcube
          playerctl
          exa
          neofetch
          hyperfine
          ripgrep
          bat
          nixfmt
          niv
          crate2nix
          rustup
          kakoune
        ];

        programs = {
          alacritty = {
            enable = true;
            settings = {
              font = {
                normal = { family = font; };
                size = 9;
              };
              colors = {
                primary = {
                  background = "0x${bgColor}";
                  foreground = "0x${fgColor}";
                };
              };
            };
          };

          firefox = {
            enable = true;
            package = pkgs.firefox.overrideAttrs (oldAttrs: rec {
              enableOfficialBranding = false;
              gssSupport = false;
              privacySupport = true;
            });
            profiles.primary = {
              name = "primary";
              settings = {
                "browser.uidensity" = 1;
                "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
                "identity.fxaccounts.toolbar.enabled" = false;
                "widget.wayland-dmabuf-vaapi.enabled" = true;
                "media.ffvpx.enabled" = false;
                "media.ffmpeg.enabled" = true;
                "gfx.webrender.all" = true;
                "gfx.webrender.enabled" = true;
                "extensions.pocket.enabled" = false;
                "reader.parse-on-load.enabled" = false;
              };
            };
            extensions = with pkgs.nur.repos.rycee.firefox-addons; [
              https-everywhere
              ublock-origin
              bitwarden
              decentraleyes
            ];
          };

          fzf = {
            enable = true;
            enableZshIntegration = true;
          };

          git = {
            aliases = {
              st = "status";
              ct = "commit";
              qct = "commit -am";
              co = "checkout";
              pl = "pull";
              ps = "push";
              a = "add";
            };
            enable = true;
            extraConfig = { pull.rebase = true; };
            lfs.enable = true;
            signing = {
              key = "927066BD8125A45B4AC4032661807181F60EFCB2";
              signByDefault = true;
            };
            userName = userRealName;
            inherit userEmail;
          };

          rofi = {
            enable = true;
            colors = {
              window = {
                background = "#${bgColor}";
                border = "#${bgColor}";
                separator = "#${bgColor}";
              };
              rows = {
                normal = {
                  background = "#${bgColor}";
                  foreground = "#${fgColor}";
                  backgroundAlt = "#${bgColor}";
                  highlight = {
                    background = "#${acColor}";
                    foreground = "#${bgColor}";
                  };
                };
              };
            };
            font = "${font} 9";
            separator = "none";
            terminal = "${pkgs.alacritty}/bin/alacritty";
          };
        };

        xdg = {
          enable = true;
          dataFile = {
            "fonts/Monoid-Bold-Tight-NoCalt.ttf".source =
              "${fontSrc}/Monoid-Bold-Tight-NoCalt.ttf";
            "fonts/Monoid-Regular-Tight-NoCalt.ttf".source =
              "${fontSrc}/Monoid-Regular-Tight-NoCalt.ttf";
            "fonts/Monoid-Italic-Tight-NoCalt.ttf".source =
              "${fontSrc}/Monoid-Italic-Tight-NoCalt.ttf";
            "fonts/Monoid-Retina-Tight-NoCalt.ttf".source =
              "${fontSrc}/Monoid-Retina-Tight-NoCalt.ttf";
            "wallpaper".source = wallpaper;
          };
          configFile = {
            "kak/".source = sources.kide;
            "kak-lsp/kak-lsp.toml".text = ''
              snippet_support = true
              verbosity = 2

              [semantic_scopes]
              variable = "variable"
              entity_name_function = "function"
              entity_name_type = "type"
              variable_other_enummember = "variable"
              entity_name_namespace = "module"

              [semantic_tokens]
              type = "type"
              variable = "variable"
              namespace = "module"
              function = "function"
              string = "string"
              keyword = "keyword"
              operator = "operator"
              comment = "comment"

              [semantic_modifiers]
              documentation = "documentation"
              readonly = "default+d"

              [server]
              timeout = 1800
              [language.rust]
              filetypes = ["rust"]
              roots = ["Cargo.toml"]
              command = "rust-analyzer"
            '';
          };
        };
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