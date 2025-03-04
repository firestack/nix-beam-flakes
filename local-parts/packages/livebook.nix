{lib, ...}: {
  perSystem = {pkgs, ...}: let
    beamPkgs = pkgs.beam.packages.erlangR26;
  in {
    packages = let
      inherit (beamPkgs) erlang rebar3;
      elixir = beamPkgs.elixir_1_15;
      hex = beamPkgs.hex.override {inherit elixir;};
      pname = "livebook";

      mixFodDeps = beamPkgs.fetchMixDeps {
        inherit elixir src version;
        pname = "mix-deps-${pname}";
        sha256 = "sha256-3S9vcRuSRrV+Ucna9aKI0u5AXQLay1rmlBBmMRUp/4o=";
      };
      src = pkgs.fetchFromGitHub {
        owner = "livebook-dev";
        repo = "livebook";
        rev = "v${version}";
        sha256 = "sha256-ZY0p6FmyKHkPIe1+eNbCOnIunICno9COrv649GBZiiI=";
      };
      # https://github.com/livebook-dev/livebook/releases
      version = "0.11.4";
    in {
      livebook = beamPkgs.mixRelease {
        buildInputs = [];
        nativeBuildInputs = [pkgs.makeWrapper];

        inherit elixir hex mixFodDeps pname src version;

        installPhase = ''
          mix escript.build

          mkdir -p $out/bin
          cp ./livebook $out/bin

          wrapProgram $out/bin/livebook \
            --prefix PATH : ${lib.makeBinPath [elixir erlang]} \
            --set MIX_REBAR3 ${rebar3}/bin/rebar3
        '';
      };

      livebook_bumblebee = beamPkgs.mixRelease {
        buildInputs = [];
        nativeBuildInputs = [pkgs.makeWrapper];

        inherit elixir hex mixFodDeps pname src version;

        installPhase = ''
          mix escript.build

          mkdir -p $out/bin
          cp ./livebook $out/bin

          wrapProgram $out/bin/livebook \
            --prefix PATH : ${lib.makeBinPath ([elixir erlang] ++ (with pkgs; [cmake gcc gnumake]))} \
            --set MIX_REBAR3 ${rebar3}/bin/rebar3
        '';
      };
    };
  };
}
