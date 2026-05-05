#lang nisp

(module-file modules submodule-typo-test
  (desc "typo inside services.openssh.settings (after lazy submodule expansion)")
  (config-body
    (set 'services.openssh.settings.PermitRotLogin "yes")))
