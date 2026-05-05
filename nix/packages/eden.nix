{
  pkgs,
  edenSrc,
  cpmCustomSources ? [],
  tzdbPath ? null,
}: let
  inherit (pkgs) lib;
  cpmCopyCommands =
    lib.concatMapStringsSep "\n" (pkg: ''
      cp -r --no-preserve=mode,ownership ${pkg.src} "$TMPDIR/${pkg.dir}"
      chmod -R u+w "$TMPDIR/${pkg.dir}"
    '')
    cpmCustomSources;

  cpmCustomFlags =
    lib.concatMapStringsSep "\n" (
      pkg: ''"-D${pkg.cmakeVar}=$TMPDIR/${pkg.dir}"''
    )
    cpmCustomSources;

  tzdbFlag = lib.optionalString (tzdbPath != null) ''
    "-DYUZU_TZDB_PATH=${tzdbPath}"
  '';
  qtWaylandDeps = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    pkgs.qt6.qtwayland
  ];
  linuxOnlyRuntimeDeps = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    pkgs.gamemode
    pkgs.discord-rpc
  ];
in
  pkgs.clangStdenv.mkDerivation {
    pname = "eden";
    version = "git";
    src = edenSrc;

    nativeBuildInputs = with pkgs; [
      cmake
      ninja
      pkg-config
      qt6.wrapQtAppsHook
      python3
      git
    ];

    buildInputs = with pkgs; [
      openssl
      boost
      fmt
      nlohmann_json
      lz4
      zlib
      zstd
      enet
      libopus
      mbedtls
      vulkan-headers
      vulkan-utility-libraries
      vulkan-loader
      spirv-tools
      spirv-headers
      vulkan-memory-allocator
      glslang
      ffmpeg-headless
      libusb1
      cubeb
      httplib
      cpp-jwt
      simpleini
      unordered_dense
      frozen
      xbyak
      SDL2
      qt6.qtbase
      qt6.qtmultimedia
      qt6.qtcharts
      qt6.qttools
      qt6.qt5compat
      qt6Packages.quazip
    ] ++ qtWaylandDeps ++ linuxOnlyRuntimeDeps;

    preConfigure = ''
      # CPM may patch these sources, so provide writable copies in TMPDIR.
      ${cpmCopyCommands}

      cmakeFlagsArray+=(
      ${cpmCustomFlags}
      ${tzdbFlag}
      )
    '';

    cmakeFlags = [
      "-GNinja"
      "-DCMAKE_BUILD_TYPE=Release"
      "-DYUZU_TESTS=OFF"
      "-DYUZU_USE_CPM=OFF"
      "-DCPMUTIL_FORCE_SYSTEM=ON"
      "-Dxbyak_FORCE_SYSTEM=ON"
      "-Dunordered_dense_FORCE_SYSTEM=ON"
      "-Dsimpleini_FORCE_SYSTEM=ON"
      "-Dmbedtls_FORCE_SYSTEM=ON"
      "-Denet_FORCE_SYSTEM=ON"
      "-DENABLE_QT=ON"
      "-DENABLE_SDL2=ON"
    ];

    # wrapQtAppsHook wraps /bin/eden for Qt runtime vars
    dontWrapQtApps = false;

    meta = {
      description = "Eden emulator packaged with pinned CPM dependencies";
      mainProgram = "eden";
    };
  }
