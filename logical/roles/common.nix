{ config, pkgs, lib, ... }:
{ imports = [
    <vi-nix/modules/git-mirror.nix>
    <vi-nix/modules/secrets.nix>
    <vi-nix/modules/tor-hidden-service.nix>
    <vi-nix/modules/muflax-blog.nix>
  ];
  
  users.mutableUsers = false;

  users.extraUsers.root = {
    openssh.authorizedKeys.keys = config.users.extraUsers.vi.openssh.authorizedKeys.keys;
  };

  users.extraUsers.vi = {
    isNormalUser = true;
    description = "vi";
    extraGroups = ["wheel" "vboxusers" ];
    group = "users";
    home = "/home/vi";
    hashedPassword = builtins.readFile <vi-nix/secrets/hashed-password.vi>;
    useDefaultShell = true;
    uid = 1337;
    openssh.authorizedKeys.keys = ["ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAnko8n4kcVcreZO62HdQ/s9ysRHrCwUKc17f7aITwSOmwJUDmmCBrODYvkIr822kgrG0dykfrIjSa1hi0xtCjFEACreAX0N2oiocqrAgeBfbQnGjeziDoqDpOUdI1rdiMK3XN3ZTvZsRFe1HO0vDv/JkfaV4+gnzBxwXW2jgkebKI/6w==" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6EXMZwI6ng1irYcl8CBkj4X7gSj23BTbA0N7gHPHz7pNOeF0MkTa7Yx0iqS2nOjMb6jvaW6T0GBZSLL0f6rpaiABA0cZEArZ/O408QROZxK5wiR7HtO3NZsCKrTR37neWkDaNhUuL08Q6PrVDQOj14aFRa290WRXmCesTuEsK0PMxWjOtZZsqaFq5czl6grcnK1L5tDEeLU7V6xlsy/49WCKySSGu9+Le0Ao/K0Qr3vvssUdF/xWGk6ipo3DFxkiAR42NSB4SpuKuieYBN+bPFtpbgIfoZqUNMS3RFV/RU3EsZu2QmVjc5STbNHscKBsKQbe/+wUMzgd2NbYcHfst"];
  };

  security.initialRootPassword = "!";

  # Locale
  i18n.consoleKeyMap = "us";
  time.timeZone = "UTC";

  # Nix
  nixpkgs.config.allowUnfree = true;

  nix.binaryCaches = [
    https://hydra.nixos.org
  ];

  nix.trustedBinaryCaches = config.nix.binaryCaches;

  nix.extraOptions = ''
    allow-unsafe-native-code-during-evaluation = true
    allow-unfree = true
  '';

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
    graphviz
    htop
    inetutils
    jotmuch
    lsof
    mercurial
    nix-exec
    nix-prefetch-scripts
    nix-repl
    openssl
    rsync
    shallot
    socat
    tcpdump
    tmux
    tree
    unzip
    urlsnap
    vim
    wget
    zip
  ];

  nixpkgs.config.packageOverrides = base: (rec {
    jotmuch                = pkgs.callPackage <vi-nix/packages/jotmuch>           { inherit urlsnap; };
    muflax-blog            = pkgs.callPackage <muflax-blog/maintenance>                             {};
    mutt                   = pkgs.callPackage <vi-nix/packages/mutt>                 { inherit base; };
    nix                    = pkgs.callPackage <vi-nix/packages/nix>                  { inherit base; };
    otf-letter-gothic-mono = pkgs.callPackage <vi-nix/packages/otf-letter-gothic-mono>              {};
    shallot                = pkgs.callPackage <vi-nix/packages/shallot>                             {};
    surf                   = pkgs.callPackage <vi-nix/packages/surf>                 { inherit base; };
  # tor                    = pkgs.callPackage <vi-nix/packages/tor>                  { inherit base; };
    urlsnap                = pkgs.callPackage <vi-nix/packages/urlsnap> { webkitgtk2 = webkitgtk280; };
    webkitgtk280           = pkgs.callPackage <vi-nix/packages/webkitgtk/2.8.0.nix>                 {};
    zathura                = pkgs.callPackage <vi-nix/packages/zathura>              { inherit base; };
  });

  # Networking
  networking.enableIPv6 = false;

  # Services
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    listenAddresses = [{ addr = "127.0.0.1"; port = 22; }];
    hostKeys = [
     { path = "/etc/ssh/ssh_host_ed25519_key";
       type = "ed25519";
       bits = 9001; # ACHTUNG! Fixed length key, but nixpkgs balks if this is unspecified. OpenSSH balks if this is specified but small.
     }
     { path = "/etc/ssh/ssh_host_rsa_key";
       type = "rsa";
       bits = 4096;
     }
    ];
    extraConfig = ''
      KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
      MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160,umac-128@openssh.com
    '';
  };

  programs.ssh.extraConfig = ''
    Host github.com
      KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1
    Host *
      KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
      MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160,umac-128@openssh.com
      PasswordAuthentication no
  '';

  services.tor.hiddenServices = [
    { name = "ssh";
      port = 22;
      hostname = "${<vi-nix/secrets>}/hidden-services.ssh.${config.networking.hostName}.hostname";
      private_key = "${<vi-nix/secrets>}/hidden-services.ssh.${config.networking.hostName}.key";
    }
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
