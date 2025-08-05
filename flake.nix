{
  description = "GBDK 2020 packaged as a Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    gbdk-flake.url = "path:../gbdk-2020-flake";
  };

  outputs = { self, nixpkgs }: {
    overlays.default = final: prev: {
      gbdk-2020 = prev.stdenv.mkDerivation rec {
        pname = "gbdk-2020";
        version = "4.4.0";

        src = prev.fetchurl {
          url = "https://github.com/gbdk-2020/gbdk-2020/releases/download/4.4.0/gbdk-linux64.tar.gz";
          sha256 = "1bgd2mch35vnxflg2ac3yqjv8x80j3kp6kf1q9rzmk0hfrv2waca";
        };

        nativeBuildInputs = [ prev.patchelf ];

        phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

        installPhase = ''
          mkdir -p $out
          cp -r * $out/
        '';

        fixupPhase = ''
          find $out/bin -type f -exec file {} \; | grep "ELF" | cut -d: -f1 | while read bin; do
            echo "Patching $bin"
            patchelf --set-interpreter ${prev.glibc}/lib/ld-linux-x86-64.so.2 \
                     --set-rpath ${prev.glibc}/lib \
                     "$bin"
          done

          patchelf --set-interpreter ${prev.glibc}/lib/ld-linux-x86-64.so.2 \
                   --set-rpath ${prev.stdenv.cc.cc.lib}/lib:${prev.glibc}/lib \
                   $out/libexec/sdcc/cc1 || true
        '';

        meta = with prev.lib; {
          description = "Game Boy Development Kit 2020 (prebuilt)";
          homepage = "https://github.com/gbdk-2020/gbdk-2020";
          license = licenses.gpl3Plus;
          platforms = platforms.linux;
        };
      };
    };
  };
}
