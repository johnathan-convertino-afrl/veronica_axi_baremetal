//******************************************************************************
/// @FILE    system_ps_wrapper.v
/// @AUTHOR  JAY CONVERTINO
/// @DATE    2024.07.30
/// @BRIEF   System wrapper for ps.
///
/// @LICENSE MIT
///  Copyright 2024 Jay Convertino
///
///  Permission is hereby granted, free of charge, to any person obtaining a copy
///  of this software and associated documentation files (the "Software"), to
///  deal in the Software without restriction, including without limitation the
///  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
///  sell copies of the Software, and to permit persons to whom the Software is
///  furnished to do so, subject to the following conditions:
///
///  The above copyright notice and this permission notice shall be included in
///  all copies or substantial portions of the Software.
///
///  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
///  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
///  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
///  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
///  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
///  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
///  IN THE SOFTWARE.
//******************************************************************************
`timescale 1ns/100ps

module system_ps_wrapper
  (
`ifdef _JTAG_IO
    input           tck,
    input           tms,
    input           tdi,
    output          tdo,
`endif
    output    [12:0]    DDR_addr,
    output    [ 2:0]    DDR_ba,
    output              DDR_cas_n,
    output    [ 0:0]    DDR_ck_n,
    output    [ 0:0]    DDR_ck_p,
    output    [ 0:0]    DDR_cke,
    output    [ 0:0]    DDR_cs_n,
    output    [ 1:0]    DDR_dm,
    inout     [15:0]    DDR_dq,
    inout     [ 1:0]    DDR_dqs_n,
    inout     [ 1:0]    DDR_dqs_p,
    output    [ 0:0]    DDR_odt,
    output              DDR_ras_n,
    output              DDR_we_n,
    input     [ 2:0]    IRQ,
    output              MDIO_mdc,
    inout               MDIO_mdio_io,
    input               MII_col,
    input               MII_crs,
    output              MII_rst_n,
    input               MII_rx_clk,
    input               MII_rx_dv,
    input               MII_rx_er,
    input     [ 3:0]    MII_rxd,
    input               MII_tx_clk,
    output              MII_tx_en,
    output    [ 3:0]    MII_txd,
    output    [31:0]    M_AXI_araddr,
    output    [ 2:0]    M_AXI_arprot,
    input               M_AXI_arready,
    output              M_AXI_arvalid,
    output    [31:0]    M_AXI_awaddr,
    output    [ 2:0]    M_AXI_awprot,
    input               M_AXI_awready,
    output              M_AXI_awvalid,
    output              M_AXI_bready,
    input     [ 1:0]    M_AXI_bresp,
    input               M_AXI_bvalid,
    input     [31:0]    M_AXI_rdata,
    output              M_AXI_rready,
    input     [ 1:0]    M_AXI_rresp,
    input               M_AXI_rvalid,
    output    [31:0]    M_AXI_wdata,
    input               M_AXI_wready,
    output    [ 3:0]    M_AXI_wstrb,
    output              M_AXI_wvalid,
    inout               QSPI_0_io0_io,
    inout               QSPI_0_io1_io,
    inout               QSPI_0_io2_io,
    inout               QSPI_0_io3_io,
    inout     [ 0:0]    QSPI_0_ss_io,
    input               UART_rxd,
    output              UART_txd,
    input     [31:0]    gpio_io_i,
    output    [31:0]    gpio_io_o,
    output    [31:0]    gpio_io_t,
    output              s_axi_clk,
    input               spi_io0_i,
    output              spi_io0_o,
    output              spi_io0_t,
    input               spi_io1_i,
    output              spi_io1_o,
    output              spi_io1_t,
    input               spi_sck_i,
    output              spi_sck_o,
    output              spi_sck_t,
    input     [ 0:0]    spi_ss_i,
    output    [ 0:0]    spi_ss_o,
    output              spi_ss_t,
    input               sys_clk,
    input               sys_rstn,
    output              vga_hsync,
    output              vga_vsync,
    output    [ 5:0]    vga_r,
    output    [ 5:0]    vga_g,
    output    [ 5:0]    vga_b,
    output              sd_resetn,
    input               sd_cd,
    output              sd_sck,
    inout               sd_cmd,
    inout     [ 3:0]    sd_dat
  );

  //ethernet buf signals
  wire           MDIO_mdio_i;
  wire           MDIO_mdio_o;
  wire           MDIO_mdio_t;

  //quad spi buf signals
  wire           QSPI_0_io0_i;
  wire           QSPI_0_io0_o;
  wire           QSPI_0_io0_t;
  wire           QSPI_0_io1_i;
  wire           QSPI_0_io1_o;
  wire           QSPI_0_io1_t;
  wire           QSPI_0_io2_i;
  wire           QSPI_0_io2_o;
  wire           QSPI_0_io2_t;
  wire           QSPI_0_io3_i;
  wire           QSPI_0_io3_o;
  wire           QSPI_0_io3_t;
  wire [ 0:0]    QSPI_0_ss_i_0;
  wire [ 0:0]    QSPI_0_ss_o_0;

  //clocks
  wire           axi_cpu_clk;
  wire           ddr_clk;
  wire           tft_clk;

  //resets
  wire [ 0:0]    ddr_rstgen_peripheral_aresetn;
  wire [ 0:0]    ddr_rstgen_peripheral_reset;
  wire [ 0:0]    sys_rstgen_interconnect_aresetn;
  wire [ 0:0]    sys_rstgen_peripheral_aresetn;
  wire [ 0:0]    sys_rstgen_peripheral_reset;
  wire           debug_rst;

  //ddr signals and clocks
  wire           axi_ddr_ctrl_mmcm_locked;
  wire           axi_ddr_ctrl_ui_clk;
  wire           axi_ddr_ctrl_ui_clk_sync_rst;

  //irq
  wire           axi_uartlite_irq;
  wire           axi_ethernet_irq;
  wire           axi_quad_spi_irq;
  wire           axi_tft_irq;
  wire           axi_timer_irq;

  //axi lite ethernet
  wire [31:0]    m_axi_eth_ARADDR;
  wire           m_axi_eth_ARREADY;
  wire           m_axi_eth_ARVALID;
  wire [31:0]    m_axi_eth_AWADDR;
  wire           m_axi_eth_AWREADY;
  wire           m_axi_eth_AWVALID;
  wire           m_axi_eth_BREADY;
  wire [ 1:0]    m_axi_eth_BRESP;
  wire           m_axi_eth_BVALID;
  wire [31:0]    m_axi_eth_RDATA;
  wire           m_axi_eth_RREADY;
  wire [ 1:0]    m_axi_eth_RRESP;
  wire           m_axi_eth_RVALID;
  wire [31:0]    m_axi_eth_WDATA;
  wire           m_axi_eth_WREADY;
  wire [ 3:0]    m_axi_eth_WSTRB;
  wire           m_axi_eth_WVALID;

  //axi lite gpio
  wire [31:0]    m_axi_gpio_ARADDR;
  wire           m_axi_gpio_ARREADY;
  wire           m_axi_gpio_ARVALID;
  wire [31:0]    m_axi_gpio_AWADDR;
  wire           m_axi_gpio_AWREADY;
  wire           m_axi_gpio_AWVALID;
  wire           m_axi_gpio_BREADY;
  wire [ 1:0]    m_axi_gpio_BRESP;
  wire           m_axi_gpio_BVALID;
  wire [31:0]    m_axi_gpio_RDATA;
  wire           m_axi_gpio_RREADY;
  wire [ 1:0]    m_axi_gpio_RRESP;
  wire           m_axi_gpio_RVALID;
  wire [31:0]    m_axi_gpio_WDATA;
  wire           m_axi_gpio_WREADY;
  wire [ 3:0]    m_axi_gpio_WSTRB;
  wire           m_axi_gpio_WVALID;

  //axi lite perf (dbus only)
  wire [31:0]    s_axi_perf_ARADDR;
  wire           s_axi_perf_ARREADY;
  wire           s_axi_perf_ARVALID;
  wire [31:0]    s_axi_perf_AWADDR;
  wire           s_axi_perf_AWREADY;
  wire           s_axi_perf_AWVALID;
  wire           s_axi_perf_BREADY;
  wire [ 1:0]    s_axi_perf_BRESP;
  wire           s_axi_perf_BVALID;
  wire [31:0]    s_axi_perf_RDATA;
  wire           s_axi_perf_RREADY;
  wire [ 1:0]    s_axi_perf_RRESP;
  wire           s_axi_perf_RVALID;
  wire [31:0]    s_axi_perf_WDATA;
  wire           s_axi_perf_WREADY;
  wire [ 3:0]    s_axi_perf_WSTRB;
  wire           s_axi_perf_WVALID;
  wire [ 2:0]    s_axi_perf_APROT;
  wire [ 2:0]    s_axi_perf_AWPROT;

  //axi4 w/ID memory bus (ibus/dbus path)
  wire [31:0]    s_axi_mbus_ARADDR;
  wire [ 1:0]    s_axi_mbus_ARBURST;
  wire [ 3:0]    s_axi_mbus_ARCACHE;
  wire [ 3:0]    s_axi_mbus_ARID;
  wire [ 7:0]    s_axi_mbus_ARLEN;
  wire [ 2:0]    s_axi_mbus_ARPROT;
  wire           s_axi_mbus_ARREADY;
  wire [ 2:0]    s_axi_mbus_ARSIZE;
  wire           s_axi_mbus_ARVALID;
  wire [31:0]    s_axi_mbus_AWADDR;
  wire [ 1:0]    s_axi_mbus_AWBURST;
  wire [ 3:0]    s_axi_mbus_AWCACHE;
  wire [ 3:0]    s_axi_mbus_AWID;
  wire [ 7:0]    s_axi_mbus_AWLEN;
  wire [ 2:0]    s_axi_mbus_AWPROT;
  wire           s_axi_mbus_AWREADY;
  wire [ 2:0]    s_axi_mbus_AWSIZE;
  wire           s_axi_mbus_AWVALID;
  wire [ 3:0]    s_axi_mbus_BID;
  wire           s_axi_mbus_BREADY;
  wire           s_axi_mbus_BVALID;
  wire [31:0]    s_axi_mbus_RDATA;
  wire [ 3:0]    s_axi_mbus_RID;
  wire           s_axi_mbus_RLAST;
  wire           s_axi_mbus_RREADY;
  wire           s_axi_mbus_RVALID;
  wire [31:0]    s_axi_mbus_WDATA;
  wire           s_axi_mbus_WLAST;
  wire           s_axi_mbus_WREADY;
  wire [ 3:0]    s_axi_mbus_WSTRB;
  wire           s_axi_mbus_WVALID;
  wire [ 0:0]    s_axi_mbus_ARLOCK;
  wire [ 3:0]    s_axi_mbus_ARQOS;
  wire [ 0:0]    s_axi_mbus_AWLOCK;
  wire [ 3:0]    s_axi_mbus_AWQOS;
  wire [ 1:0]    s_axi_mbus_RRESP;
  wire [ 1:0]    s_axi_mbus_BRESP;

  //axi4 w/ID memory bus DDR (ibus/dbus path)
  wire [31:0]    m_axi_ddr_ARADDR;
  wire [ 1:0]    m_axi_ddr_ARBURST;
  wire [ 3:0]    m_axi_ddr_ARCACHE;
  wire [ 3:0]    m_axi_ddr_ARID;
  wire [ 7:0]    m_axi_ddr_ARLEN;
  wire [ 2:0]    m_axi_ddr_ARPROT;
  wire           m_axi_ddr_ARREADY;
  wire [ 2:0]    m_axi_ddr_ARSIZE;
  wire           m_axi_ddr_ARVALID;
  wire [31:0]    m_axi_ddr_AWADDR;
  wire [ 1:0]    m_axi_ddr_AWBURST;
  wire [ 3:0]    m_axi_ddr_AWCACHE;
  wire [ 3:0]    m_axi_ddr_AWID;
  wire [ 7:0]    m_axi_ddr_AWLEN;
  wire [ 2:0]    m_axi_ddr_AWPROT;
  wire           m_axi_ddr_AWREADY;
  wire [ 2:0]    m_axi_ddr_AWSIZE;
  wire           m_axi_ddr_AWVALID;
  wire [ 3:0]    m_axi_ddr_BID;
  wire           m_axi_ddr_BREADY;
  wire           m_axi_ddr_BVALID;
  wire [31:0]    m_axi_ddr_RDATA;
  wire [ 3:0]    m_axi_ddr_RID;
  wire           m_axi_ddr_RLAST;
  wire           m_axi_ddr_RREADY;
  wire           m_axi_ddr_RVALID;
  wire [31:0]    m_axi_ddr_WDATA;
  wire           m_axi_ddr_WLAST;
  wire           m_axi_ddr_WREADY;
  wire [ 3:0]    m_axi_ddr_WSTRB;
  wire           m_axi_ddr_WVALID;
  wire [ 0:0]    m_axi_ddr_ARLOCK;
  wire [ 3:0]    m_axi_ddr_ARQOS;
  wire [ 0:0]    m_axi_ddr_AWLOCK;
  wire [ 3:0]    m_axi_ddr_AWQOS;
  wire [ 1:0]    m_axi_ddr_RRESP;
  wire [ 1:0]    m_axi_ddr_BRESP;

  //axi lite qspi
  wire [31:0]    m_axi_qspi_ARADDR;
  wire           m_axi_qspi_ARREADY;
  wire           m_axi_qspi_ARVALID;
  wire [31:0]    m_axi_qspi_AWADDR;
  wire           m_axi_qspi_AWREADY;
  wire           m_axi_qspi_AWVALID;
  wire           m_axi_qspi_BREADY;
  wire [ 1:0]    m_axi_qspi_BRESP;
  wire           m_axi_qspi_BVALID;
  wire [31:0]    m_axi_qspi_RDATA;
  wire           m_axi_qspi_RREADY;
  wire [ 1:0]    m_axi_qspi_RRESP;
  wire           m_axi_qspi_RVALID;
  wire [31:0]    m_axi_qspi_WDATA;
  wire           m_axi_qspi_WREADY;
  wire [ 3:0]    m_axi_qspi_WSTRB;
  wire           m_axi_qspi_WVALID;

  //axi lite spi
  wire [31:0]    m_axi_spi_ARADDR;
  wire           m_axi_spi_ARREADY;
  wire           m_axi_spi_ARVALID;
  wire [31:0]    m_axi_spi_AWADDR;
  wire           m_axi_spi_AWREADY;
  wire           m_axi_spi_AWVALID;
  wire           m_axi_spi_BREADY;
  wire [ 1:0]    m_axi_spi_BRESP;
  wire           m_axi_spi_BVALID;
  wire [31:0]    m_axi_spi_RDATA;
  wire           m_axi_spi_RREADY;
  wire [ 1:0]    m_axi_spi_RRESP;
  wire           m_axi_spi_RVALID;
  wire [31:0]    m_axi_spi_WDATA;
  wire           m_axi_spi_WREADY;
  wire [ 3:0]    m_axi_spi_WSTRB;
  wire           m_axi_spi_WVALID;

  //axi lite uart
  wire [31:0]    m_axi_uart_ARADDR;
  wire           m_axi_uart_ARREADY;
  wire           m_axi_uart_ARVALID;
  wire [31:0]    m_axi_uart_AWADDR;
  wire           m_axi_uart_AWREADY;
  wire           m_axi_uart_AWVALID;
  wire           m_axi_uart_BREADY;
  wire [ 1:0]    m_axi_uart_BRESP;
  wire           m_axi_uart_BVALID;
  wire [31:0]    m_axi_uart_RDATA;
  wire           m_axi_uart_RREADY;
  wire [ 1:0]    m_axi_uart_RRESP;
  wire           m_axi_uart_RVALID;
  wire [31:0]    m_axi_uart_WDATA;
  wire           m_axi_uart_WREADY;
  wire [ 3:0]    m_axi_uart_WSTRB;
  wire           m_axi_uart_WVALID;

  //axi lite timer
  wire [31:0]    m_axi_timer_ARADDR;
  wire           m_axi_timer_ARREADY;
  wire           m_axi_timer_ARVALID;
  wire [31:0]    m_axi_timer_AWADDR;
  wire           m_axi_timer_AWREADY;
  wire           m_axi_timer_AWVALID;
  wire           m_axi_timer_BREADY;
  wire [ 1:0]    m_axi_timer_BRESP;
  wire           m_axi_timer_BVALID;
  wire [31:0]    m_axi_timer_RDATA;
  wire           m_axi_timer_RREADY;
  wire [ 1:0]    m_axi_timer_RRESP;
  wire           m_axi_timer_RVALID;
  wire [31:0]    m_axi_timer_WDATA;
  wire           m_axi_timer_WREADY;
  wire [ 3:0]    m_axi_timer_WSTRB;
  wire           m_axi_timer_WVALID;

  //axi lite tft vga controller
  wire [31:0]    m_axi_vga_ARADDR;
  wire           m_axi_vga_ARREADY;
  wire           m_axi_vga_ARVALID;
  wire [31:0]    m_axi_vga_AWADDR;
  wire           m_axi_vga_AWREADY;
  wire           m_axi_vga_AWVALID;
  wire           m_axi_vga_BREADY;
  wire [ 1:0]    m_axi_vga_BRESP;
  wire           m_axi_vga_BVALID;
  wire [31:0]    m_axi_vga_RDATA;
  wire           m_axi_vga_RREADY;
  wire [ 1:0]    m_axi_vga_RRESP;
  wire           m_axi_vga_RVALID;
  wire [31:0]    m_axi_vga_WDATA;
  wire           m_axi_vga_WREADY;
  wire [ 3:0]    m_axi_vga_WSTRB;
  wire           m_axi_vga_WVALID;

  //dma1 tft vga
  wire [31:0]   s_axi_dma_vga_araddr;
  wire [ 3:0]   s_axi_dma_vga_arcache;
  wire [ 7:0]   s_axi_dma_vga_arlen;
  wire [ 2:0]   s_axi_dma_vga_arprot;
  wire          s_axi_dma_vga_arready;
  wire [ 2:0]   s_axi_dma_vga_arsize;
  wire          s_axi_dma_vga_arvalid;
  wire [ 1:0]   s_axi_dma_vga_arburst;
  wire [31:0]   s_axi_dma_vga_awaddr;
  wire [ 3:0]   s_axi_dma_vga_awcache;
  wire [ 7:0]   s_axi_dma_vga_awlen;
  wire [ 2:0]   s_axi_dma_vga_awprot;
  wire          s_axi_dma_vga_awready;
  wire [ 2:0]   s_axi_dma_vga_awsize;
  wire          s_axi_dma_vga_awvalid;
  wire [ 1:0]   s_axi_dma_vga_awburst;
  wire          s_axi_dma_vga_bready;
  wire          s_axi_dma_vga_bvalid;
  wire [ 1:0]   s_axi_dma_vga_bresp;
  wire [31:0]   s_axi_dma_vga_rdata;
  wire          s_axi_dma_vga_rlast;
  wire          s_axi_dma_vga_rready;
  wire          s_axi_dma_vga_rvalid;
  wire [ 1:0]   s_axi_dma_vga_rresp;
  wire [31:0]   s_axi_dma_vga_wdata;
  wire          s_axi_dma_vga_wlast;
  wire          s_axi_dma_vga_wready;
  wire [ 3:0]   s_axi_dma_vga_wstrb;
  wire          s_axi_dma_vga_wvalid;
  wire [ 3:0]   s_axi_dma_vga_bid; //dummy
  wire [ 3:0]   s_axi_dma_vga_rid; //dummy

  //sdio
  //axi lite
  wire          m_axi_sdio_awvalid;
  wire          m_axi_sdio_awready;
  wire [ 4:0]   m_axi_sdio_awaddr;
  wire [ 2:0]   m_axi_sdio_awprot;
  wire          m_axi_sdio_wvalid;
  wire          m_axi_sdio_wready;
  wire [31:0]   m_axi_sdio_wdata;
  wire [ 3:0]   m_axi_sdio_wstrb;
  wire          m_axi_sdio_bvalid;
  wire          m_axi_sdio_bready;
  wire [ 1:0]   m_axi_sdio_bresp;
  wire          m_axi_sdio_arvalid;
  wire          m_axi_sdio_arready;
  wire [ 4:0]   m_axi_sdio_araddr;
  wire [ 2:0]   m_axi_sdio_arprot;
  wire          m_axi_sdio_rvalid;
  wire          m_axi_sdio_rready;
  wire [31:0]   m_axi_sdio_rdata;
  wire [ 1:0]   m_axi_sdio_rresp;
  //dma to xclk
  wire          s_axi_dma_sdio_awvalid;
  wire          s_axi_dma_sdio_awready;
  wire [ 3:0]   s_axi_dma_sdio_awid;
  wire [31:0]   s_axi_dma_sdio_awaddr;
  wire [ 7:0]   s_axi_dma_sdio_awlen;
  wire [ 2:0]   s_axi_dma_sdio_awsize;
  wire [ 1:0]   s_axi_dma_sdio_awburst;
  wire          s_axi_dma_sdio_awlock;
  wire [ 3:0]   s_axi_dma_sdio_awcache;
  wire [ 2:0]   s_axi_dma_sdio_awprot;
  wire [ 3:0]   s_axi_dma_sdio_awqos;
  wire          s_axi_dma_sdio_wvalid;
  wire          s_axi_dma_sdio_wready;
  wire [31:0]   s_axi_dma_sdio_wdata;
  wire [ 3:0]   s_axi_dma_sdio_wstrb;
  wire          s_axi_dma_sdio_wlast;
  wire          s_axi_dma_sdio_bvalid;
  wire          s_axi_dma_sdio_bready;
  wire [ 3:0]   s_axi_dma_sdio_bid;
  wire [ 1:0]   s_axi_dma_sdio_bresp;
  wire          s_axi_dma_sdio_arvalid;
  wire          s_axi_dma_sdio_arready;
  wire [ 3:0]   s_axi_dma_sdio_arid;
  wire [31:0]   s_axi_dma_sdio_araddr;
  wire [ 7:0]   s_axi_dma_sdio_arlen;
  wire [ 2:0]   s_axi_dma_sdio_arsize;
  wire [ 1:0]   s_axi_dma_sdio_arburst;
  wire          s_axi_dma_sdio_arlock;
  wire [ 3:0]   s_axi_dma_sdio_arcache;
  wire [ 2:0]   s_axi_dma_sdio_arprot;
  wire [ 3:0]   s_axi_dma_sdio_arqos;
  wire          s_axi_dma_sdio_rvalid;
  wire          s_axi_dma_sdio_rready;
  wire [ 3:0]   s_axi_dma_sdio_rid;
  wire [31:0]   s_axi_dma_sdio_rdata;
  wire          s_axi_dma_sdio_rlast;
  wire [ 1:0]   s_axi_dma_sdio_rresp;
  //dma to mbusxbar
  wire [ 3:0]   s_axi_dma_axixclk_awid;
  wire [31:0]   s_axi_dma_axixclk_awaddr;
  wire [ 7:0]   s_axi_dma_axixclk_awlen;
  wire [ 2:0]   s_axi_dma_axixclk_awsize;
  wire [ 1:0]   s_axi_dma_axixclk_awburst;
  wire          s_axi_dma_axixclk_awlock;
  wire [ 3:0]   s_axi_dma_axixclk_awcache;
  wire [ 2:0]   s_axi_dma_axixclk_awprot;
  wire [ 3:0]   s_axi_dma_axixclk_awqos;
  wire          s_axi_dma_axixclk_awvalid;
  wire          s_axi_dma_axixclk_awready;
  wire [31:0]   s_axi_dma_axixclk_wdata;
  wire [ 3:0]   s_axi_dma_axixclk_wstrb;
  wire          s_axi_dma_axixclk_wlast;
  wire          s_axi_dma_axixclk_wvalid;
  wire          s_axi_dma_axixclk_wready;
  wire [ 3:0]   s_axi_dma_axixclk_bid;
  wire [ 1:0]   s_axi_dma_axixclk_bresp;
  wire          s_axi_dma_axixclk_bvalid;
  wire          s_axi_dma_axixclk_bready;
  wire [ 3:0]   s_axi_dma_axixclk_arid;
  wire [31:0]   s_axi_dma_axixclk_araddr;
  wire [ 7:0]   s_axi_dma_axixclk_arlen;
  wire [ 2:0]   s_axi_dma_axixclk_arsize;
  wire [ 1:0]   s_axi_dma_axixclk_arburst;
  wire          s_axi_dma_axixclk_arlock;
  wire [ 3:0]   s_axi_dma_axixclk_arcache;
  wire [ 2:0]   s_axi_dma_axixclk_arprot;
  wire [ 3:0]   s_axi_dma_axixclk_arqos;
  wire          s_axi_dma_axixclk_arvalid;
  wire          s_axi_dma_axixclk_arready;
  wire [ 3:0]   s_axi_dma_axixclk_rid;
  wire [31:0]   s_axi_dma_axixclk_rdata;
  wire [ 1:0]   s_axi_dma_axixclk_rresp;
  wire          s_axi_dma_axixclk_rlast;
  wire          s_axi_dma_axixclk_rvalid;
  wire          s_axi_dma_axixclk_rready;

  //fill in vector
  wire [7*3-1:0]  m_axi_awprot_fill;
  wire [7*3-1:0]  m_axi_arprot_fill;
  wire            s_axi_dma_axixclk_aresetn;

  //distribute clock for axi and assign to output for m_axi_acc
  assign s_axi_clk = axi_cpu_clk;

  //MDIO ETH BUF
  IOBUF MDIO_mdio_iobuf
  (
    .I(MDIO_mdio_o),
    .IO(MDIO_mdio_io),
    .O(MDIO_mdio_i),
    .T(MDIO_mdio_t)
  );

  //QUAD SPI BUFS
  IOBUF QSPI_0_io0_iobuf
  (
    .I(QSPI_0_io0_o),
    .IO(QSPI_0_io0_io),
    .O(QSPI_0_io0_i),
    .T(QSPI_0_io0_t)
  );

  IOBUF QSPI_0_io1_iobuf
  (
    .I(QSPI_0_io1_o),
    .IO(QSPI_0_io1_io),
    .O(QSPI_0_io1_i),
    .T(QSPI_0_io1_t)
  );

  IOBUF QSPI_0_io2_iobuf
  (
    .I(QSPI_0_io2_o),
    .IO(QSPI_0_io2_io),
    .O(QSPI_0_io2_i),
    .T(QSPI_0_io2_t)
  );

  IOBUF QSPI_0_io3_iobuf
  (
    .I(QSPI_0_io3_o),
    .IO(QSPI_0_io3_io),
    .O(QSPI_0_io3_i),
    .T(QSPI_0_io3_t)
  );

  IOBUF QSPI_0_ss_iobuf_0
  (
    .I(QSPI_0_ss_o_0),
    .IO(QSPI_0_ss_io[0]),
    .O(QSPI_0_ss_i_0),
    .T(QSPI_0_ss_t)
  );

  axi_ddr_ctrl inst_axi_ddr_ctrl
  (
    .aresetn(ddr_rstgen_peripheral_aresetn),
    .ddr2_addr(DDR_addr),
    .ddr2_ba(DDR_ba),
    .ddr2_cas_n(DDR_cas_n),
    .ddr2_ck_n(DDR_ck_n),
    .ddr2_ck_p(DDR_ck_p),
    .ddr2_cke(DDR_cke),
    .ddr2_cs_n(DDR_cs_n),
    .ddr2_dm(DDR_dm),
    .ddr2_dq(DDR_dq[15:0]),
    .ddr2_dqs_n(DDR_dqs_n[1:0]),
    .ddr2_dqs_p(DDR_dqs_p[1:0]),
    .ddr2_odt(DDR_odt),
    .ddr2_ras_n(DDR_ras_n),
    .ddr2_we_n(DDR_we_n),
    .mmcm_locked(axi_ddr_ctrl_mmcm_locked),
    .s_axi_araddr(m_axi_ddr_ARADDR & 32'h0FFFFFFF),
    .s_axi_arburst(m_axi_ddr_ARBURST),
    .s_axi_arcache(m_axi_ddr_ARCACHE),
    .s_axi_arid(m_axi_ddr_ARID),
    .s_axi_arlen(m_axi_ddr_ARLEN),
    .s_axi_arlock(m_axi_ddr_ARLOCK),
    .s_axi_arprot(m_axi_ddr_ARPROT),
    .s_axi_arqos(m_axi_ddr_ARQOS),
    .s_axi_arready(m_axi_ddr_ARREADY),
    .s_axi_arsize(m_axi_ddr_ARSIZE),
    .s_axi_arvalid(m_axi_ddr_ARVALID),
    .s_axi_awaddr(m_axi_ddr_AWADDR & 32'h0FFFFFFF),
    .s_axi_awburst(m_axi_ddr_AWBURST),
    .s_axi_awcache(m_axi_ddr_AWCACHE),
    .s_axi_awid(m_axi_ddr_AWID),
    .s_axi_awlen(m_axi_ddr_AWLEN),
    .s_axi_awlock(m_axi_ddr_AWLOCK),
    .s_axi_awprot(m_axi_ddr_AWPROT),
    .s_axi_awqos(m_axi_ddr_AWQOS),
    .s_axi_awready(m_axi_ddr_AWREADY),
    .s_axi_awsize(m_axi_ddr_AWSIZE),
    .s_axi_awvalid(m_axi_ddr_AWVALID),
    .s_axi_bid(m_axi_ddr_BID),
    .s_axi_bready(m_axi_ddr_BREADY),
    .s_axi_bvalid(m_axi_ddr_BVALID),
    .s_axi_bresp(m_axi_ddr_BRESP),
    .s_axi_rdata(m_axi_ddr_RDATA),
    .s_axi_rid(m_axi_ddr_RID),
    .s_axi_rlast(m_axi_ddr_RLAST),
    .s_axi_rready(m_axi_ddr_RREADY),
    .s_axi_rvalid(m_axi_ddr_RVALID),
    .s_axi_rresp(m_axi_ddr_RRESP),
    .s_axi_wdata(m_axi_ddr_WDATA),
    .s_axi_wlast(m_axi_ddr_WLAST),
    .s_axi_wready(m_axi_ddr_WREADY),
    .s_axi_wstrb(m_axi_ddr_WSTRB),
    .s_axi_wvalid(m_axi_ddr_WVALID),
    .sys_clk_i(ddr_clk),
    .sys_rst(sys_rstn),
    .ui_clk(axi_ddr_ctrl_ui_clk),
    .ui_clk_sync_rst(axi_ddr_ctrl_ui_clk_sync_rst)
  );

  axi_ethernet inst_axi_ethernet
  (
    .ip2intc_irpt(axi_ethernet_irq),
    .phy_col(MII_col),
    .phy_crs(MII_crs),
    .phy_dv(MII_rx_dv),
    .phy_mdc(MDIO_mdc),
    .phy_mdio_i(MDIO_mdio_i),
    .phy_mdio_o(MDIO_mdio_o),
    .phy_mdio_t(MDIO_mdio_t),
    .phy_rst_n(MII_rst_n),
    .phy_rx_clk(MII_rx_clk),
    .phy_rx_data(MII_rxd),
    .phy_rx_er(MII_rx_er),
    .phy_tx_clk(MII_tx_clk),
    .phy_tx_data(MII_txd),
    .phy_tx_en(MII_tx_en),
    .s_axi_aclk(axi_cpu_clk),
    .s_axi_araddr(m_axi_eth_ARADDR[12:0]),
    .s_axi_aresetn(sys_rstgen_peripheral_aresetn),
    .s_axi_arready(m_axi_eth_ARREADY),
    .s_axi_arvalid(m_axi_eth_ARVALID),
    .s_axi_awaddr(m_axi_eth_AWADDR[12:0]),
    .s_axi_awready(m_axi_eth_AWREADY),
    .s_axi_awvalid(m_axi_eth_AWVALID),
    .s_axi_bready(m_axi_eth_BREADY),
    .s_axi_bresp(m_axi_eth_BRESP),
    .s_axi_bvalid(m_axi_eth_BVALID),
    .s_axi_rdata(m_axi_eth_RDATA),
    .s_axi_rready(m_axi_eth_RREADY),
    .s_axi_rresp(m_axi_eth_RRESP),
    .s_axi_rvalid(m_axi_eth_RVALID),
    .s_axi_wdata(m_axi_eth_WDATA),
    .s_axi_wready(m_axi_eth_WREADY),
    .s_axi_wstrb(m_axi_eth_WSTRB),
    .s_axi_wvalid(m_axi_eth_WVALID)
  );

  axi_gpio32 inst_axi_gpio32
  (
    .gpio_io_i(gpio_io_i),
    .gpio_io_o(gpio_io_o),
    .gpio_io_t(gpio_io_t),
    .s_axi_aclk(axi_cpu_clk),
    .s_axi_araddr(m_axi_gpio_ARADDR[8:0]),
    .s_axi_aresetn(sys_rstgen_peripheral_aresetn),
    .s_axi_arready(m_axi_gpio_ARREADY),
    .s_axi_arvalid(m_axi_gpio_ARVALID),
    .s_axi_awaddr(m_axi_gpio_AWADDR[8:0]),
    .s_axi_awready(m_axi_gpio_AWREADY),
    .s_axi_awvalid(m_axi_gpio_AWVALID),
    .s_axi_bready(m_axi_gpio_BREADY),
    .s_axi_bresp(m_axi_gpio_BRESP),
    .s_axi_bvalid(m_axi_gpio_BVALID),
    .s_axi_rdata(m_axi_gpio_RDATA),
    .s_axi_rready(m_axi_gpio_RREADY),
    .s_axi_rresp(m_axi_gpio_RRESP),
    .s_axi_rvalid(m_axi_gpio_RVALID),
    .s_axi_wdata(m_axi_gpio_WDATA),
    .s_axi_wready(m_axi_gpio_WREADY),
    .s_axi_wstrb(m_axi_gpio_WSTRB),
    .s_axi_wvalid(m_axi_gpio_WVALID)
  );

  axi_spix4 inst_axi_spix4
  (
    .ext_spi_clk(axi_cpu_clk),
    .io0_i(QSPI_0_io0_i),
    .io0_o(QSPI_0_io0_o),
    .io0_t(QSPI_0_io0_t),
    .io1_i(QSPI_0_io1_i),
    .io1_o(QSPI_0_io1_o),
    .io1_t(QSPI_0_io1_t),
    .io2_i(QSPI_0_io2_i),
    .io2_o(QSPI_0_io2_o),
    .io2_t(QSPI_0_io2_t),
    .io3_i(QSPI_0_io3_i),
    .io3_o(QSPI_0_io3_o),
    .io3_t(QSPI_0_io3_t),
    .ip2intc_irpt(axi_quad_spi_irq),
    .s_axi_aclk(axi_cpu_clk),
    .s_axi_araddr(m_axi_qspi_ARADDR[6:0]),
    .s_axi_aresetn(sys_rstgen_interconnect_aresetn),
    .s_axi_arready(m_axi_qspi_ARREADY),
    .s_axi_arvalid(m_axi_qspi_ARVALID),
    .s_axi_awaddr(m_axi_qspi_AWADDR[6:0]),
    .s_axi_awready(m_axi_qspi_AWREADY),
    .s_axi_awvalid(m_axi_qspi_AWVALID),
    .s_axi_bready(m_axi_qspi_BREADY),
    .s_axi_bresp(m_axi_qspi_BRESP),
    .s_axi_bvalid(m_axi_qspi_BVALID),
    .s_axi_rdata(m_axi_qspi_RDATA),
    .s_axi_rready(m_axi_qspi_RREADY),
    .s_axi_rresp(m_axi_qspi_RRESP),
    .s_axi_rvalid(m_axi_qspi_RVALID),
    .s_axi_wdata(m_axi_qspi_WDATA),
    .s_axi_wready(m_axi_qspi_WREADY),
    .s_axi_wstrb(m_axi_qspi_WSTRB),
    .s_axi_wvalid(m_axi_qspi_WVALID),
    .ss_i(QSPI_0_ss_i_0),
    .ss_o(QSPI_0_ss_o_0),
    .ss_t(QSPI_0_ss_t_0)
  );

  axi_spix1 inst_axi_spix1
  (
    .ext_spi_clk(axi_cpu_clk),
    .io0_i(spi_io0_i),
    .io0_o(spi_io0_o),
    .io0_t(spi_io0_t),
    .io1_i(spi_io1_i),
    .io1_o(spi_io1_o),
    .io1_t(spi_io1_t),
    .ip2intc_irpt(axi_spi_irq),
    .s_axi_aclk(axi_cpu_clk),
    .s_axi_araddr(m_axi_spi_ARADDR[6:0]),
    .s_axi_aresetn(sys_rstgen_peripheral_aresetn),
    .s_axi_arready(m_axi_spi_ARREADY),
    .s_axi_arvalid(m_axi_spi_ARVALID),
    .s_axi_awaddr(m_axi_spi_AWADDR[6:0]),
    .s_axi_awready(m_axi_spi_AWREADY),
    .s_axi_awvalid(m_axi_spi_AWVALID),
    .s_axi_bready(m_axi_spi_BREADY),
    .s_axi_bresp(m_axi_spi_BRESP),
    .s_axi_bvalid(m_axi_spi_BVALID),
    .s_axi_rdata(m_axi_spi_RDATA),
    .s_axi_rready(m_axi_spi_RREADY),
    .s_axi_rresp(m_axi_spi_RRESP),
    .s_axi_rvalid(m_axi_spi_RVALID),
    .s_axi_wdata(m_axi_spi_WDATA),
    .s_axi_wready(m_axi_spi_WREADY),
    .s_axi_wstrb(m_axi_spi_WSTRB),
    .s_axi_wvalid(m_axi_spi_WVALID),
    .sck_i(spi_sck_i),
    .sck_o(spi_sck_o),
    .sck_t(spi_sck_t),
    .ss_i(spi_ss_i),
    .ss_o(spi_ss_o),
    .ss_t(spi_ss_t)
  );

  axi_uart inst_axi_uart
  (
    .interrupt(axi_uartlite_irq),
    .rx(UART_rxd),
    .s_axi_aclk(axi_cpu_clk),
    .s_axi_araddr(m_axi_uart_ARADDR[3:0]),
    .s_axi_aresetn(sys_rstgen_peripheral_aresetn),
    .s_axi_arready(m_axi_uart_ARREADY),
    .s_axi_arvalid(m_axi_uart_ARVALID),
    .s_axi_awaddr(m_axi_uart_AWADDR[3:0]),
    .s_axi_awready(m_axi_uart_AWREADY),
    .s_axi_awvalid(m_axi_uart_AWVALID),
    .s_axi_bready(m_axi_uart_BREADY),
    .s_axi_bresp(m_axi_uart_BRESP),
    .s_axi_bvalid(m_axi_uart_BVALID),
    .s_axi_rdata(m_axi_uart_RDATA),
    .s_axi_rready(m_axi_uart_RREADY),
    .s_axi_rresp(m_axi_uart_RRESP),
    .s_axi_rvalid(m_axi_uart_RVALID),
    .s_axi_wdata(m_axi_uart_WDATA),
    .s_axi_wready(m_axi_uart_WREADY),
    .s_axi_wstrb(m_axi_uart_WSTRB),
    .s_axi_wvalid(m_axi_uart_WVALID),
    .tx(UART_txd)
  );

  axi_double_timer inst_axi_double_timer
  (
    .capturetrig0(1'b0),    // input wire capturetrig0
    .capturetrig1(1'b0),    // input wire capturetrig1
    .generateout0(),    // output wire generateout0
    .generateout1(),    // output wire generateout1
    .pwm0(pwm0),                    // output wire pwm0
    .interrupt(axi_timer_irq),          // output wire interrupt
    .freeze(1'b0),                // input wire freeze
    .s_axi_aclk(axi_cpu_clk),
    .s_axi_araddr(m_axi_timer_ARADDR[4:0]),
    .s_axi_aresetn(sys_rstgen_peripheral_aresetn),
    .s_axi_arready(m_axi_timer_ARREADY),
    .s_axi_arvalid(m_axi_timer_ARVALID),
    .s_axi_awaddr(m_axi_timer_AWADDR[4:0]),
    .s_axi_awready(m_axi_timer_AWREADY),
    .s_axi_awvalid(m_axi_timer_AWVALID),
    .s_axi_bready(m_axi_timer_BREADY),
    .s_axi_bresp(m_axi_timer_BRESP),
    .s_axi_bvalid(m_axi_timer_BVALID),
    .s_axi_rdata(m_axi_timer_RDATA),
    .s_axi_rready(m_axi_timer_RREADY),
    .s_axi_rresp(m_axi_timer_RRESP),
    .s_axi_rvalid(m_axi_timer_RVALID),
    .s_axi_wdata(m_axi_timer_WDATA),
    .s_axi_wready(m_axi_timer_WREADY),
    .s_axi_wstrb(m_axi_timer_WSTRB),
    .s_axi_wvalid(m_axi_timer_WVALID)
  );

  axi_tft_vga inst_axi_tft_vga
  (
    .s_axi_aclk(axi_cpu_clk),
    .s_axi_aresetn(sys_rstgen_peripheral_aresetn),
    .m_axi_aclk(axi_ddr_ctrl_ui_clk),
    .m_axi_aresetn(ddr_rstgen_peripheral_aresetn),
    .md_error(),
    .ip2intc_irpt(axi_tft_irq),
    .m_axi_arready(s_axi_dma_vga_arready),  // input wire m_axi_arready
    .m_axi_arvalid(s_axi_dma_vga_arvalid),  // output wire m_axi_arvalid
    .m_axi_araddr(s_axi_dma_vga_araddr),    // output wire [31 : 0] m_axi_araddr
    .m_axi_arlen(s_axi_dma_vga_arlen),      // output wire [7 : 0] m_axi_arlen
    .m_axi_arsize(s_axi_dma_vga_arsize),    // output wire [2 : 0] m_axi_arsize
    .m_axi_arburst(s_axi_dma_vga_arburst),  // output wire [1 : 0] m_axi_arburst
    .m_axi_arprot(s_axi_dma_vga_arprot),    // output wire [2 : 0] m_axi_arprot
    .m_axi_arcache(s_axi_dma_vga_arcache),  // output wire [3 : 0] m_axi_arcache
    .m_axi_rready(s_axi_dma_vga_rready),    // output wire m_axi_rready
    .m_axi_rvalid(s_axi_dma_vga_rvalid),    // input wire m_axi_rvalid
    .m_axi_rdata(s_axi_dma_vga_rdata),      // input wire [31 : 0] m_axi_rdata
    .m_axi_rresp(s_axi_dma_vga_rresp),      // input wire [1 : 0] m_axi_rresp
    .m_axi_rlast(s_axi_dma_vga_rlast),      // input wire m_axi_rlast
    .m_axi_awready(s_axi_dma_vga_awready),  // input wire m_axi_awready
    .m_axi_awvalid(s_axi_dma_vga_awvalid),  // output wire m_axi_awvalid
    .m_axi_awaddr(s_axi_dma_vga_awaddr),    // output wire [31 : 0] m_axi_awaddr
    .m_axi_awlen(s_axi_dma_vga_awlen),      // output wire [7 : 0] m_axi_awlen
    .m_axi_awsize(s_axi_dma_vga_awsize),    // output wire [2 : 0] m_axi_awsize
    .m_axi_awburst(s_axi_dma_vga_awburst),  // output wire [1 : 0] m_axi_awburst
    .m_axi_awprot(s_axi_dma_vga_awprot),    // output wire [2 : 0] m_axi_awprot
    .m_axi_awcache(s_axi_dma_vga_awcache),  // output wire [3 : 0] m_axi_awcache
    .m_axi_wready(s_axi_dma_vga_wready),    // input wire m_axi_wready
    .m_axi_wvalid(s_axi_dma_vga_wvalid),    // output wire m_axi_wvalid
    .m_axi_wdata(s_axi_dma_vga_wdata),      // output wire [31 : 0] m_axi_wdata
    .m_axi_wstrb(s_axi_dma_vga_wstrb),      // output wire [3 : 0] m_axi_wstrb
    .m_axi_wlast(s_axi_dma_vga_wlast),      // output wire m_axi_wlast
    .m_axi_bready(s_axi_dma_vga_bready),    // output wire m_axi_bready
    .m_axi_bvalid(s_axi_dma_vga_bvalid),    // input wire m_axi_bvalid
    .m_axi_bresp(s_axi_dma_vga_bresp),      // input wire [1 : 0] m_axi_bresp
    .s_axi_awaddr(m_axi_vga_AWADDR),
    .s_axi_awvalid(m_axi_vga_AWVALID),
    .s_axi_awready(m_axi_vga_AWREADY),
    .s_axi_wdata(m_axi_vga_WDATA),
    .s_axi_wstrb(m_axi_vga_WSTRB),
    .s_axi_wvalid(m_axi_vga_WVALID),
    .s_axi_wready(m_axi_vga_WREADY),
    .s_axi_bresp(m_axi_vga_BRESP),
    .s_axi_bvalid(m_axi_vga_BVALID),
    .s_axi_bready(m_axi_vga_BREADY),
    .s_axi_araddr(m_axi_vga_ARADDR),
    .s_axi_arvalid(m_axi_vga_ARVALID),
    .s_axi_arready(m_axi_vga_ARREADY),
    .s_axi_rdata(m_axi_vga_RDATA),
    .s_axi_rresp(m_axi_vga_RRESP),
    .s_axi_rvalid(m_axi_vga_RVALID),
    .s_axi_rready(m_axi_vga_RREADY),
    .sys_tft_clk(tft_clk),
    .tft_hsync(vga_hsync),
    .tft_vsync(vga_vsync),
    .tft_de(),
    .tft_dps(),
    .tft_vga_clk(),
    .tft_vga_r(vga_r),
    .tft_vga_g(vga_g),
    .tft_vga_b(vga_b)
  );

  sdio_top #(
    // ADDRESS_WIDTH: Number of bits to the DMA's address lines,
    // as required to access octets of memory.  This is not the word
    // address width, but the octet/byte address width.
    .ADDRESS_WIDTH(32),
    // OPT_DMA: Set to 1 to include the DMA in the design
    .OPT_DMA(1),
    // AXI_IW: ID width of the AXI interface
    .AXI_IW(4)
  ) inst_sdio_top (
    .i_clk(axi_cpu_clk),
    .i_reset(sys_rstgen_peripheral_reset),
    .i_hsclk(1'b0),
    // Control interface
    .S_AXIL_AWVALID(m_axi_sdio_awvalid),
    .S_AXIL_AWREADY(m_axi_sdio_awready),
    .S_AXIL_AWADDR(m_axi_sdio_awaddr),
    .S_AXIL_AWPROT(m_axi_sdio_awprot),
    .S_AXIL_WVALID(m_axi_sdio_wvalid),
    .S_AXIL_WREADY(m_axi_sdio_wready),
    .S_AXIL_WDATA(m_axi_sdio_wdata),
    .S_AXIL_WSTRB(m_axi_sdio_wstrb),
    .S_AXIL_BVALID(m_axi_sdio_bvalid),
    .S_AXIL_BREADY(m_axi_sdio_bready),
    .S_AXIL_BRESP(m_axi_sdio_bresp),
    .S_AXIL_ARVALID(m_axi_sdio_arvalid),
    .S_AXIL_ARREADY(m_axi_sdio_arready),
    .S_AXIL_ARADDR(m_axi_sdio_araddr),
    .S_AXIL_ARPROT(m_axi_sdio_arprot),
    .S_AXIL_RVALID(m_axi_sdio_rvalid),
    .S_AXIL_RREADY(m_axi_sdio_rready),
    .S_AXIL_RDATA(m_axi_sdio_rdata),
    .S_AXIL_RRESP(m_axi_sdio_rresp),
    // DMA interface
    .M_AXI_AWVALID(s_axi_dma_sdio_awvalid),
    .M_AXI_AWREADY(s_axi_dma_sdio_awready),
    .M_AXI_AWID(s_axi_dma_sdio_awid),
    .M_AXI_AWADDR(s_axi_dma_sdio_awaddr),
    .M_AXI_AWLEN(s_axi_dma_sdio_awlen),
    .M_AXI_AWSIZE(s_axi_dma_sdio_awsize),
    .M_AXI_AWBURST(s_axi_dma_sdio_awburst),
    .M_AXI_AWLOCK(s_axi_dma_sdio_awlock),
    .M_AXI_AWCACHE(s_axi_dma_sdio_awcache),
    .M_AXI_AWPROT(s_axi_dma_sdio_awprot),
    .M_AXI_AWQOS(s_axi_dma_sdio_awqos),
    .M_AXI_WVALID(s_axi_dma_sdio_wvalid),
    .M_AXI_WREADY(s_axi_dma_sdio_wready),
    .M_AXI_WDATA(s_axi_dma_sdio_wdata),
    .M_AXI_WSTRB(s_axi_dma_sdio_wstrb),
    .M_AXI_WLAST(s_axi_dma_sdio_wlast),
    .M_AXI_BVALID(s_axi_dma_sdio_bvalid),
    .M_AXI_BREADY(s_axi_dma_sdio_bready),
    .M_AXI_BID(s_axi_dma_sdio_bid),
    .M_AXI_BRESP(s_axi_dma_sdio_bresp),
    .M_AXI_ARVALID(s_axi_dma_sdio_arvalid),
    .M_AXI_ARREADY(s_axi_dma_sdio_arready),
    .M_AXI_ARID(s_axi_dma_sdio_arid),
    .M_AXI_ARADDR(s_axi_dma_sdio_araddr),
    .M_AXI_ARLEN(s_axi_dma_sdio_arlen),
    .M_AXI_ARSIZE(s_axi_dma_sdio_arsize),
    .M_AXI_ARBURST(s_axi_dma_sdio_arburst),
    .M_AXI_ARLOCK(s_axi_dma_sdio_arlock),
    .M_AXI_ARCACHE(s_axi_dma_sdio_arcache),
    .M_AXI_ARPROT(s_axi_dma_sdio_arprot),
    .M_AXI_ARQOS(s_axi_dma_sdio_arqos),
    .M_AXI_RVALID(s_axi_dma_sdio_rvalid),
    .M_AXI_RREADY(s_axi_dma_sdio_rready),
    .M_AXI_RID(s_axi_dma_sdio_rid),
    .M_AXI_RDATA(s_axi_dma_sdio_rdata),
    .M_AXI_RLAST(s_axi_dma_sdio_rlast),
    .M_AXI_RRESP(s_axi_dma_sdio_rresp),
    // External DMA streaming interface
    .s_valid(1'b0),
    .s_ready(),
    .s_data(0),
    .m_valid(),
    .m_ready(1'b0),
    .m_data(),
    .m_last(),
    // IO interface
    .o_ck(sd_sck),
    .i_ds(1'b0),
    .io_cmd(sd_cmd),
    .io_dat(sd_dat),
    .i_card_detect(sd_cd),
    .o_hwreset_n(sd_resetn),
    .o_1p8v(),
    .o_int(spio_irq),
    .o_debug()
  );

  clk_wiz_1 inst_clk_wiz_1
  (
    .clk_in1(sys_clk),
    .clk_out1(axi_cpu_clk),
    .clk_out2(ddr_clk),
    .clk_out3(tft_clk)
  );

  ddr_rstgen inst_ddr_rstgen
  (
    .aux_reset_in(axi_ddr_ctrl_ui_clk_sync_rst),
    .dcm_locked(axi_ddr_ctrl_mmcm_locked),
    .ext_reset_in(sys_rstn & s_axi_dma_axixclk_aresetn),
    .mb_debug_sys_rst(debug_rst),
    .peripheral_reset(ddr_rstgen_peripheral_reset),
    .peripheral_aresetn(ddr_rstgen_peripheral_aresetn),
    .slowest_sync_clk(axi_ddr_ctrl_ui_clk)
  );

  axixclk #(
    .C_S_AXI_ID_WIDTH(4),
    .C_S_AXI_DATA_WIDTH(32),
    .C_S_AXI_ADDR_WIDTH(32),
    .XCLOCK_FFS(2),
    .LGFIFO(5)
  ) inst_axixclk (
    .S_AXI_ACLK(axi_cpu_clk),
    .S_AXI_ARESETN(sys_rstgen_peripheral_aresetn),
    .S_AXI_AWID(s_axi_dma_sdio_awid),
    .S_AXI_AWADDR(s_axi_dma_sdio_awaddr),
    .S_AXI_AWLEN(s_axi_dma_sdio_awlen),
    .S_AXI_AWSIZE(s_axi_dma_sdio_awsize),
    .S_AXI_AWBURST(s_axi_dma_sdio_awburst),
    .S_AXI_AWLOCK(s_axi_dma_sdio_awlock),
    .S_AXI_AWCACHE(s_axi_dma_sdio_awcache),
    .S_AXI_AWPROT(s_axi_dma_sdio_awprot),
    .S_AXI_AWQOS(s_axi_dma_sdio_awqos),
    .S_AXI_AWVALID(s_axi_dma_sdio_awvalid),
    .S_AXI_AWREADY(s_axi_dma_sdio_awready),
    .S_AXI_WDATA(s_axi_dma_sdio_wdata),
    .S_AXI_WSTRB(s_axi_dma_sdio_wstrb),
    .S_AXI_WLAST(s_axi_dma_sdio_wlast),
    .S_AXI_WVALID(s_axi_dma_sdio_wvalid),
    .S_AXI_WREADY(s_axi_dma_sdio_wready),
    .S_AXI_BID(s_axi_dma_sdio_bid),
    .S_AXI_BRESP(s_axi_dma_sdio_bresp),
    .S_AXI_BVALID(s_axi_dma_sdio_bvalid),
    .S_AXI_BREADY(s_axi_dma_sdio_bready),
    .S_AXI_ARID(s_axi_dma_sdio_arid),
    .S_AXI_ARADDR(s_axi_dma_sdio_araddr),
    .S_AXI_ARLEN(s_axi_dma_sdio_arlen),
    .S_AXI_ARSIZE(s_axi_dma_sdio_arsize),
    .S_AXI_ARBURST(s_axi_dma_sdio_arburst),
    .S_AXI_ARLOCK(s_axi_dma_sdio_arlock),
    .S_AXI_ARCACHE(s_axi_dma_sdio_arcache),
    .S_AXI_ARPROT(s_axi_dma_sdio_arprot),
    .S_AXI_ARQOS(s_axi_dma_sdio_arqos),
    .S_AXI_ARVALID(s_axi_dma_sdio_arvalid),
    .S_AXI_ARREADY(s_axi_dma_sdio_arready),
    .S_AXI_RID(s_axi_dma_sdio_rid),
    .S_AXI_RDATA(s_axi_dma_sdio_rdata),
    .S_AXI_RRESP(s_axi_dma_sdio_rresp),
    .S_AXI_RLAST(s_axi_dma_sdio_rlast),
    .S_AXI_RVALID(s_axi_dma_sdio_rvalid),
    .S_AXI_RREADY(s_axi_dma_sdio_rready),
    //	Downstream port
    .M_AXI_ACLK(axi_ddr_ctrl_ui_clk),
    .M_AXI_ARESETN(s_axi_dma_axixclk_aresetn),
    .M_AXI_AWID(s_axi_dma_axixclk_awid),
    .M_AXI_AWADDR(s_axi_dma_axixclk_awaddr),
    .M_AXI_AWLEN(s_axi_dma_axixclk_awlen),
    .M_AXI_AWSIZE(s_axi_dma_axixclk_awsize),
    .M_AXI_AWBURST(s_axi_dma_axixclk_awburst),
    .M_AXI_AWLOCK(s_axi_dma_axixclk_awlock),
    .M_AXI_AWCACHE(s_axi_dma_axixclk_awcache),
    .M_AXI_AWPROT(s_axi_dma_axixclk_awprot),
    .M_AXI_AWQOS(s_axi_dma_axixclk_awqos),
    .M_AXI_AWVALID(s_axi_dma_axixclk_awvalid),
    .M_AXI_AWREADY(s_axi_dma_axixclk_awready),
    .M_AXI_WDATA(s_axi_dma_axixclk_wdata),
    .M_AXI_WSTRB(s_axi_dma_axixclk_wstrb),
    .M_AXI_WLAST(s_axi_dma_axixclk_wlast),
    .M_AXI_WVALID(s_axi_dma_axixclk_wvalid),
    .M_AXI_WREADY(s_axi_dma_axixclk_wready),
    .M_AXI_BID(s_axi_dma_axixclk_bid),
    .M_AXI_BRESP(s_axi_dma_axixclk_bresp),
    .M_AXI_BVALID(s_axi_dma_axixclk_bvalid),
    .M_AXI_BREADY(s_axi_dma_axixclk_bready),
    .M_AXI_ARID(s_axi_dma_axixclk_arid),
    .M_AXI_ARADDR(s_axi_dma_axixclk_araddr),
    .M_AXI_ARLEN(s_axi_dma_axixclk_arlen),
    .M_AXI_ARSIZE(s_axi_dma_axixclk_arsize),
    .M_AXI_ARBURST(s_axi_dma_axixclk_arburst),
    .M_AXI_ARLOCK(s_axi_dma_axixclk_arlock),
    .M_AXI_ARCACHE(s_axi_dma_axixclk_arcache),
    .M_AXI_ARPROT(s_axi_dma_axixclk_arprot),
    .M_AXI_ARQOS(s_axi_dma_axixclk_arqos),
    .M_AXI_ARVALID(s_axi_dma_axixclk_arvalid),
    .M_AXI_ARREADY(s_axi_dma_axixclk_arready),
    .M_AXI_RID(s_axi_dma_axixclk_rid),
    .M_AXI_RDATA(s_axi_dma_axixclk_rdata),
    .M_AXI_RRESP(s_axi_dma_axixclk_rresp),
    .M_AXI_RLAST(s_axi_dma_axixclk_rlast),
    .M_AXI_RVALID(s_axi_dma_axixclk_rvalid),
    .M_AXI_RREADY(s_axi_dma_axixclk_rready)
  );

  axilxbar #(
    .C_AXI_DATA_WIDTH(32),
    .C_AXI_ADDR_WIDTH(32),
    .NM(1),
    .NS(7),      //sdio, tft vga, double timer, ethernet, spi, qspi, uart, gpio
    .SLAVE_ADDR({{32'h44A70000},{32'h44A60000},{32'h44A50000},{32'h44A40000},{32'h44A30000},{32'h44A20000},{32'h44A10000},{32'h44A00000}}),
    .SLAVE_MASK({{32'hFFFF0000},{32'hFFFF0000},{32'hFFFF0000},{32'hFFFF0000},{32'hFFFF0000},{32'hFFFF0000},{32'hFFFF0000},{32'hFFFF0000}})
  ) inst_axilite_perf_xbar (
    .S_AXI_ACLK     (axi_cpu_clk),
    .S_AXI_ARESETN  (sys_rstgen_peripheral_aresetn),
    .S_AXI_AWADDR   (s_axi_perf_AWADDR),
    .S_AXI_AWPROT   (s_axi_perf_AWPROT),
    .S_AXI_AWVALID  (s_axi_perf_AWVALID),
    .S_AXI_AWREADY  (s_axi_perf_AWREADY),
    .S_AXI_WDATA    (s_axi_perf_WDATA),
    .S_AXI_WSTRB    (s_axi_perf_WSTRB),
    .S_AXI_WVALID   (s_axi_perf_AWVALID),
    .S_AXI_WREADY   (s_axi_perf_WREADY),
    .S_AXI_BRESP    (s_axi_perf_BRESP),
    .S_AXI_BVALID   (s_axi_perf_BVALID),
    .S_AXI_BREADY   (s_axi_perf_BREADY),
    .S_AXI_ARADDR   (s_axi_perf_ARADDR),
    .S_AXI_ARPROT   (s_axi_perf_APROT),
    .S_AXI_ARVALID  (s_axi_perf_ARVALID),
    .S_AXI_ARREADY  (s_axi_perf_ARREADY),
    .S_AXI_RDATA    (s_axi_perf_RDATA),
    .S_AXI_RRESP    (s_axi_perf_RRESP),
    .S_AXI_RVALID   (s_axi_perf_RVALID),
    .S_AXI_RREADY   (s_axi_perf_RREADY),
    .M_AXI_AWADDR  ({m_axi_sdio_awaddr,     m_axi_vga_AWADDR,      m_axi_timer_AWADDR,    m_axi_eth_AWADDR,    m_axi_spi_AWADDR,    m_axi_qspi_AWADDR,    m_axi_uart_AWADDR,     m_axi_gpio_AWADDR}),
    .M_AXI_AWPROT  ({m_axi_sdio_awprot,     m_axi_awprot_fill}),
    .M_AXI_AWVALID ({m_axi_sdio_awvalid,    m_axi_vga_AWVALID,     m_axi_timer_AWVALID,   m_axi_eth_AWVALID,   m_axi_spi_AWVALID,   m_axi_qspi_AWVALID,   m_axi_uart_AWVALID,    m_axi_gpio_AWVALID}),
    .M_AXI_AWREADY ({m_axi_sdio_awready,    m_axi_vga_AWREADY,     m_axi_timer_AWREADY,   m_axi_eth_AWREADY,   m_axi_spi_AWREADY,   m_axi_qspi_AWREADY,   m_axi_uart_AWREADY,    m_axi_gpio_AWREADY}),
    .M_AXI_WDATA   ({m_axi_sdio_wdata,      m_axi_vga_WDATA,       m_axi_timer_WDATA,     m_axi_eth_WDATA,     m_axi_spi_WDATA,     m_axi_qspi_WDATA,     m_axi_uart_WDATA,      m_axi_gpio_WDATA}),
    .M_AXI_WSTRB   ({m_axi_sdio_wstrb,      m_axi_vga_WSTRB,       m_axi_timer_WSTRB,     m_axi_eth_WSTRB,     m_axi_spi_WSTRB,     m_axi_qspi_WSTRB,     m_axi_uart_WSTRB,      m_axi_gpio_WSTRB}),
    .M_AXI_WVALID  ({m_axi_sdio_wvalid,     m_axi_vga_WVALID,      m_axi_timer_WVALID,    m_axi_eth_WVALID,    m_axi_spi_WVALID,    m_axi_qspi_WVALID,    m_axi_uart_WVALID,     m_axi_gpio_WVALID}),
    .M_AXI_WREADY  ({m_axi_sdio_wready,     m_axi_vga_WREADY,      m_axi_timer_WREADY,    m_axi_eth_WREADY,    m_axi_spi_WREADY,    m_axi_qspi_WREADY,    m_axi_uart_WREADY,     m_axi_gpio_WREADY}),
    .M_AXI_BRESP   ({m_axi_sdio_bresp,      m_axi_vga_BRESP,       m_axi_timer_BRESP,     m_axi_eth_BRESP,     m_axi_spi_BRESP,     m_axi_qspi_BRESP,     m_axi_uart_BRESP,      m_axi_gpio_BRESP}),
    .M_AXI_BVALID  ({m_axi_sdio_bvalid,     m_axi_vga_BVALID,      m_axi_timer_BVALID,    m_axi_eth_BVALID,    m_axi_spi_BVALID,    m_axi_qspi_BVALID,    m_axi_uart_BVALID,     m_axi_gpio_BVALID}),
    .M_AXI_BREADY  ({m_axi_sdio_bready,     m_axi_vga_BREADY,      m_axi_timer_BREADY,    m_axi_eth_BREADY,    m_axi_spi_BREADY,    m_axi_qspi_BREADY,    m_axi_uart_BREADY,     m_axi_gpio_BREADY}),
    .M_AXI_ARADDR  ({m_axi_sdio_araddr,     m_axi_vga_ARADDR,      m_axi_timer_ARADDR,    m_axi_eth_ARADDR,    m_axi_spi_ARADDR,    m_axi_qspi_ARADDR,    m_axi_uart_ARADDR,     m_axi_gpio_ARADDR}),
    .M_AXI_ARPROT  ({m_axi_sdio_arprot,     m_axi_arprot_fill}),
    .M_AXI_ARVALID ({m_axi_sdio_arvalid,    m_axi_vga_ARVALID,     m_axi_timer_ARVALID,   m_axi_eth_ARVALID,   m_axi_spi_ARVALID,   m_axi_qspi_ARVALID,   m_axi_uart_ARVALID,    m_axi_gpio_ARVALID}),
    .M_AXI_ARREADY ({m_axi_sdio_arready,    m_axi_vga_ARREADY,     m_axi_timer_ARREADY,   m_axi_eth_ARREADY,   m_axi_spi_ARREADY,   m_axi_qspi_ARREADY,   m_axi_uart_ARREADY,    m_axi_gpio_ARREADY}),
    .M_AXI_RDATA   ({m_axi_sdio_rdata,      m_axi_vga_RDATA,       m_axi_timer_RDATA,     m_axi_eth_RDATA,     m_axi_spi_RDATA,     m_axi_qspi_RDATA,     m_axi_uart_RDATA,      m_axi_gpio_RDATA}),
    .M_AXI_RRESP   ({m_axi_sdio_rresp,      m_axi_vga_RRESP,       m_axi_timer_RRESP,     m_axi_eth_RRESP,     m_axi_spi_RRESP,     m_axi_qspi_RRESP,     m_axi_uart_RRESP,      m_axi_gpio_RRESP}),
    .M_AXI_RVALID  ({m_axi_sdio_rvalid,     m_axi_vga_RVALID,      m_axi_timer_RVALID,    m_axi_eth_RVALID,    m_axi_spi_RVALID,    m_axi_qspi_RVALID,    m_axi_uart_RVALID,     m_axi_gpio_RVALID}),
    .M_AXI_RREADY  ({m_axi_sdio_rready,     m_axi_vga_RREADY,      m_axi_timer_RREADY,    m_axi_eth_RREADY,    m_axi_spi_RREADY,    m_axi_qspi_RREADY,    m_axi_uart_RREADY,     m_axi_gpio_RREADY})
  );

  axixbar #(
    .C_AXI_DATA_WIDTH(32),
    .C_AXI_ADDR_WIDTH(32),
    .C_AXI_ID_WIDTH(4),
    .NM(3),   //IBUS/DBUS @ 0x90000000 plus 2 dma cores
    .NS(1),   //single Large RAM slave, 0xC0000000 is 1 GB mask (0x40000000 twos compliment).
    .SLAVE_ADDR({{32'h90000000}}),
    .SLAVE_MASK({{32'hC0000000}})
  ) inst_axi_mem_xbar (
    //slave interface input (from masters, number masters)\
    .S_AXI_ACLK(axi_ddr_ctrl_ui_clk),
    .S_AXI_ARESETN(ddr_rstgen_peripheral_aresetn),
    .S_AXI_AWID    ({s_axi_dma_axixclk_awid,     4'h0,                  s_axi_mbus_AWID}),
    .S_AXI_AWADDR  ({s_axi_dma_axixclk_awaddr,   s_axi_dma_vga_awaddr,  s_axi_mbus_AWADDR}),
    .S_AXI_AWLEN   ({s_axi_dma_axixclk_awlen,    s_axi_dma_vga_awlen,   s_axi_mbus_AWLEN}),
    .S_AXI_AWSIZE  ({s_axi_dma_axixclk_awsize,   s_axi_dma_vga_awsize,  s_axi_mbus_AWSIZE}),
    .S_AXI_AWBURST ({s_axi_dma_axixclk_awburst,  s_axi_dma_vga_awburst, s_axi_mbus_AWBURST}),
    .S_AXI_AWLOCK  ({s_axi_dma_axixclk_awlock,   4'h0,                  s_axi_mbus_AWLOCK}),
    .S_AXI_AWCACHE ({s_axi_dma_axixclk_awcache,  s_axi_dma_vga_awcache, s_axi_mbus_AWCACHE}),
    .S_AXI_AWPROT  ({s_axi_dma_axixclk_awprot,   s_axi_dma_vga_awprot,  s_axi_mbus_AWPROT}),
    .S_AXI_AWQOS   ({s_axi_dma_axixclk_awqos,    4'h0,                  s_axi_mbus_AWQOS}),
    .S_AXI_AWVALID ({s_axi_dma_axixclk_awvalid,  s_axi_dma_vga_awvalid, s_axi_mbus_AWVALID}),
    .S_AXI_AWREADY ({s_axi_dma_axixclk_awready,  s_axi_dma_vga_awready, s_axi_mbus_AWREADY}),
    .S_AXI_WDATA   ({s_axi_dma_axixclk_wdata,    s_axi_dma_vga_wdata,   s_axi_mbus_WDATA}),
    .S_AXI_WSTRB   ({s_axi_dma_axixclk_wstrb,    s_axi_dma_vga_wstrb,   s_axi_mbus_WSTRB}),
    .S_AXI_WLAST   ({s_axi_dma_axixclk_wlast,    s_axi_dma_vga_wlast,   s_axi_mbus_WLAST}),
    .S_AXI_WVALID  ({s_axi_dma_axixclk_wvalid,   s_axi_dma_vga_wvalid,  s_axi_mbus_WVALID}),
    .S_AXI_WREADY  ({s_axi_dma_axixclk_wready,   s_axi_dma_vga_wready,  s_axi_mbus_WREADY}),
    .S_AXI_BID     ({s_axi_dma_axixclk_bid,      s_axi_dma_vga_bid,     s_axi_mbus_BID}),
    .S_AXI_BRESP   ({s_axi_dma_axixclk_bresp,    s_axi_dma_vga_bresp,   s_axi_mbus_BRESP}),
    .S_AXI_BVALID  ({s_axi_dma_axixclk_bvalid,   s_axi_dma_vga_bvalid,  s_axi_mbus_BVALID}),
    .S_AXI_BREADY  ({s_axi_dma_axixclk_bready,   s_axi_dma_vga_bready,  s_axi_mbus_BREADY}),
    .S_AXI_ARID    ({s_axi_dma_axixclk_arid,     4'h0,                  s_axi_mbus_ARID}),
    .S_AXI_ARADDR  ({s_axi_dma_axixclk_araddr,   s_axi_dma_vga_araddr,  s_axi_mbus_ARADDR}),
    .S_AXI_ARLEN   ({s_axi_dma_axixclk_arlen,    s_axi_dma_vga_arlen,   s_axi_mbus_ARLEN}),
    .S_AXI_ARSIZE  ({s_axi_dma_axixclk_arsize,   s_axi_dma_vga_arsize,  s_axi_mbus_ARSIZE}),
    .S_AXI_ARBURST ({s_axi_dma_axixclk_arburst,  s_axi_dma_vga_arburst, s_axi_mbus_ARBURST}),
    .S_AXI_ARLOCK  ({s_axi_dma_axixclk_arlock,   1'b0,                  s_axi_mbus_ARLOCK}),
    .S_AXI_ARCACHE ({s_axi_dma_axixclk_arcache,  s_axi_dma_vga_arcache, s_axi_mbus_ARCACHE}),
    .S_AXI_ARPROT  ({s_axi_dma_axixclk_arprot,   s_axi_dma_vga_arprot,  s_axi_mbus_ARPROT}),
    .S_AXI_ARQOS   ({s_axi_dma_axixclk_arqos,    4'h0,                  s_axi_mbus_ARQOS}),
    .S_AXI_ARVALID ({s_axi_dma_axixclk_arvalid,  s_axi_dma_vga_arvalid, s_axi_mbus_ARVALID}),
    .S_AXI_ARREADY ({s_axi_dma_axixclk_arready,  s_axi_dma_vga_arready, s_axi_mbus_ARREADY}),
    .S_AXI_RID     ({s_axi_dma_axixclk_rid,      s_axi_dma_vga_rid,     s_axi_mbus_RID}),
    .S_AXI_RDATA   ({s_axi_dma_axixclk_rdata,    s_axi_dma_vga_rdata,   s_axi_mbus_RDATA}),
    .S_AXI_RRESP   ({s_axi_dma_axixclk_rresp,    s_axi_dma_vga_rresp,   s_axi_mbus_RRESP}),
    .S_AXI_RLAST   ({s_axi_dma_axixclk_rlast,    s_axi_dma_vga_rlast,   s_axi_mbus_RLAST}),
    .S_AXI_RVALID  ({s_axi_dma_axixclk_rvalid,   s_axi_dma_vga_rvalid,  s_axi_mbus_RVALID}),
    .S_AXI_RREADY  ({s_axi_dma_axixclk_rready,   s_axi_dma_vga_rready,  s_axi_mbus_RREADY}),
    //master output (to slaves, number slaves)
    .M_AXI_AWID(m_axi_ddr_AWID),
    .M_AXI_AWADDR(m_axi_ddr_AWADDR),
    .M_AXI_AWLEN(m_axi_ddr_AWLEN),
    .M_AXI_AWSIZE(m_axi_ddr_AWSIZE),
    .M_AXI_AWBURST(m_axi_ddr_AWBURST),
    .M_AXI_AWLOCK(m_axi_ddr_AWLOCK),
    .M_AXI_AWCACHE(m_axi_ddr_AWCACHE),
    .M_AXI_AWPROT(m_axi_ddr_AWPROT),
    .M_AXI_AWQOS(m_axi_ddr_AWQOS),
    .M_AXI_AWVALID(m_axi_ddr_AWVALID),
    .M_AXI_AWREADY(m_axi_ddr_AWREADY),
    .M_AXI_WDATA(m_axi_ddr_WDATA),
    .M_AXI_WSTRB(m_axi_ddr_WSTRB),
    .M_AXI_WLAST(m_axi_ddr_WLAST),
    .M_AXI_WVALID(m_axi_ddr_WVALID),
    .M_AXI_WREADY(m_axi_ddr_WREADY),
    .M_AXI_BID(m_axi_ddr_BID),
    .M_AXI_BRESP(m_axi_ddr_BRESP),
    .M_AXI_BVALID(m_axi_ddr_BVALID),
    .M_AXI_BREADY(m_axi_ddr_BREADY),
    .M_AXI_ARID(m_axi_ddr_ARID),
    .M_AXI_ARADDR(m_axi_ddr_ARADDR),
    .M_AXI_ARLEN(m_axi_ddr_ARLEN),
    .M_AXI_ARSIZE(m_axi_ddr_ARSIZE),
    .M_AXI_ARBURST(m_axi_ddr_ARBURST),
    .M_AXI_ARLOCK(m_axi_ddr_ARLOCK),
    .M_AXI_ARCACHE(m_axi_ddr_ARCACHE),
    .M_AXI_ARPROT(m_axi_ddr_ARPROT),
    .M_AXI_ARQOS(m_axi_ddr_ARQOS),
    .M_AXI_ARVALID(m_axi_ddr_ARVALID),
    .M_AXI_ARREADY(m_axi_ddr_ARREADY),
    .M_AXI_RID(m_axi_ddr_RID),
    .M_AXI_RDATA(m_axi_ddr_RDATA),
    .M_AXI_RRESP(m_axi_ddr_RRESP),
    .M_AXI_RLAST(m_axi_ddr_RLAST),
    .M_AXI_RVALID(m_axi_ddr_RVALID),
    .M_AXI_RREADY(m_axi_ddr_RREADY)
  );

  Veronica inst_veronica
  (
    .io_aclk(axi_cpu_clk),
    .io_arst(sys_rstgen_peripheral_reset),
    .io_debug_rst(debug_rst),
    .io_ddr_clk(axi_ddr_ctrl_ui_clk),
    .io_ddr_rst(ddr_rstgen_peripheral_reset),
    .io_irq({{128-9{1'b0}}, spio_irq, axi_timer_irq, axi_tft_irq, axi_quad_spi_irq, axi_spi_irq, axi_ethernet_irq, axi_uartlite_irq, IRQ, 1'b0}),
    //.io_s_axi_dma0_aclk(s_axi_dma_aclk),
    //.io_s_axi_dma0_arst(s_axi_dma_arst),
    //.io_s_axi_dma1_aclk(axi_cpu_clk),
    //.io_s_axi_dma1_arst(sys_rstgen_peripheral_reset),
  `ifdef _JTAG_IO
    .io_jtag_tms(tms),
    .io_jtag_tdi(tdi),
    .io_jtag_tdo(tdo),
    .io_jtag_tck(tck),
  `endif
    .m_axi_acc_araddr(M_AXI_araddr),
    .m_axi_acc_arprot(M_AXI_arprot),
    .m_axi_acc_arready(M_AXI_arready),
    .m_axi_acc_arvalid(M_AXI_arvalid),
    .m_axi_acc_awaddr(M_AXI_awaddr),
    .m_axi_acc_awprot(M_AXI_awprot),
    .m_axi_acc_awready(M_AXI_awready),
    .m_axi_acc_awvalid(M_AXI_awvalid),
    .m_axi_acc_bready(M_AXI_bready),
    .m_axi_acc_bresp(M_AXI_bresp),
    .m_axi_acc_bvalid(M_AXI_bvalid),
    .m_axi_acc_rdata(M_AXI_rdata),
    .m_axi_acc_rready(M_AXI_rready),
    .m_axi_acc_rresp(M_AXI_rresp),
    .m_axi_acc_rvalid(M_AXI_rvalid),
    .m_axi_acc_wdata(M_AXI_wdata),
    .m_axi_acc_wready(M_AXI_wready),
    .m_axi_acc_wstrb(M_AXI_wstrb),
    .m_axi_acc_wvalid(M_AXI_wvalid),
    .m_axi_perf_araddr(s_axi_perf_ARADDR),
    .m_axi_perf_arready(s_axi_perf_ARREADY),
    .m_axi_perf_arvalid(s_axi_perf_ARVALID),
    .m_axi_perf_arprot(s_axi_perf_ARPROT),
    .m_axi_perf_awaddr(s_axi_perf_AWADDR),
    .m_axi_perf_awprot(s_axi_perf_AWPROT),
    .m_axi_perf_awready(s_axi_perf_AWREADY),
    .m_axi_perf_awvalid(s_axi_perf_AWVALID),
    .m_axi_perf_bready(s_axi_perf_BREADY),
    .m_axi_perf_bresp(s_axi_perf_BRESP),
    .m_axi_perf_bvalid(s_axi_perf_BVALID),
    .m_axi_perf_rdata(s_axi_perf_RDATA),
    .m_axi_perf_rready(s_axi_perf_RREADY),
    .m_axi_perf_rresp(s_axi_perf_RRESP),
    .m_axi_perf_rvalid(s_axi_perf_RVALID),
    .m_axi_perf_wdata(s_axi_perf_WDATA),
    .m_axi_perf_wready(s_axi_perf_WREADY),
    .m_axi_perf_wstrb(s_axi_perf_WSTRB),
    .m_axi_perf_wvalid(s_axi_perf_WVALID),
    .m_axi_mbus_araddr(s_axi_mbus_ARADDR),
    .m_axi_mbus_arburst(s_axi_mbus_ARBURST),
    .m_axi_mbus_arcache(s_axi_mbus_ARCACHE),
    .m_axi_mbus_arid(s_axi_mbus_ARID),
    .m_axi_mbus_arlen(s_axi_mbus_ARLEN),
    .m_axi_mbus_arprot(s_axi_mbus_ARPROT),
    .m_axi_mbus_arready(s_axi_mbus_ARREADY),
    .m_axi_mbus_arsize(s_axi_mbus_ARSIZE),
    .m_axi_mbus_arvalid(s_axi_mbus_ARVALID),
    .m_axi_mbus_awaddr(s_axi_mbus_AWADDR),
    .m_axi_mbus_awburst(s_axi_mbus_AWBURST),
    .m_axi_mbus_awcache(s_axi_mbus_AWCACHE),
    .m_axi_mbus_awid(s_axi_mbus_AWID),
    .m_axi_mbus_awlen(s_axi_mbus_AWLEN),
    .m_axi_mbus_awprot(s_axi_mbus_AWPROT),
    .m_axi_mbus_awready(s_axi_mbus_AWREADY),
    .m_axi_mbus_awsize(s_axi_mbus_AWSIZE),
    .m_axi_mbus_awvalid(s_axi_mbus_AWVALID),
    .m_axi_mbus_bid(s_axi_mbus_BID),
    .m_axi_mbus_bready(s_axi_mbus_BREADY),
    .m_axi_mbus_bvalid(s_axi_mbus_BVALID),
    .m_axi_mbus_rdata(s_axi_mbus_RDATA),
    .m_axi_mbus_rid(s_axi_mbus_RID),
    .m_axi_mbus_rlast(s_axi_mbus_RLAST),
    .m_axi_mbus_rready(s_axi_mbus_RREADY),
    .m_axi_mbus_rvalid(s_axi_mbus_RVALID),
    .m_axi_mbus_wdata(s_axi_mbus_WDATA),
    .m_axi_mbus_wlast(s_axi_mbus_WLAST),
    .m_axi_mbus_wready(s_axi_mbus_WREADY),
    .m_axi_mbus_wstrb(s_axi_mbus_WSTRB),
    .m_axi_mbus_wvalid(s_axi_mbus_WVALID),
    .m_axi_mbus_arqos(s_axi_mbus_ARQOS),
    .m_axi_mbus_arlock(s_axi_mbus_ARLOCK),
    .m_axi_mbus_awqos(s_axi_mbus_AWQOS),
    .m_axi_mbus_awlock(s_axi_mbus_AWLOCK),
    .m_axi_mbus_rresp(s_axi_mbus_RRESP),
    .m_axi_mbus_bresp(s_axi_mbus_BRESP)
  );

  sys_rstgen inst_sys_rstgen
  (
    .aux_reset_in(axi_ddr_ctrl_ui_clk_sync_rst),
    .dcm_locked(axi_ddr_ctrl_mmcm_locked),
    .ext_reset_in(sys_rstn),
    .interconnect_aresetn(sys_rstgen_interconnect_aresetn),
    .mb_debug_sys_rst(debug_rst),
    .peripheral_reset(sys_rstgen_peripheral_reset),
    .peripheral_aresetn(sys_rstgen_peripheral_aresetn),
    .slowest_sync_clk(axi_cpu_clk)
  );
endmodule
