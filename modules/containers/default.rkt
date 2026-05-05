#lang nisp

(module-file modules containers
  (desc "Podman containers with Distrobox")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    (set 'virtualisation.podman
      (att ('enable #t)
           ;; Docker-compatible CLI alias (podman runs when you type `docker`)
           ('dockerCompat #t)
           ;; Enable default network for rootless containers
           ('defaultNetwork.settings.dns_enabled #t)))

    ;; Add user to podman group
    (nix-attr-entry '("users" "users" "${username}" "extraGroups")
                    (lst "podman"))

    (set 'environment.systemPackages (with-pkgs 'distrobox 'podman-compose))))
