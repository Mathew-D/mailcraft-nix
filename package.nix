{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  makeWrapper,
  # linked
  alsa-lib,
  # dlopen()ed
  dbus,
  libGL,
  vulkan-loader,
  wayland,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxrandr,
  libxkbcommon,
  libva,
}:

stdenv.mkDerivation rec {
  pname = "mailcraft";
  version = "0.12.0";

  src = appimageTools.extract {
    pname = "mailcraft";
    inherit version;
    src = fetchurl {
      url = "https://github.com/UCS-Care-Group/mailcraft/releases/download/v${version}/mailcraft-${version}-linux-x86_64.AppImage";
      hash = "sha256-BWTvCD/xI37KaCNQNN8Ju8PubrtYaf/lCdLL0J5T7FE=";
    };
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [ stdenv.cc.cc.lib alsa-lib ];

  runtimeDependencies = map lib.getLib [
    dbus
    libGL
    vulkan-loader
    wayland
    libx11
    libxcb
    libxcursor
    libxi
    libxrandr
    libxkbcommon
    libva
  ];

  appendRunpaths = [ "/run/opengl-driver/lib" ];
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin usr/bin/*
    if [ -d usr/share ]; then cp -r usr/share $out/share; fi
    runHook postInstall
  '';

  # Some apps preflight their libraries with `ldconfig -p`, which can't see the
  # RPATH above (dlopen finds them fine), then warn or refuse to start.
  postFixup = ''
    for bin in $out/bin/*; do
      var="$(basename "$bin" | tr 'a-z-' 'A-Z_')_SKIP_LIB_CHECK"
      if grep -qa "$var" "$bin"; then
        wrapProgram "$bin" --set-default "$var" 1
      fi
    done
  '';

  meta = with lib; {
    description = "Open-source, clean-room mail, calendar and contacts program in pure Rust, for Microsoft 365, Outlook.com and IMAP";
    homepage = "https://github.com/UCS-Care-Group/mailcraft";
    license = with licenses; [ asl20 ];
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    mainProgram = "mailcraft";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
