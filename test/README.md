# Sample testbench for a Tiny Tapeout project

This is a sample testbench for a Tiny Tapeout project. It uses [cocotb](https://docs.cocotb.org/en/stable/) to drive the DUT and check the outputs.
See below to get started or for more information, check the [website](https://tinytapeout.com/hdl/testing/).

## Setting up

1. Edit [`../info.yaml`](../info.yaml) — `top_module` and `source_files` are read from there by the Makefile, so you don't edit them here.
2. Edit [tb.v](tb.v) and replace `tt_um_example` with your module name.

The Makefile requires `PDK_ROOT` to be set; the Nix devshell (`nix develop`) sets this automatically.

## How to run

RTL simulation:

```sh
make -B
```

Gate-level simulation (after running the harden flow — `./tt/tt_tool.py --harden --no-docker` from the repo root):

```sh
make -B GATES=yes
```

The Makefile picks up the netlist from `../runs/wokwi/final/pnl/<top_module>.pnl.v` automatically. If you want to test a different netlist, drop it in as `gate_level_netlist.v` and it'll be used instead.

If you wish to save the waveform in VCD format instead of FST, edit `tb.v` to use `$dumpfile("tb.vcd");` and then run:

```sh
make -B FST=
```

## How to view the waveform file

Waveforms are written under `sim_build/rtl/tb.fst` (RTL) or `sim_build/gl/tb.fst` (gate-level).

Using GTKWave

```sh
gtkwave sim_build/rtl/tb.fst tb.gtkw
```

Using Surfer

```sh
surfer sim_build/rtl/tb.fst
```
