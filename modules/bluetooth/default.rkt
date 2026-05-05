#lang nisp

(module-file modules bluetooth
  (desc "Enable Bluetooth configuration")
  (config-body
    ;; Enable Bluetooth hardware support
    (set hardware.bluetooth
      (att (enable #t)
           (powerOnBoot #t)
           (settings
             (att (General
                    (att (Enable "Source,Sink,Media,Socket")
                         (Experimental #t)))))))

    ;; Enable Blueman for GUI management
    (set services.blueman.enable #t)

    ;; Make sure bluetooth is available to user session
    (set environment.systemPackages (with-pkgs bluez))))
