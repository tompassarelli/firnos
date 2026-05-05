#lang nisp

(module-file modules glide
  (desc "Glide touchpad motion detection daemon")
  (option-attrs
    ('device          (mkopt #:type (t-str)
                            #:default "/dev/input/by-path/platform-AMDI0010:03-event-mouse"
                            #:desc "Touchpad evdev device path"))
    ('kanataAddress   (mkopt #:type (t-str)
                            #:default "127.0.0.1:7070"
                            #:desc "Kanata TCP server address (ip:port)"))
    ('virtualKey      (mkopt #:type (t-str)
                            #:default "pad-touch"
                            #:desc "Kanata virtual key name to press/release on activation"))
    ('motionThreshold (mkopt #:type (t-int)
                            #:default 2
                            #:desc "Min Euclidean displacement (device abs units) per evdev report to count as motion"))
    ('minStreak       (mkopt #:type (t-int)
                            #:default 16
                            #:desc "Consecutive motion-positive samples required to activate (~7ms each, 16 ≈ 112ms)")))
  (raw-body (imports (p "./glide.nix"))))
