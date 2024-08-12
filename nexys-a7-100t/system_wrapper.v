// ***************************************************************************
// ***************************************************************************
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module system
  (
    // clock and reset
    input           clk
    input           resetn,
    // leds
    output  [15:0]  leds,
    // slide switches
    input   [15:0]  slide_switches,
    // uart
    input           ftdi_tx,
    output          ftdi_rx,
    input           ftdi_rts,
    output          ftdi_cts
  );

  wire sys_clk;
  wire reset;

  wire  [31:0]  s_apb_paddr;
  wire  [0:0]   s_apb_psel;
  wire          s_apb_penable;
  wire          s_apb_pready;
  wire          s_apb_pwrite;
  wire  [31:0]  s_apb_pwdata;
  wire  [31:0]  s_apb_prdata;
  wire          s_apb_pslverror;

  assign ftdi_cts = ftdi_rts;
  
  clk_wiz_1 inst_clk_wiz_1 (
    .clk_out1(sys_clk),
    .resetn(resetn),
    .clk_in1(clk)
  );

  sys_rstgen inst_sys_rstgen (
    .slowest_sync_clk(sys_clk),
    .ext_reset_in(resetn),
    .aux_reset_in(1'b1),
    .mb_debug_sys_rst(1'b0),
    .dcm_locked(1'b1),
    .mb_reset(),
    .bus_struct_reset(),
    .peripheral_reset(reset),
    .interconnect_aresetn(),
    .peripheral_aresetn()
  );

  //Murax inst_murax (
    //.io_asyncReset(reset),
    //.io_mainClk(sys_clk),
    //.io_gpioA_read(slide_switches),
    //.io_gpioA_write(leds),
    //.io_gpioA_writeEnable(),
    //.io_uart_txd(ftdi_rx),
    //.io_uart_rxd(ftdi_tx),
    //.io_m_apb_PADDR(s_apb_paddr),
    //.io_m_apb_PSEL(s_apb_psel),
    //.io_m_apb_PENABLE(s_apb_penable),
    //.io_m_apb_PREADY(s_apb_pready),
    //.io_m_apb_PWRITE(s_apb_pwrite),
    //.io_m_apb_PWDATA(s_apb_pwdata),
    //.io_m_apb_PRDATA(s_apb_prdata),
    //.io_m_apb_PSLVERROR(s_apb_pslverror)
  //);

  Veronica inst_veronica (
    .io_asyncReset(reset),
    .io_axiClk(sys_clk),
    //.io_vgaClk(sys_clk),
    .io_jtag_tms(),
    .io_jtag_tdi(),
    .io_jtag_tdo(),
    .io_jtag_tck(),
    .m_axi_awvalid(),
    .m_axi_awready(),
    .m_axi_awaddr(),
    .m_axi_awid(),
    .m_axi_awregion(),
    .m_axi_awlen(),
    .m_axi_awsize(),
    .m_axi_awburst(),
    .m_axi_awcache(),
    .m_axi_awprot(),
    .m_axi_wvalid(),
    .m_axi_wready(),
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wlast(),
    .m_axi_bvalid(),
    .m_axi_bready(),
    .m_axi_bid(),
    .m_axi_arvalid(),
    .m_axi_arready(),
    .m_axi_araddr(),
    .m_axi_arid(),
    .m_axi_arregion(),
    .m_axi_arlen(),
    .m_axi_arsize(),
    .m_axi_arburst(),
    .m_axi_arcache(),
    .m_axi_arprot(),
    .m_axi_rvalid(),
    .m_axi_rready(),
    .m_axi_rdata(),
    .m_axi_rid(),
    .m_axi_rlast(),
    .io_gpioA_read(),
    .io_gpioA_write(),
    .o_gpioA_writeEnable(),
    .io_gpioB_read(),
    .io_gpioB_write(),
    .io_gpioB_writeEnable(),
    .io_uart_txd(),
    .io_uart_rxd(),
    .io_vga_vSync(),
    .io_vga_hSync(),
    .io_vga_colorEn(),
    .io_vga_color_r(),
    .io_vga_color_g(),
    .io_vga_color_b(),
    .io_irq()
  );

endmodule
