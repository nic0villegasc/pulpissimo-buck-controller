#############################
# Read Technology Libraries #
#############################

# Liberty file of standard cells
yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib

# Liberty file of I/O pads
yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_io/lib/gf180mcu_fd_io__tt_025C_5v00.lib

# Liberty file of SRAM IP
yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_ip_sram/lib/gf180mcu_fd_ip_sram__sram64x8m8wm1__tt_025C_5v00.lib
yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_ip_sram/lib/gf180mcu_fd_ip_sram__sram128x8m8wm1__tt_025C_5v00.lib
yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_ip_sram/lib/gf180mcu_fd_ip_sram__sram256x8m8wm1__tt_025C_5v00.lib
yosys read_liberty -lib $env(PDKPATH)/libs.ref/gf180mcu_fd_ip_sram/lib/gf180mcu_fd_ip_sram__sram512x8m8wm1__tt_025C_5v00.lib

###############
# Load Design #
###############

yosys plugin -i slang.so

yosys read_slang --top pulpissimo -F /foss/designs/pulpissimo/pulpissimo.flist --allow-use-before-declare --ignore-unknown-modules --keep-hierarchy

yosys stat
