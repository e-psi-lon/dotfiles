{ spicetify-nix, pkgs, ... }:

let
    spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
    programs.spicetify = {
        enable = true;
        alwaysEnableDevTools = true;
        
        enabledExtensions = with spicePkgs.extensions; [
        ];
        
        enabledCustomApps = with spicePkgs.apps; [
            marketplace
            lyricsPlus
        ];
        
        enabledSnippets = [
            pokemonAdventure
            nyanCatProgressBar
            circularAlbumArt
        ];
        
        windowManagerPatch = true;
        experimentalFeatures = true;
    };
}
