{pkgs, ...}: let
  inherit (pkgs) lib;
  pname = "t3code";
  version = "0.0.21";

  src = pkgs.fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-eQCfskpl+JJOyaYY7ogYCi0ZCuWNRcEpseWMniS/LCQ=";
  };

  appimageContents = pkgs.appimageTools.extractType2 {
    inherit pname version src;
  };
in
  pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    nativeBuildInputs = with pkgs; [
      desktop-file-utils
    ];

    extraInstallCommands = ''
      mkdir -p $out/share
      cp -r ${appimageContents}/usr/share/icons $out/share/

      cp ${appimageContents}/t3code.desktop $out/t3code.desktop
      desktop-file-install \
        --dir $out/share/applications \
        --set-key Exec \
        --set-value t3code \
        --delete-original \
        $out/t3code.desktop
    '';

    passthru.updateScript = pkgs.nix-update-script {};

    meta = {
      description = "Desktop GUI for coding agents like Codex and Claude";
      homepage = "https://github.com/pingdotgg/t3code";
      changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${version}";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [];
      mainProgram = "t3code";
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
