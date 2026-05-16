#lang nisp

(module-file modules thermal-management
  (desc "CPU thermal management for sustained builds")
  (config-body
    ;; Use amd_pstate in active mode (kernel manages P-states directly)
    (set boot.kernelParams (lst "amd_pstate=active"))

    ;; auto-cpufreq: adaptive governor + turbo control
    ;; Turbo disabled on both AC and battery — on sustained all-core loads
    ;; (Firefox builds), turbo causes boost/throttle oscillation that
    ;; generates more heat than steady base clocks with no real throughput gain.
    (set services.auto-cpufreq.enable #t)
    (set services.auto-cpufreq.settings
      (att (charger (att (governor "performance")
                         (turbo "never")
                         (energy_performance_preference "balance_performance")))
           (battery (att (governor "powersave")
                         (turbo "never")
                         (energy_performance_preference "power")))))))
