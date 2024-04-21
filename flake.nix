{
  description = "Randy's Darwin Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
    let
      configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages =
          [
            pkgs.nixpkgs-fmt
            pkgs.neofetch
            pkgs.htop
            pkgs.zsh-completions
            pkgs.openconnect
            pkgs.neovim
            pkgs.imagemagick
            pkgs.tmux
            pkgs.eza
            pkgs.ncdu
            pkgs.bashInteractive
            pkgs.bash-completion
            pkgs.nix-bash-completions
            pkgs.zsh
          ];

        environment.variables = {
          EDITOR = "nvim";
        };

        environment.shells = [ 
          pkgs.bashInteractive
          pkgs.zsh
        ];

        environment.shellAliases = {
          ls = "eza";
          ll = "eza --hyperlink --git -lh";
          default-rebuild = "darwin-rebuild switch --flake ~/.config/nix-darwin";
          sudoedit = "sudo -e";
        };

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;

        nixpkgs.config.allowUnsupportedSystem = true;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";
        nix.extraOptions = ''
          extra-platforms = x86_64-darwin aarch64-darwin
        '';

        nixpkgs.config.allowUnfree = true;

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true; # default shell on catalina
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.defaults.".GlobalPreferences"."com.apple.mouse.scaling" = -1.0;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 4;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";

        fonts.fontDir.enable = true;
        fonts.fonts = [
          pkgs.jetbrains-mono
        ];

        homebrew = {
          enable = true;
          onActivation.cleanup = "zap";

          casks = [
            "rectangle"
            "visual-studio-code"
            "spotify"
            "firefox"
            "appcleaner"
            "iterm2"
            "discord"
            "microsoft-office-businesspro"
            "altserver"
            "termius"
          ];

          masApps = {
            "Bitwarden" = 1352778147;
            "Microsoft Remote Desktop" = 1295203466;
            "WireGuard" = 1451685025;
            "Notability" = 360593530;
          };
        };

        system.defaults = {
          dock = {
            autohide = true;
          };
          finder = {
            AppleShowAllExtensions = true;
            ShowPathbar = true;
          };
          NSGlobalDomain.ApplePressAndHoldEnabled = false;
        };
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Randys-Laptop
      darwinConfigurations."Randys-Laptop" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Randys-Laptop".pkgs;
    };
}
