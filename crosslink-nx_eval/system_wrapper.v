//******************************************************************************
//  file:     system_wrapper.v
//
//  author:   JAY CONVERTINO
//
//  date:     2024/11/25
//
//  about:    Brief
//  System wrapper for ps (INCOMPLETE, CURRENTLY HAS OLD MURAX CODE.. DO NOT USE).
//
//  license: License MIT
//  Copyright 2024 Jay Convertino
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//******************************************************************************

`timescale 1ns/100ps

/*
 * Module: system_wrapper
 *
 * System wrapper for (INCOMPLETE, CURRENTLY HAS OLD MURAX CODE).
 *
 */
module system_wrapper
  (
    // clock and reset
    input           clk,
    input           resetn,
    // leds
    output  [7:0]  leds,
    // slide switches
    input   [7:0]  slide_switches,
    // uart
    input           ftdi_tx,
    output          ftdi_rx,
    // jtag
    input           tck,
    input           tms,
    input           tdi,
    output          tdo
  );

  wire osc_clk;
  wire sys_clk;

  wire  [31:0]  s_apb_paddr;
  wire  [0:0]   s_apb_psel;
  wire          s_apb_penable;
  wire          s_apb_pready;
  wire          s_apb_pwrite;
  wire  [31:0]  s_apb_pwdata;
  wire  [31:0]  s_apb_prdata;
  wire          s_apb_pslverror;
  
  //75.0 MHz
  clk_osc_1 inst_clk_osc_1 (
    .hf_out_en_i(1'b1),
    .hf_clk_out_o(osc_clk)
  );

  //100 MHz
  clk_wiz_1 inst_clk_wiz_1 (
    .clkop_o(sys_clk),
    .rstn_i(resetn),
    .clki_i(osc_clk)
  );

  apb_rom  #(
    .ADDRESS_WIDTH(32),
    .BUS_WIDTH(4)
  ) inst_apb_rom (
    //clk reset
    .clk(sys_clk),
    .rst(~resetn),
    //APB3(
    .s_apb_paddr(s_apb_paddr),
    .s_apb_psel(s_apb_psel),
    .s_apb_penable(s_apb_penable),
    .s_apb_pready(s_apb_pready),
    .s_apb_pwrite(s_apb_pwrite),
    .s_apb_pwdata(s_apb_pwdata),
    .s_apb_prdata(s_apb_prdata),
    .s_apb_pslverror(s_apb_pslverror)
  );

  Murax inst_murax (
    .io_asyncReset(~resetn),
    .io_mainClk(sys_clk),
    .io_gpioA_read(slide_switches),
    .io_gpioA_write(leds),
    .io_gpioA_writeEnable(),
    .io_uart_txd(ftdi_rx),
    .io_uart_rxd(ftdi_tx),
    .io_m_apb_PADDR(s_apb_paddr),
    .io_m_apb_PSEL(s_apb_psel),
    .io_m_apb_PENABLE(s_apb_penable),
    .io_m_apb_PREADY(s_apb_pready),
    .io_m_apb_PWRITE(s_apb_pwrite),
    .io_m_apb_PWDATA(s_apb_pwdata),
    .io_m_apb_PRDATA(s_apb_prdata),
    .io_m_apb_PSLVERROR(s_apb_pslverror),
    .io_jtag_tms(tms),
    .io_jtag_tdi(tdi),
    .io_jtag_tdo(tdo),
    .io_jtag_tck(tck)
  );

endmodule
