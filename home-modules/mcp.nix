{
  config,
  subPath,
  paths,
  ...
}:

let
  mcp = import (subPath paths.lib "mcp");
in
{
  config = {
    programs.mcp = {
      enable = true;
      servers = {
        nixos = mcp.raw {
          command = "nix";
          args = [
            "run"
            "github:utensils/mcp-nixos"
          ];
        };
        fetch = mcp.uvx { package = "mcp-server-fetch"; };
        git = mcp.npx { package = "mcp-server-git"; };
        sequential-thinking = mcp.npx { package = "@modelcontextprotocol/server-sequential-thinking"; };
        time = mcp.uvx { package = "mcp-server-time"; };
        memory = mcp.npx {
          package = "@modelcontextprotocol/server-memory";
          env.MEMORY_FILE_PATH = "${config.xdg.dataHome}/mcp/memory.jsonl";
        };
        discord = mcp.http { url = "https://docs.discord.com/mcp"; };
        github = mcp.http {
          url = "https://api.githubcopilot.com/mcp/";
          headers = {
            Authorization = "Bearer $GITHUB_PAT";
          };
        };
        context7 = mcp.http {
          url = "https://mcp.context7.com/mcp";
          headers = {
            Authorization = "Bearer $CONTEXT7_API_KEY";
          };
        };
      };
    };
    home.file.".ai/mcp/mcp.json".source = config.xdg.configFile."mcp/mcp.json".source;
  };
}
