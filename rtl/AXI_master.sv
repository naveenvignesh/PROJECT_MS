module AXI_master(AXI_clks.to_rtl clks,
                  AXI_rd_addr_ch.master_if raddr_ch,AXI_rd_data_ch.master_if rdata_ch,
                  AXI_wr_addr_ch.master_if waddr_ch,AXI_wr_data_ch.master_if wdata_ch,
                  AXI_wr_resp_ch.master_if wresp_ch,                  
                  input rd,input [31:0] haddr,input main_ptr_empty,output haddr_pull);

//parameter AWID = 4'h0;
//parameter ARID = 4'h1;

typedef enum reg [3:0] {RST_=4'h0,FREE=4'h1,HEAD=4'h2,LINK=4'h3} ch_state; 
typedef enum reg [3:0] {RST=4'h0,INIT=4'h1,RD=4'h2,RD_BURST=4'h3}state; 
typedef enum reg [2:0] {B_ONE=3'b000,B_TWO=3'b001,B_FOUR=3'b010,B_EIGHT=3'b011,B_ST=3'b100,B_TW=3'b101,B_OTE=3'b110,B_TFS=3'b111}bur_size; 
typedef enum reg [1:0] {FIXED = 2'b00,INCR=2'b01,WRAP=2'b10,RESV=2'b11} bur_type; 
typedef enum reg [1:0] {OKAY = 2'b00,EXOKAY=2'b01,SLVERR=2'b10,DECERR=2'b11} rsp_type; 

state cur_state,nxt_state;
ch_state cur_chstate_0,nxt_chstate_0;
ch_state cur_chstate_1,nxt_chstate_1;
ch_state cur_chstate_2,nxt_chstate_2;
bur_size bsize;
bur_type btype;
rsp_type rtype;
reg [3:0] arid,arid_nxt;
reg [2:0] ch_req_arb;
reg [2:0] ch_gnt_d,ch_gnt_nxt;
reg arb_nxt,nxtaddr_to_axi_ready;

reg [7:0] burst_cnt_nxt,burst_cnt_d;
reg [31:0] araddr_nxt,araddr_d;
reg [1:0]  arlen;
reg [2:0]  arsize;
reg        arburst_nxt,arvalid_nxt,arready,awvalid,wvalid,rready,burst_done;
reg        arburst_d,arvalid_d;

assign raddr_ch.ARADDR = araddr_nxt;
assign raddr_ch.ARLEN  = arlen;
assign raddr_ch.ARSIZE = arsize;
assign raddr_ch.ARBURST = arburst_nxt;
assign raddr_ch.ARVALID = arvalid_nxt;
//assign arready = raddr_ch.ARREADY;

assign waddr_ch.AWVALID = awvalid;
assign wdata_ch.WVALID  = wvalid;

//assign rdata_ch.RID;
//assign rdata_ch.RDATA;
//assign rdata_ch.RRESP;
//assign rdata_ch.RLAST;
//assign rdata_ch.RUSER;
//assign rdata_ch.RVAILD;
assign rdata_ch.RREADY=rready;

dma_fifo #(32,5) wchaddr_tomem_fifo (.clk(clks.clk),.rst(clks.rst),.push(wchaddr_push),.pull(wchaddr_pull),.data_in(wchaddr_datain),.data_out(wchaddr_dataout),.depth_left(wchaddr_depthleft),.full(wchaddr_full),.empty(wchaddr_empty));
//dma_fifo #(64,5) wchdata_tomem_fifo (.clks(clks),.push(wchdata_push),.pull(wchdata_pull),.data_in(wchaddr_datain),.data_out(wchaddr_dataout),.depth_left(wchaddr_depthleft),.full(wchaddr_full),.empty(wchaddr_empty));

wire         rchaddr_push,rchaddr_pull;
wire [31:0]  rchaddr_datain,rchaddr_dataout;
wire         rchaddr_depthleft;
wire         rchaddr_full,rchaddr_empty;
reg  [31:0]  hold_addr,nxtaddr_to_axi;

