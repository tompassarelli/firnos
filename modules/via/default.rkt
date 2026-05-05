#lang nisp

(module-file modules via
  (desc "VIA keyboard configurator support")
  (lets ([username config.myConfig.modules.users.username]))
  (config-body
    ;; Udev rules for VIA to access keyboards
    ;; Based on official VIA udev rules: https://github.com/the-via/releases/releases/latest
    (set services.udev.extraRules
      (ms "# VIA keyboard access rules"
          "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\", MODE=\"0660\", GROUP=\"plugdev\", TAG+=\"uaccess\""
          ""
          "# Additional rules for QMK/VIA keyboards"
          "SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"c2ab\", ATTRS{idProduct}==\"3939\", TAG+=\"uaccess\""))

    ;; Ensure plugdev group exists
    (set users.groups.plugdev (att))

    ;; Add your user to plugdev group
    (set users.users
      (att ("${username}.extraGroups" (lst "plugdev"))))))
