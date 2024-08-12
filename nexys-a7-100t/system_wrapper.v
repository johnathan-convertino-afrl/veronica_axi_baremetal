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
    .m_axi_mbus_awvalid(),
    .m_axi_mbus_awready(),
    .m_axi_mbus_awaddr(),
    .m_axi_mbus_awid(),
    .m_axi_mbus_awregion(),
    .m_axi_mbus_awlen(),
    .m_axi_mbus_awsize(),
    .m_axi_mbus_awburst(),
    .m_axi_mbus_awcache(),
    .m_axi_mbus_awprot(),
    .m_axi_mbus_wvalid(),
    .m_axi_mbus_wready(),
    .m_axi_mbus_wdata(),
    .m_axi_mbus_wstrb(),
    .m_axi_mbus_wlast(),
    .m_axi_mbus_bvalid(),
    .m_axi_mbus_bready(),
    .m_axi_mbus_bid(),
    .m_axi_mbus_arvalid(),
    .m_axi_mbus_arready(),
    .m_axi_mbus_araddr(),
    .m_axi_mbus_arid(),
    .m_axi_mbus_arregion(),
    .m_axi_mbus_arlen(),
    .m_axi_mbus_arsize(),
    .m_axi_mbus_arburst(),
    .m_axi_mbus_arcache(),
    .m_axi_mbus_arprot(),
    .m_axi_mbus_rvalid(),
    .m_axi_mbus_rready(),
    .m_axi_mbus_rdata(),
    .m_axi_mbus_rid(),
    .m_axi_mbus_rlast(),
    .m_axi_acc_awvalid(),
    .m_axi_acc_awready(),
    .m_axi_acc_awaddr(),
    .m_axi_acc_awprot(),
    .m_axi_acc_wvalid(),
    .m_axi_acc_wready(),
    .m_axi_acc_wdata(),
    .m_axi_acc_wstrb(),
    .m_axi_acc_bvalid(),
    .m_axi_acc_bready(),
    .m_axi_acc_bresp(),
    .m_axi_acc_arvalid(),
    .m_axi_acc_arready(),
    .m_axi_acc_araddr(),
    .m_axi_acc_arprot(),
    .m_axi_acc_rvalid(),
    .m_axi_acc_rready(),
    .m_axi_acc_rdata(),
    .m_axi_acc_rresp(),
    .io_gpioA_read(),
    .io_gpioA_write(),
    .io_gpioA_writeEnable(),
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
