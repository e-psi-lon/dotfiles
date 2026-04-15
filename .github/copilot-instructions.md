# Dotfiles & System Configuration Conventions

When assisting with Nix code in this personal system configuration (dotfiles) repository, strictly adhere to the following architectural and formatting conventions.

## 1. Nix Formatting and Style

*   **Indentation:** Always use exactly 2 spaces (no tabs).
*   **Brackets & Braces:** Place opening braces `{` and brackets `[` on the same line as the variable or parameter declaration. Do not add extra blank lines before closing braces.
*   **Attribute Sets:** Keep simple nested attributes compact (e.g., `boot.loader.efi.efiSysMountPoint = "/boot/efi";`). Place list items on separate lines if there are multiple items.
*   **Conditionals & Defaults:** Utilize `lib.mkIf` for conditional configurations and `lib.mkDefault` or `lib.mkForce` to manage configuration priorities appropriately.
*   **Using the main binary:** When applicable, avoid using raw interpolation (e.g., `"${pkgs.somePackage}/bin/someExecutable"`). Instead, prefer using `lib.getExe pkgs.somePackage` for better readability and maintainability. 

## 2. Naming Conventions

*   **Files / Directories:** Use `kebab-case` for file and directory names (e.g., `desktop-kde.nix`, `home-modules`).
*   **Variables (let bindings):** Use `camelCase` for local bindings (e.g., `zshConfigEarlyInit`).

## 3. Module Authorship & Parameters

The project depends on custom arguments passed through `specialArgs` and `extraSpecialArgs`. A standard module should look like this:

```nix
{
  config,
  lib,
  pkgs,
  paths,
  subPath,
  username,
  hashes,
  ...
}:
{
  # Output configuration here
}
```

*   **`paths` / `subPath`:** Always use the `paths` attribute set and the `subPath` helper function to construct paths for cross-directory imports. **Do not use raw relative string interpolations** (like `../modules/common`). Instead, use:
    ```nix
    imports = [
      (subPath paths.modules "common")
      (subPath paths.home-modules "discord.nix")
    ];
    ```
*   **`hashes`:** Contains external data parsed from `resources/hashes.toml`.
*   **`username`:** The main user identity string.

## 4. Architectural Separation and Feature Placement

To ensure things go where they belong, ask yourself the scope of the feature before creating or modifying files:

*   **Generic & Universal:** Applies to every machine or every user profile.
    *   System: `modules/common/`
    *   User: `home-modules/common/`
*   **Reusable & Opt-in:** Not shared by default, but can be reused across multiple machines or profiles (e.g., desktop environments, specific heavy apps).
    *   System: `modules/` (top-level)
    *   User: `home-modules/` (top-level)
*   **Specific & Dedicated:** Tied to specific hardware or a single distinct device/setup (e.g., hardware mounts (`/mnt/data`), specific boot parameters).
    *   System: `hosts/` (in the specific host folder)
    *   User: `home/` (in the specific profile file)

*   **`lib/`:** Custom utility functions (e.g., `paths.nix`, `mkNixosSystem.nix`, `mkBindMount.nix`).
*   **`resources/`:** Static configuration files like themes (`theme.json`), scripts, and TOML data.
*   **`containers/`:** Custom podman compose-based system to manage containerized services.
*   **`pkgs/`:** Custom package definitions and overrides.

Always preserve the separation between Home Manager (user) configurations and NixOS (system) configurations.
