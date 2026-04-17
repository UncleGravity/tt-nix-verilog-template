# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_reset(dut):
    """After reset, digit should be 0 and uo_out should show 7-seg pattern for '0'."""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # 7-seg pattern for digit 0: 0b00111111 = 0x3F, dp off (ui_in[0]=0)
    assert dut.uo_out.value == 0x3F, f"Expected 0x3F, got {hex(dut.uo_out.value)}"

    # Turn on dot segment via ui_in[0]
    dut.ui_in.value = 1
    await ClockCycles(dut.clk, 1)
    val = int(dut.uo_out.value)
    assert val & 0x80, f"Expected dp bit set, got {hex(val)}"

    # Turn off dot segment, check dp clears while digit bits unchanged
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 1)
    val2 = int(dut.uo_out.value)
    assert not (val2 & 0x80), f"Expected dp bit clear, got {hex(val2)}"
    assert (val & 0x7F) == (val2 & 0x7F), "Lower 7 bits should match with dp toggled"
