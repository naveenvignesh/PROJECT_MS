`timescale 1ns/1ps
`include "files.sv"
import ethernet_frame_pkg::*;

module ethernet_tb;

 AXI_clks       clks ();
 AXI_rd_addr_ch rd_addr_ch();
 AXI_rd_data_ch rd_data_ch();
 AXI_wr_data_ch wr_data_ch();
 AXI_wr_addr_ch wr_addr_ch();  
 AXI_wr_resp_ch wr_resp_ch();  
 
 //wr_addr_ch.master_if  axi_waif;
 //wr_data_ch.master_if  axi_wdif;
 // axiclk and tx clk generation
 //reg axi_clk,rst,tx_clk;
 reg tx_clk;
logic [31:0] start_addr;

default clocking axi_clocking @(posedge clks.clk);
endclocking 

clocking eth_tx_rec @(posedge tx_clk);
endclocking 



 initial begin 
   start_addr =32'hFFFF_0008;
   clks.clk = 0;
   forever #5 clks.clk = ~clks.clk;
 end 

 initial begin 
   tx_clk = 0;
   forever #5 tx_clk = ~tx_clk;
 end 

 initial begin
   clks.rst = 1; #2;
   clks.rst = 0;
   ##5; #4;
   clks.rst = 1;
   ##10;
   traffic_gen();
   ##100;
   $finish;
 end

  initial begin 
    $dumpvars(0,ethernet_tb);
    $dumpfile("mac_core.vcd");
  end

task traffic_gen();
  int i =0;
  while (i<5) begin
   generate_pkt(i);
    i++; 
  end
endtask

//logic [32:0] axi_waddr[$];
//logic [63:0] axi_wdata[$];
//tb_link_regs create_link_hdr_pop;

task generate_pkt(int num);
 // generate packets here
 pkt_gen_mem_fill pkt = new();
 pkt.build_ethernet_frame();
 pkt.mem_fill();
 //pkt.link_hdr_fill();
 //axi_waddr.push_back(generate_wr_addr_to_axi(num));
 //axi_wdata.push_back(pkt.link_hdr_fill());
 tb_axi_master.axi_waddr.push_back(generate_wr_addr_to_axi(num));
 tb_axi_master.axi_wdata.push_back(pkt.link_hdr_fill());
 //$display("axi_waddr:%h axi_wdata:%h",axi_waddr[num],axi_wdata[num]);
 $display("axi_waddr:%h axi_wdata:%h",tb_axi_master.axi_waddr[num],
                                      tb_axi_master.axi_wdata[num]);
endtask 

function logic [31:0] generate_wr_addr_to_axi(int num);
       return (start_addr+((num%16)*8));
endfunction 

// axi addr drive channel
/*typedef enum logic [2:0] {RST_WA=3'h0,WAD=3'h1,WA=3'h2,WA_HOLD=3'h3} axi_wr_state;
axi_wr_state wra_cur_state,wra_nxt_state;
axi_wr_state wrd_cur_state,wrd_nxt_state;
reg awvalid_d,awvalid_nxt;
reg wvalid_d,wvalid_nxt;
reg [31:0] awaddr_d,awaddr_nxt;
reg [63:0] wdata_d,wdata_nxt;
reg [3:0]  awid_d,wid_d;
assign    wr_addr_ch.master_if.AWVALID = awvalid_nxt;  
assign    wr_addr_ch.master_if.AWADDR  = awaddr_nxt;  
assign    wr_addr_ch.master_if.WAID    = awid_d;  
assign    wr_addr_ch.master_if.WDATA   = wdata_nxt;  
assign    wr_addr_ch.master_if.WLAST   = 0;  
assign    wr_addr_ch.master_if.WID     = wid_d;  
assign    wr_addr_ch.master_if.WVALID = wvalid_nxt;  

always @(posedge clks.clk or negedge clks.rst) begin 
  if(!clks.rst) begin 
             wra_cur_state <= #0 RST_WA;
             wrd_cur_state <= #0 RST_WA;
             awvalid_d       <= #0 0;
             wvalid_d       <= #0 0;
             awaddr_d        <= #0 0;
             wdata_d        <= #0 0;
             awid_d          <= #0 0;
             wid_d           <= #0 0;
  end else begin 
             wra_cur_state <= #1 wra_nxt_state;
             wrd_cur_state <= #1 wrd_nxt_state;
             awvalid_d     <= #1 awvalid_nxt;
             wvalid_d      <= #1 wvalid_nxt;
             awaddr_d      <= #1 awaddr_nxt;
             wdata_d      <= #1 wdata_nxt;  
             awid_d        <= #1 3;
             wid_d         <= #1 3;
           end
end  

always @(*) begin 
   wra_nxt_state = wra_cur_state;
   awvalid_nxt   = awvalid_d;
   awaddr_nxt    = awaddr_d;
   case(wra_cur_state)
    RST_WA: begin
            
             awvalid_nxt   = 0;
           if(!clks.rst) wra_nxt_state = RST_WA; 
           else          wra_nxt_state = WA; 
	 end
    WAD: begin 
           if(!axi_waddr.size()) begin 
               wra_nxt_state  = WAD;
               awvalid_nxt   = 0;
            end else begin 
               awvalid_nxt   = 1;
               awaddr_nxt    = axi_waddr.pop_front();
               wra_nxt_state = WA;
                     end
         end
    WA:  begin
            if(wr_addr_ch.slave_if.AWREADY) begin 
                if(axi_waddr.size()) begin
                  wra_nxt_state = WA;
                  awaddr_nxt    = axi_waddr.pop_front();
                  awvalid_nxt   = 1; 
                end else begin 
                           awvalid_nxt   = 0;
                           wra_nxt_state = WAD; 
                         end
            end  
           end
   endcase
end

// axi data drive channel

always @(*) begin 
   wrd_nxt_state = wrd_cur_state;
   wvalid_nxt    = wvalid_d;
   case(wrd_cur_state)
    RST_WA: begin
            
             wvalid_nxt   = 0;
           if(!clks.rst) wrd_nxt_state = RST_WA; 
           else          wrd_nxt_state = WA; 
	 end
    WAD: begin 
           if(!axi_wdata.size()) begin 
               wrd_nxt_state  = WAD;
               wvalid_nxt   = 0;
            end else begin 
               wvalid_nxt   = 1;
               wdata_nxt    = axi_wdata.pop_front();
               wrd_nxt_state = WA;
                     end
         end
    WA:  begin
            if(wr_addr_ch.slave_if.WREADY) begin 
                if(axi_wdata.size()) begin
                  wrd_nxt_state = WA;
                  wdata_nxt     = axi_wdata.pop_front();
                  wvalid_nxt    = 1; 
                end else begin 
                           wvalid_nxt    = 0;
                           wrd_nxt_state = WAD; 
                         end
            end  
           end
   endcase
end
//////////////////////////////////////////////////////////////////////////
*/
eth_core tx(   clks.to_rtl,
               rd_addr_ch.slave_if,
               rd_data_ch.slave_if,
               wr_addr_ch.slave_if,
               wr_data_ch.slave_if,
               wr_resp_ch.slave_if );

axi_master_model tb_axi_master( wr_addr_ch.master_if,
                                wr_data_ch.master_if,
                                clks.to_rtl
                           );
// axi addr drive to rtl
/*initial begin 
   forever begin
            if(link_hdr_regs) 
           end
end */

endmodule 
