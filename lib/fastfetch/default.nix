{
  fastfetchModules = builtins.listToAttrs (
    map (name: { name = name; value = { type = name; }; }) [
      "separator" "colors" "title" "os" "host" "kernel" 
      "uptime" "packages" "shell" "terminal" "de" "wm" "cpu" 
      "gpu" "memory" "swap" "disk" "display" "wifi" "localip" "battery"
    ]
  ) // {
    breakModule = { type = "break"; };
  };
  # Helper functions

  override = mod: attrs: mod // attrs;

  green = mod: attrs: mod // { keyColor = "green"; } // attrs;
  cyan = mod: attrs: mod // { keyColor = "cyan"; } // attrs;
  yellow = mod: attrs: mod // { keyColor = "yellow"; } // attrs;
  magenta = mod: attrs: mod // { keyColor = "magenta"; } // attrs;
  red = mod: attrs: mod // { keyColor = "red"; } // attrs;
}