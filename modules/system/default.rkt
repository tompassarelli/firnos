#lang nisp

(module-file modules system
  (desc "system")
  (no-enable)
  (option-attrs
    (stateVersion
      (mkopt #:type (t-str)
             #:desc (ms "The NixOS state version. Set this to the NixOS version you originally"
                        "installed (e.g., \"24.05\", \"25.05\"). Do NOT change this after initial"
                        "install unless you know what you're doing."
                        ""
                        "This controls backwards compatibility for stateful data like database"
                        "schemas, service data directories, etc."))))
  (config-body
    (set system.stateVersion 'cfg.stateVersion)))
