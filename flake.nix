{
  description = "Custom fonts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs: let
    eachSystem = inputs.nixpkgs.lib.genAttrs ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
  in {
    packages = eachSystem (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
      mkTarball = font: let
        pname = "${font.pname}-tarball";
      in
        pkgs.runCommand "${pname}-${font.version}" {
          src = null;
          inherit (font) version;
          nativeBuildInputs = [pkgs.gnutar pkgs.findutils];
        } ''
          WORKDIR="$PWD"
          mkdir -p "$WORKDIR/share/fonts/truetype"
          cd "${font.outPath}"
          find . -type f -name "*.ttf" -print0 | xargs -0 -I {} install -Dm 444 {} "$WORKDIR/share/fonts/truetype/"
          XZ_OPT='-9' tar -cJf "$WORKDIR/${font.pname}.tar.xz" share
          mkdir -p "$out"
          cp -av "$WORKDIR/${font.pname}.tar.xz" "$out"/
        '';
    in {
      input-fixed = mkTarball (pkgs.iosevka.override {
        set = "InputFixed";
        privateBuildPlan = builtins.readFile ./plans/IosevkaInputFixed.toml;
      });
      pragmata-fixed = mkTarball (pkgs.iosevka.override {
        set = "PragmataFixed";
        privateBuildPlan = builtins.readFile ./plans/IosevkaPragmataFixed.toml;
      });
    });
  };
}
