#lang nisp

(module-file modules swap
  (desc "zram-based compressed swap")
  (config-body
    ;; zram: in-RAM compressed swap. zstd typically gives 3-4x compression,
    ;; so memoryPercent=50 on 128GB ≈ 64GB allocation holding ~200GB of
    ;; compressed pages. Eliminates the no-swap thrash failure mode where
    ;; the kernel can't push cold pages anywhere and systemd-oomd's PSI
    ;; signals are degraded.
    (set zramSwap.enable #t)
    (set zramSwap.algorithm "zstd")
    (set zramSwap.memoryPercent 50)

    ;; vm tuning for zram: aggressive swapping is cheap when the swap
    ;; device IS RAM. page-cluster=0 because zram pages are individually
    ;; compressed and there's no benefit to readahead.
    ;;
    ;; Note: boot.kernel.sysctl wants flat string keys ("vm.X" = N;), not
    ;; nested attrs. The "\"...\"" wrapping forces nisp to emit a literal
    ;; quoted attr name instead of splitting on dot.
    (set boot.kernel.sysctl
      (att
        ("\"vm.swappiness\"" 180)
        ("\"vm.watermark_boost_factor\"" 0)
        ("\"vm.watermark_scale_factor\"" 125)
        ("\"vm.page-cluster\"" 0)))))
