#############################
# Read Technology Libraries #
#############################

# Liberty file of standard cells
yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib

# Liberty file of I/O pads
yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_io/lib/gf180mcu_fd_io__tt_025C_5v00.lib

# Liberty file of SRAM IP
# yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_ip_sram/lib/gf180mcu_fd_ip_sram__sram64x8m8wm1__tt_025C_5v00.lib
# yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_ip_sram/lib/gf180mcu_fd_ip_sram__sram128x8m8wm1__tt_025C_5v00.lib
# yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_ip_sram/lib/gf180mcu_fd_ip_sram__sram256x8m8wm1__tt_025C_5v00.lib
yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_ip_sram/lib/gf180mcu_fd_ip_sram__sram512x8m8wm1__tt_025C_5v00.lib

###############
# Load Design #
###############

yosys plugin -i slang.so

yosys read_slang --top pulpissimo -F /foss/designs/pulpissimo/pulpissimo.flist -D SYNTHESIS -D VERILATOR --allow-use-before-declare --ignore-unknown-modules --keep-hierarchy

#yosys stat -liberty $env(PDKPATH)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib

yosys stat
yosys tee -q -o "reports/pulpissimo_parsed.rpt" stat
yosys write_verilog "out/pulpissimo_analysis.v"

#########################
###### Elaboration ######
#########################
# 5.1 Resolve design hierarchy
yosys hierarchy -check -top pulpissimo

# 5.2 Convert processes to netlists
yosys proc

# 5.3 Export report and netlist
yosys stat
yosys tee -q -o "reports/pulpissimo_netlist.rpt" stat
yosys write_verilog "out/pulpissimo_netlist.v"

####################################
###### Coarse-grain Synthesis ######
####################################
# 6.1 Early-stage design check
yosys check
# 6.2 First opt pass (no FF)
yosys opt -noff
# 6.3 Extract FSM and write report
yosys fsm
yosys stat
yosys tee -q -o "reports/pulpissimo_opt_fms.rpt" stat
# 6.4 Perform wreduce
yosys wreduce
# 6.5 Perform peepopt
yosys peepopt
# 6.6 Perform full opt
yosys opt -noff -full
# 6.7 Infer memories and optimize register-files
yosys memory
# 6.8 Optimize flip-flops
yosys opt_dff
yosys stat
yosys tee -q -o "reports/pulpissimos_opt_dff.rpt" stat

###########################################
###### Define target clock frequency ######
###########################################

# 7.1 Define clock period variable
set period_ps 10000

##################################
###### Fine-grain synthesis ######
##################################

# 9.1 Generic cell substitution
yosys techmap
# 9.2 Generate report
yosys stat
yosys tee -q -o "reports/croc_techmap.rpt" stat

############################
###### Flatten design ######
############################

# Before flattening, preserve the hierarchy of critical modules to
# prevent synthesis tools from breaking them.

# 1. Preserve ALL Clock Domain Crossing (CDC) and synchronization modules.
# This is critical for preventing metastability issues.
yosys setattr -set keep_hierarchy 1 "t:cdc_*"
yosys setattr -set keep_hierarchy 1 "t:sync*"
yosys setattr -set keep_hierarchy 1 "t:axi_cdc*"
yosys setattr -set keep_hierarchy 1 "t:dmi_cdc"

# 2. Preserve ALL memories (SRAMs, ROMs, Register Files).
# This is mandatory for the physical design (place-and-route) flow.
yosys setattr -set keep_hierarchy 1 "t:*_sram*"
yosys setattr -set keep_hierarchy 1 "t:*_ram*"
yosys setattr -set keep_hierarchy 1 "t:*_rom"
yosys setattr -set keep_hierarchy 1 "t:scm_*"
yosys setattr -set keep_hierarchy 1 "t:register_file_*"

# 3. Preserve specialized clocking and reset logic.
yosys setattr -set keep_hierarchy 1 "t:glitch_free_clk_mux"
yosys setattr -set keep_hierarchy 1 "t:rstgen*"

# 4. (Optional but Recommended) Preserve major IP block boundaries for easier debugging.
yosys setattr -set keep_hierarchy 1 "t:riscv_core"
yosys setattr -set keep_hierarchy 1 "t:ibex_core"
yosys setattr -set keep_hierarchy 1 "t:pulp_soc"

# Flatten the rest of the design to allow for cross-boundary optimizations.
yosys flatten

# Liberty file of standard cells
yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib

# Liberty file of I/O pads
yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_io/lib/gf180mcu_fd_io__tt_025C_5v00.lib

# Liberty file of SRAM IP
yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_ip_sram/lib/gf180mcu_fd_ip_sram__sram512x8m8wm1__tt_025C_5v00.lib

################################
###### Technology Mapping ######
################################

# 1. Register mapping to the GF180nmcu standard cell library
yosys dfflibmap -liberty $env(PDKPATH)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib

# 2. Generate a post-dfflibmap statistics report
yosys stat -liberty $env(PDKPATH)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib
yosys tee -q -o "reports/pulpissimo_dfflibmap.rpt" stat

# 3. Combinational logic mapping using ABC
yosys abc -liberty $env(PDKPATH)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib -D ${period_ps} -constr src/yosys_abc.constr -script scripts/abc-opt.script

# 4. Generate a post-ABC statistics report
yosys stat -liberty $env(PDKPATH)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib
yosys tee -q -o "reports/pulpissimo_abc.rpt" stat

# 5. Export the final technology-mapped netlist
yosys write_verilog out/pulpissimo.v
