{
  raw = config: config;

  http = { url, headers ? {}, env ? {} }: { inherit url; }
    // (if headers != {} then { inherit headers; } else {})
    // (if env    != {} then { inherit env; } else {});

  uvx = { package, args ? [], env ? {} }:
    { command = "uvx"; args = [ package ] ++ args; }
    // (if env != {} then { inherit env; } else {});

  npx = { package, args ? [], env ? {} }:
    { command = "npx"; args = [ "-y" package ] ++ args; }
    // (if env != {} then { inherit env; } else {});
}