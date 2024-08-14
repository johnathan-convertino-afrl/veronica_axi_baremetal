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
          input     [28:0]    IRQ,
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
          input               UART_rxd,
          output              UART_txd,
          input     [31:0]    gpio0_io_i,
          output    [31:0]    gpio0_io_o,
          output    [31:0]    gpio0_io_t,
          input     [31:0]    gpio1_io_i,
          output    [31:0]    gpio1_io_o,
          output    [31:0]    gpio1_io_t,
          input               s_axi_dma_arstn,
          output              s_axi_clk,
          input               s_axi_dma_aclk,
          input     [31:0]    s_axi_dma_araddr,
          input     [ 3:0]    s_axi_dma_arcache,
          input     [ 7:0]    s_axi_dma_arlen,
          input     [ 2:0]    s_axi_dma_arprot,
          output              s_axi_dma_arready,
          input     [ 2:0]    s_axi_dma_arsize,
          input               s_axi_dma_arvalid,
          input     [31:0]    s_axi_dma_awaddr,
          input     [ 3:0]    s_axi_dma_awcache,
          input     [ 7:0]    s_axi_dma_awlen,
          input     [ 2:0]    s_axi_dma_awprot,
          output              s_axi_dma_awready,
          input     [ 2:0]    s_axi_dma_awsize,
          input               s_axi_dma_awvalid,
          input               s_axi_dma_bready,
          output              s_axi_dma_bvalid,
          output    [31:0]    s_axi_dma_rdata,
          output              s_axi_dma_rlast,
          input               s_axi_dma_rready,
          output              s_axi_dma_rvalid,
          input     [31:0]    s_axi_dma_wdata,
          input               s_axi_dma_wlast,
          output              s_axi_dma_wready,
          input     [ 3:0]    s_axi_dma_wstrb,
          input               s_axi_dma_wvalid,
          output    [ 7:0]    spi_ss,
          output              spi_sclk,
          output              spi_mosi,
          input               spi_miso,
          input               sys_clk,
          input               sys_rstn,
          output              vga_vSync,
          output              vga_hSync,
          output              vga_colorEn,
          output [2:0]        vga_color_r,
          output [2:0]        vga_color_g,
          output [1:0]        vga_color_b
     );

     //ethernet buf signals
     wire           MDIO_mdio_i;
     wire           MDIO_mdio_o;
     wire           MDIO_mdio_t;

     //clocks
     wire           cpu_clk;
     wire           ddr_clk;
     wire           vga_clk;

     //jtag
     wire           jtag_tck;
     wire           jtag_tdi;
     wire           jtag_tdo;
     wire           jtag_tms;

     //resets
     wire [ 0:0]    ddr_rstgen_peripheral_aresetn;
     wire [ 0:0]    sys_rstgen_peripheral_aresetn;
     wire [ 0:0]    sys_rstgen_peripheral_reset;

     //ddr signals and clocks
     wire           axi_ddr_ctrl_mmcm_locked;
     wire           axi_ddr_ctrl_ui_clk;
     wire           axi_ddr_ctrl_ui_clk_sync_rst;

     //axi4 w/ID memory bus (ibus/dbus path)
     wire [31:0]    m_axi_mbus_ARADDR;
     wire [ 1:0]    m_axi_mbus_ARBURST;
     wire [ 3:0]    m_axi_mbus_ARCACHE;
     wire [ 3:0]    m_axi_mbus_ARID;
     wire [ 7:0]    m_axi_mbus_ARLEN;
     wire [ 2:0]    m_axi_mbus_ARPROT;
     wire           m_axi_mbus_ARREADY;
     wire [ 2:0]    m_axi_mbus_ARSIZE;
     wire           m_axi_mbus_ARVALID;
     wire [31:0]    m_axi_mbus_AWADDR;
     wire [ 1:0]    m_axi_mbus_AWBURST;
     wire [ 3:0]    m_axi_mbus_AWCACHE;
     wire [ 3:0]    m_axi_mbus_AWID;
     wire [ 7:0]    m_axi_mbus_AWLEN;
     wire [ 2:0]    m_axi_mbus_AWPROT;
     wire           m_axi_mbus_AWREADY;
     wire [ 2:0]    m_axi_mbus_AWSIZE;
     wire           m_axi_mbus_AWVALID;
     wire [ 3:0]    m_axi_mbus_BID;
     wire           m_axi_mbus_BREADY;
     wire           m_axi_mbus_BVALID;
     wire [31:0]    m_axi_mbus_RDATA;
     wire [ 3:0]    m_axi_mbus_RID;
     wire           m_axi_mbus_RLAST;
     wire           m_axi_mbus_RREADY;
     wire           m_axi_mbus_RVALID;
     wire [31:0]    m_axi_mbus_WDATA;
     wire           m_axi_mbus_WLAST;
     wire           m_axi_mbus_WREADY;
     wire [ 3:0]    m_axi_mbus_WSTRB;
     wire           m_axi_mbus_WVALID;

     //distribute clock for axi and assign to output for m_axi_acc
     assign s_axi_clk = cpu_clk;

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
          .s_axi_araddr(m_axi_mbus_ARADDR),
          .s_axi_arburst(m_axi_mbus_ARBURST),
          .s_axi_arcache(m_axi_mbus_ARCACHE),
          .s_axi_arid(m_axi_mbus_ARID),
          .s_axi_arlen(m_axi_mbus_ARLEN),
          .s_axi_arlock(1'b0),
          .s_axi_arprot(m_axi_mbus_ARPROT),
          .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
          .s_axi_arready(m_axi_mbus_ARREADY),
          .s_axi_arsize(m_axi_mbus_ARSIZE),
          .s_axi_arvalid(m_axi_mbus_ARVALID),
          .s_axi_awaddr(m_axi_mbus_AWADDR),
          .s_axi_awburst(m_axi_mbus_AWBURST),
          .s_axi_awcache(m_axi_mbus_AWCACHE),
          .s_axi_awid(m_axi_mbus_AWID),
          .s_axi_awlen(m_axi_mbus_AWLEN),
          .s_axi_awlock(1'b0),
          .s_axi_awprot(m_axi_mbus_AWPROT),
          .s_axi_awqos({1'b0,1'b0,1'b0,1'b0}),
          .s_axi_awready(m_axi_mbus_AWREADY),
          .s_axi_awsize(m_axi_mbus_AWSIZE),
          .s_axi_awvalid(m_axi_mbus_AWVALID),
          .s_axi_bid(m_axi_mbus_BID),
          .s_axi_bready(m_axi_mbus_BREADY),
          .s_axi_bvalid(m_axi_mbus_BVALID),
          .s_axi_rdata(m_axi_mbus_RDATA),
          .s_axi_rid(m_axi_mbus_RID),
          .s_axi_rlast(m_axi_mbus_RLAST),
          .s_axi_rready(m_axi_mbus_RREADY),
          .s_axi_rvalid(m_axi_mbus_RVALID),
          .s_axi_wdata(m_axi_mbus_WDATA),
          .s_axi_wlast(m_axi_mbus_WLAST),
          .s_axi_wready(m_axi_mbus_WREADY),
          .s_axi_wstrb(m_axi_mbus_WSTRB),
          .s_axi_wvalid(m_axi_mbus_WVALID),
          .sys_clk_i(ddr_clk),
          .sys_rst(sys_rstn),
          .ui_clk(axi_ddr_ctrl_ui_clk),
          .ui_clk_sync_rst(axi_ddr_ctrl_ui_clk_sync_rst)
     );

     clk_wiz_1 inst_clk_wiz_1
     (
          .clk_in1(sys_clk),
          .clk_out1(cpu_clk),
          .clk_out2(ddr_clk),
          .clk_out3(vga_clk)
     );

     ddr_rstgen inst_ddr_rstgen
     (
          .aux_reset_in(axi_ddr_ctrl_ui_clk_sync_rst),
          .dcm_locked(axi_ddr_ctrl_mmcm_locked),
          .ext_reset_in(sys_rstn),
          .mb_debug_sys_rst(1'b0),
          .peripheral_aresetn(ddr_rstgen_peripheral_aresetn),
          .slowest_sync_clk(axi_ddr_ctrl_ui_clk)
     );

     //BSCANE2 #(
          //.DISABLE_JTAG("FALSE"),
          //.JTAG_CHAIN(2)
     //) inst_bSCANE2 (
          //.CAPTURE (), //o
          //.DRCK    (), //o
          //.RESET   (), //o
          //.RUNTEST (), //o
          //.SEL     (), //o
          //.SHIFT   (), //o
          //.TCK     (jtag_tck), //o
          //.TDI     (jtag_tdi), //o
          //.TMS     (jtag_tms), //o
          //.UPDATE  (), //o
          //.TDO     (jtag_tdo)  //i
     //);

     Veronica inst_veronica
     (
          .io_arst(sys_rstgen_peripheral_reset),
          .io_axi_clk(cpu_clk),
          .io_vga_clk(vga_clk),
          .io_ddr_clk(axi_ddr_ctrl_ui_clk),
          //.io_eth_clk(eth_clk),
          .io_s_axi_dma0_aclk(s_axi_dma_aclk),
          .io_s_axi_dma0_arstn(s_axi_dma_arstn),
          //.io_jtag_tms(jtag_tms),
          //.io_jtag_tdi(jtag_tdi),
          //.io_jtag_tdo(jtag_tdo),
          //.io_jtag_tck(jtag_tck),
          .m_axi_mbus_araddr(m_axi_mbus_ARADDR),
          .m_axi_mbus_arburst(m_axi_mbus_ARBURST),
          .m_axi_mbus_arcache(m_axi_mbus_ARCACHE),
          .m_axi_mbus_arid(m_axi_mbus_ARID),
          .m_axi_mbus_arlen(m_axi_mbus_ARLEN),
          .m_axi_mbus_arprot(m_axi_mbus_ARPROT),
          .m_axi_mbus_arready(m_axi_mbus_ARREADY),
          .m_axi_mbus_arsize(m_axi_mbus_ARSIZE),
          .m_axi_mbus_arvalid(m_axi_mbus_ARVALID),
          .m_axi_mbus_awaddr(m_axi_mbus_AWADDR),
          .m_axi_mbus_awburst(m_axi_mbus_AWBURST),
          .m_axi_mbus_awcache(m_axi_mbus_AWCACHE),
          .m_axi_mbus_awid(m_axi_mbus_AWID),
          .m_axi_mbus_awlen(m_axi_mbus_AWLEN),
          .m_axi_mbus_awprot(m_axi_mbus_AWPROT),
          .m_axi_mbus_awready(m_axi_mbus_AWREADY),
          .m_axi_mbus_awsize(m_axi_mbus_AWSIZE),
          .m_axi_mbus_awvalid(m_axi_mbus_AWVALID),
          .m_axi_mbus_bid(m_axi_mbus_BID),
          .m_axi_mbus_bready(m_axi_mbus_BREADY),
          .m_axi_mbus_bvalid(m_axi_mbus_BVALID),
          .m_axi_mbus_rdata(m_axi_mbus_RDATA),
          .m_axi_mbus_rid(m_axi_mbus_RID),
          .m_axi_mbus_rlast(m_axi_mbus_RLAST),
          .m_axi_mbus_rready(m_axi_mbus_RREADY),
          .m_axi_mbus_rvalid(m_axi_mbus_RVALID),
          .m_axi_mbus_wdata(m_axi_mbus_WDATA),
          .m_axi_mbus_wlast(m_axi_mbus_WLAST),
          .m_axi_mbus_wready(m_axi_mbus_WREADY),
          .m_axi_mbus_wstrb(m_axi_mbus_WSTRB),
          .m_axi_mbus_wvalid(m_axi_mbus_WVALID),
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
          .s_axi_dma0_araddr(s_axi_dma_araddr),
          .s_axi_dma0_arcache(s_axi_dma_arcache),
          .s_axi_dma0_arlen(s_axi_dma_arlen),
          .s_axi_dma0_arprot(s_axi_dma_arprot),
          .s_axi_dma0_arready(s_axi_dma_arready),
          .s_axi_dma0_arsize(s_axi_dma_arsize),
          .s_axi_dma0_arvalid(s_axi_dma_arvalid),
          .s_axi_dma0_awaddr(s_axi_dma_awaddr),
          .s_axi_dma0_awcache(s_axi_dma_awcache),
          .s_axi_dma0_awlen(s_axi_dma_awlen),
          .s_axi_dma0_awprot(s_axi_dma_awprot),
          .s_axi_dma0_awready(s_axi_dma_awready),
          .s_axi_dma0_awsize(s_axi_dma_awsize),
          .s_axi_dma0_awvalid(s_axi_dma_awvalid),
          .s_axi_dma0_bready(s_axi_dma_bready),
          .s_axi_dma0_bvalid(s_axi_dma_bvalid),
          .s_axi_dma0_rdata(s_axi_dma_rdata),
          .s_axi_dma0_rlast(s_axi_dma_rlast),
          .s_axi_dma0_rready(s_axi_dma_rready),
          .s_axi_dma0_rvalid(s_axi_dma_rvalid),
          .s_axi_dma0_wdata(s_axi_dma_wdata),
          .s_axi_dma0_wlast(s_axi_dma_wlast),
          .s_axi_dma0_wready(s_axi_dma_wready),
          .s_axi_dma0_wstrb(s_axi_dma_wstrb),
          .s_axi_dma0_wvalid(s_axi_dma_wvalid),
          .io_gpioA_read(gpio0_io_i),
          .io_gpioA_write(gpio0_io_o),
          .io_gpioA_writeEnable(gpio0_io_t),
          .io_gpioB_read(gpio1_io_i),
          .io_gpioB_write(gpio1_io_0),
          .io_gpioB_writeEnable(gpio1_io_t),
          .io_uart_txd(UART_txd),
          .io_uart_rxd(UART_rxd),
          .io_spi_ss(spi_ss),
          .io_spi_sclk(spi_sclk),
          .io_spi_mosi(spi_mosi),
          .io_spi_miso(spi_miso),
          .io_i2c_sda_write(),
          .io_i2c_sda_read(1'b0),
          .io_i2c_scl_write(),
          .io_i2c_scl_read(1'b0),
          .io_vga_vSync(vga_vSync),
          .io_vga_hSync(vga_hSync),
          .io_vga_colorEn(vga_colorEn),
          .io_vga_color_r(vga_color_r),
          .io_vga_color_g(vga_color_g),
          .io_vga_color_b(vga_color_b),
          .io_irq(IRQ)
     );

     sys_rstgen inst_sys_rstgen
     (
          .aux_reset_in(axi_ddr_ctrl_ui_clk_sync_rst),
          .dcm_locked(axi_ddr_ctrl_mmcm_locked),
          .ext_reset_in(sys_rstn),
          .mb_debug_sys_rst(1'b0),
          .peripheral_reset(sys_rstgen_peripheral_reset),
          .peripheral_aresetn(sys_rstgen_peripheral_aresetn),
          .slowest_sync_clk(cpu_clk)
     );
endmodule
