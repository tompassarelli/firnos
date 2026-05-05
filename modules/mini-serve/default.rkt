#lang nisp

(module-file modules mini-serve
  (desc "Enable mini-serve localhost background page")
  (lets
    ([page (call 'pkgs.writeTextDir "index.html"
             (ms "<!DOCTYPE html><html><body style=\"background:#2b3339;margin:0\"></body></html>"))]))
  (config-body
    (set systemd.services.mini-serve
      (att
        (description "Minimal localhost web server")
        (wantedBy (lst "multi-user.target"))
        (after (lst "network.target"))
        (serviceConfig
          (att
            (ExecStart (s 'pkgs.darkhttpd "/bin/darkhttpd " 'page " --port 39847 --addr 127.0.0.1"))
            (Restart "always")
            (DynamicUser #t)))))))
