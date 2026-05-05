#lang nisp

(module-file modules dotnet
  (desc ".NET SDK and CLI tools")
  (config-body
    ;; .NET 8 SDK (LTS) - includes CLI, runtime, and ASP.NET
    (set 'environment.systemPackages (with-pkgs 'dotnet-sdk_8))

    ;; Ensure globally-installed dotnet tools (installed via
    ;; `dotnet tool install -g <tool>`) end up on PATH. The binaries
    ;; land in ~/.dotnet/tools after install.
    (set 'environment.sessionVariables.PATH (lst "$HOME/.dotnet/tools"))

    ;; Global dotnet tools currently in use on this system (track here
    ;; so future `nixos-rebuild switch` rebuilds don't silently drop them):
    ;;
    ;;   microsoft.sqlpackage
    ;;     -> used by ~/code/msa/kea for `bun run db:dump` (MSSQL schema extract)
    ;;     -> install with: dotnet tool install -g microsoft.sqlpackage
    ;;     -> binary name on disk is lowercase: `sqlpackage`
    ;;
    ;; These are user-scope installs (under $HOME/.dotnet/tools), not
    ;; nixpkgs-managed. A clean rebuild of the home dir would lose them;
    ;; re-run the install after wiping $HOME/.dotnet.
    ))
