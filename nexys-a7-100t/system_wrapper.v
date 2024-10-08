// ***************************************************************************
// ***************************************************************************
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module system
  (
`ifdef _JTAG_IO
    // jtag
    input           tck,
    input           tms,
    input           tdi,
    output          tdo,
`endif
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
    output            eth_mdc,
    inout             eth_mdio,
    input             eth_rstn,
    input             eth_crsdv,
    input             eth_rxerr,
    input   [1:0]     eth_rxd,
    output            eth_txen,
    output  [1:0]     eth_txd,
    output            eth_refclk,
    input             eth_50mclk,
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
    output            ftdi_cts,
    //qspi
    inout  [3:0]      qspi_dq,
    output            qspi_csn,
    //sd card
    output            sd_reset,
    input             sd_cd,
    output            sd_sck,
    inout             sd_cmd,
    inout  [ 3:0]     sd_dat
  );

  wire          sys_clk;
  wire          reset;

  wire          MII_col;
  wire          MII_crs;
  wire          MII_rst_n;
  wire          MII_rx_clk;
  wire          MII_rx_dv;
  wire          MII_rx_er;
  wire  [3:0]   MII_rxd;
  wire          MII_tx_clk;
  wire          MII_tx_en;
  wire  [3:0]   MII_txd;

  wire  [5:0]   s_vga_r;
  wire  [5:0]   s_vga_g;
  wire  [5:0]   s_vga_b;

  wire          s_sd_resetn;

  assign vga_r = (s_vga_r > 15 ? 4'b1111 : s_vga_r[3:0]);
  assign vga_g = (s_vga_g > 15 ? 4'b1111 : s_vga_g[3:0]);
  assign vga_b = (s_vga_b > 15 ? 4'b1111 : s_vga_b[3:0]);

  assign ftdi_cts = ftdi_rts;

  assign eth_refclk = 1'bz;

  assign sd_reset = ~s_sd_resetn;

  util_mii_to_rmii #(
    .INTF_CFG(0),
    .RATE_10_100(0)
  ) inst_util_mii_to_rmii (
    // MAC to MII(PHY)
    .mac_tx_en(MII_tx_en),
    .mac_txd(MII_txd),
    .mac_tx_er(1'b0),
    //MII to MAC
    .mii_tx_clk(MII_tx_clk),
    .mii_rx_clk(MII_rx_clk),
    .mii_col(MII_col),
    .mii_crs(MII_crs),
    .mii_rx_dv(MII_rx_dv),
    .mii_rx_er(MII_rx_er),
    .mii_rxd(MII_rxd),
    // RMII to PHY
    .rmii_txd(eth_txd),
    .rmii_tx_en(eth_txen),
    // PHY to RMII
    .phy_rxd(eth_rxd),
    .phy_crs_dv(eth_crsdv),
    .phy_rx_er(eth_rxerr),
    // External
    .ref_clk(eth_50mclk),
    .reset_n(eth_rstn)
  );

  system_ps_wrapper inst_system_ps_wrapper (
`ifdef _JTAG_IO
      // jtag
    .tck(tck),
    .tms(tms),
    .tdi(tdi),
    .tdo(tdo),
`endif
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
    .IRQ(3'b000),
    .MDIO_mdc(eth_mdc),
    .MDIO_mdio_io(eth_mdio),
    .MII_col(MII_col),
    .MII_crs(MII_crs),
    .MII_rst_n(MII_rst_n),
    .MII_rx_clk(MII_rx_clk),
    .MII_rx_dv(MII_rx_dv),
    .MII_rx_er(MII_rx_er),
    .MII_rxd(MII_rxd),
    .MII_tx_clk(MII_tx_clk),
    .MII_tx_en(MII_tx_en),
    .MII_txd(MII_txd),
    .M_AXI_araddr(),
    .M_AXI_arprot(),
    .M_AXI_arready(1'b1),
    .M_AXI_arvalid(),
    .M_AXI_awaddr(),
    .M_AXI_awprot(),
    .M_AXI_awready(1'b1),
    .M_AXI_awvalid(),
    .M_AXI_bready(),
    .M_AXI_bresp(3'b000),
    .M_AXI_bvalid(2'b00),
    .M_AXI_rdata(32'h00000000),
    .M_AXI_rready(),
    .M_AXI_rresp(3'b000),
    .M_AXI_rvalid(1'b00),
    .M_AXI_wdata(),
    .M_AXI_wready(1'b1),
    .M_AXI_wstrb(),
    .M_AXI_wvalid(),
    .QSPI_0_io0_io(qspi_dq[0]),
    .QSPI_0_io1_io(qspi_dq[1]),
    .QSPI_0_io2_io(qspi_dq[2]),
    .QSPI_0_io3_io(qspi_dq[3]),
    .QSPI_0_ss_io(qspi_csn),
    .UART_rxd(ftdi_tx),
    .UART_txd(ftdi_rx),
    .gpio_io_i(slide_switches),
    .gpio_io_o(leds),
    .gpio_io_t(),
    .s_axi_clk(),
    .spi_io0_i(1'b0),
    .spi_io0_o(),
    .spi_io0_t(),
    .spi_io1_i(1'b0),
    .spi_io1_o(),
    .spi_io1_t(),
    .spi_sck_i(1'b0),
    .spi_sck_o(),
    .spi_sck_t(),
    .spi_ss_i(1'b0),
    .spi_ss_o(),
    .spi_ss_t(),
    .sys_clk(clk),
    .sys_rstn(resetn),
    .vga_hsync(vga_hs),
    .vga_vsync(vga_vs),
    .vga_r(s_vga_r),
    .vga_g(s_vga_g),
    .vga_b(s_vga_b),
    .sd_resetn(s_sd_resetn),
    .sd_cd(sd_cd),
    .sd_sck(sd_sck),
    .sd_cmd(sd_cmd),
    .sd_dat(sd_dat)
  );
endmodule
