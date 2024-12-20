# Veronica AXI Baremetal FPGA Project
### Contains core files and scripts to generate a Vexriscv platform using fusesoc.

![image](docs/manual/img/AFRL.png)

---

   author: Jay Convertino

   date: 2024.11.25

   details: Generate Vexriscv (Veronica, RISCV) FPGA image for various targets. See fusesoc section for targets available.

   license: MIT

---

### Version
#### Current
  - none

#### Previous
  - none

### DOCUMENTATION
  For detailed usage information, please navigate to one of the following sources. They are the same, just in a different format.

  - [veronica_axi_baremetal.pdf](docs/manual/veronica_axi_baremetal.pdf)
  - [github page](https://johnathan-convertino-afrl.github.io/veronica_axi_baremetal/)

### DEPENDENCIES
#### Build
  - AFRL:utility:digilent_nexys-a7-100t_board_base_constr:1.0.0
  - AFRL:utility:digilent_nexys-a7-100t_board_base_ddr_cfg:1.0.0
  - AFRL:utility:vivado_board_support_packages
  - AD:ethernet:util_mii_to_rmii:1.0.0
  - AFRL:utility:helper:1.0.0
  - AFRL:utility:tcl_helper_check:1.0.0
  - zipcpu:axi_lite:crossbar:1.0.0
  - zipcpu:axi:crossbar:1.0.0
  - zipcpu:axi:sdio:1.0.0
  - zipcpu:axi:axixclk:1.0.0
  - spinalhdl:cpu:veronica_axi_jtag_io:1.0.0
  - spinalhdl:cpu:veronica_axi_secure_jtag_io:1.0.0
  - spinalhdl:cpu:veronica_axi_jtag_xilinx_bscane:1.0.0
  - spinalhdl:cpu:veronica_axi_secure_jtag_xilinx_bscane:1.0.0

#### Simulation
  - none, not implimented.

### FUSESOC

* fusesoc_info.core created.
* Simulation not available

#### Targets

* RUN WITH: (fusesoc run --target=zed_bootgen VENDER:CORE:NAME:VERSION)
* -- target can be one of the below.
  - nexys-a7-100t                       : Base for nexys-a7-100t digilent development board builds, do not use.
  - nexys-a7-100t_uc_secure_jtag_io     : Build for nexys-a7-100t digilent development board with PMP enabled Veronica RISCV and JTAG using IO pins.
  - nexys-a7-100t_uc_jtag_io            : Build for nexys-a7-100t digilent development board with standard Veronica RISCV and JTAG using IO pins.
  - nexys-a7-100t_uc_secure_jtag_bscane : Build for nexys-a7-100t digilent development board with PMP enabled Veronica RISCV using Xilinx BSCANE JTAG.
  - nexys-a7-100t_uc_jtag_bscane        : Build for nexys-a7-100t digilent development board with standard Veronica RISCV using Xilinx BSCANE JTAG.
