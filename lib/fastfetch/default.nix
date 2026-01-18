{
  fastfetchModules = builtins.listToAttrs (
    map (name: { name = name; value = { type = name; }; }) [
      "separator" "colors" "title" "os" "host" "kernel" 
      "uptime" "packages" "shell" "terminal" "de" "wm" "cpu" 
      "gpu" "memory" "swap" "disk" "display" "wifi" "localip" "battery"
      "weather" "publicip"
    ]
  ) // {
    breakModule = { type = "break"; };
  };
  # Helper functions

  override = mod: attrs: mod // attrs;
} // builtins.listToAttrs (
  map (color: { 
    name = color; 
    value = mod: attrs: mod // { keyColor = color; } // attrs;
  })
  ["green" "cyan" "yellow" "magenta" "red"]
)