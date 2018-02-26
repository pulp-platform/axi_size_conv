// Copyright 2015-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`timescale  1ns/1ps


module tb;

   parameter AXI128_ADDR_WIDTH  = 32;
   parameter AXI128_DATA_WIDTH  = 128;
   parameter AXI128_STRB_WIDTH  =  16;
   parameter AXI128_USER_WIDTH  =  6;
   parameter AXI128_ID_WIDTH    =  5;

   parameter AXI64_ADDR_WIDTH  = 32;
   parameter AXI64_DATA_WIDTH  = 64;
   parameter AXI64_STRB_WIDTH  =  8;
   parameter AXI64_USER_WIDTH  =  6;
   parameter AXI64_ID_WIDTH    =  5;


   parameter AXI32_ADDR_WIDTH  = 32;
   parameter AXI32_DATA_WIDTH  = 32;
   parameter AXI32_STRB_WIDTH  =  4;
   parameter AXI32_USER_WIDTH  =  6;
   parameter AXI32_ID_WIDTH    =  5;


   logic                          clk;
   logic                          rst_n;
   logic                          test_mode_i;
   logic                          axi_fetch_enable;

    AXI_BUS
    #(
        .AXI_ADDR_WIDTH ( AXI32_ADDR_WIDTH    ),
        .AXI_DATA_WIDTH ( AXI32_DATA_WIDTH    ),
        .AXI_ID_WIDTH   ( AXI32_ID_WIDTH      ),
        .AXI_USER_WIDTH ( AXI32_USER_WIDTH    )
    )
    axi_32_bus();

    AXI_BUS
    #(
        .AXI_ADDR_WIDTH ( AXI64_ADDR_WIDTH    ),
        .AXI_DATA_WIDTH ( AXI64_DATA_WIDTH    ),
        .AXI_ID_WIDTH   ( AXI64_ID_WIDTH      ),
        .AXI_USER_WIDTH ( AXI64_USER_WIDTH    )
    )
    axi_64_bus();

    AXI_BUS
    #(
        .AXI_ADDR_WIDTH ( AXI128_ADDR_WIDTH    ),
        .AXI_DATA_WIDTH ( AXI128_DATA_WIDTH    ),
        .AXI_ID_WIDTH   ( AXI128_ID_WIDTH      ),
        .AXI_USER_WIDTH ( AXI128_USER_WIDTH    )
    )
    axi_128_bus();




   Write_Upsize
   #(
       .AXI_ADDR_WIDTH     ( AXI32_ADDR_WIDTH   ),
       .AXI_DATA_WIDTH_IN  ( AXI32_DATA_WIDTH   ),
       .AXI_USER_WIDTH_IN  ( AXI32_USER_WIDTH   ),
       .AXI_ID_WIDTH_IN    ( AXI32_ID_WIDTH     ),
       .AXI_STRB_WIDTH_IN  ( AXI32_STRB_WIDTH   ),

       .AXI_DATA_WIDTH_OUT ( AXI128_DATA_WIDTH  ),
       .AXI_USER_WIDTH_OUT ( AXI128_USER_WIDTH  ),
       .AXI_ID_WIDTH_OUT   ( AXI128_ID_WIDTH    ),
       .AXI_STRB_WIDTH_OUT ( AXI128_STRB_WIDTH  )
   )
   Write_Upsize_32_to_128
   (
       .clk_i                  ( clk                   ),
       .rst_ni                 ( rst_n                 ),
       .test_en_i              ( test_mode_i           ),
       // AXI4 SLAVE
       //***************************************
       // WRITE ADDRESS CHANNEL
       .axi_slave_aw_valid_i   ( axi_32_bus.aw_valid   ),
       .axi_slave_aw_addr_i    ( axi_32_bus.aw_addr    ),
       .axi_slave_aw_prot_i    ( axi_32_bus.aw_prot    ),
       .axi_slave_aw_region_i  ( axi_32_bus.aw_region  ),
       .axi_slave_aw_len_i     ( axi_32_bus.aw_len     ),
       .axi_slave_aw_size_i    ( axi_32_bus.aw_size    ),
       .axi_slave_aw_burst_i   ( axi_32_bus.aw_burst   ),
       .axi_slave_aw_lock_i    ( axi_32_bus.aw_lock    ),
       .axi_slave_aw_cache_i   ( axi_32_bus.aw_cache   ),
       .axi_slave_aw_qos_i     ( axi_32_bus.aw_qos     ),
       .axi_slave_aw_id_i      ( axi_32_bus.aw_id      ),
       .axi_slave_aw_user_i    ( axi_32_bus.aw_user    ),
       .axi_slave_aw_ready_o   ( axi_32_bus.aw_ready   ),

       .axi_slave_w_valid_i    ( axi_32_bus.w_valid    ),
       .axi_slave_w_data_i     ( axi_32_bus.w_data     ),
       .axi_slave_w_strb_i     ( axi_32_bus.w_strb     ),
       .axi_slave_w_user_i     ( axi_32_bus.w_user     ),
       .axi_slave_w_last_i     ( axi_32_bus.w_last     ),
       .axi_slave_w_ready_o    ( axi_32_bus.w_ready    ),

       .axi_slave_b_valid_o    ( axi_32_bus.b_valid    ),
       .axi_slave_b_resp_o     ( axi_32_bus.b_resp     ),
       .axi_slave_b_id_o       ( axi_32_bus.b_id       ),
       .axi_slave_b_user_o     ( axi_32_bus.b_user     ),
       .axi_slave_b_ready_i    ( axi_32_bus.b_ready    ),

       // WRITE ADDRESS CHANNEL
       .axi_master_aw_valid_o  ( axi_128_bus.aw_valid  ),
       .axi_master_aw_addr_o   ( axi_128_bus.aw_addr   ),
       .axi_master_aw_prot_o   ( axi_128_bus.aw_prot   ),
       .axi_master_aw_region_o ( axi_128_bus.aw_region ),
       .axi_master_aw_len_o    ( axi_128_bus.aw_len    ),
       .axi_master_aw_size_o   ( axi_128_bus.aw_size   ),
       .axi_master_aw_burst_o  ( axi_128_bus.aw_burst  ),
       .axi_master_aw_lock_o   ( axi_128_bus.aw_lock   ),
       .axi_master_aw_cache_o  ( axi_128_bus.aw_cache  ),
       .axi_master_aw_qos_o    ( axi_128_bus.aw_qos    ),
       .axi_master_aw_id_o     ( axi_128_bus.aw_id     ),
       .axi_master_aw_user_o   ( axi_128_bus.aw_user   ),
       .axi_master_aw_ready_i  ( axi_128_bus.aw_ready  ),

       .axi_master_w_valid_o   ( axi_128_bus.w_valid   ),
       .axi_master_w_data_o    ( axi_128_bus.w_data    ),
       .axi_master_w_strb_o    ( axi_128_bus.w_strb    ),
       .axi_master_w_user_o    ( axi_128_bus.w_user    ),
       .axi_master_w_last_o    ( axi_128_bus.w_last    ),
       .axi_master_w_ready_i   ( axi_128_bus.w_ready   ),

       .axi_master_b_valid_i   ( axi_128_bus.b_valid   ),
       .axi_master_b_resp_i    ( axi_128_bus.b_resp    ),
       .axi_master_b_id_i      ( axi_128_bus.b_id      ),
       .axi_master_b_user_i    ( axi_128_bus.b_user    ),
       .axi_master_b_ready_o   ( axi_128_bus.b_ready   )
   );






   always
   begin
      #(1.0) clk = ~clk;
   end

   always_ff @(posedge clk)
   begin
      axi_128_bus.aw_ready <= $random()%2;
      axi_128_bus.w_ready  <= $random()%2;

      if(axi_128_bus.w_valid & axi_128_bus.w_last & axi_128_bus.w_ready)
         axi_128_bus.b_valid <= 1'b1;

      if(axi_128_bus.w_valid & axi_128_bus.w_ready & ~axi_128_bus.w_last)
            $display("axi_128_bus.w_data = %16h;   axi_128_bus.w_strb=%16h \n",axi_128_bus.w_data, axi_128_bus.w_strb);

      if(axi_128_bus.w_valid & axi_128_bus.w_last & axi_128_bus.w_ready)
            $display("axi_128_bus.w_data = %16h;   axi_128_bus.w_strb=%16h \n\n\n",axi_128_bus.w_data, axi_128_bus.w_strb);
   end



   assign axi_128_bus.b_resp  = '0;
   assign axi_128_bus.b_id    = '0;
   assign axi_128_bus.b_user  = '0;



   initial
   begin
      rst_n = 1'b1;
      clk   = 1'b0;
      axi_fetch_enable = '0;
      test_mode_i = 1'b0;


      @(negedge clk);
      @(negedge clk);
      @(negedge clk);

      rst_n  = 1'b0;

      @(negedge clk);
      @(negedge clk);
      @(negedge clk);

      rst_n = 1'b1;

      @(negedge clk);
      @(negedge clk);
      @(negedge clk);
      @(negedge clk);

      axi_fetch_enable = '1;

   end



   axi32_tgen_wrap
   #(
      .AXI4_ADDRESS_WIDTH ( AXI32_ADDR_WIDTH  ), //= 32,
      .AXI4_RDATA_WIDTH   ( AXI32_DATA_WIDTH  ), //= 32,
      .AXI4_WDATA_WIDTH   ( AXI32_DATA_WIDTH  ), //= 32,
      .AXI4_ID_WIDTH      ( AXI32_ID_WIDTH    ), //= 16,
      .AXI4_USER_WIDTH    ( AXI32_USER_WIDTH  ), //= 10,
      .AXI_NUMBYTES       ( AXI32_STRB_WIDTH  ), //= AXIAXI_STRB_WIDTH  4_WDATA_WIDTH/8,
      .SRC_ID             ( '0                )  //= 0
   )
   AXI32_TGEN
   (
      .clk              ( clk              ),
      .rst_n            ( rst_n            ),

      .axi_port_master  ( axi_32_bus       ),

      .fetch_en_i       ( axi_fetch_enable ),
      .eoc_o            (                  ),
      .PASS_o           (                  ),
      .FAIL_o           (                  )
   );
endmodule
