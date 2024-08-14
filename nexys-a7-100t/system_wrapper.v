// ***************************************************************************
// ***************************************************************************
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module system
  (
    // clock and reset
    input             clk,
    input             resetn,
    //ddr2
    inout   [12:0]    ddr2_addr,
    inout   [ 2:0]    ddr2_ba,
    inout             ddr2_cas_n,
    inout             ddr2_ck_n,
    inout             ddr2_ck_p,
    inout             ddr2_cke,
    inout             ddr2_cs_n,
    inout   [ 1:0]    ddr2_dm,
    inout   [15:0]    ddr2_dq,
    inout   [ 1:0]    ddr2_dqs_n,
    inout   [ 1:0]    ddr2_dqs_p,
    inout             ddr2_odt,
    inout             ddr2_ras_n,
    inout             ddr2_reset_n,
    inout             ddr2_we_n,
    //ethernet
    //output            eth_mdc,
    //inout             eth_mdio,
    //input             eth_rstn,
    //input             eth_crsdv,
    //input             eth_rxerr,
    //input   [1:0]     eth_rxd,
    //output            eth_txen,
    //output  [1:0]     eth_txd,
    //output            eth_refclk,
    //input             eth_50mclk,
    //pmod for spi
    output            pmod_ja_ncs,
    output            pmod_ja_mosi,
    input             pmod_ja_miso,
    output            pmod_ja_sck,
    //vga
    output  [ 3:0]    vga_r,
    output  [ 3:0]    vga_g,
    output  [ 3:0]    vga_b,
    output            vga_hs,
    output            vga_vs,
    // leds
    output  [15:0]    leds,
    // slide switches
    input   [15:0]    slide_switches,
    // uart
    input             ftdi_tx,
    output            ftdi_rx,
    input             ftdi_rts,
    output            ftdi_cts
  );

  wire          sys_clk;
  wire          reset;
  wire  [ 2:0]  s_vga_r;
  wire  [ 2:0]  s_vga_b;
  wire  [ 2:0]  s_vga_g;
  wire  [ 7:0]  s_spi_ss;

  //vga
  assign vga_r = {s_vga_r, 1'b0};
  assign vga_g = {s_vga_g, 1'b0};
  assign vga_b = {s_vga_b, 2'b00};

  //spi
  assign pmod_ja_ncs = s_spi_ss[0];

  //uart
  assign ftdi_cts = ftdi_rts;

  //assign eth_refclk = 1'bz;

  system_ps_wrapper inst_system_ps_wrapper (
    .DDR_addr(ddr2_addr),
    .DDR_ba(ddr2_ba),
    .DDR_cas_n(ddr2_cas_n),
    .DDR_ck_n(ddr2_ck_n),
    .DDR_ck_p(ddr2_ck_p),
    .DDR_cke(ddr2_cke),
    .DDR_cs_n(ddr2_cs_n),
    .DDR_dm(ddr2_dm),
    .DDR_dq(ddr2_dq),
    .DDR_dqs_n(ddr2_dqs_n),
    .DDR_dqs_p(ddr2_dqs_p),
    .DDR_odt(ddr2_odt),
    .DDR_ras_n(ddr2_ras_n),
    .DDR_we_n(ddr2_we_n),
    .IRQ(0),
    .M_AXI_araddr(),
    .M_AXI_arprot(),
    .M_AXI_arready(1'b0),
    .M_AXI_arvalid(),
    .M_AXI_awaddr(),
    .M_AXI_awprot(),
    .M_AXI_awready(1'b0),
    .M_AXI_awvalid(),
    .M_AXI_bready(),
    .M_AXI_bresp(3'b000),
    .M_AXI_bvalid(2'b00),
    .M_AXI_rdata(32'h00000000),
    .M_AXI_rready(),
    .M_AXI_rresp(3'b000),
    .M_AXI_rvalid(1'b00),
    .M_AXI_wdata(),
    .M_AXI_wready(1'b0),
    .M_AXI_wstrb(),
    .M_AXI_wvalid(),
    .s_axi_dma_arstn(1'b1),
    .s_axi_dma_aclk(1'b0),
    .s_axi_dma_araddr(32'h00000000),
    .s_axi_dma_arcache(4'b0000),
    .s_axi_dma_arlen(8'b00000000),
    .s_axi_dma_arprot(3'b000),
    .s_axi_dma_arready(),
    .s_axi_dma_arsize(3'b000),
    .s_axi_dma_arvalid(1'b0),
    .s_axi_dma_awaddr(32'h00000000),
    .s_axi_dma_awcache(4'b0000),
    .s_axi_dma_awlen(8'b00000000),
    .s_axi_dma_awprot(3'b000),
    .s_axi_dma_awready(),
    .s_axi_dma_awsize(3'b000),
    .s_axi_dma_awvalid(1'b0),
    .s_axi_dma_bready(1'b0),
    .s_axi_dma_bvalid(),
    .s_axi_dma_rdata(),
    .s_axi_dma_rlast(),
    .s_axi_dma_rready(1'b0),
    .s_axi_dma_rvalid(),
    .s_axi_dma_wdata(32'h00000000),
    .s_axi_dma_wlast(1'b0),
    .s_axi_dma_wready(),
    .s_axi_dma_wstrb(4'b0000),
    .s_axi_dma_wvalid(1'b0),
    .UART_rxd(ftdi_tx),
    .UART_txd(ftdi_rx),
    .gpio0_io_i(slide_switches),
    .gpio0_io_o(leds),
    .gpio0_io_t(),
    .gpio1_io_i(0),
    .gpio1_io_o(),
    .gpio1_io_t(),
    .s_axi_clk(),
    .spi_ss(s_spi_ss),
    .spi_sclk(pmod_ja_sck),
    .spi_mosi(pmod_ja_mosi),
    .spi_miso(pmod_ja_miso),
    .sys_clk(clk),
    .sys_rstn(resetn),
    .vga_vSync(vga_vs),
    .vga_hSync(vga_hs),
    .vga_colorEn(),
    .vga_color_r(s_vga_r),
    .vga_color_g(s_vga_g),
    .vga_color_b(s_vga_b)
  );
endmodule
