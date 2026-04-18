![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout Verilog Template (Nix)

A Tiny Tapeout Verilog project template with a Nix flake for one-command setup. Aims to replace the upstream devcontainer / manual-install flow with a single `nix develop` on macOS and Linux.

> Based on the [official TT Verilog template](https://github.com/TinyTapeout/tt10-verilog-template).

## TLDR:
```sh
# After installing Nix:
nix run nixpkgs#cachix -- use librelane # Use librelane binary cache
nix develop                             # Enter dev shell with all dependencies
./tt/tt_tool.py --harden --no-docker    # Harden silicon
./tt/tt_fpga.py harden                  # Harden FPGA bitstream
./tt/tt_fpga.py configure --port /dev/<your-tty> --upload --clockrate 12000000
cd test && make -B                      # RTL test
cd test && make -B GATES=yes            # gate-level test (needs prior harden)
```

## What you get

- `nix develop` — full EDA toolchain (librelane, yosys, iverilog, klayout, openroad, magic, netgen, verilator, nextpnr, icestorm) plus `tt-support-tools` and the sky130A PDK, installed automatically on first enter.
- `nix run .#test` / `.#harden` / `.#fpga` — the common workflows as one-liners.
- Works on `aarch64-darwin`, `x86_64-linux`, `aarch64-linux`.

## Prerequisites

1. [Install Nix](https://github.com/DeterminateSystems/nix-installer) (the Determinate installer is a good choice. It enables flakes by default).
   ```sh
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```
2. If you installed upstream Nix instead, enable flakes:
   ```sh
   mkdir -p ~/.config/nix
   echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
   ```
3. Enable the LibreLane binary cache so the first `nix develop` doesn't build an entire EDA stack from source:
   ```sh
   nix run nixpkgs#cachix -- use librelane
   ```

## Quick start

```sh
# Use this repo as a template on GitHub, then:
git clone git@github.com:<you>/<your-project>.git
cd <your-project>
nix develop
```

First enter takes a few minutes (downloads prebuilt tools from the cache, clones `tt-support-tools`, creates the Python venv, installs the sky130A PDK into `.pdk/`). Subsequent enters are instant.

## Common tasks

All runnable from the project root without first entering the devshell:

| Command | What it does |
|---|---|
| `nix run .#test`   | RTL simulation (cocotb + icarus), equivalent to `cd test && make -B` |
| `nix run .#harden` | ASIC harden flow for Tiny Tapeout (`tt/tt_tool.py --harden --no-docker`) |
| `nix run .#fpga`   | FPGA bitstream build for the TT FPGA breakout (`tt/tt_fpga.py harden`) |

## Making it yours

1. Put your Verilog under `src/` (the default `project.v` is a stub).
2. Edit `info.yaml` — `top_module`, `source_files`, project metadata. See the [info.yaml migration tool](https://tinytapeout.github.io/tt-yaml-upgrade-tool/).
3. Describe the design in `docs/info.md`.
4. Adapt the testbench in `test/tb.v` and `test/test.py`. See [test/README.md](test/README.md).

## CI

The upstream GitHub Actions workflows (`.github/workflows/{gds,docs,test,fpga}.yaml`) are unchanged and continue to build on TT's hosted runners — they don't depend on this flake.

## Resources

- [Tiny Tapeout](https://tinytapeout.com) · [FAQ](https://tinytapeout.com/faq/) · [Discord](https://tinytapeout.com/discord)
- [Local hardening guide](https://www.tinytapeout.com/guides/local-hardening/) · [FPGA breakout guide](https://tinytapeout.com/guides/fpga-breakout/)
- [LibreLane docs](https://librelane.readthedocs.io/en/stable/)
- [Submit to the next shuttle](https://app.tinytapeout.com/)
