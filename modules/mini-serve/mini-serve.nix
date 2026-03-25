{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.mini-serve;

  page = pkgs.writeTextDir "index.html" ''
    <!DOCTYPE html><html><body style="background:#2b3339;margin:0"></body></html>
  '';
in
{
  config = lib.mkIf cfg.enable {
    systemd.services.mini-serve = {
      description = "Minimal localhost web server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.darkhttpd}/bin/darkhttpd ${page} --port 39847 --addr 127.0.0.1";
        Restart = "always";
        DynamicUser = true;
      };
    };
  };
}
