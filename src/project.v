/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  reg [23:0] counter;
  reg [3:0]  digit;

  always @(posedge clk) begin
    if (!rst_n) begin
      counter <= 0;
      digit   <= 0;
    end else begin
      counter <= counter + 1;
      if (counter == 0) begin
        if (digit == 9)
          digit <= 0;
        else
          digit <= digit + 1;
      end
    end
  end

  // 7-segment decoder: uo_out = {dp, g, f, e, d, c, b, a}
  reg [7:0] segments;
  always @(*) begin
    case (digit)
      //                 .gfedcba
      4'd0: segments = 8'b00111111;
      4'd1: segments = 8'b00000110;
      4'd2: segments = 8'b01011011;
      4'd3: segments = 8'b01001111;
      4'd4: segments = 8'b01100110;
      4'd5: segments = 8'b01101101;
      4'd6: segments = 8'b01111101;
      4'd7: segments = 8'b00000111;
      4'd8: segments = 8'b01111111;
      4'd9: segments = 8'b01101111;
      default: segments = 8'b00000000;
    endcase
  end

  assign uo_out  = {ui_in[0], segments[6:0]};
  assign uio_out = 0;
  assign uio_oe  = 0;

  wire _unused = &{ena, ui_in, uio_in, 1'b0};

endmodule
