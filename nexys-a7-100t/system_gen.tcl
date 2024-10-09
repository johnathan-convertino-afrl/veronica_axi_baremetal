# set part [get_property PART [current_project]]
#
#
# set CLK_FREQ_MHZ [get_property CONFIG.CLKOUT1_REQUESTED_OUT_FREQ [get_ips clk_wiz_1]]
# set_property generic clock_speed=[ expr $CLK_FREQ_MHZ * 1000000 ] [current_fileset]

set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]

reorder_files -fileset constrs_1 -front [get_files system_constr.tcl]

#fixes for zipcpu axi_crossbar in vivado. default_net will screw up synth. make all files last.
reorder_files -fileset sources_1 -back [get_files skidbuffer.v]
reorder_files -fileset sources_1 -back [get_files addrdecode.v]
reorder_files -fileset sources_1 -back [get_files axixbar.v]
reorder_files -fileset sources_1 -back [get_files axilxbar.v]
#fixes for zipcpu sdspi in vivado. default_net will screw up synth. make all files last.
reorder_files -fileset sources_1 -back [get_files afifo.v]
reorder_files -fileset sources_1 -back [get_files sdckgen.v]
reorder_files -fileset sources_1 -back [get_files sddma_rxgears.v]
reorder_files -fileset sources_1 -back [get_files sddma.v]
reorder_files -fileset sources_1 -back [get_files sdio.v]
reorder_files -fileset sources_1 -back [get_files sdio_top.v]
reorder_files -fileset sources_1 -back [get_files sdtxframe.v]
reorder_files -fileset sources_1 -back [get_files sdcmd.v]
# reorder_files -fileset sources_1 -back [get_files sddma_s2mm.v]
reorder_files -fileset sources_1 -back [get_files sdfifo.v]
# reorder_files -fileset sources_1 -back [get_files sdio.v]
# reorder_files -fileset sources_1 -back [get_files sdwb.v]
reorder_files -fileset sources_1 -back [get_files xsdddr.v]
# reorder_files -fileset sources_1 -back [get_files sddma_mm2s.v]
reorder_files -fileset sources_1 -back [get_files sddma_txgears.v]
reorder_files -fileset sources_1 -back [get_files sdfrontend.v]
reorder_files -fileset sources_1 -back [get_files sdrxframe.v]
reorder_files -fileset sources_1 -back [get_files xsdserdes8x.v]
reorder_files -fileset sources_1 -back [get_files axixclk.v]
reorder_files -fileset sources_1 -back [get_files sdaxil.v]
reorder_files -fileset sources_1 -back [get_files sdskid.v]

# set_property strategy Performance_Retiming [get_runs impl_1]
# set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
# set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
# set_property dataflow_viewer_settings "min_width=16"   [current_fileset]
# set_property strategy Performance_Retiming [get_runs impl_1]
# set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]
