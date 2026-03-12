{pkgs, ...}: let
  lib = pkgs.lib;
in
  pkgs.stdenvNoCC.mkDerivation rec {
    pname = "commet";
    version = "0.4.1";

    src = pkgs.fetchurl {
      url = "https://github.com/commetchat/commet/releases/download/v${version}/commet-linux-portable-x64.tar.gz";
      hash = "sha256-BHR4xnFyesYBKA7fdNxniBeI0m64/MX6dM+QXgdgwsw=";
    };

    sourceRoot = "bundle";

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = with pkgs; [
      atk
      cairo
      dbus
      ffmpeg
      fontconfig
      gdk-pixbuf
      glib
      gtk3
      harfbuzz
      keybinder3
      libdrm
      libepoxy
      libsoup_3
      mesa
      mpv
      pango
      stdenv.cc.cc.lib
      webkitgtk_4_1
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      zlib
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/libexec/commet $out/bin
      cp -r ./* $out/libexec/commet/

      makeWrapper $out/libexec/commet/commet $out/bin/commet \
        --chdir $out/libexec/commet \
        --prefix LD_LIBRARY_PATH : "$out/libexec/commet/lib:${lib.makeLibraryPath buildInputs}"

      runHook postInstall
    '';

    meta = {
      description = "Feature-rich Matrix client built with Flutter";
      homepage = "https://github.com/commetchat/commet";
      license = lib.licenses.agpl3Only;
      mainProgram = "commet";
      platforms = lib.platforms.linux;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
