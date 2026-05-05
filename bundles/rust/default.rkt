#lang nisp

(bundle-file rust
  (desc "Rust development toolchain")
  (sub-modules* (rustc #t) (cargo #t) (rust-analyzer #t) (clippy #t)
                (rustfmt #t) (pkg-config #t) (gcc #t) (bevy #f)))
