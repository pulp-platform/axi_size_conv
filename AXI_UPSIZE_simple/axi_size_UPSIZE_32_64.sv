// Copyright 2015-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`define OKAY    2'b00
`define EXOKAY  2'b01
`define SLVERR  2'b10
`define DECERR  2'b11


module axi_size_UPSIZE_32_64
#(
    parameter  AXI_ADDR_WIDTH     = 32,

    // Slave side
    parameter AXI_DATA_WIDTH_IN   = 32,
    parameter AXI_USER_WIDTH_IN   = 6,
    parameter AXI_ID_WIDTH_IN     = 3,
    parameter AXI_STRB_WIDTH_IN   = AXI_DATA_WIDTH_IN/8,

    //Master side
    parameter AXI_DATA_WIDTH_OUT  = 64,
    parameter AXI_USER_WIDTH_OUT  = 6,
    parameter AXI_ID_WIDTH_OUT    = 3,
    parameter AXI_STRB_WIDTH_OUT  = AXI_DATA_WIDTH_OUT/8,

    parameter RATIO               = AXI_DATA_WIDTH_OUT/AXI_DATA_WIDTH_IN
)
(
    input  logic                                   clk_i,
    input  logic                                   rst_ni,
    input  logic                                   test_mode_i,

    /////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                                                             //
    //    ███████╗██╗      █████╗ ██╗   ██╗███████╗    ██████╗  ██████╗ ██████╗ ████████╗          //
    //    ██╔════╝██║     ██╔══██╗██║   ██║██╔════╝    ██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝          //
    //    ███████╗██║     ███████║██║   ██║█████╗      ██████╔╝██║   ██║██████╔╝   ██║             //
    //    ╚════██║██║     ██╔══██║╚██╗ ██╔╝██╔══╝      ██╔═══╝ ██║   ██║██╔══██╗   ██║             //
    //    ███████║███████╗██║  ██║ ╚████╔╝ ███████╗    ██║     ╚██████╔╝██║  ██║   ██║             //
    //    ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝    ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝             //
    /////////////////////////////////////////////////////////////////////////////////////////////////

    // AXI4 SLAVE
    //***************************************
    // WRITE ADDRESS CHANNEL
    input  logic                                       axi_slave_aw_valid_i,
    input  logic [AXI_ADDR_WIDTH-1:0]                  axi_slave_aw_addr_i,
    input  logic [2:0]                                 axi_slave_aw_prot_i,
    input  logic [3:0]                                 axi_slave_aw_region_i,
    input  logic [7:0]                                 axi_slave_aw_len_i,
    input  logic [2:0]                                 axi_slave_aw_size_i,
    input  logic [1:0]                                 axi_slave_aw_burst_i,
    input  logic                                       axi_slave_aw_lock_i,
    input  logic [3:0]                                 axi_slave_aw_cache_i,
    input  logic [3:0]                                 axi_slave_aw_qos_i,
    input  logic [AXI_ID_WIDTH_IN-1:0]                 axi_slave_aw_id_i,
    input  logic [AXI_USER_WIDTH_IN-1:0]               axi_slave_aw_user_i,
    output logic                                       axi_slave_aw_ready_o,

    // READ ADDRESS CHANNEL
    input  logic                                       axi_slave_ar_valid_i,
    input  logic [AXI_ADDR_WIDTH-1:0]                  axi_slave_ar_addr_i,
    input  logic [2:0]                                 axi_slave_ar_prot_i,
    input  logic [3:0]                                 axi_slave_ar_region_i,
    input  logic [7:0]                                 axi_slave_ar_len_i,
    input  logic [2:0]                                 axi_slave_ar_size_i,
    input  logic [1:0]                                 axi_slave_ar_burst_i,
    input  logic                                       axi_slave_ar_lock_i,
    input  logic [3:0]                                 axi_slave_ar_cache_i,
    input  logic [3:0]                                 axi_slave_ar_qos_i,
    input  logic [AXI_ID_WIDTH_IN-1:0]                 axi_slave_ar_id_i,
    input  logic [AXI_USER_WIDTH_IN-1:0]               axi_slave_ar_user_i,
    output logic                                       axi_slave_ar_ready_o,

    // WRITE DATA CHANNEL
    input  logic                                       axi_slave_w_valid_i,
    input  logic [AXI_DATA_WIDTH_IN-1:0]               axi_slave_w_data_i,
    input  logic [AXI_STRB_WIDTH_IN-1:0]               axi_slave_w_strb_i,
    input  logic [AXI_USER_WIDTH_IN-1:0]               axi_slave_w_user_i,
    input  logic                                       axi_slave_w_last_i,
    output logic                                       axi_slave_w_ready_o,

    // READ DATA CHANNEL
    output logic                                       axi_slave_r_valid_o,
    output logic [AXI_DATA_WIDTH_IN-1:0]               axi_slave_r_data_o,
    output logic [1:0]                                 axi_slave_r_resp_o,
    output logic                                       axi_slave_r_last_o,
    output logic [AXI_ID_WIDTH_IN-1:0]                 axi_slave_r_id_o,
    output logic [AXI_USER_WIDTH_IN-1:0]               axi_slave_r_user_o,
    input  logic                                       axi_slave_r_ready_i,

    // WRITE RESPONSE CHANNEL
    output logic                                       axi_slave_b_valid_o,
    output logic [1:0]                                 axi_slave_b_resp_o,
    output logic [AXI_ID_WIDTH_IN-1:0]                 axi_slave_b_id_o,
    output logic [AXI_USER_WIDTH_IN-1:0]               axi_slave_b_user_o,
    input  logic                                       axi_slave_b_ready_i,


    ////////////////////////////////////////////////////////////////////////////////////////////////
    // ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗     ██████╗  ██████╗ ██████╗ ████████╗ //
    // ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗    ██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝ //
    // ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝    ██████╔╝██║   ██║██████╔╝   ██║    //
    // ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗    ██╔═══╝ ██║   ██║██╔══██╗   ██║    //
    // ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║    ██║     ╚██████╔╝██║  ██║   ██║    //
    // ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝    ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝    //
    ////////////////////////////////////////////////////////////////////////////////////////////////

    //***************************************
    // WRITE ADDRESS CHANNEL
    output logic                                       axi_master_aw_valid_o,
    output logic [AXI_ADDR_WIDTH-1:0]                  axi_master_aw_addr_o,
    output logic [2:0]                                 axi_master_aw_prot_o,
    output logic [3:0]                                 axi_master_aw_region_o,
    output logic [7:0]                                 axi_master_aw_len_o,
    output logic [2:0]                                 axi_master_aw_size_o,
    output logic [1:0]                                 axi_master_aw_burst_o,
    output logic                                       axi_master_aw_lock_o,
    output logic [3:0]                                 axi_master_aw_cache_o,
    output logic [3:0]                                 axi_master_aw_qos_o,
    output logic [AXI_ID_WIDTH_OUT-1:0]                axi_master_aw_id_o,
    output logic [AXI_USER_WIDTH_OUT-1:0]              axi_master_aw_user_o,
    input  logic                                       axi_master_aw_ready_i,

    // READ ADDRESS CHANNEL
    output logic                                       axi_master_ar_valid_o,
    output logic [AXI_ADDR_WIDTH-1:0]                  axi_master_ar_addr_o,
    output logic [2:0]                                 axi_master_ar_prot_o,
    output logic [3:0]                                 axi_master_ar_region_o,
    output logic [7:0]                                 axi_master_ar_len_o,
    output logic [2:0]                                 axi_master_ar_size_o,
    output logic [1:0]                                 axi_master_ar_burst_o,
    output logic                                       axi_master_ar_lock_o,
    output logic [3:0]                                 axi_master_ar_cache_o,
    output logic [3:0]                                 axi_master_ar_qos_o,
    output logic [AXI_ID_WIDTH_OUT-1:0]                axi_master_ar_id_o,
    output logic [AXI_USER_WIDTH_OUT-1:0]              axi_master_ar_user_o,
    input  logic                                       axi_master_ar_ready_i,

    // WRITE DATA CHANNEL
    output logic                                       axi_master_w_valid_o,
    output logic [AXI_DATA_WIDTH_OUT-1:0]              axi_master_w_data_o,
    output logic [AXI_STRB_WIDTH_OUT-1:0]              axi_master_w_strb_o,
    output logic [AXI_USER_WIDTH_OUT-1:0]              axi_master_w_user_o,
    output logic                                       axi_master_w_last_o,
    input  logic                                       axi_master_w_ready_i,

    // READ DATA CHANNEL
    input  logic                                       axi_master_r_valid_i,
    input  logic [RATIO-1:0][AXI_DATA_WIDTH_IN-1:0]    axi_master_r_data_i,
    input  logic [1:0]                                 axi_master_r_resp_i,
    input  logic                                       axi_master_r_last_i,
    input  logic [AXI_ID_WIDTH_OUT-1:0]                axi_master_r_id_i,
    input  logic [AXI_USER_WIDTH_OUT-1:0]              axi_master_r_user_i,
    output logic                                       axi_master_r_ready_o,

    // WRITE RESPONSE CHANNEL
    input  logic                                       axi_master_b_valid_i,
    input  logic [1:0]                                 axi_master_b_resp_i,
    input  logic [AXI_ID_WIDTH_OUT-1:0]                axi_master_b_id_i,
    input  logic [AXI_USER_WIDTH_OUT-1:0]              axi_master_b_user_i,
    output logic                                       axi_master_b_ready_o
);

   logic              stall_AR;

   logic              save_info;
   logic              release_entry;

   logic [1:0]                             LUT_valid_entry; //
   logic [1:0]                             LUT_info; //
   logic [1:0] [AXI_ID_WIDTH_IN-1:0]       LUT_id_in;


   assign stall_AR = &LUT_valid_entry;
   assign axi_master_ar_valid_o = axi_slave_ar_valid_i  & ~stall_AR;
   assign axi_slave_ar_ready_o  = axi_master_ar_ready_i & ~stall_AR;
   assign save_info             = axi_slave_ar_valid_i  & axi_slave_ar_ready_o;
   assign release_entry         = axi_master_r_valid_i  & axi_slave_r_ready_i;

   // ██████╗ ███████╗ █████╗ ██████╗
   // ██╔══██╗██╔════╝██╔══██╗██╔══██╗
   // ██████╔╝█████╗  ███████║██║  ██║
   // ██╔══██╗██╔══╝  ██╔══██║██║  ██║
   // ██║  ██║███████╗██║  ██║██████╔╝
   // ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝

   assign   axi_master_ar_addr_o    = axi_slave_ar_addr_i;
   assign   axi_master_ar_prot_o    = axi_slave_ar_prot_i;
   assign   axi_master_ar_region_o  = axi_slave_ar_region_i;
   assign   axi_master_ar_len_o     = 8'h00;
   assign   axi_master_ar_size_o    = 3'b010;
   assign   axi_master_ar_burst_o   = axi_slave_ar_burst_i;
   assign   axi_master_ar_lock_o    = axi_slave_ar_lock_i;
   assign   axi_master_ar_cache_o   = axi_slave_ar_cache_i;
   assign   axi_master_ar_qos_o     = axi_slave_ar_qos_i;

   assign   axi_master_ar_user_o    = axi_slave_ar_user_i;



   assign   axi_slave_r_valid_o     = axi_master_r_valid_i;
   assign   axi_slave_r_resp_o      = axi_master_r_resp_i;
   assign   axi_slave_r_last_o      = axi_master_r_last_i;
   assign   axi_slave_r_user_o      = axi_master_r_user_i;
   assign   axi_master_r_ready_o    = axi_slave_r_ready_i;


   always_ff @(posedge clk_i or negedge rst_ni)
   begin : proc_sample_ID_Offsed
      if(~rst_ni)
      begin
         LUT_valid_entry <= '0;
         LUT_info        <= '0;
         LUT_id_in       <= '0;
      end
      else
      begin

         if(release_entry)
         begin
            LUT_valid_entry[axi_master_r_id_i[0]] <= 1'b0;
         end

         if(save_info)
         begin
            casex(LUT_valid_entry)
            2'bx0 : begin LUT_valid_entry[0] <= 1'b1;   LUT_info[0] <= axi_slave_ar_addr_i[2];  LUT_id_in[0] <= axi_slave_ar_id_i;  end
            2'b01 : begin LUT_valid_entry[1] <= 1'b1;   LUT_info[1] <= axi_slave_ar_addr_i[2];  LUT_id_in[1] <= axi_slave_ar_id_i;  end
            endcase
         end
      end
   end


   // REMAPPING of the ID
   always_comb
   begin
      casex(LUT_valid_entry)

      2'bx0 :
      begin
            axi_master_ar_id_o  = 0;
      end

      2'b01 :
      begin
            axi_master_ar_id_o      = 1;
      end

      default: begin
         axi_master_ar_id_o = '0;
      end

      endcase
   end



   assign axi_slave_r_data_o  = (LUT_info[axi_master_r_id_i[0]]) ?  axi_master_r_data_i[1]   :  axi_master_r_data_i[0] ;
   assign axi_slave_r_id_o    =  LUT_id_in[axi_master_r_id_i[0]];


   // ██╗    ██╗██████╗ ██╗████████╗███████╗
   // ██║    ██║██╔══██╗██║╚══██╔══╝██╔════╝
   // ██║ █╗ ██║██████╔╝██║   ██║   █████╗
   // ██║███╗██║██╔══██╗██║   ██║   ██╔══╝
   // ╚███╔███╔╝██║  ██║██║   ██║   ███████╗
   //  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝   ╚═╝   ╚══════╝


   logic      push_data_FIFO;
   logic      push_valid_FIFO;
   logic      push_grant_FIFO;

   logic      pop_data_FIFO;
   logic      pop_valid_FIFO;
   logic      pop_grant_FIFO;

   assign push_data_FIFO  = axi_slave_aw_addr_i[2];
   assign push_valid_FIFO = axi_slave_aw_valid_i &  axi_slave_aw_ready_o;

   assign pop_grant_FIFO  = axi_slave_w_last_i & axi_slave_w_valid_i & axi_slave_w_ready_o;

   generic_fifo
   #(
      .DATA_WIDTH   ( 1               ),
      .DATA_DEPTH   ( 2               )
   )
   alignment_AW_axi64
   (
      .clk          ( clk_i           ),
      .rst_n        ( rst_ni          ),
      .test_mode_i  ( test_mode_i     ),

      .data_i       ( push_data_FIFO  ),
      .valid_i      ( push_valid_FIFO ),
      .grant_o      ( push_grant_FIFO ),

      .data_o       ( pop_data_FIFO   ),
      .valid_o      ( pop_valid_FIFO  ),
      .grant_i      ( pop_grant_FIFO  )
   );

   assign   axi_master_aw_addr_o    =  axi_slave_aw_addr_i;
   assign   axi_master_aw_prot_o    =  axi_slave_aw_prot_i;
   assign   axi_master_aw_region_o  =  axi_slave_aw_region_i;
   assign   axi_master_aw_len_o     =  8'h00;
   assign   axi_master_aw_size_o    =  3'b010;
   assign   axi_master_aw_burst_o   =  axi_slave_aw_burst_i;
   assign   axi_master_aw_lock_o    =  axi_slave_aw_lock_i;
   assign   axi_master_aw_cache_o   =  axi_slave_aw_cache_i;
   assign   axi_master_aw_qos_o     =  axi_slave_aw_qos_i;
   assign   axi_master_aw_id_o      =  axi_slave_aw_id_i;
   assign   axi_master_aw_user_o    =  axi_slave_aw_user_i;
   assign   axi_master_aw_valid_o   =  axi_slave_aw_valid_i & push_grant_FIFO;
   assign   axi_slave_aw_ready_o    =  axi_master_aw_ready_i & push_grant_FIFO;

   assign   axi_master_w_valid_o    =  axi_slave_w_valid_i & pop_valid_FIFO;
   assign   axi_master_w_data_o     =  ( pop_data_FIFO ) ? {axi_slave_w_data_i,{AXI_DATA_WIDTH_IN{1'b0}}} : {{{AXI_DATA_WIDTH_IN{1'b0}},axi_slave_w_data_i}};
   assign   axi_master_w_strb_o     =  ( pop_data_FIFO ) ? {axi_slave_w_strb_i,{AXI_STRB_WIDTH_IN{1'b0}}} : {{{AXI_STRB_WIDTH_IN{1'b0}},axi_slave_w_strb_i}};
   assign   axi_master_w_user_o     =  axi_slave_w_user_i;
   assign   axi_master_w_last_o     =  axi_slave_w_last_i;
   assign   axi_slave_w_ready_o     =  axi_master_w_ready_i;

   assign   axi_slave_b_valid_o     = axi_master_b_valid_i;
   assign   axi_slave_b_resp_o      = axi_master_b_resp_i;
   assign   axi_slave_b_id_o        = axi_master_b_id_i;
   assign   axi_slave_b_user_o      = axi_master_b_user_i;
   assign   axi_master_b_ready_o    = axi_slave_b_ready_i;


endmodule // axi_size_conv
