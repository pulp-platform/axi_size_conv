onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/axi_128_bus/w_valid
add wave -noupdate /tb/axi_128_bus/w_ready
add wave -noupdate /tb/axi_128_bus/w_last
add wave -noupdate /tb/Write_Upsize_32_to_128/clk_i
add wave -noupdate /tb/Write_Upsize_32_to_128/rst_ni
add wave -noupdate /tb/Write_Upsize_32_to_128/test_en_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_valid_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_addr_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_id_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_prot_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_region_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_len_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_size_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_burst_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_lock_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_cache_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_qos_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_user_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_ready_o
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_w_valid_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_w_data_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_w_strb_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_w_user_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_w_last_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_w_ready_o
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_b_valid_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_b_resp_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_b_id_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_b_user_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_b_ready_i
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/Write_Upsize_32_to_128/clk_i
add wave -noupdate /tb/Write_Upsize_32_to_128/push_data_FIFO
add wave -noupdate -color Cyan -itemcolor Cyan /tb/Write_Upsize_32_to_128/push_valid_FIFO
add wave -noupdate /tb/Write_Upsize_32_to_128/push_grant_FIFO
add wave -noupdate /tb/Write_Upsize_32_to_128/pop_data_FIFO
add wave -noupdate -color Magenta -itemcolor Magenta /tb/Write_Upsize_32_to_128/pop_valid_FIFO
add wave -noupdate /tb/Write_Upsize_32_to_128/pop_grant_FIFO
add wave -noupdate /tb/axi_128_bus/w_last
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_valid_o
add wave -noupdate -color Gold -itemcolor Gold /tb/Write_Upsize_32_to_128/axi_master_aw_ready_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_addr_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_prot_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_region_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_len_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_size_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_burst_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_lock_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_cache_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_qos_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_id_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_user_o
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_w_data_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_w_strb_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_w_user_o
add wave -noupdate -color Magenta -itemcolor Magenta /tb/Write_Upsize_32_to_128/axi_master_w_last_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_w_valid_o
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_w_ready_i
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/Write_Upsize_32_to_128/clear_strobe
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_b_valid_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_b_resp_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_b_id_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_b_user_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_b_ready_o
add wave -noupdate /tb/Write_Upsize_32_to_128/CounterBurst_CS
add wave -noupdate /tb/Write_Upsize_32_to_128/CounterBurst_NS
add wave -noupdate /tb/Write_Upsize_32_to_128/Chunk_Pointer
add wave -noupdate /tb/Write_Upsize_32_to_128/CounterChunk_CS
add wave -noupdate /tb/Write_Upsize_32_to_128/CounterChunk_NS
add wave -noupdate /tb/Write_Upsize_32_to_128/CS
add wave -noupdate /tb/Write_Upsize_32_to_128/NS
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/Write_Upsize_32_to_128/clk_i
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_valid_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_addr_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_prot_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_region_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_len_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_size_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_burst_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_lock_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_cache_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_qos_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_id_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_user_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_ready_int
add wave -noupdate -divider {New Divider}
add wave -noupdate -color Magenta -itemcolor Magenta /tb/Write_Upsize_32_to_128/pop_valid_FIFO
add wave -noupdate /tb/Write_Upsize_32_to_128/clk_i
add wave -noupdate -color Cyan -itemcolor Cyan /tb/Write_Upsize_32_to_128/update_write_data
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_w_valid_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_w_data_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_w_strb_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_w_user_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_w_last_int
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_w_ready_int
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_slave_aw_len_Q
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_aw_displacement_Q
add wave -noupdate -expand /tb/Write_Upsize_32_to_128/axi_master_w_data_Q
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_w_strb_Q
add wave -noupdate /tb/Write_Upsize_32_to_128/axi_master_w_user_Q
add wave -noupdate /tb/Write_Upsize_32_to_128/start_ADDR
add wave -noupdate /tb/Write_Upsize_32_to_128/end_ADDR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {56324 ps} 0} {{Cursor 2} {68418084 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 236
configure wave -valuecolwidth 307
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {105 ns}
