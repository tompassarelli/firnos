#lang nisp

(module-file modules pipewire
  (desc "PipeWire audio configuration")
  (config-body
    (service pipewire
      (att (pulse.enable #t)
           (alsa.enable #t)
           (alsa.support32Bit #t)))))
