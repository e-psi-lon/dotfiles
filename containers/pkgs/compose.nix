{
  runCommand,
  remarshal,
  closureInfo,
  enabledImages,
  composeSet,
}:
runCommand "compose"
  {
    nativeBuildInputs = [ remarshal ];
    closureInfo = closureInfo { rootPaths = enabledImages; };
    json = builtins.toJSON composeSet;
    manifest = builtins.toJSON (
      map (img: {
        name = img.imageName;
        tag = img.imageTag;
        path = img;
      }) enabledImages
    );
    passAsFile = [
      "json"
      "manifest"
    ];
  }
  ''
    mkdir -p $out
    json2yaml "$jsonPath" > $out/podman-compose.yml
    cp "$manifestPath" $out/images.json
  ''