dma_fifo #(32,5) rchaddr_fifo_tomem (.clk(clks.clk),.rst(clks.rst),.push(rchaddr_push),.pull(rchaddr_pull),.data_in(rchaddr_datain),.data_out(rchaddr_dataout),.depth_left(rchaddr_depthleft),.full(rchaddr_full),.empty(rchaddr_empty));

//dma_fifo #(32,5) rchaddr_fifo_tomem (.clks(clks),.push(rchaddr_push),.pull(rchaddr_pull),.data_in(rchaddr_datain),.data_out(rchaddr_dataout),.depth_left(rchaddr_depthleft),.full(rchaddr_full),.empty(rchaddr_empty));

//dma_fifo #(32) wchaddr_totb_fifo (.clks(clks),.push(wchaddr_push),.pull(wchaddr_pull),.data_in(wchaddr_datain),.data_out(wchaddr_dataout),.depth_left(wchaddr_depthleft),.full(wchaddr_full),.empty(wchaddr_empty));
//dma_fifo #(64) wchdata_totb_fifo (.clks(clks),.push(wchdata_push),.pull(wchdata_pull),.data_in(wchaddr_datain),.data_out(wchaddr_dataout),.depth_left(wchaddr_depthleft),.full(wchaddr_full),.empty(wchaddr_empty));
reg [3:0] arid_d,arid_dnxt;
// state machine to read burst of data from memory
always @(posedge clks.clk or negedge clks.rst) begin 

  if(!clks.rst) begin 
            cur_state <= #0 RST;
            araddr_d <= #0 32'h0;
            arvalid_d   <= #0 0;
            arburst_d   <= #0 0;
            arid_d     <= #0 0;
  end else begin 
            cur_state <= #1 nxt_state;
            araddr_d  <= #1 araddr_nxt;
            arvalid_d   <= #0 arvalid_nxt;
            arburst_d   <= #0 arburst_nxt;
            arid_d     <= #0 arid_dnxt;
           end
end 

// next state calculation for read state burst machine
always @(*) begin
  //hold_addr_nxt = hold_addr_d;
  nxt_state   = cur_state; 
  araddr_nxt  = araddr_d;   
  arburst_nxt = arburst_d;   
  arvalid_nxt = 0;   
  bsize     = B_EIGHT;
  btype     = INCR;
  arlen     = 4'h2;   // 2 bursts 
  arsize    = 3'b011; // 8 bytes   
  arb_nxt   = 0;
  arid_dnxt = arid_d;

  case(cur_state) 
   RST: begin 
          nxt_state     = INIT;
          araddr_nxt    = 32'h00000000;   
          arburst_nxt   = 1'h0;   
          arvalid_nxt   = 1'h0;   
          bsize         = B_EIGHT;
          btype         = INCR;
	end
   INIT:begin
          if(rd) begin 
          nxt_state         = RD;
          araddr_nxt        = nxtaddr_to_axi;   
          arvalid_nxt       = 1'h1;   
          arburst_nxt       = 1'h1;   
          arb_nxt           = 1;
          //hold_addr_nxt     = nxtaddr_to_axi;
          arid_dnxt         = arid;
          end else begin 
          nxt_state         = INIT;
          //arvalid           = 1'h0;   
	   end
	end
   RD:  begin
          if(raddr_ch.ARREADY) begin 

                if(nxtaddr_to_axi_ready) begin 
                   nxt_state         = RD;
                   arvalid_nxt           = 1'b1;   
                   araddr_nxt            = nxtaddr_to_axi;
                end else begin 
                          arvalid_nxt           = 1'b0;   
                          nxt_state         = INIT;
                         end 

          end else begin 
                      arvalid_nxt  = arvalid_d;   
                   end 
	end
  endcase 
end 

