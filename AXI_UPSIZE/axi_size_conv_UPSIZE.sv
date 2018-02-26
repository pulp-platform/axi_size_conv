// Copyright 2015-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// ============================================================================= //
// Company:        Multitherman Laboratory @ DEIS - University of Bologna        //
//                    Viale Risorgimento 2 40136                                 //
//                    Bologna - fax 0512093785 -                                 //
//                                                                               //
// Engineer:       Igor Loi - igor.loi@unibo.it                                  //
//                                                                               //
//                                                                               //
// Additional contributions by:                                                  //
//                                                                               //
//                                                                               //
//                                                                               //
// Create Date:    25/06/2015                                                    //
// Design Name:    AXI 4 INTERCONNECT                                            //
// Module Name:    axi_size_conv_UPSIZE                                          //
// Project Name:   PULP                                                          //
// Language:       SystemVerilog                                                 //
//                                                                               //
// Description:    Used to link 2 AXI domains with different datawidth           //
//                 Slave port eg 64 bit, Master port > 64bit (eg 128 bit)         //
//                                                                               //
// Revision:                                                                     //
// Revision v0.1 - 25/06/2015 : File Created                                     //
//                 LIMITATIONS : Burst Type is INCR only, SIZE is fixed          //
//                 NO error detection and handling                               //
//                                                                               //
//                                                                               //
//                                                                               //
//                                                                               //
//                                                                               //
// ============================================================================= //


