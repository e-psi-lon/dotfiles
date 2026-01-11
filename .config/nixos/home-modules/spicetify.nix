{ spicetify-nix, pkgs, ... }:

let
    spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
    imports = [
        spicetify-nix.homeManagerModules.spicetify
    ];

    programs.spicetify = {
        enable = true;
        alwaysEnableDevTools = true;
        
        enabledExtensions = with spicePkgs.extensions; [
            adblock
            shuffle
            hidePodcasts
            powerBar
            queueTime
            volumePercentage
            beautifulLyrics
            copyToClipboard
            showQueueDuration
            fullAlbumDate
            wikify
            phraseToPlaylist
            songStats
            history
            betterGenres
        ];
        
        enabledCustomApps = with spicePkgs.apps; [
            marketplace
            lyricsPlus
        ];
        
        enabledSnippets = with spicePkgs.snippets; [
            pokemonAdventure
            nyanCatProgressBar
            circularAlbumArt
            rotatingCoverart
        ];
        
        windowManagerPatch = true;
        experimentalFeatures = true;
    };
}
