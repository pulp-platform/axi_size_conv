#!/bin/tcsh

if (-e "work") then
   echo "dir existe"
else
   vlib work 
endif


vlog -sv -quiet  ../TB/tb_Write_UPSIZE.sv 

vlog -quiet -sv  ../TB/AXI32_TGEN/axi32_tgen.sv +incdir+../TB/AXI32_TGEN/traffic_pattern/
vlog -quiet -sv  ../TB/AXI32_TGEN/axi32_tgen_wrap.sv
vlog -quiet -sv  ../TB/interface.sv

vlog -quiet -sv ../AXI_UPSIZE/Write_UPSIZE.sv



vlog -quiet -sv ../../axi_slice/axi_ar_buffer.sv  
vlog -quiet -sv ../../axi_slice/axi_aw_buffer.sv  
vlog -quiet -sv ../../axi_slice/axi_b_buffer.sv   
vlog -quiet -sv ../../axi_slice/axi_buffer.sv     
vlog -quiet -sv ../../axi_slice/axi_r_buffer.sv   
vlog -quiet -sv ../../axi_slice/axi_slice.sv      
vlog -quiet -sv ../../axi_slice/axi_w_buffer.sv   


vlog -quiet -sv ../../../common_cells/generic_fifo.sv
vlog -quiet -sv ../../../common_cells/cluster_clock_gating.sv

