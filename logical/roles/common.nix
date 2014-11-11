{ config, pkgs, lib, ... }:
{ imports = [
    ../../modules/git-mirror.nix
    ../../modules/secrets.nix
    ../../modules/tor-hidden-service.nix
  ];
  
  users.mutableUsers = false;

  users.extraUsers.root = {
    hashedPassword = "$6$4CptotwIgzT58jB$CIhWW6FzHO1irNchO.KYaLBwKZLrknoMPzWVNjfJH9FQf0opTrJmzguV6lblT7z4dDPNrZoN07GpoZThzwY960";
    openssh.authorizedKeys.keys = ["ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAnko8n4kcVcreZO62HdQ/s9ysRHrCwUKc17f7aITwSOmwJUDmmCBrODYvkIr822kgrG0dykfrIjSa1hi0xtCjFEACreAX0N2oiocqrAgeBfbQnGjeziDoqDpOUdI1rdiMK3XN3ZTvZsRFe1HO0vDv/JkfaV4+gnzBxwXW2jgkebKI/6w==" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6EXMZwI6ng1irYcl8CBkj4X7gSj23BTbA0N7gHPHz7pNOeF0MkTa7Yx0iqS2nOjMb6jvaW6T0GBZSLL0f6rpaiABA0cZEArZ/O408QROZxK5wiR7HtO3NZsCKrTR37neWkDaNhUuL08Q6PrVDQOj14aFRa290WRXmCesTuEsK0PMxWjOtZZsqaFq5czl6grcnK1L5tDEeLU7V6xlsy/49WCKySSGu9+Le0Ao/K0Qr3vvssUdF/xWGk6ipo3DFxkiAR42NSB4SpuKuieYBN+bPFtpbgIfoZqUNMS3RFV/RU3EsZu2QmVjc5STbNHscKBsKQbe/+wUMzgd2NbYcHfst"];
  };

  users.extraUsers.vi = {
    isNormalUser = true;
    description = "vi";
    extraGroups = ["wheel" "vboxusers" ];
    group = "users";
    home = "/home/vi";
    hashedPassword = "$6$jsl6DJ3J$p/45DOLzK5frmUNKonpcsWx5f.cQuz6Su6wjBftoQnM7DHzdTo/6Lh0OaV1E7Jn4dp4OrzaepjACz/zZqbCIP0";
    useDefaultShell = true;
    uid = 1337;
    openssh.authorizedKeys.keys = ["ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAnko8n4kcVcreZO62HdQ/s9ysRHrCwUKc17f7aITwSOmwJUDmmCBrODYvkIr822kgrG0dykfrIjSa1hi0xtCjFEACreAX0N2oiocqrAgeBfbQnGjeziDoqDpOUdI1rdiMK3XN3ZTvZsRFe1HO0vDv/JkfaV4+gnzBxwXW2jgkebKI/6w==" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6EXMZwI6ng1irYcl8CBkj4X7gSj23BTbA0N7gHPHz7pNOeF0MkTa7Yx0iqS2nOjMb6jvaW6T0GBZSLL0f6rpaiABA0cZEArZ/O408QROZxK5wiR7HtO3NZsCKrTR37neWkDaNhUuL08Q6PrVDQOj14aFRa290WRXmCesTuEsK0PMxWjOtZZsqaFq5czl6grcnK1L5tDEeLU7V6xlsy/49WCKySSGu9+Le0Ao/K0Qr3vvssUdF/xWGk6ipo3DFxkiAR42NSB4SpuKuieYBN+bPFtpbgIfoZqUNMS3RFV/RU3EsZu2QmVjc5STbNHscKBsKQbe/+wUMzgd2NbYcHfst"];
  };

  # Locale
  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
    supportedLocales = ["en_US.UTF-8"];
  };
  time = {
    timeZone = "UTC";
  };
  # Nix
  nixpkgs.config.allowUnfree = true;

  nix.binaryCaches = [
    https://hydra.nixos.org
  ];

  nix.trustedBinaryCaches = config.nix.binaryCaches;
  # Core Packages
  environment.systemPackages = with pkgs; [
    acpi
    bc
    bind
    binutils
    cacert
    coreutils
    dos2unix
    file
    git
    gnumake
    gnupg
    gnused
    htop
    inetutils
    lsof
    mercurial
    nix-prefetch-scripts
    nix-repl
    rsync
    tcpdump
    tmux
    tree
    unzip
    vim
    wget
    zip
  ];
  nixpkgs.config.packageOverrides = pkgs : {
    vi-surf    = pkgs.callPackage ../../packages/vi-surf {};
    vi-mutt    = pkgs.callPackage ../../packages/vi-mutt {};
    vi-zathura = pkgs.callPackage ../../packages/vi-zathura {};
    vi-nix     = pkgs.callPackage ../../packages/vi-nix {};
  };
  # Networking
  networking.enableIPv6 = false;
  # Services
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    extraConfig = ''
      Ciphers aes256-ctr
      MACs hmac-sha2-512
    '';
  };

  services.tor.hiddenServices = [
    { name = "ssh"; port = 22; }
  ];

  system.activationScripts.ssl = ''
    ln -sf /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
  '';
  
  services.git-mirror.remotes = [
    { repo = "git@github.com:fmap/vi-etc.git"; name = "vi-etc"; key = "/etc/keys/github.vi-etc.id_rsa"; }
    { repo = "git@github.com:fmap/vi-bin.git"; name = "vi-bin"; key = "/etc/keys/github.vi-bin.id_rsa"; }
  ];

  services.secrets = [
    { key = "github.vi-bin.id_rsa"; user = "root"; group = "root"; chmod = "0"; }
    { key = "github.vi-etc.id_rsa"; user = "root"; group = "root"; chmod = "0"; }
  ];
}