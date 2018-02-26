// Copyright 2015-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// NOTE:
// This block does not implement any thype of error checking and Handling
// If Awlen !=  than the real number of write beats , then everything is screwed uo
// Be carefull


module Write_Upsize
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

    parameter SLICE_DEPTH         = 4
)
(
    input  logic                      clk_i,
    input  logic                      rst_ni,
    input  logic                      test_en_i,

   // INPUt SIDE
   // ADDRESS WRITE DATA CHANNEL
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

    // WRITE DATA CHANNEL
    input  logic                                       axi_slave_w_valid_i,
    input  logic [AXI_DATA_WIDTH_IN-1:0]               axi_slave_w_data_i,
    input  logic [AXI_STRB_WIDTH_IN-1:0]               axi_slave_w_strb_i,
    input  logic [AXI_USER_WIDTH_IN-1:0]               axi_slave_w_user_i,
    input  logic                                       axi_slave_w_last_i,
    output logic                                       axi_slave_w_ready_o,

    // BACKWARD WRITE RESPONSE CHANNEL
    output logic                                       axi_slave_b_valid_o,
    output logic [1:0]                                 axi_slave_b_resp_o,
    output logic [AXI_ID_WIDTH_IN-1:0]                 axi_slave_b_id_o,
    output logic [AXI_USER_WIDTH_IN-1:0]               axi_slave_b_user_o,
    input  logic                                       axi_slave_b_ready_i,

    // OUTPUT SIDE
    // ADDRESS WRITE DATA CHANNEL
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

    // WRITE DATA CHANNEL
    output logic                                       axi_master_w_valid_o,
    output logic [AXI_DATA_WIDTH_OUT-1:0]              axi_master_w_data_o,
    output logic [AXI_STRB_WIDTH_OUT-1:0]              axi_master_w_strb_o,
    output logic [AXI_USER_WIDTH_OUT-1:0]              axi_master_w_user_o,
    output logic                                       axi_master_w_last_o,
    input  logic                                       axi_master_w_ready_i,

    // BACKWARD WRITE RESPONSE CHANNEL
    input  logic                                       axi_master_b_valid_i,
    input  logic [1:0]                                 axi_master_b_resp_i,
    input  logic [AXI_ID_WIDTH_OUT-1:0]                axi_master_b_id_i,
    input  logic [AXI_USER_WIDTH_OUT-1:0]              axi_master_b_user_i,
    output logic                                       axi_master_b_ready_o
);

   localparam   DATA_WIDTH_RATIO = AXI_DATA_WIDTH_OUT/AXI_DATA_WIDTH_IN;
   localparam   FIFO_DATA_WIDTH  =  $clog2(AXI_DATA_WIDTH_OUT/AXI_DATA_WIDTH_IN)+8;
   localparam   FIFO_DATA_DEPTH  =  4;
   localparam   OFFSET = $clog2(AXI_DATA_WIDTH_IN)-3;
   typedef      logic [2:0]   logic_3_bit;

   logic [7:0]  CounterBurst_CS, CounterBurst_NS;
   logic [$clog2(DATA_WIDTH_RATIO)-1:0]   Chunk_Pointer, CounterChunk_CS, CounterChunk_NS;


   enum logic [1:0]  { IDLE, DISPATCH, COLLECT_BURST, COLLECT_BURST_DISPATCH } CS, NS;


   // INPUt SIDE
   // ADDRESS WRITE DATA CHANNEL
   logic                                       axi_slave_aw_valid_int;
   logic [AXI_ADDR_WIDTH-1:0]                  axi_slave_aw_addr_int;
   logic [2:0]                                 axi_slave_aw_prot_int;
   logic [3:0]                                 axi_slave_aw_region_int;
   logic [7:0]                                 axi_slave_aw_len_int;
   logic [2:0]                                 axi_slave_aw_size_int;
   logic [1:0]                                 axi_slave_aw_burst_int;
   logic                                       axi_slave_aw_lock_int;
   logic [3:0]                                 axi_slave_aw_cache_int;
   logic [3:0]                                 axi_slave_aw_qos_int;
   logic [AXI_ID_WIDTH_IN-1:0]                 axi_slave_aw_id_int;
   logic [AXI_USER_WIDTH_IN-1:0]               axi_slave_aw_user_int;
   logic                                       axi_slave_aw_ready_int;

   // WRITE DATA CHANNEL
   logic                                       axi_slave_w_valid_int;
   logic [AXI_DATA_WIDTH_IN-1:0]               axi_slave_w_data_int;
   logic [AXI_STRB_WIDTH_IN-1:0]               axi_slave_w_strb_int;
   logic [AXI_USER_WIDTH_IN-1:0]               axi_slave_w_user_int;
   logic                                       axi_slave_w_last_int;
   logic                                       axi_slave_w_ready_int;

   // SLices data from the FIFO pop side
   logic [7:0]                                 axi_slave_aw_len_Q;
   logic [$clog2(DATA_WIDTH_RATIO)-1:0]        axi_master_aw_displacement_Q;



   // Signals From Slice to FIFO and FIFO to WRITE FSM
   logic [FIFO_DATA_WIDTH-1:0]                                        push_data_FIFO;
   logic                                                              push_valid_FIFO;
   logic                                                              push_grant_FIFO;
   logic [FIFO_DATA_WIDTH-1:0]                                        pop_data_FIFO;
   logic                                                              pop_valid_FIFO;
   logic                                                              pop_grant_FIFO;


    // WRITE DATA CHANNEL
    logic [DATA_WIDTH_RATIO-1:0][AXI_DATA_WIDTH_IN-1:0]               axi_master_w_data_Q;
    logic [DATA_WIDTH_RATIO-1:0][AXI_STRB_WIDTH_IN-1:0]               axi_master_w_strb_Q;
    logic [AXI_USER_WIDTH_IN-1:0]                                     axi_master_w_user_Q;


    logic                                                             clear_strobe, update_write_data;



   // AXI WRITE ADDRESS CHANNEL BUFFER
   axi_aw_buffer
   #(
       .ID_WIDTH     ( AXI_ID_WIDTH_IN   ),
       .ADDR_WIDTH   ( AXI_ADDR_WIDTH    ),
       .USER_WIDTH   ( AXI_USER_WIDTH_IN ),
       .BUFFER_DEPTH ( SLICE_DEPTH       )
   )
   aw_buffer_i
   (
      .clk_i            ( clk_i                    ),
      .rst_ni           ( rst_ni                   ),
      .test_en_i        ( test_en_i                ),

      .slave_valid_i    ( axi_slave_aw_valid_i     ),
      .slave_addr_i     ( axi_slave_aw_addr_i      ),
      .slave_prot_i     ( axi_slave_aw_prot_i      ),
      .slave_region_i   ( axi_slave_aw_region_i    ),
      .slave_len_i      ( axi_slave_aw_len_i       ),
      .slave_size_i     ( axi_slave_aw_size_i      ),
      .slave_burst_i    ( axi_slave_aw_burst_i     ),
      .slave_lock_i     ( axi_slave_aw_lock_i      ),
      .slave_cache_i    ( axi_slave_aw_cache_i     ),
      .slave_qos_i      ( axi_slave_aw_qos_i       ),
      .slave_id_i       ( axi_slave_aw_id_i        ),
      .slave_user_i     ( axi_slave_aw_user_i      ),
      .slave_ready_o    ( axi_slave_aw_ready_o     ),

      .master_valid_o   ( axi_slave_aw_valid_int   ),
      .master_addr_o    ( axi_slave_aw_addr_int    ),
      .master_prot_o    ( axi_slave_aw_prot_int    ),
      .master_region_o  ( axi_slave_aw_region_int  ),
      .master_len_o     ( axi_slave_aw_len_int     ),
      .master_size_o    ( axi_slave_aw_size_int    ),
      .master_burst_o   ( axi_slave_aw_burst_int   ),
      .master_lock_o    ( axi_slave_aw_lock_int    ),
      .master_cache_o   ( axi_slave_aw_cache_int   ),
      .master_qos_o     ( axi_slave_aw_qos_int     ),
      .master_id_o      ( axi_slave_aw_id_int      ),
      .master_user_o    ( axi_slave_aw_user_int    ),
      .master_ready_i   ( axi_slave_aw_ready_int   )
   );


   // WRITE DATA CHANNEL BUFFER
   axi_w_buffer
   #(
       .DATA_WIDTH   ( AXI_DATA_WIDTH_IN  ),
       .USER_WIDTH   ( AXI_USER_WIDTH_IN  ),
       .BUFFER_DEPTH ( SLICE_DEPTH        )
   )
   w_buffer_i
   (
      .clk_i          ( clk_i                  ),
      .rst_ni         ( rst_ni                 ),
      .test_en_i      ( test_en_i              ),

      .slave_valid_i  ( axi_slave_w_valid_i    ),
      .slave_data_i   ( axi_slave_w_data_i     ),
      .slave_strb_i   ( axi_slave_w_strb_i     ),
      .slave_user_i   ( axi_slave_w_user_i     ),
      .slave_last_i   ( axi_slave_w_last_i     ),
      .slave_ready_o  ( axi_slave_w_ready_o    ),

      .master_valid_o ( axi_slave_w_valid_int  ),
      .master_data_o  ( axi_slave_w_data_int   ),
      .master_strb_o  ( axi_slave_w_strb_int   ),
      .master_user_o  ( axi_slave_w_user_int   ),
      .master_last_o  ( axi_slave_w_last_int   ),
      .master_ready_i ( axi_slave_w_ready_int  )
   );



   // WRITE RESPONSE CHANNEL BUFFER
   axi_b_buffer
   #(
       .ID_WIDTH      ( AXI_ID_WIDTH_OUT       ),
       .USER_WIDTH    ( AXI_USER_WIDTH_OUT     ),
       .BUFFER_DEPTH  ( SLICE_DEPTH            )
   )
   b_buffer_i
   (
      .clk_i           ( clk_i                 ),
      .rst_ni          ( rst_ni                ),
      .test_en_i       ( test_en_i             ),

      .slave_valid_i   ( axi_master_b_valid_i  ),
      .slave_resp_i    ( axi_master_b_resp_i   ),
      .slave_id_i      ( axi_master_b_id_i     ),
      .slave_user_i    ( axi_master_b_user_i   ),
      .slave_ready_o   ( axi_master_b_ready_o  ),

      .master_valid_o  ( axi_slave_b_valid_o   ),
      .master_resp_o   ( axi_slave_b_resp_o    ),
      .master_id_o     ( axi_slave_b_id_o      ),
      .master_user_o   ( axi_slave_b_user_o    ),
      .master_ready_i  ( axi_slave_b_ready_i   )
   );





   generic_fifo
   #(
      .DATA_WIDTH   ( FIFO_DATA_WIDTH ),
      .DATA_DEPTH   ( FIFO_DATA_DEPTH )
   )
   alignment_AW_axi64
   (
      .clk          ( clk_i           ),
      .rst_n        ( rst_ni          ),
      .test_mode_i  ( test_en_i       ),

      .data_i       ( push_data_FIFO  ),
      .valid_i      ( push_valid_FIFO ),
      .grant_o      ( push_grant_FIFO ),

      .data_o       ( pop_data_FIFO   ),
      .valid_o      ( pop_valid_FIFO  ),
      .grant_i      ( pop_grant_FIFO  )
   );


   assign push_data_FIFO   =  {axi_slave_aw_addr_int[OFFSET+FIFO_DATA_WIDTH-1:OFFSET], axi_slave_aw_len_int };
   assign push_valid_FIFO  =  axi_master_aw_valid_o & axi_master_aw_ready_i;

   assign axi_master_aw_valid_o  = push_grant_FIFO & axi_slave_aw_valid_int;
   assign axi_slave_aw_ready_int = push_grant_FIFO & axi_master_aw_ready_i;


   logic [31:0]   start_ADDR;
   logic [31:0]   end_ADDR;

   assign start_ADDR = axi_slave_aw_addr_int;                                                      // 0x00
   assign end_ADDR   = axi_slave_aw_addr_int + { axi_slave_aw_len_int , {OFFSET{1'b0}} };          // 0x34 eg Len = 13

   assign axi_master_aw_len_o  = end_ADDR[11:OFFSET+DATA_WIDTH_RATIO] - start_ADDR[11:OFFSET+DATA_WIDTH_RATIO]; // 4K Boundary

   // Slice the pop data into displament info and number of packet to send
   assign {axi_master_aw_displacement_Q, axi_slave_aw_len_Q } = pop_data_FIFO;

   always_ff @(posedge clk_i or negedge rst_ni)
   begin
      if(~rst_ni)
      begin
         CS <= IDLE;
         CounterBurst_CS <= '0;
      end
      else
      begin
          CS <= NS;
          CounterBurst_CS <= CounterBurst_NS;
      end
   end


   assign axi_master_aw_addr_o   = axi_slave_aw_addr_int;
   assign axi_master_aw_prot_o   = axi_slave_aw_prot_int;
   assign axi_master_aw_region_o = axi_slave_aw_region_int;
   assign axi_master_aw_size_o   = logic_3_bit'($clog2(AXI_DATA_WIDTH_OUT)-3);
   assign axi_master_aw_burst_o  = axi_slave_aw_burst_int;
   assign axi_master_aw_lock_o   = axi_slave_aw_lock_int;
   assign axi_master_aw_cache_o  = axi_slave_aw_cache_int;
   assign axi_master_aw_qos_o    = axi_slave_aw_qos_int;
   assign axi_master_aw_id_o     = axi_slave_aw_id_int;
   assign axi_master_aw_user_o   = axi_slave_aw_user_int;



   assign axi_master_w_strb_o  = axi_master_w_strb_Q;
   assign axi_master_w_data_o  = axi_master_w_data_Q;
   assign axi_master_w_user_o  = axi_master_w_user_Q;


   always_comb
   begin
      CounterBurst_NS  = CounterBurst_CS;
      CounterChunk_NS  = CounterChunk_CS;

      NS               = CS;
      pop_grant_FIFO   = 1'b0;
      CounterChunk_NS  = CounterChunk_CS;
      Chunk_Pointer    = axi_master_aw_displacement_Q;

      axi_master_w_valid_o = 1'b0;
      axi_master_w_last_o  = 1'b0;

      update_write_data = 1'b0;
      clear_strobe      = 1'b0;

      axi_slave_w_ready_int = 1'b0;



      case(CS)

         IDLE:
         begin

               Chunk_Pointer   = axi_master_aw_displacement_Q;
               CounterBurst_NS = '0;
               axi_slave_w_ready_int = pop_valid_FIFO;

               if(pop_valid_FIFO)
               begin

                     update_write_data = axi_slave_w_valid_int;

                     // If there is valid write data
                     if(axi_slave_w_valid_int)
                     begin
                           // Chck if it is a single beat transaction
                           if( axi_slave_w_last_int == 1'b1) //
                           begin
                              NS = DISPATCH;
                              // Single beat transaction , pop the FIFO
                              pop_grant_FIFO = 1'b1;
                              // Pop W slice only if there is a valid info in th AW FIFO
                              axi_slave_w_ready_int = axi_master_w_ready_i;
                           end
                           else
                           begin
                              // More than one beat transfer, collect data!!!
                              CounterChunk_NS = axi_master_aw_displacement_Q + 1'b1;// Dont care about overflow


                              if(axi_master_aw_displacement_Q == '1)
                              begin
                                 CounterBurst_NS = 8'h01;
                                 NS = COLLECT_BURST_DISPATCH;
                              end
                              else
                              begin
                                 CounterBurst_NS = '0;
                                 NS = COLLECT_BURST;
                              end

                           end
                     end
                     else  // There is no valid Wdata, wait here
                     begin
                        NS = IDLE;
                     end

               end
               else
               begin
                  NS = IDLE;
               end
         end


         DISPATCH:
         begin
            axi_master_w_valid_o = 1'b1;
            axi_master_w_last_o  = 1'b1;

            clear_strobe         = axi_master_w_ready_i;

            if(axi_master_w_ready_i)  // Ready ti dispatch and process incoming write
            begin
                           // Pop W slice only if there is a valid info in th AW FIFO
                           axi_slave_w_ready_int = axi_master_w_ready_i;

                           if(pop_valid_FIFO)
                           begin

                                 update_write_data = axi_slave_w_valid_int;

                                 // If there is valid write data
                                 if(axi_slave_w_valid_int)
                                 begin
                                       // Chck if it is a single beat transaction
                                       if( axi_slave_w_last_int == 1'b1) //
                                       begin
                                          NS = DISPATCH;
                                          // Single beat transaction , pop the FIFO
                                          pop_grant_FIFO = 1'b1;

                                       end
                                       else
                                       begin
                                          // More than one beat transfer, collect data!!!
                                          CounterChunk_NS = axi_master_aw_displacement_Q + 1'b1;// Dont care about overflow

                                          if(axi_master_aw_displacement_Q == '1)
                                          begin
                                             CounterBurst_NS = 8'h01;
                                             NS = COLLECT_BURST_DISPATCH;
                                          end
                                          else
                                          begin
                                             CounterBurst_NS = '0;
                                             NS = COLLECT_BURST;
                                          end

                                       end
                                 end
                                 else  // There is no valid Wdata, wait here
                                 begin
                                    NS = IDLE;
                                 end

                           end
                           else
                           begin
                              NS = IDLE;
                           end

            end
            else
            begin
               NS = DISPATCH;
            end
         end



         COLLECT_BURST:
         begin
            axi_master_w_valid_o = 1'b0;
            axi_master_w_last_o  = 1'b0;

            Chunk_Pointer        = CounterChunk_CS;
            update_write_data    = axi_slave_w_valid_int;

            axi_slave_w_ready_int = 1'b1;
            update_write_data     = axi_slave_w_valid_int;

            if(axi_slave_w_last_int == 1'b1)
            begin
               NS = DISPATCH;
               pop_grant_FIFO = 1'b1;
            end
            else
            begin
               CounterChunk_NS = CounterChunk_CS + 1'b1; // Dont care about verflow

               if(CounterChunk_CS == '1)
               begin
                  NS = COLLECT_BURST_DISPATCH;
                  CounterBurst_NS = CounterBurst_CS + 1'b1;
               end
               else
               begin
                  NS = COLLECT_BURST;
               end
            end

         end




         COLLECT_BURST_DISPATCH:
         begin

            axi_master_w_valid_o = 1'b1;
            axi_master_w_last_o  = 1'b0;
            clear_strobe         = axi_master_w_ready_i;

            if(axi_master_w_ready_i)
            begin
                  Chunk_Pointer        = CounterChunk_CS;
                  update_write_data    = axi_slave_w_valid_int;

                  axi_slave_w_ready_int = 1'b1;
                  update_write_data     = axi_slave_w_valid_int;

                  if(axi_slave_w_last_int == 1'b1)
                  begin
                     NS = DISPATCH;
                     pop_grant_FIFO = 1'b1;
                  end
                  else
                  begin
                     CounterChunk_NS = CounterChunk_CS + 1'b1; // Dont care about verflow

                     if(CounterChunk_CS == '1)
                     begin
                        NS = COLLECT_BURST_DISPATCH;
                        CounterBurst_NS = CounterBurst_CS + 1'b1;
                     end
                     else
                     begin
                        NS = COLLECT_BURST;
                     end
                  end
            end
            else  // Master not ready  Stay Here
            begin
               NS = COLLECT_BURST_DISPATCH;
            end


         end



         default:
         begin
            NS = IDLE;
         end


      endcase // CS
   end



   always_ff @(posedge clk_i, negedge rst_ni)
   begin
      if(rst_ni == 1'b0)
      begin
         axi_master_w_strb_Q <= '0;
         axi_master_w_data_Q <= '0;
         axi_master_w_user_Q <= '0;
         CounterChunk_CS     <= '0;

      end
      else
      begin
         CounterChunk_CS       <= CounterChunk_NS;

         if(clear_strobe)
         begin
            axi_master_w_strb_Q <= '0;
            axi_master_w_data_Q <= '0;
         end

         if(update_write_data)
         begin
            axi_master_w_data_Q[Chunk_Pointer] <= axi_slave_w_data_int;
            axi_master_w_strb_Q[Chunk_Pointer] <= axi_slave_w_strb_int;
            axi_master_w_user_Q                <= axi_slave_w_user_int;
         end

      end

   end


   // synopsys translate_off
   initial
   begin : CHECK_PARAMS
      if(AXI_USER_WIDTH_IN != AXI_USER_WIDTH_OUT )
      begin
         $fatal("AXI_USER_WIDTH_IN (%d)!= AXI_USER_WIDTH_OUT  (%d) --> in %m \n", AXI_USER_WIDTH_IN, AXI_USER_WIDTH_OUT );
      end

      if(AXI_DATA_WIDTH_IN >= AXI_DATA_WIDTH_OUT )
      begin
         $fatal("AXI_DATA_WIDTH_IN (%d) >= AXI_DATA_WIDTH_OUT  (%d) --> in %m \n", AXI_DATA_WIDTH_IN, AXI_DATA_WIDTH_OUT );
      end

      if(AXI_ID_WIDTH_IN != AXI_ID_WIDTH_OUT )
      begin
         $fatal("AXI_ID_WIDTH_IN (%d) >= AXI_ID_WIDTH_OUT  (%d) --> in %m \n", AXI_ID_WIDTH_IN, AXI_ID_WIDTH_OUT );
      end
   end
   // synopsys translate_on


endmodule
