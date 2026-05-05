firn — FirnOS config management

Usage:
  firn <command> [args...]

Commands:
  rebuild [host]              nixos-rebuild switch + tag generation
  list                        list all modules and bundles
  list --used                 show modules/bundles in use and where
  list --unused               show modules/bundles not referenced anywhere
  refs <name>                 show what references a module/bundle
  mod <name>                  scaffold a new module (.rkt)
  bundle <name> <mods...>     scaffold a new bundle (.rkt)
  secret <name>               create/edit an encrypted secret
  secret list                 list secret files
  secret show <name>          decrypt and display a secret
  gen                         show current and next generation numbers
  enable <name> [host]        toggle a module/bundle on in host config
  disable <name> [host]       toggle a module/bundle off in host config
  status [host]               list enabled modules/bundles for host
