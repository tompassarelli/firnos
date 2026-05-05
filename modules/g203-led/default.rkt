#lang nisp

(module-file modules g203-led
  (desc "Logitech G102/G203 LED control")
  (config-body
    (set environment.systemPackages (with-pkgs g203-led))

    ;; Turn off G102/G203 Lightsync LED on connect
    (set services.udev.extraRules
      (ms "ACTION==\"add\", SUBSYSTEM==\"usb\", ATTR{idVendor}==\"046d\", ATTR{idProduct}==\"c092\", RUN+=\"${pkgs.g203-led}/bin/g203-led lightsync solid 000000\""))))
