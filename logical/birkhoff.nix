{ config, pkgs, ... }:
{ imports = [ ./roles/common.nix ];

  networking.hostName = "birkhoff";

  networking.wireless.enable = false;
    
  networking.firewall.enable = true;
  networking.firewall.rejectPackets = true;
  networking.firewall.allowPing = false;
  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPortRanges = [];

  services.logind.extraConfig = ''
    HandleLidSwitch=ignore
  '';

  services.znc = {
    enable         = true;
    mutable        = false;
    modulePackages = [pkgs.vi-znc.modules.privmsg];
  };

  services.tor.hiddenServices = [
    { name = "znc"; port = config.services.znc.confOptions.port; }
  ];

  # declarative later:
  services.znc.zncConf = with builtins; let znc = config.services.znc; in ''
    AnonIPLimit = 10
    ConnectDelay = 8
    MaxBufferSize = 500
    SSLCertFile = ${znc.dataDir}/znc.pem
    Skin = _default_
    StatusPrefix = *
    Version = 1.2

    <Listener listener0>
      AllowIRC = true
      AllowWeb = false
      IPv4 = true
      IPv6 = false
      Port = ${if znc.confOptions.useSSL then "+" else ""}${toString znc.confOptions.port}
      SSL = ${if znc.confOptions.useSSL then "true" else "false"}
    </Listener>

    <User vi>
      Admin = true
      Allow = *
      AutoClearChanBuffer = false
      Buffer = 150
      AppendTimestamp = false
      PrependTimestamp = false
      ChanModes = +stn
      DenyLoadMod = false
      DenySetBindHost = true
      MultiClients = true
      LoadModule = privmsg
      <Network freenode>
        Ident = WashIrving
        Nick = Qfwfq
        RealName = Washington Irving
        LoadModule = nickserv ${readFile ../secrets/freenode.nickserv}
        IRCConnectEnabled = true
        Server = irc.freenode.net +6697
        <Chan ##hplusroadmap>
        </Chan>
        <Chan #hackerspacesg>
        </Chan>
      </Network>
      <Network zalora>
        Ident = vi
        Nick = vi
        RealName = vi
        IRCConnectEnabled = true
        Server = zalora.irc.slack.com +6667 ${readFile ../secrets/zalora.irc-gateway}
        <Chan #general>
          Detached =true
        </Chan>
        <Chan #fpdelta>
        </Chan>
        <Chan #fp-at-office>
          Detached =true
        </Chan>
        <Chan #nix-users>
        </Chan>
        <Chan #devops-internal>
        </Chan>
      </Network>
      <Pass password>
        Method = sha256
        Hash = 3d27f7c7947831b7aa194d2a41927baa73afb39b318857bbf0f5ce4e6a5b6f6b
        Salt = 94Ed?eQ2KY-Lcy0p.SSq
      </Pass>
    </User>
  '';
}
