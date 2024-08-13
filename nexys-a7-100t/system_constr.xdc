set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]


## I/O delay constraints
create_clock -period 10.000 -name VIRTUAL_clk_out1_system_clk_wiz_1 -waveform {0.000 5.000}

set_input_delay -clock VIRTUAL_clk_out1_system_clk_wiz_1 -max 50.000 [get_ports ftdi_tx]
set_input_delay -clock VIRTUAL_clk_out1_system_clk_wiz_1 -min 20.000 [get_ports ftdi_tx]
set_output_delay -clock VIRTUAL_clk_out1_system_clk_wiz_1 -max 50.000 [get_ports ftdi_rx]
set_output_delay -clock VIRTUAL_clk_out1_system_clk_wiz_1 -min 20.000 [get_ports ftdi_rx]
set_input_delay -clock VIRTUAL_clk_out1_system_clk_wiz_1 -max 100.000 [get_ports resetn]
set_input_delay -clock VIRTUAL_clk_out1_system_clk_wiz_1 -min 50.000 [get_ports resetn]

## it doesn't actually matter
set_false_path -through [get_ports ftdi_tx]
set_false_path -through [get_ports ftdi_rx]
set_false_path -through [get_ports resetn]

##Pmod Headers
##Pmod Header pmod_ja
set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports { pmod_ja_ncs  }]
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { pmod_ja_mosi }]
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { pmod_ja_miso }]
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { pmod_ja_sck  }]
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { pmod_ja_nc   }]
set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { pmod_ja_rst  }]
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { pmod_ja_w    }]
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { pmod_ja_hld  }]


set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]






