module dma_controller_tx(AXI_clks.to_rtl clks,
                         input [31:0] slave_addr,
                         input [63:0] slave_data,
                         input wr_en,
                         output clink_regs linkregs);

 base_address baddr,baddr_nxt;      // base pointer to program starting memory address 
 clink_regs   clink_ptr,clink_ptr_nxt;  // linked list  

 // 0xFFFF_0000 addr for base pointer
 // 0xFFFF_0008 addr for link_0
 // 0xFFFF_0010 addr for link_1
 // 0xFFFF_0018 addr for link_2
 // 0xFFFF_0020 addr for link_3
 // 0xFFFF_0028 addr for link_4
 // 0xFFFF_0030 addr for link_5
 // 0xFFFF_0038 addr for link_6
 // 0xFFFF_0040 addr for link_7
 // 0xFFFF_0048 addr for link_8
 // 0xFFFF_0050 addr for link_9
 // 0xFFFF_0058 addr for link_10
 // 0xFFFF_0060 addr for link_11
 // 0xFFFF_0068 addr for link_12
 // 0xFFFF_0070 addr for link_13
 // 0xFFFF_0078 addr for link_14
 // 0xFFFF_0080 addr for link_15
 
 always @(posedge clks.clk or negedge clks.rst) begin 
     if(!clks.rst) begin
         baddr <= #0 64'h0;
         for(integer i=0;i<16;i++) begin 
         clink_ptr.l_reg[i] <= #0 64'h0; 
         end  

     end else begin
                  case(slave_addr) 
                    32'hFFFF_0000:  baddr <= #1 slave_data; 
                    32'hFFFF_0008:  clink_ptr.l_reg[0] <= #1 slave_data;
                    32'hFFFF_0010:  clink_ptr.l_reg[1] <= #1 slave_data;
                    32'hFFFF_0018:  clink_ptr.l_reg[2] <= #1 slave_data;
                    32'hFFFF_0020:  clink_ptr.l_reg[3] <= #1 slave_data;
                    32'hFFFF_0028:  clink_ptr.l_reg[4] <= #1 slave_data;
                    32'hFFFF_0030:  clink_ptr.l_reg[5] <= #1 slave_data;
                    32'hFFFF_0038:  clink_ptr.l_reg[6] <= #1 slave_data;
                    32'hFFFF_0040:  clink_ptr.l_reg[7] <= #1 slave_data;
                    32'hFFFF_0048:  clink_ptr.l_reg[8] <= #1 slave_data;
                    32'hFFFF_0050:  clink_ptr.l_reg[9] <= #1 slave_data;
                    32'hFFFF_0058:  clink_ptr.l_reg[10]<= #1 slave_data;
                    32'hFFFF_0060:  clink_ptr.l_reg[11]<= #1 slave_data;
                    32'hFFFF_0068:  clink_ptr.l_reg[12]<= #1 slave_data;
                    32'hFFFF_0070:  clink_ptr.l_reg[13]<= #1 slave_data;
                    32'hFFFF_0078:  clink_ptr.l_reg[14]<= #1 slave_data;
                    32'hFFFF_0080:  clink_ptr.l_reg[15]<= #1 slave_data;
                  endcase 
              end
 end 

// AXI master interface to perform reads from memory
link_regs reg_0;
link_regs reg_1;
link_regs reg_2;
link_regs reg_3;
link_regs reg_4;
link_regs reg_5;
link_regs reg_6;
link_regs reg_7;
link_regs reg_8;
link_regs reg_9;
link_regs reg_10;
link_regs reg_11;
link_regs reg_12;
link_regs reg_13;
link_regs reg_14;
link_regs reg_15;

assign reg_0  =clink_ptr.l_reg[0];
assign reg_1  =clink_ptr.l_reg[1];
assign reg_2  =clink_ptr.l_reg[2];
assign reg_3  =clink_ptr.l_reg[3]; 
assign reg_4  =clink_ptr.l_reg[4]; 
assign reg_5  =clink_ptr.l_reg[5]; 
assign reg_6  =clink_ptr.l_reg[6]; 
assign reg_7  =clink_ptr.l_reg[7]; 
assign reg_8  =clink_ptr.l_reg[8]; 
assign reg_9  =clink_ptr.l_reg[9]; 
assign reg_10 =clink_ptr.l_reg[10]; 
assign reg_11 =clink_ptr.l_reg[11]; 
assign reg_12 =clink_ptr.l_reg[12]; 
assign reg_13 =clink_ptr.l_reg[13]; 
assign reg_14 =clink_ptr.l_reg[14]; 
assign reg_15 =clink_ptr.l_reg[15]; 

endmodule 

