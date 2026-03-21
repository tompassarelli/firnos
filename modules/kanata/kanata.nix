{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.kanata;
in
{
  config = lib.mkIf cfg.enable {
    # Hardware support for kanata
    hardware.uinput.enable = true;     # Required for kanata to access uinput

  # Proper udev rules for uinput access
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';
  users.groups.uinput = {};

  # Create dedicated kanata user with proper permissions
  users.users.kanata = {
    isSystemUser = true;
    group = "kanata";
    extraGroups = [ "input" "uinput" ];
  };
  users.groups.kanata = {};

  services.kanata = {
    enable = true;
    package = pkgs.kanata-git;
    keyboards = lib.mkIf (cfg.devices != []) {
      main = {
        devices = cfg.devices;
        port = lib.mkIf config.myConfig.glide.enable 7070;
        extraDefCfg = "process-unmapped-keys yes"; # req for tap-hold-press, or need a set of explicit passthrough keys
        config = let
          # Always define full keyboard for layer switching (ISO layout)
          srcKeys = ''
            grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]
            caps a    s    d    f    g    h    j    k    l    ;    '    \    ret
            lsft 102d z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            rmet ralt cmp  rctl
            mbck mfwd f10
          '';

          baseKeys = ''
            grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    [    y    u    i    o    p    \
            ${if cfg.capsLockEscCtrl then "@capesc" else "caps"} a    s    d    f    g    ]    h    j    k    l    ;    '    ret
            @lshiftcaps @slashshift z x    c    v    b    /    n    m    ,    .    rsft
            lctl lalt lmet      ${if cfg.spacebarSymbols then "@spacesym" else "spc"}           @enteralt ralt cmp  rctl
            @m4shift @m5ctrl XX
          '';

        in ''
          ;; Define aliases (tap-hold-order: pure event-driven, no timers)
          ${lib.optionalString cfg.capsLockEscCtrl "(defalias capesc (tap-hold-press 0 65535 esc lctl))"}
          ${lib.optionalString cfg.spacebarSymbols "(defalias spacesym (tap-hold-order 200 50 spc (layer-while-held symbols)))"}
          (defalias lshiftcaps (tap-dance-eager 200 (lsft caps)))
          (defalias slashshift (tap-hold-order 0 0 / lsft))
          (defalias enteralt (tap-hold-order 0 0 ret ralt))
          (defalias apostrophenum (tap-hold-order 0 0 ' (layer-while-held numbers)))
          (defalias m4shift (tap-hold-order 0 0 mbck lsft))
          (defalias m5ctrl (tap-hold-order 0 0 mfwd lctl))
          (defalias bracketpair (macro [ ] left))

          ${lib.optionalString config.myConfig.glide.enable ''
          ;; Touchpad contact virtual key
          (defvirtualkeys pad-touch (layer-while-held pad-layer))
          ''}

          ;; Source layer
          (defsrc ${srcKeys})

          ;; Base layer
          (deflayer base ${baseKeys})

          ;; Numbers layer - qwert=12345, uiop[=67890, jkl;=arrows, m,.=home+-end
          (deflayer numbers
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    1    2    3    4    5    _    6    7    8    9    0    _
            _    _    _    _    _    _    _    left down up   rght _    _    _
            _    _    _    _    _    _    _    _    home +    -    end  _
            _    _    _              _              _    _    _    _
            _    _    _
          )

          ${lib.optionalString cfg.spacebarSymbols ''
          ;; Symbols layer (spacebar hold)
          ;; Top:    ! @ # $ % _ ^ & * ( )   (shifted numbers)
          ;; Home:   M-a M-s M-d M-f M-g _ M-h M-j M-k M-l (super+home row)
          ;; Bottom: { } [] ] _ M-n _ ' - = , .  (brackets/punctuation + super+n)
          (deflayer symbols
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    S-1  S-2  S-3  S-4  S-5  _    S-6  S-7  S-8  S-9  S-0  _
            _    M-a  M-s  M-d  M-f  M-g  _    M-h  M-j  M-k  M-l  _    _    _
            _    _    S-[  S-]  @bracketpair  ]    _    _    M-n  '    -    =    _
            _    _    _              _              _    _    _    _
            _    _    _
          )
          ''}

          ${lib.optionalString config.myConfig.glide.enable ''
          ;; Pad layer - active while finger is on touchpad
          ;; d = left click, f = right click
          (deflayer pad-layer
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    mrgt mlft _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _              (layer-while-held pad-nav)              _    _    _    _
            _    _    _
          )

          ;; Pad-nav layer - touchpad + spacebar held
          ;; e=up s=left d=down f=right
          (deflayer pad-nav
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    up   _    _    _    _    _    _    _    _    _
            _    _    left down rght _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _              _              _    _    _    _
            _    _    _
          )
          ''}
        '';
      };
    };
  };

    # Use dedicated user instead of DynamicUser (better security than root)
    systemd.services.kanata-main.serviceConfig = lib.mkIf (cfg.devices != []) {
      DynamicUser = lib.mkForce false;
      User = "kanata";
    };
  };
}
