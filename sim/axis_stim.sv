
`timescale 1ns / 1ps  // <time_unit>/<time_precision>

module axis_stim #
	(
		parameter integer                         DATA_WIDTH	  = 32,
    parameter integer                         FRAME_LENGTH  = 64,
    parameter integer                         NUM_FRAMES    = 1, // FIX. this needs to be variable input that can change during runtime
    parameter integer                         CNTR_WIDTH    = 8,
    parameter [(DATA_WIDTH-CNTR_WIDTH)-1 : 0] FIXED_DATA    = '1,
    parameter time                            FRAME_DELAY   = 0ns // single clock cycle between frames when 0. aligned to clock edge
	)
	(
		input                         clk		        ,
    input                         start         ,
    output [DATA_WIDTH-1 : 0]     M_AXIS_tdata  ,
    output [3:0]                  M_AXIS_tdest  ,
    output [(DATA_WIDTH/8)-1 : 0] M_AXIS_tkeep  ,
    output                        M_AXIS_tlast  ,
    input                         M_AXIS_tready ,
    output                        M_AXIS_tvalid
  );

  generate if (CNTR_WIDTH > DATA_WIDTH)
    initial $fatal("ERROR: %m CNTR_WIDTH (%0d) cannot exceed DATA_WIDTH (%0d)", CNTR_WIDTH, DATA_WIDTH); // %m prints instance name/path
  endgenerate

  generate if (DATA_WIDTH % 8 != 0)
    initial $fatal("ERROR: %m DATA_WIDTH (%0d) must be a multiple of 8", DATA_WIDTH);
  endgenerate


//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------

logic [DATA_WIDTH-1 : 0]     tdata      , tdata2 ;
logic [3:0]                  tdest      , tdest2 ;
logic [(DATA_WIDTH/8)-1 : 0] tkeep='1   , tkeep2='1 ;
logic                        tlast      , tlast2 ;
logic                        tready     , tready2;
logic                        tvalid     , tvalid2;

assign M_AXIS_tdata   = tdata2 ;
assign M_AXIS_tdest   = tdest2 ;
assign M_AXIS_tkeep   = tkeep2 ;
assign M_AXIS_tlast   = tlast2 ;
assign M_AXIS_tvalid  = tvalid2;
assign tready = M_AXIS_tready;

logic [CNTR_WIDTH-1:0]          data_cnt=0;
logic [$clog2(FRAME_LENGTH):0]  frame_len_cnt=0;
logic cnt_en=0;
int   num=0;

//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------

  initial begin
    
    while(1) begin
      wait(start == 1);
      cntr(NUM_FRAMES);
    end

  end

  task cntr;
    input integer NumFrames;
  begin
    num = NumFrames;
    while (num > 0) begin
      @(posedge clk);
      cnt_en <= 1;
      wait(frame_len_cnt==FRAME_LENGTH-1);
      @(posedge clk);
      cnt_en <= 0;
      num = num-1;
      #FRAME_DELAY;
    end;
  end
  endtask  


  always @(posedge clk) begin 
    if (~cnt_en) begin
      data_cnt      <= 0;
      frame_len_cnt <= 0;
    end else if (cnt_en & tready) begin
      data_cnt      <= data_cnt + 1;
      frame_len_cnt <= frame_len_cnt + 1;
    end
  end 


  //assign tdata[CNTR_WIDTH-1:0] = data_cnt;
  //assign tdata[DATA_WIDTH-1:CNTR_WIDTH] = FIXED_DATA;
  //assign tdata = (num == 2)? {FIXED_DATA,data_cnt} : {28'h7775B00,data_cnt};
  assign tdata = ((num == 2) & (tvalid == 1))? {FIXED_DATA,data_cnt} : ((num == 1) & (tvalid == 1))? {28'h7775B00,data_cnt} :0;
  assign tlast = (frame_len_cnt == FRAME_LENGTH-1)? '1:0;
  //assign tlast = ((frame_len_cnt == FRAME_LENGTH-1)&(num==1))? '1:0;
  assign tvalid = cnt_en;

  // quick. fix/change this
  //assign tdest = (num == 1)? 1:0;
  assign tdest = ((num == 2) & (tvalid == 1))? 0 : ((num == 1) & (tvalid == 1))? 1 :0;

// Register signals before sending to IP!!!!!
// without this, there were issues with last word of frame
  always @(posedge clk) begin 
    tdata2   <= tdata ;
    tdest2   <= tdest ;
    tkeep2   <= tkeep ;
    tlast2   <= tlast ;
    tvalid2  <= tvalid;
  end

endmodule