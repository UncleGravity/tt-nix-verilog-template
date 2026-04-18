{
  description = "Tiny Tapeout verilog development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    librelane.url = "github:librelane/librelane";
  };

  outputs = { self, nixpkgs, librelane }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Wrap a shell command as a flake app that re-enters the devshell so the
      # user can run `nix run .#<name>` without first running `nix develop`.
      mkDevApp = pkgs: name: cmd: {
        type = "app";
        program = toString (pkgs.writeShellScript "tt-${name}" ''
          set -e
          exec nix develop --command bash -c ${pkgs.lib.escapeShellArg cmd}
        '');
      };
    in {
      apps = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          test   = mkDevApp pkgs "test"   "cd test && make -B";
          harden = mkDevApp pkgs "harden" "./tt/tt_tool.py --harden --no-docker";
          fpga   = mkDevApp pkgs "fpga"   "./tt/tt_fpga.py harden";
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          python = pkgs.python3.withPackages (ps: [ ps.tkinter ]);
        in {
          default = pkgs.mkShell {

            # ------------------------------------------------------------------
            # DEPENDENCIES
            inputsFrom = [ librelane.devShells.${system}.default ];
            buildInputs = [
              # pkgs.librelane # included in librelane devshell
              pkgs.nextpnr
              pkgs.icestorm
              pkgs.pdk-ciel

              # Tiny Tapeout tools dependencies
              python
              pkgs.cairosvg

              # Testing
              # pkgs.iverilog # included in librelane devshell
              # pkgs.gtkwave # included in librelane devshell
              pkgs.surfer
            ];

            # ------------------------------------------------------------------
            # SHELL HOOK - runs after calling `nix develop`
            shellHook = ''
              FLAKE_ROOT=$(git rev-parse --show-toplevel)

              # Clone tt-support-tools if not present
              if [ ! -d "$FLAKE_ROOT/tt/.git" ]; then
                echo "Cloning tt-support-tools..."
                git clone https://github.com/TinyTapeout/tt-support-tools.git "$FLAKE_ROOT/tt"
              fi

              # Install tt deps
              if [ ! -d "$FLAKE_ROOT/tt/.venv" ]; then
                echo "Installing tt-support-tools python dependencies..."
                uv venv --project="$FLAKE_ROOT/tt" --python=${python} # Create venv
                uv --project="$FLAKE_ROOT/tt" sync # Install python dependencies

                echo "Installing testbench python dependencies..."
                uv --project="$FLAKE_ROOT/tt" add pytest cocotb
              fi
              source "$FLAKE_ROOT/tt/.venv/bin/activate"

              # Install sky130A PDK if not present
              export PDK_ROOT="$FLAKE_ROOT/.pdk"
              if [ ! -d "$PDK_ROOT/sky130A" ]; then
                echo "Installing sky130A PDK..."
                ciel enable --pdk-family sky130 8afc8346a57fe1ab7934ba5a6056ea8b43078e71
              fi
            '';
            # ------------------------------------------------------------------
          };
        }
      );
    };
}