// Read data channel state machine
//
typedef enum reg [3:0] {RST_DCH=4'h0,WAIT_FOR_RVALID=4'h1,DONE=4'h2}dch_state; 
dch_state dch_cur_state,dch_nxt_state;
wire rd_error;
reg  wr_link_addr;
reg  wr_pkt_data ;
reg  link_push_0,link_push_1,link_push_2;
reg  link_pull_0,link_pull_1,link_pull_2;
reg  link_full_0,link_full_1,link_full_2;
reg [31:0]  link_datain_0,link_datain_1,link_datain_2;
reg [31:0]  link_dataout_0,link_dataout_1,link_dataout_2;
reg pfifo_push_0,pfifo_push_1,pfifo_push_2;
reg pfifo_pull_0,pfifo_pull_1,pfifo_pull_2;
reg [31:0]  pfifo_datain_0,pfifo_datain_1,pfifo_datain_2;
reg [31:0]  pfifo_dataout_0,pfifo_dataout_1,pfifo_dataout_2;
/*typedef packed struct{
 reg [31:0] addr;
 reg rdy;
} link_addr_reg;
 
link_addr_reg link_addr_0,link_addr_1,link_addr_2;
link_addr_reg link_nxt_0,link_nxt_1,link_nxt_2; */

assign rd_error = ~((rdata_ch.RRESP == 2'b00) | (rdata_ch.RRESP == 2'b01));

always @(posedge clks.clk or negedge clks.rst) begin 
   if(!clks.rst) begin
    dch_cur_state <= #0 RST_DCH; 
    burst_cnt_d <= #0 0;
   end else begin 
    dch_cur_state    <= #1 dch_nxt_state; 
    burst_cnt_d      <= #1 burst_cnt_nxt;
   end
end 

always @(*) begin 
   rready= 0;
   dch_nxt_state = dch_cur_state;
   burst_cnt_nxt = burst_cnt_d;
   wr_link_addr  = 0;
   wr_pkt_data   = 0;
   
   case(dch_cur_state)
    RST_DCH:begin 
             if(clks.rst) begin
                dch_nxt_state = WAIT_FOR_RVALID;
                rready        = 1'b0; 
             end else dch_nxt_state = RST;
        end
    WAIT_FOR_RVALID: begin 
                     rready = 1'b1;
                     if(rdata_ch.RVALID & !rdata_ch.RLAST & !rd_error) begin 
                       // push into fifo data pkt
                        burst_cnt_nxt = burst_cnt_d + 1;
                        wr_pkt_data   = 1;
                     end else if(rdata_ch.RVALID & rdata_ch.RLAST & !rd_error) begin 
                               // push into LINK addr ready fifo 
                        burst_cnt_nxt = burst_cnt_d + 1;
                        wr_link_addr = 1;
                               end
                     dch_nxt_state = WAIT_FOR_RVALID;
	           end
    
   endcase

end

always @(*) begin 
  
  link_push_0 = 0;
  link_push_1 = 0;
  link_push_2 = 0;
  
  pfifo_push_0 = 0;
  pfifo_push_1 = 0;
  pfifo_push_2 = 0;

  if(wr_link_addr) begin 
    case(rdata_ch.RID)
    0: begin  
        link_datain_0   = rdata_ch.RDATA;
        link_push_0     = 1;
       end
    1: begin 
        link_datain_1   = rdata_ch.RDATA;
        link_push_1     = 1;
       end
    2: begin 
        link_datain_2   = rdata_ch.RDATA;
        link_push_2     = 1;
       end
    endcase 
  end

  if(wr_pkt_data) begin 
    case(rdata_ch.RID)
    0: begin  
        pfifo_datain_0   = rdata_ch.RDATA;
        pfifo_push_0     = 1;
       end
    1: begin 
        pfifo_datain_1   = rdata_ch.RDATA;
        pfifo_push_1     = 1;
       end
    2: begin 
        pfifo_datain_2   = rdata_ch.RDATA;
        pfifo_push_2     = 1;
       end
    endcase 
  end

end

// channel state machines for three channel states
// ch0,ch1,ch2

always @(posedge clks.clk or negedge clks.rst) begin 
  if(!clks.rst) begin 
    ch_gnt_d <= #0 0;
    arid     <= #0 0;
  end else begin 
            ch_gnt_d <= #1 ch_gnt_nxt;
            arid     <= #1 arid_nxt;
           end
end

always @(*) begin

 ch_gnt_nxt = ch_gnt_d;
 arid_nxt   = arid;   

  if(arb_nxt) begin 
    case(ch_gnt_d)
      3'b000: begin 
                case(ch_req_arb)
                  3'b??1:begin ch_gnt_nxt = 3'b001;arid_nxt = 0; end
                  3'b?10:begin ch_gnt_nxt = 3'b010;arid_nxt = 1; end
                  3'b100:begin ch_gnt_nxt = 3'b100;arid_nxt = 2; end
                endcase
              end 
      3'b001: begin 
                case(ch_req_arb)
                  3'b?1?:begin ch_gnt_nxt = 3'b010;arid_nxt = 1; end
                  3'b10?:begin ch_gnt_nxt = 3'b100;arid_nxt = 2; end
                  3'b001:begin ch_gnt_nxt = 3'b001;arid_nxt = 0; end
                endcase
              end 
      3'b010: begin 
                case(ch_req_arb)
                  3'b1??:begin ch_gnt_nxt = 3'b100;arid_nxt = 2; end
                  3'b0?1:begin ch_gnt_nxt = 3'b001;arid_nxt = 0; end
                  3'b010:begin ch_gnt_nxt = 3'b010;arid_nxt = 1; end
                endcase
              end 
      3'b100: begin 
                case(ch_req_arb)
                  3'b??1:begin ch_gnt_nxt = 3'b001;arid_nxt = 0; end
                  3'b?10:begin ch_gnt_nxt = 3'b010;arid_nxt = 1; end
                  3'b100:begin ch_gnt_nxt = 3'b100;arid_nxt = 2; end
                endcase
              end 
    endcase 
  end
end
reg [31:0] haddr0_d,haddr1_d,haddr2_d;
reg [31:0] haddr0_nxt,haddr1_nxt,haddr2_nxt;
reg link_empty_0,link_empty_1,link_empty_2;
/// nxt addr calculation based on selected channel
always@(*) begin
   nxtaddr_to_axi = 32'h0000_0000; 
   //link_pull = 0;
   nxtaddr_to_axi_ready = !(main_ptr_empty & link_empty_0 & link_empty_1 & link_empty_2);
   haddr0_nxt = haddr0_d;
   haddr1_nxt = haddr1_d;
   haddr2_nxt = haddr2_d;

   case(ch_gnt_d)
     001:begin
           nxtaddr_to_axi = link_empty_0 ? haddr : link_dataout_0 ;
           haddr0_nxt = link_empty_0 ? haddr:haddr0_d;
           //link_pull_0    =   link_empty_0 ? 0: 1 ; 
           //haddr_pull     =   link_empty_0 ? 1: 0 ; 
	 end
     010:begin 
           nxtaddr_to_axi = link_empty_1 ? haddr : link_dataout_1 ;
           haddr1_nxt = link_empty_1 ? haddr:haddr1_d;
           //link_pull_1    =   link_empty_1 ? 0: 1 ; 
           //haddr_pull     =   link_empty_1 ? 1: 0 ; 
	 end
     100:begin 
           nxtaddr_to_axi = link_empty_2 ? haddr : link_dataout_2 ;
           haddr2_nxt = link_empty_2 ? haddr:haddr2_d;
           //link_pull_2    =   link_empty_2 ? 0: 1 ; 
           //haddr_pull     =   link_empty_2 ? 1: 0 ; 
	 end
     default: begin 
	      end
   endcase
end

always @(posedge clks.clk or negedge clks.rst) begin
  if(!clks.rst) begin 
    cur_chstate_0 <= #0 RST_;
    cur_chstate_1 <= #0 RST_;
    cur_chstate_2 <= #0 RST_;
    ch_gnt_d      <= #0 0;
  end else begin 
    cur_chstate_0 <= #0 nxt_chstate_0;
    cur_chstate_1 <= #0 nxt_chstate_1;
    cur_chstate_2 <= #0 nxt_chstate_2;
    ch_gnt_d      <= #0 ch_gnt_nxt;
           end 
end 

always @(*) begin 
  nxt_chstate_0 = cur_chstate_0;
  nxt_chstate_1 = cur_chstate_1;
  nxt_chstate_2 = cur_chstate_2;
  ch_req_arb    = 3'b000;
   
  case(cur_chstate_0)
   RST_: begin 
           if(clks.rst) begin 
               nxt_chstate_0 = FREE; 
           end
        end
   FREE: begin 
          ch_req_arb[0] = 1'b1;
         end
   HEAD: begin 
            nxt_chstate_0 = (link_empty_0) ? HEAD : LINK; 
            ch_req_arb[0] = (link_empty_0) ? 1'b0 : 1'b1;
         end
   LINK: begin 
            ch_req_arb[0] = (link_empty_0)& (link_dataout_0 ==haddr0_d) ? 1'b0 : 1'b1;
            nxt_chstate_0 = (link_dataout_0 == haddr0_d) ? FREE : LINK;
         end
  endcase
 
  case(cur_chstate_1)
   RST_: begin 
           if(clks.rst) begin 
               nxt_chstate_1 = FREE; 
           end
        end
   FREE: begin 
          ch_req_arb[1] = 1'b1;
         end
   HEAD: begin 
            nxt_chstate_1 = (link_empty_1) ? HEAD : LINK; 
            ch_req_arb[1] = (link_empty_1) ? 1'b0 : 1'b1;
         end
   LINK: begin 
            ch_req_arb[1] = (link_empty_1)& (link_dataout_1 ==haddr1_d) ? 1'b0 : 1'b1;
            nxt_chstate_1 = (link_dataout_1 == haddr1_d) ? FREE : LINK;
         end
  endcase

  case(cur_chstate_2)
   RST_: begin 
           if(clks.rst) begin 
               nxt_chstate_2 = FREE; 
           end
        end
   FREE: begin 
          ch_req_arb[2] = 1'b1;
         end
   HEAD: begin 
            nxt_chstate_2 = (link_empty_2) ? HEAD : LINK; 
            ch_req_arb[2] = (link_empty_2) ? 1'b0 : 1'b1;
         end
   LINK: begin 
            ch_req_arb[2] = (link_empty_2)& (link_dataout_2 ==haddr2_d) ? 1'b0 : 1'b1;
            nxt_chstate_2 = (link_dataout_2 == haddr2_d) ? FREE : LINK;
         end
  endcase


end 
/////////////////////////////////////////////
/////////////////////////////////////////////
dma_fifo #(32,1) link_addr_0_fifo (.clk(clks.clk),.rst(clks.rst),.push(link_push_0),.pull(link_pull_0),.data_in(link_datain_0),.data_out(link_dataout_0),.depth_left(link_depthleft_0),.full(link_full_0),.empty(link_empty_0));
dma_fifo #(32,1) link_addr_1_fifo (.clk(clks.clk),.rst(clks.rst),.push(link_push_1),.pull(link_pull_1),.data_in(link_datain_1),.data_out(link_dataout_1),.depth_left(link_depthleft_1),.full(link_full_1),.empty(link_empty_1));
dma_fifo #(32,1) link_addr_2_fifo (.clk(clks.clk),.rst(clks.rst),.push(link_push_2),.pull(link_pull_2),.data_in(link_datain_2),.data_out(link_dataout_2),.depth_left(link_depthleft_2),.full(link_full_2),.empty(link_empty_2));

/////////////////////////////////////////////
/////////////////////////////////////////////
dma_fifo #(32,1) pkt0_fifo (.clk(clks.clk),.rst(clks.rst),.push(pfifo_push_0),.pull(pfifo_pop_0),.data_in(pfifo_datain_0),.data_out(pfifo_dataout_0),.depth_left(pfifo_depthleft_0),.full(pfifo_full_0),.empty(pfifo_empty_0));
dma_fifo #(32,1) pkt1_fifo (.clk(clks.clk),.rst(clks.rst),.push(pfifo_push_1),.pull(pfifo_pop_1),.data_in(pfifo_datain_1),.data_out(pfifo_dataout_1),.depth_left(pfifo_depthleft_1),.full(pfifo_full_1),.empty(pfifo_empty_1));
dma_fifo #(32,1) pkt2_fifo (.clk(clks.clk),.rst(clks.rst),.push(pfifo_push_2),.pull(pfifo_pop_2),.data_in(pfifo_datain_2),.data_out(pfifo_dataout_2),.depth_left(pfifo_depthleft_2),.full(pfifo_full_2),.empty(pfifo_empty_2));

endmodule 

