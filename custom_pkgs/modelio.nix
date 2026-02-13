{ 
  stdenv, 
  fetchurl, 
  rpm, 
  cpio, 
  gtk3, 
  libxcb, 
  lib, 
  autoPatchelfHook, 
  libsecret, 
  xorg, 
  alsa-lib, 
  webkitgtk_4_1,
  makeWrapper, 
  unzip, 
  libGLU 
}:

stdenv.mkDerivation rec {
  pname = "modelio";
  version = "5.4.1";
  
  src = fetchurl {
    url = "https://github.com/ModelioOpenSource/Modelio/releases/download/v${version}/modelio-open-source-${version}.el8.x86_64.rpm";
    sha256 = "sha256-V7Vq8o5HZmfhGaDwd1vo1PRaaF6UVSmc9N+ggd+Y3M4=";
  };

  nativeBuildInputs = [ rpm cpio autoPatchelfHook makeWrapper unzip ];
  buildInputs = [ gtk3 libxcb libsecret xorg.libXtst alsa-lib webkitgtk_4_1 libGLU ];

  unpackPhase = ''
    rpm2cpio $src | cpio -idmv
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/modelio
    mkdir -p $out/bin
    cp -r usr/lib64/modelio-open-source${lib.versions.majorMinor version}/* $out/lib/modelio/
    
    # Extract SWT native libraries
    SWT_JAR=$(find $out/lib/modelio/plugins/ -name "org.eclipse.swt.gtk.linux.x86_64_*.jar" | head -n 1)
    SWT_NATIVES_DIR=$out/lib/modelio/swt-natives
    unzip -q "$SWT_JAR" "*.so" -d "$SWT_NATIVES_DIR"
    
    # Remove the version suffix 
    find "$SWT_NATIVES_DIR" -name "libswt-*.so" | while read -r lib; do
      dir=$(dirname "$lib")
      base=$(basename "$lib" .so | sed 's/-[0-9]*r[0-9]*$//')
      mv "$lib" "$dir/$base.so"
    done
    
    # 3. Wrap the executable
    makeWrapper $out/lib/modelio/modelio.sh $out/bin/modelio \
      --prefix LD_LIBRARY_PATH : "$SWT_NATIVES_DIR" \
      --set-default SWT_GTK3 1 \
      --add-flags "-Djava.library.path=$SWT_NATIVES_DIR "
    rm -f $out/lib/modelio/gtkrc-modelio

    runHook postInstall
  '';
  
  meta = with lib; {
    description = "Free UML and BPMN modeling application";
    homepage = "https://www.modelio.org/";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}