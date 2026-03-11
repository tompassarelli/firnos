# Application Notes

## Niri Window Manager

### Minecraft Compatibility

If using Minecraft or other Java AWT applications on niri, set this environment variable:

```bash
_JAVA_AWT_WM_NONREPARENTING=1
```

Source: [Reddit - Niri Noctalia](https://www.reddit.com/r/unixporn/comments/1lyni3b/niri_noctalia_quiet_by_design_nixos_quickshell/)

## Walker Application Launcher

### Why Walker over Anyrun

- **Actively developed**: v2.9.0 (Nov 2025) vs Anyrun (maintenance mode)
- **More features**: AI integration, clipboard history, bookmarks
- **Better Wayland support**: Works great on niri (most features generic Wayland, only one optional Hyprland module)
- **Already in nixpkgs**: No need for flake input
- **No flickering**: Anyrun has flickering issue (no input debouncing, re-sorts on every keystroke)

### Activation Mode Feature

Walker's "activation_mode" allows quick item selection via modifier key + letter:

- Hold Right Alt (ralt) + press letter keys (j/k/l/;/a/s/d/f)
- Letters appear on the right side of each result
- Instantly activates the corresponding item

#### Configuration

```toml
# dotfiles/walker/config.toml
[keys]
trigger_labels = "ralt"  # Use Right Alt as trigger modifier

[activation_mode]
labels = "jkl;asdf"  # Letters used for quick selection
```

Config is generated programmatically in `modules/walker/walker.nix`.

#### Usage

1. Open walker (`Super+Space`)
2. Type to filter results
3. Hold Right Alt
4. Press letter shown next to desired result
5. Item activates immediately
