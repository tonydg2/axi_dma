
`timescale 1ns / 1ps  // <time_unit>/<time_precision>
  // time_unit: measurement of delays / simulation time (#10 = 10<time_unit>)
  // time_precision: how delay values are rounded before being used in simulation (degree of accuracy of the time unit)

//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------

module dma_top_tb ;

  logic clk=0, rstn=0, rst;

  always #2 clk = ~clk; // 250mhz period = 4ns, invert every 2ns

  initial begin
    rstn <= 0;
    #20;
    rstn <= 1;
  end
  assign rst = !rstn;

  logic [31:0]  S_AXIL_araddr  =0   ;         
  logic [2:0]   S_AXIL_arprot  =0   ;     
  logic         S_AXIL_arready =0   ;     
  logic         S_AXIL_arvalid =0   ;     
  logic [31:0]  S_AXIL_awaddr  =0   ;
  logic [2:0]   S_AXIL_awprot  =0   ;     
  logic         S_AXIL_awready =0   ;     
  logic         S_AXIL_awvalid =0   ;     
  logic         S_AXIL_bready  =0   ;     
  logic [1:0]   S_AXIL_bresp   =0   ;   
  logic         S_AXIL_bvalid  =0   ;     
  logic [31:0]  S_AXIL_rdata   =0   ;   
  logic         S_AXIL_rready  =0   ;     
  logic [1:0]   S_AXIL_rresp   =0   ;   
  logic         S_AXIL_rvalid  =0   ;     
  logic [31:0]  S_AXIL_wdata   =0   ;   
  logic         S_AXIL_wready  =0   ;     
  logic [3:0]   S_AXIL_wstrb   ='1  ;   
  logic         S_AXIL_wvalid  =0   ;     

  logic [31:0] S2MM_tdata='0 ;
  logic [ 3:0] S2MM_tkeep='0 ,S2MM_tdest='0;
  logic S2MM_tlast='0, S2MM_tready='0, S2MM_tvalid='0;
  logic [ 7:0] S2MM_tid='0;
  logic [15:0] S2MM_tuser='0;

  top_bd_wrapper  top_bd_wrapper_i (
    .M_AXIS_MM2S_tdata        (                 ),
    .M_AXIS_MM2S_tdest        (                 ),
    .M_AXIS_MM2S_tid          (                 ),
    .M_AXIS_MM2S_tkeep        (                 ),
    .M_AXIS_MM2S_tlast        (                 ),
    .M_AXIS_MM2S_tready       ('1               ),
    .M_AXIS_MM2S_tuser        (                 ),
    .M_AXIS_MM2S_tvalid       (                 ),
    .S_AXIL_araddr            (S_AXIL_araddr    ),
    .S_AXIL_arready           (S_AXIL_arready   ),
    .S_AXIL_arvalid           (S_AXIL_arvalid   ),
    .S_AXIL_arprot            ('0),
    .S_AXIL_awaddr            (S_AXIL_awaddr    ),
    .S_AXIL_awready           (S_AXIL_awready   ),
    .S_AXIL_awvalid           (S_AXIL_awvalid   ),
    .S_AXIL_awprot            ('0),
    .S_AXIL_bready            (S_AXIL_bready    ),
    .S_AXIL_bresp             (S_AXIL_bresp     ),
    .S_AXIL_bvalid            (S_AXIL_bvalid    ),
    .S_AXIL_rdata             (S_AXIL_rdata     ),
    .S_AXIL_rready            (S_AXIL_rready    ),
    .S_AXIL_rresp             (S_AXIL_rresp     ),
    .S_AXIL_rvalid            (S_AXIL_rvalid    ),
    .S_AXIL_wdata             (S_AXIL_wdata     ),
    .S_AXIL_wready            (S_AXIL_wready    ),
    .S_AXIL_wvalid            (S_AXIL_wvalid    ),
    .S_AXIL_wstrb             ('1),
    .S_AXIS_S2MM_tdata        (S2MM_tdata       ),
    .S_AXIS_S2MM_tdest        (S2MM_tdest       ),
    .S_AXIS_S2MM_tid          (S2MM_tid         ),
    .S_AXIS_S2MM_tkeep        (S2MM_tkeep       ),              
    .S_AXIS_S2MM_tlast        (S2MM_tlast       ),              
    .S_AXIS_S2MM_tready       (S2MM_tready      ),              
    .S_AXIS_S2MM_tuser        (S2MM_tuser       ),
    .S_AXIS_S2MM_tvalid       (S2MM_tvalid      ),              
    .aclk                     (clk              ),      
    .arstn                    (rstn             )
  );


  axil_stim_dma  # (
    .DATA_WIDTH (32),
    .ADDR_WIDTH (32)
  ) axil_stim_dma_i (
    .start            (1'b1),
    .done             (axil_done),
    .M_AXI_aclk       (clk),
    .M_AXI_aresetn    (rstn),
    .M_AXI_araddr     (S_AXIL_araddr ),       
    .M_AXI_arprot     (S_AXIL_arprot ),       
    .M_AXI_arready    (S_AXIL_arready),      
    .M_AXI_arvalid    (S_AXIL_arvalid),      
    .M_AXI_awaddr     (S_AXIL_awaddr ),      
    .M_AXI_awprot     (S_AXIL_awprot ),      
    .M_AXI_awready    (S_AXIL_awready),      
    .M_AXI_awvalid    (S_AXIL_awvalid),      
    .M_AXI_bready     (S_AXIL_bready ),      
    .M_AXI_bresp      (S_AXIL_bresp  ),      
    .M_AXI_bvalid     (S_AXIL_bvalid ),      
    .M_AXI_rdata      (S_AXIL_rdata  ),      
    .M_AXI_rready     (S_AXIL_rready ),      
    .M_AXI_rresp      (S_AXIL_rresp  ),      
    .M_AXI_rvalid     (S_AXIL_rvalid ),      
    .M_AXI_wdata      (S_AXIL_wdata  ),      
    .M_AXI_wready     (S_AXIL_wready ),      
    .M_AXI_wstrb      (S_AXIL_wstrb  ),      
    .M_AXI_wvalid     (S_AXIL_wvalid )
  );

  logic start=0;

  axis_stim  # (
    .DATA_WIDTH	    (32),
    .FRAME_LENGTH   (16),
    .NUM_FRAMES     (2),
    .CNTR_WIDTH     (4),
    .FIXED_DATA     (28'h666A500),
    .FRAME_DELAY    (1000ns)
  ) axis_stim_i (
    .clk            (clk),
    .start          (start),
    .M_AXIS_tdata   (S2MM_tdata ),
    .M_AXIS_tdest   (S2MM_tdest ),
    .M_AXIS_tkeep   (S2MM_tkeep ),
    .M_AXIS_tlast   (S2MM_tlast ),
    .M_AXIS_tready  (S2MM_tready),
    .M_AXIS_tvalid  (S2MM_tvalid)
  );

//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------


initial begin 
  wait(rst==0);
//  #200ns;tready=1;
  wait(axil_done == 1);
  #20ns;start_en;
end


task start_en;
  begin 
    @(posedge clk); start <= 1;
    @(posedge clk); start <= 0;
  end 
endtask
  

endmodule