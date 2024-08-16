# set part [get_property PART [current_project]]
#
#
# set CLK_FREQ_MHZ [get_property CONFIG.CLKOUT1_REQUESTED_OUT_FREQ [get_ips clk_wiz_1]]
# set_property generic clock_speed=[ expr $CLK_FREQ_MHZ * 1000000 ] [current_fileset]

set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]

reorder_files -fileset constrs_1 -front [get_files system_constr.xdc]

#fixes for zipcpu axi_crossbar in vivado. default_net will screw up synth. make all files last.
reorder_files -fileset sources_1 -back [get_files skidbuffer.v]
reorder_files -fileset sources_1 -back [get_files axilxbar.v]
reorder_files -fileset sources_1 -back [get_files addrdecode.v]

set_property target_constrs_file [get_files system_constr.xdc] [current_fileset -constrset]
