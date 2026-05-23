# Using FirnOS as a flake input

The [`template/`](../template/) directory is the recommended starting
point (`nix flake init -t github:tompassarelli/firnos`). To consume
FirnOS as a flake input from your own repo instead:

```nix
{
  inputs.firnos.url = "github:tompassarelli/firnos";
  outputs = { firnos, ... }: {
    nixosConfigurations.my-machine = firnos.lib.mkSystem {
      hostname = "my-machine";
      hostConfig = ./hosts/my-machine/configuration.nix;
      hardwareConfig = ./hosts/my-machine/hardware-configuration.nix;
    };
    # macOS:
    darwinConfigurations.my-mac = firnos.lib.mkDarwinSystem {
      hostname = "my-mac";
      hostConfig = ./hosts/my-mac/configuration.nix;
    };
  };
}
```

## `lib.mkSystem` (NixOS)

| | required | type | default |
|---|---|---|---|
| `hostname` | yes | string | — |
| `hostConfig` | yes | path | — |
| `hardwareConfig` | yes | path | — |
| `system` | no | string | `"x86_64-linux"` |
| `extraModules` | no | list | `[]` |
| `extraOverlays` | no | list | `[]` |
| `extraSpecialArgs` | no | attrset | `{}` |

## `lib.mkDarwinSystem` (nix-darwin)

| | required | type | default |
|---|---|---|---|
| `hostname` | yes | string | — |
| `hostConfig` | yes | path | — |
| `system` | no | string | `"aarch64-darwin"` |
| `extraModules` | no | list | `[]` |
| `extraOverlays` | no | list | `[]` |
| `extraSpecialArgs` | no | attrset | `{}` |

No `hardwareConfig` on darwin — macOS has no analogue. See
[MACOS.md](MACOS.md) for the bootstrap walkthrough.
