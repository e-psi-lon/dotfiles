{
  lib,
  ... 
}: 

{

  options.hasNvidiaGpu = lib.mkEnableOption "nvidia gpu";
}