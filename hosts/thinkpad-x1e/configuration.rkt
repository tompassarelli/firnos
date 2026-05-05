#lang nisp

;; Host-specific configuration for thinkpad-x1e
;; NOTE: This host is not actively used. Copy whiterabbit's configuration
;; here and customize as needed if this machine comes back into service.
(host-file
  (set myConfig.modules.system.stateVersion "25.05")
  (enable myConfig.modules.boot
          myConfig.modules.users)
  (set myConfig.modules.users.username "tom")
  (enable myConfig.modules.fish))
