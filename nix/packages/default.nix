{
  pkgs,
  eden-src,
  mcl-src,
  sirit-src,
  frozen-src,
  tzdb-src,
}: let
  cpmCustomSources = [
    {
      src = mcl-src;
      dir = "mcl";
      cmakeVar = "mcl_CUSTOM_DIR";
    }
    {
      src = sirit-src;
      dir = "sirit";
      cmakeVar = "sirit_CUSTOM_DIR";
    }
    {
      src = frozen-src;
      dir = "frozen";
      cmakeVar = "frozen_CUSTOM_DIR";
    }
  ];
in {
  eden = import ./eden.nix {
    inherit pkgs cpmCustomSources;
    edenSrc = eden-src;
    tzdbPath = tzdb-src;
  };

  commet = import ./commet.nix {
    inherit pkgs;
  };

  t3code = import ./t3code.nix {
    inherit pkgs;
  };
}
