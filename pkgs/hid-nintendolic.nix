{ lib, stdenv, fetchFromGitLab, kernel }:

stdenv.mkDerivation {
  pname = "hid-nintendolic";
  version = "3.2";

  src = fetchFromGitLab {
    owner = "cipitaua";
    repo = "dkms-hid-nintendolic";
    rev = "main";
    sha256 = "sha256-T0jOtk9JblNbA7eYRv4JbtS2NKpLW00A1jGWQlSSKJk=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  postPatch = ''
    substituteInPlace src/hid-nintendolic.c \
      --replace-fail "#include <asm/unaligned.h>" "#include <linux/unaligned.h>"
    '';

  buildPhase = ''
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd)/src \
      modules
  '';

  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/hid
    cp src/*.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/hid/
  '';

  meta = with lib; {
    description = "Linux HID driver for HORI Nintendo-licensed Pro Controllers";
    homepage = "https://gitlab.com/cipitaua/dkms-hid-nintendolic";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}