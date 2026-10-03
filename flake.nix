{
  description = "Asciidoctor extension to embed Kaitai Struct definitions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};

      # Tools the extension shells out to at render time
      tools = with pkgs; [ kaitai-struct-compiler graphviz ];
    in {
      packages.default = pkgs.stdenvNoCC.mkDerivation {
        pname = "asciidoctor-kaitai-example";
        version = self.shortRev or self.dirtyShortRev or "dev";
        src = self;
        nativeBuildInputs = [ pkgs.asciidoctor pkgs.gnumake ] ++ tools;
        buildPhase = "make all test";
        installPhase = ''
          mkdir -p $out
          cp examples/example.html $out/
          cp -r examples/exports $out/
        '';
      };

      checks.default = self.packages.${system}.default;

      devShells.default = pkgs.mkShell {
        packages = [ pkgs.asciidoctor pkgs.ruby pkgs.gnumake ] ++ tools;
      };
    });
}