`define MOD_DATA_OUT(VALUE)     ( (VALUE == 32) ? 8'h04 : (VALUE == 64) ? 8'h08 : (VALUE == 128) ? 8'h10 : (VALUE == 256) ? 8'h20 : (VALUE == 512) ? 8'h40 : 8'h80    )
`define MASK_ADDRESS(VALUE)     ( (VALUE == 32) ? 32'hFFFF_FFFC : (VALUE == 64) ? 32'hFFFF_FFF8 : (VALUE == 128) ? 32'hFFFF_FFF0 : (VALUE == 256) ? 32'hFFFF_FFC0 : 32'hFFFF_FF80   )

`define OKAY    2'b00
`define EXOKAY  2'b01
`define SLVERR  2'b10
`define DECERR  2'b11


module axi_size_conv_UPSIZE
#(
    parameter  AXI_ADDR_WIDTH     = 32,

    // Slave side
    parameter AXI_DATA_WIDTH_IN   = 32,
    parameter AXI_USER_WIDTH_IN   = 6,
    parameter AXI_ID_WIDTH_IN     = 3,
    parameter AXI_STRB_WIDTH_IN   = AXI_DATA_WIDTH_IN/8,

    //Master side
    parameter AXI_DATA_WIDTH_OUT  = 128,
    parameter AXI_USER_WIDTH_OUT  = 6,
    parameter AXI_ID_WIDTH_OUT    = 3,
    parameter AXI_STRB_WIDTH_OUT  = AXI_DATA_WIDTH_OUT/8,

    parameter RATIO               = AXI_DATA_WIDTH_OUT/AXI_DATA_WIDTH_IN
)
(
    input  logic                                   clk_i,
    input  logic                                   rst_ni,
    input  logic                                       test_mode_i,

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

    localparam   SHIFT             = $clog2(AXI_DATA_WIDTH_OUT/AXI_DATA_WIDTH_IN);
    localparam   WORD_SELECT_SIZE  = $clog2(AXI_DATA_WIDTH_OUT/AXI_DATA_WIDTH_IN);

    enum logic [2:0] {IDLE_W, SINGLE_W, DISPATCH_SINGLE_WRITE, BURST_W,  DISPATCH_BURST_WRITE, DISPATCH_INTERM_BURST, WAIT_WDATA_BURST_W } CS_W, NS_W;
    enum logic [1:0] {IDLE_R, SINGLE_R, BURST_R, LAST_R } CS_R, NS_R;

    // READ CHANNEL
    logic [AXI_ADDR_WIDTH-1:0]      first_AR_address;
    logic [AXI_ADDR_WIDTH-1:0]      last_AR_address;
    logic [WORD_SELECT_SIZE-1:0]    first_AR_WORD;
    logic [WORD_SELECT_SIZE-1:0]    last_AR_WORD;

    logic [WORD_SELECT_SIZE-1:0]    first_AR_WORD_int;
    logic [WORD_SELECT_SIZE-1:0]    last_AR_WORD_int;
    logic [AXI_ID_WIDTH_IN-1:0]     ar_id_int;
    logic [7:0]                     ar_master_len_int;
    logic [7:0]                     ar_slave_len_int;

    logic [2:0]                     ar_slave_size_int;

    logic [AXI_USER_WIDTH_IN-1:0]   ar_user_int;

    logic                           push_grant_AR_info;
    logic                           valid_AR_info;
    logic                           pop_AR_info;

    logic [WORD_SELECT_SIZE-1:0]    AR_counter_slave_burst_CS,  AR_counter_slave_burst_NS;
    logic [7:0]                     AR_counter_master_burst_CS, AR_counter_master_burst_NS;



    // ██████╗ ███████╗ █████╗ ██████╗
    // ██╔══██╗██╔════╝██╔══██╗██╔══██╗
    // ██████╔╝█████╗  ███████║██║  ██║
    // ██╔══██╗██╔══╝  ██╔══██║██║  ██║
    // ██║  ██║███████╗██║  ██║██████╔╝
    // ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝


    // Address READ
    always_comb
    begin
        axi_master_ar_len_o      = (last_AR_address - first_AR_address ) >> ($clog2(AXI_DATA_WIDTH_OUT/8));
        axi_master_ar_valid_o    = axi_slave_ar_valid_i & push_grant_AR_info;
        axi_slave_ar_ready_o     = axi_master_ar_ready_i & push_grant_AR_info;

        case(AXI_DATA_WIDTH_OUT/8) // FIXME --> Should use the real bit lane usage
            1:    axi_master_ar_size_o     =  3'b000;
            2:    axi_master_ar_size_o     =  3'b001;
            4:    axi_master_ar_size_o     =  3'b010;
            8:    axi_master_ar_size_o     =  3'b011;
            16:   axi_master_ar_size_o     =  3'b100;
            32:   axi_master_ar_size_o     =  3'b101;
            64:   axi_master_ar_size_o     =  3'b110;
            128:  axi_master_ar_size_o     =  3'b111;
        endcase // AXI_DATA_WIDTH_OUT

        case(AXI_DATA_WIDTH_OUT)
            32:   axi_master_ar_addr_o     = {axi_slave_ar_addr_i[AXI_ADDR_WIDTH-1:2],     2'b00}   ;
            64:   axi_master_ar_addr_o     = {axi_slave_ar_addr_i[AXI_ADDR_WIDTH-1:3],    3'b000}   ;
            128:  axi_master_ar_addr_o     = {axi_slave_ar_addr_i[AXI_ADDR_WIDTH-1:4],   4'b0000}   ;
            256:  axi_master_ar_addr_o     = {axi_slave_ar_addr_i[AXI_ADDR_WIDTH-1:5],  5'b00000}   ;
            512:  axi_master_ar_addr_o     = {axi_slave_ar_addr_i[AXI_ADDR_WIDTH-1:6], 6'b000000}   ;
            1024: axi_master_ar_addr_o     = {axi_slave_ar_addr_i[AXI_ADDR_WIDTH-1:7],7'b0000000}   ;
        endcase

        axi_master_ar_burst_o    = axi_slave_ar_burst_i  ;


        axi_master_ar_id_o       = axi_slave_ar_id_i     ;
        axi_master_ar_user_o     = axi_slave_ar_user_i   ;

        // Useless signals
        axi_master_ar_prot_o     = axi_slave_ar_prot_i   ;
        axi_master_ar_region_o   = axi_slave_ar_region_i ;
        axi_master_ar_lock_o     = axi_slave_ar_lock_i   ;
        axi_master_ar_cache_o    = axi_slave_ar_cache_i  ;
        axi_master_ar_qos_o      = axi_slave_ar_qos_i    ;
    end


    assign first_AR_address     = axi_slave_ar_addr_i & `MASK_ADDRESS(AXI_DATA_WIDTH_OUT);
    assign last_AR_address      = axi_slave_ar_addr_i + (axi_slave_ar_len_i << $clog2(AXI_DATA_WIDTH_IN/8));

    assign first_AR_WORD        = (axi_slave_ar_addr_i[7:0] % `MOD_DATA_OUT(AXI_DATA_WIDTH_OUT)) >> $clog2(AXI_DATA_WIDTH_OUT/AXI_DATA_WIDTH_IN);
    assign last_AR_WORD         = ((  axi_slave_ar_addr_i[7:0] +  ( axi_slave_ar_len_i << $clog2(AXI_DATA_WIDTH_IN/8)))  %  `MOD_DATA_OUT(AXI_DATA_WIDTH_OUT)) >> $clog2(AXI_DATA_WIDTH_IN/8)  ;





    always_ff @(posedge clk_i , negedge rst_ni)
    begin : UPDATE_R_CS
        if(~rst_ni)
        begin
            CS_R                    <= IDLE_R;
            AR_counter_slave_burst_CS  <= '0;
            AR_counter_master_burst_CS <= '0;
        end
        else
        begin
             CS_R <= NS_R;
            AR_counter_slave_burst_CS  <= AR_counter_slave_burst_NS;
            AR_counter_master_burst_CS <= AR_counter_master_burst_NS;
        end
    end


    always_comb
    begin
      pop_AR_info             = '0;
      axi_slave_r_valid_o     = 1'b0;
      axi_slave_r_resp_o      = `OKAY;
      axi_slave_r_user_o      = ar_user_int;
      axi_slave_r_id_o        = ar_id_int;
      axi_slave_r_last_o      = 1'b0;

      axi_master_r_ready_o    = 1'b0;
      AR_counter_slave_burst_NS  = AR_counter_slave_burst_CS;
        AR_counter_master_burst_NS = AR_counter_master_burst_CS;

      NS_R = CS_R;


      case(CS_R)

         IDLE_R:
         begin
            axi_master_r_ready_o = 1'b0; // Stall the memory first!!!
            axi_slave_r_data_o = axi_master_r_data_i[first_AR_WORD_int];

            if( axi_master_r_valid_i && valid_AR_info ) // if we have any inciming read then --> FIXME handle valid_AR_info
            begin


               if(ar_slave_len_int == 0)  //single transfer
               begin
                  NS_R = IDLE_R;
                  if(axi_slave_r_ready_i)
                  begin
                     axi_master_r_ready_o = 1'b1;
                     axi_slave_r_valid_o  = 1'b1;
                     axi_slave_r_last_o   = 1'b1;
                     pop_AR_info          = 1'b1;
                  end

               end
               else // multiple transfer
               begin
                  if(ar_master_len_int == 0) // single burst on wide BUS, multiple beats on narrow BUS
                  begin
                     if(axi_slave_r_ready_i)
                     begin
                        NS_R = SINGLE_R;
                        AR_counter_slave_burst_NS = first_AR_WORD_int + 1'b1;
                        axi_slave_r_valid_o  = 1'b1;
                     end
                     else
                     begin
                        NS_R = IDLE_R;
                     end
                  end
                  else
                  begin
                     if(axi_slave_r_ready_i)
                     begin
                        NS_R = BURST_R;
                        axi_slave_r_valid_o  = 1'b1;

                        AR_counter_slave_burst_NS  = first_AR_WORD_int + 1'b1;

                        if(&first_AR_WORD_int) // is the last chucnk, read another wide chunck on master rdata
                        begin
                           AR_counter_master_burst_NS = 1;
                           axi_master_r_ready_o    = 1'b1;
                        end
                        else // old rdata on master
                        begin
                           AR_counter_master_burst_NS = 0;
                           axi_master_r_ready_o    = 1'b0;
                        end

                     end
                     else
                     begin
                        NS_R = IDLE_R;
                     end

                  end
               end


            end
         end //~IDLE_R

         SINGLE_R :
         begin
            axi_slave_r_data_o  = axi_master_r_data_i[AR_counter_slave_burst_CS];
            axi_slave_r_valid_o = axi_master_r_valid_i;

            if(axi_master_r_valid_i)
            begin
                  if(axi_slave_r_ready_i)
                  begin
                     if(AR_counter_slave_burst_CS == last_AR_WORD_int)
                     begin
                        NS_R = IDLE_R;
                        axi_master_r_ready_o = 1'b1;
                        pop_AR_info         = 1'b1;
                     end
                  end
                  else
                  begin
                     NS_R = SINGLE_R;
                     axi_master_r_ready_o = 1'b0;
                     pop_AR_info          = 1'b0;
                  end
            end
            else
            begin
                  NS_R = SINGLE_R;
            end


         end //~SINGLE_R


         BURST_R :
         begin
            axi_slave_r_data_o = axi_master_r_data_i[AR_counter_slave_burst_CS];
            axi_slave_r_valid_o = axi_master_r_valid_i;

            if(axi_master_r_valid_i == 1'b1)
            begin

                  if(axi_slave_r_ready_i)
                  begin
                     AR_counter_slave_burst_NS = AR_counter_slave_burst_CS + 1'b1;

                     if(AR_counter_master_burst_CS == ar_master_len_int) // exit if AR_counter_slave_burst_CS ==  last_AR_WORD_int
                     begin
                           if(AR_counter_slave_burst_CS == last_AR_WORD_int)
                           begin
                              axi_master_r_ready_o      = 1'b1;
                              pop_AR_info               = 1'b1;
                              NS_R                      = IDLE_R;
                           end
                           else
                           begin
                              axi_master_r_ready_o      = 1'b0;
                              pop_AR_info               = 1'b0;
                              NS_R                      = BURST_R;
                              AR_counter_slave_burst_NS = AR_counter_slave_burst_CS +1'b1;
                           end
                     end
                     else
                     begin
                           NS_R = BURST_R;

                           if(&AR_counter_slave_burst_CS) // on last slave iteration on mster chunck, increment the master burst counter
                           begin
                              AR_counter_master_burst_NS = AR_counter_master_burst_CS + 1'b1;
                              axi_master_r_ready_o    = 1'b1;
                           end
                           else
                           begin
                              AR_counter_master_burst_NS = AR_counter_master_burst_CS;
                              axi_master_r_ready_o    = 1'b0;
                           end
                     end
                  end

            end
            else
            begin
                  NS_R = BURST_R;
            end

         end //~BURST_R



      endcase // CS_R
    end



    generic_fifo
    #(
          .DATA_WIDTH  (16+AXI_ID_WIDTH_IN+WORD_SELECT_SIZE*2+AXI_USER_WIDTH_IN+3),
          .DATA_DEPTH  (4)
    )
    FIFO_AR
    (
          .clk         (clk_i),
          .rst_n       (rst_ni),
          .test_mode_i (test_mode_i),

          .data_i     ({ axi_slave_ar_size_i,  axi_slave_ar_len_i, axi_master_ar_len_o,   axi_slave_ar_user_i,      axi_slave_ar_id_i,     last_AR_WORD, first_AR_WORD}),
          .valid_i    (axi_slave_ar_valid_i & axi_master_ar_ready_i),
          .grant_o   (push_grant_AR_info),

          .data_o    ({ar_slave_size_int, ar_slave_len_int,   ar_master_len_int ,     ar_user_int,             ar_id_int,              last_AR_WORD_int,first_AR_WORD_int}),
          .valid_o   (valid_AR_info),
          .grant_i    (pop_AR_info)
    );



   // ██╗    ██╗██████╗ ██╗████████╗███████╗
   // ██║    ██║██╔══██╗██║╚══██╔══╝██╔════╝
   // ██║ █╗ ██║██████╔╝██║   ██║   █████╗
   // ██║███╗██║██╔══██╗██║   ██║   ██╔══╝
   // ╚███╔███╔╝██║  ██║██║   ██║   ███████╗
   //  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝   ╚═╝   ╚══════╝


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
       .axi_slave_aw_valid_i   ( axi_slave_aw_valid_i   ),
       .axi_slave_aw_addr_i    ( axi_slave_aw_addr_i    ),
       .axi_slave_aw_prot_i    ( axi_slave_aw_prot_i    ),
       .axi_slave_aw_region_i  ( axi_slave_aw_region_i  ),
       .axi_slave_aw_len_i     ( axi_slave_aw_len_i     ),
       .axi_slave_aw_size_i    ( axi_slave_aw_size_i    ),
       .axi_slave_aw_burst_i   ( axi_slave_aw_burst_i   ),
       .axi_slave_aw_lock_i    ( axi_slave_aw_lock_i    ),
       .axi_slave_aw_cache_i   ( axi_slave_aw_cache_i   ),
       .axi_slave_aw_qos_i     ( axi_slave_aw_qos_i     ),
       .axi_slave_aw_id_i      ( axi_slave_aw_id_i      ),
       .axi_slave_aw_user_i    ( axi_slave_aw_user_i    ),
       .axi_slave_aw_ready_o   ( axi_slave_aw_ready_o   ),

       .axi_slave_w_valid_i    ( axi_slave_w_valid_i    ),
       .axi_slave_w_data_i     ( axi_slave_w_data_i     ),
       .axi_slave_w_strb_i     ( axi_slave_w_strb_i     ),
       .axi_slave_w_user_i     ( axi_slave_w_user_i     ),
       .axi_slave_w_last_i     ( axi_slave_w_last_i     ),
       .axi_slave_w_ready_o    ( axi_slave_w_ready_o    ),

       .axi_slave_b_valid_o    ( axi_slave_b_valid_o    ),
       .axi_slave_b_resp_o     ( axi_slave_b_resp_o     ),
       .axi_slave_b_id_o       ( axi_slave_b_id_o       ),
       .axi_slave_b_user_o     ( axi_slave_b_user_o     ),
       .axi_slave_b_ready_i    ( axi_slave_b_ready_i    ),

       // WRITE ADDRESS CHANNEL
       .axi_master_aw_valid_o  ( axi_master_aw_valid_o  ),
       .axi_master_aw_addr_o   ( axi_master_aw_addr_o   ),
       .axi_master_aw_prot_o   ( axi_master_aw_prot_o   ),
       .axi_master_aw_region_o ( axi_master_aw_region_o ),
       .axi_master_aw_len_o    ( axi_master_aw_len_o    ),
       .axi_master_aw_size_o   ( axi_master_aw_size_o   ),
       .axi_master_aw_burst_o  ( axi_master_aw_burst_o  ),
       .axi_master_aw_lock_o   ( axi_master_aw_lock_o   ),
       .axi_master_aw_cache_o  ( axi_master_aw_cache_o  ),
       .axi_master_aw_qos_o    ( axi_master_aw_qos_o    ),
       .axi_master_aw_id_o     ( axi_master_aw_id_o     ),
       .axi_master_aw_user_o   ( axi_master_aw_user_o   ),
       .axi_master_aw_ready_i  ( axi_master_aw_ready_i  ),

       .axi_master_w_valid_o   ( axi_master_w_valid_o   ),
       .axi_master_w_data_o    ( axi_master_w_data_o    ),
       .axi_master_w_strb_o    ( axi_master_w_strb_o    ),
       .axi_master_w_user_o    ( axi_master_w_user_o    ),
       .axi_master_w_last_o    ( axi_master_w_last_o    ),
       .axi_master_w_ready_i   ( axi_master_w_ready_i   ),

       .axi_master_b_valid_i   ( axi_master_b_valid_i   ),
       .axi_master_b_resp_i    ( axi_master_b_resp_i    ),
       .axi_master_b_id_i      ( axi_master_b_id_i      ),
       .axi_master_b_user_i    ( axi_master_b_user_i    ),
       .axi_master_b_ready_o   ( axi_master_b_ready_o   )
   );



//synopsys translate_off
initial
begin
    //Check that AXI_DATA_WIDTH_OUT is greater than AXI_DATA_WIDTH_IN
    if(AXI_DATA_WIDTH_OUT <= AXI_DATA_WIDTH_IN )
        $fatal("Assertion: AXI_DATA_WIDTH_OUT [%d] >  AXI_DATA_WIDTH_IN[%d] is false!!!!", AXI_DATA_WIDTH_OUT, AXI_DATA_WIDTH_IN ) ;

    //Check that AXI_DATA_WIDTH_OUT is greater than AXI_DATA_WIDTH_IN
    if(AXI_DATA_WIDTH_OUT !=  2**$clog2(AXI_DATA_WIDTH_OUT))
        $fatal("Assertion: AXI_DATA_WIDTH_OUT [%d] is not power of 2", AXI_DATA_WIDTH_OUT ) ;

    //Check that AXI_DATA_WIDTH_IN is greater than AXI_DATA_WIDTH_IN
    if(AXI_DATA_WIDTH_IN !=  2**$clog2(AXI_DATA_WIDTH_IN))
        $fatal("Assertion: AXI_DATA_WIDTH_IN [%d] is not power of 2", AXI_DATA_WIDTH_IN ) ;

    if(AXI_ID_WIDTH_OUT != AXI_ID_WIDTH_IN)
        $fatal("Assertion: AXI_ID_WIDTH_OUT [%d] == AXI_ID_WIDTH_IN[%d] is not true", AXI_ID_WIDTH_OUT,  AXI_ID_WIDTH_IN) ;

    if(AXI_USER_WIDTH_OUT != AXI_USER_WIDTH_IN)
        $fatal("Assertion: AXI_USER_WIDTH_OUT [%d] == AXI_USER_WIDTH_IN[%d] is not true", AXI_USER_WIDTH_OUT,  AXI_USER_WIDTH_IN) ;
end
//synopsys translate_on


endmodule // axi_size_conv
