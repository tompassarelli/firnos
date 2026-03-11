# NixOS Module System Deep Dive

## Overview

The NixOS module system is a **declarative configuration composition framework** with lazy evaluation, structural typing, and a merge-based evaluation model.

## Core Concept: Fixpoint Evaluation of Composable Declarations

At its heart, the module system solves this problem: **How do you compose multiple configuration fragments that can both consume and produce configuration values, resolve their interdependencies, and validate the result - all in a lazy, purely functional language?**

The solution is a **fixed-point evaluator** that:

1. Collects all option declarations (`options = { ... }`)
2. Collects all value definitions (`config = { ... }`)
3. Recursively evaluates them until reaching a fixpoint where `config` can reference itself

### The Evaluation Model

Conceptually, this is what happens:

```nix
let
  # Step 1: Merge all modules
  merged = evalModules {
    modules = [ ./module1.nix ./module2.nix ... ];
  };

  # Step 2: Fix-point evaluation
  # config can reference itself because of lazy evaluation
  config = fix (self: /* merge all module configs with self available */);
in config
```

The **fixpoint** (`fix` function) is key. It's defined as:

```nix
fix = f: let x = f x; in x
```

This creates a self-referential binding where `config.foo` can depend on `config.bar` and vice versa, as long as there's no infinite recursion (which lazy evaluation prevents).

## Type System: Structural Types with Merge Semantics

Each option has a **type** that defines:

1. **Validation**: What values are acceptable
2. **Merge behavior**: How multiple definitions combine
3. **Coercion**: How to normalize values

```nix
options.myConfig.users.username = lib.mkOption {
  type = lib.types.str;           # Type: string
  default = "tom";                 # Default value
  description = "Username";        # Documentation
};
```

### Type Hierarchy

- **Simple types**: `bool`, `int`, `str`, `path` - last definition wins
- **Composite types**: `listOf`, `attrsOf` - merge by concatenation/union
- **Submodule types**: Recursive module evaluation within an option
- **Custom types**: You can define merge semantics

### Example of Merge Semantics

```nix
# Module A:
config.environment.systemPackages = [ pkgs.vim ];

# Module B:
config.environment.systemPackages = [ pkgs.git ];

# Result: [ pkgs.vim pkgs.git ]  (concatenated because listOf)
```

### Priority System

The module system has a **priority-based override mechanism**:

```nix
config.foo = lib.mkDefault "value";      # priority 1000
config.foo = "value";                     # priority 100 (normal)
config.foo = lib.mkForce "value";        # priority 50
config.foo = lib.mkOverride 10 "value";  # custom priority
```

Lower priority number = higher precedence. This is how you resolve conflicts when multiple modules define the same non-mergeable option.

## Module Structure: The Triple

Each module is a function returning an attrset with up to three keys:

```nix
{ config, lib, pkgs, ... }:  # Module arguments (dependency injection)
{
  imports = [ ... ];          # Import other modules (graph composition)
  options = { ... };          # Declare what options exist (schema)
  config = { ... };           # Define values for options (data)
}
```

### The `config` vs `cfg` Pattern

You'll see this constantly:

```nix
{ config, lib, ... }:
let
  cfg = config.myConfig.foo;  # Local alias to this module's options
in
{
  options.myConfig.foo = {
    enable = lib.mkEnableOption "foo";
  };

  config = lib.mkIf cfg.enable {  # Only apply if enabled
    # ...
  };
}
```

This leverages the fixpoint: `config` (the argument) is the **entire system configuration**. You read from it to make decisions, then contribute back to it.

## Lazy Evaluation Implications

The module system is **maximally lazy**:

```nix
# This doesn't error even though bar doesn't exist:
config = lib.mkIf false {
  services.nonexistent.enable = config.nonexistent.bar;
};
```

This means:
- Unused modules contribute zero evaluation cost
- Conditional configuration (`mkIf`) is cheap
- You can have circular dependencies as long as they're not strict

## specialArgs vs Module Options

### specialArgs (anti-pattern)

```nix
specialArgs = { username = "tom"; };

# In modules:
{ config, lib, username, ... }:  # username injected as parameter
```

**Properties**:
- Lexically scoped (visible only where explicitly imported)
- No type checking
- No validation
- No discoverability (`nixos-option` can't see it)
- Bypasses the module system
- Can't be overridden by other modules

### Module Options (recommended)

```nix
options.myConfig.users.username = lib.mkOption {
  type = lib.types.str;
  default = "tom";
};

# In modules:
{ config, lib, ... }:
let username = config.myConfig.users.username; in
```

**Properties**:
- Part of the configuration graph
- Type-checked and validated
- Composable (multiple modules can set it with priorities)
- Discoverable (`nixos-option myConfig.users.username`)
- Can have defaults, documentation, assertions
- Participates in fixpoint evaluation

### Why Module Options Are Superior

1. **Composability**: Any module can override `config.myConfig.users.username` using priorities
2. **Validation**: The type system catches errors at evaluation time
3. **Documentation**: `nixos-option` generates docs automatically
4. **Introspection**: Tools can query available options
5. **Separation of concerns**: Host configs set values, modules declare structure

## The DAG: Module Import Graph

Modules form a **directed acyclic graph** via `imports`:

```nix
# flake.nix
modules = [
  ./host-config.nix
  ./modules/foo
  ./modules/bar
];

# modules/foo/default.nix
{ ... }: {
  imports = [ ./sub-module.nix ];
  # ...
}
```

The module system:
1. Recursively traverses the import graph
2. Deduplicates (same module imported twice = evaluated once)
3. Merges all `options` declarations
4. Merges all `config` values
5. Evaluates the fixpoint

## Advanced: Submodules

You can nest module evaluation:

```nix
options.services.foo = lib.mkOption {
  type = lib.types.attrsOf (lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "foo instance";
      port = lib.mkOption { type = lib.types.port; };
    };
  });
};

# Usage:
config.services.foo.instance1.enable = true;
config.services.foo.instance1.port = 8080;
```

This creates **nested module evaluation** - each submodule has its own fixpoint with its own `config` argument.

## Assertions and Warnings

The module system has a validation phase:

```nix
config = {
  assertions = [{
    assertion = cfg.enable -> config.networking.firewall.enable;
    message = "foo requires firewall to be enabled";
  }];

  warnings = lib.optional (cfg.deprecated) "foo is deprecated";
};
```

These run **after** fixpoint evaluation but **before** system build.

## Why This Design?

The module system achieves:

1. **Modularity**: Compose independent configuration fragments
2. **Override semantics**: Clear priority-based conflict resolution
3. **Type safety**: Catch configuration errors before deployment
4. **Lazy evaluation**: Pay-for-what-you-use performance
5. **Introspection**: Machine-readable schema for tooling
6. **Documentation**: Self-documenting configuration

The tradeoff is complexity - understanding fixpoint evaluation, merge semantics, and lazy evaluation requires functional programming sophistication.

## Your Refactor in This Context

By moving from `specialArgs` to module options, you:

- Moved `username` from external injection into the configuration graph
- Enabled type checking, validation, and composition
- Made it introspectable and documentable
- Allowed host configs to override it declaratively
- Followed the principle: **configuration data belongs in the module system, not in function parameters**

`chosenTheme` should follow the same path for the same reasons - it's configuration data that should participate in the module system's composition and validation machinery, not bypass it via `specialArgs`.
