
module AXI_master ( \clks.clk , \clks.rst , \raddr_ch.ARID , \raddr_ch.ARADDR , 
        \raddr_ch.ARLEN , \raddr_ch.ARSIZE , \raddr_ch.ARBURST , 
        \raddr_ch.ARLOCK , \raddr_ch.ARCACHE , \raddr_ch.ARPROT , 
        \raddr_ch.ARQOS , \raddr_ch.ARREGION , \raddr_ch.ARUSER , 
        \raddr_ch.ARVALID , \raddr_ch.ARREADY , \rdata_ch.RID , 
        \rdata_ch.RDATA , \rdata_ch.RRESP , \rdata_ch.RLAST , \rdata_ch.RUSER , 
        \rdata_ch.RVAILD , \rdata_ch.RREADY , \waddr_ch.AWID , 
        \waddr_ch.AWADDR , \waddr_ch.AWLEN , \waddr_ch.AWSIZE , 
        \waddr_ch.AWBURST , \waddr_ch.AWLOCK , \waddr_ch.AWCACHE , 
        \waddr_ch.AWPROT , \waddr_ch.AWVALID , \waddr_ch.AWREADY , 
        \wdata_ch.WID , \wdata_ch.WDATA , \wdata_ch.WLAST , \wdata_ch.WVALID , 
        \wdata_ch.WREADY , \wresp_ch.BID , \wresp_ch.BRESP , \wresp_ch.BUSER , 
        \wresp_ch.BVALID , \wresp_ch.BREADY , rd, haddr );
  output [3:0] \raddr_ch.ARID ;
  output [31:0] \raddr_ch.ARADDR ;
  output [3:0] \raddr_ch.ARLEN ;
  output [2:0] \raddr_ch.ARSIZE ;
  output [1:0] \raddr_ch.ARBURST ;
  output [1:0] \raddr_ch.ARLOCK ;
  output [3:0] \raddr_ch.ARCACHE ;
  output [2:0] \raddr_ch.ARPROT ;
  output [3:0] \waddr_ch.AWID ;
  output [31:0] \waddr_ch.AWADDR ;
  output [3:0] \waddr_ch.AWLEN ;
  output [2:0] \waddr_ch.AWSIZE ;
  output [1:0] \waddr_ch.AWBURST ;
  output [1:0] \waddr_ch.AWLOCK ;
  output [1:0] \waddr_ch.AWCACHE ;
  output [2:0] \waddr_ch.AWPROT ;
  output [3:0] \wdata_ch.WID ;
  output [31:0] \wdata_ch.WDATA ;
  input [3:0] \wresp_ch.BID ;
  input [1:0] \wresp_ch.BRESP ;
  input [31:0] haddr;
  input \clks.clk , \clks.rst , \rdata_ch.RID , \rdata_ch.RDATA ,
         \rdata_ch.RRESP , \rdata_ch.RLAST , \rdata_ch.RUSER ,
         \rdata_ch.RVAILD , \waddr_ch.AWREADY , \wdata_ch.WREADY ,
         \wresp_ch.BUSER , \wresp_ch.BVALID , rd;
  output \raddr_ch.ARQOS , \raddr_ch.ARREGION , \raddr_ch.ARUSER ,
         \raddr_ch.ARVALID , \raddr_ch.ARREADY , \rdata_ch.RREADY ,
         \waddr_ch.AWVALID , \wdata_ch.WLAST , \wdata_ch.WVALID ,
         \wresp_ch.BREADY ;
  wire   \cur_state[0] , N19, N21, N23, N25, N27, N29, N31, N33, N35, N37, N39,
         N41, N43, N45, N47, N49, N51, N53, N55, N57, N59, N61, N63, N65, N67,
         N69, N71, N73, N75, N77, N79, N81, N83, N99, n1, n3, n5, n6, n7, n9,
         n10, n12, n13;
  tri   \clks.clk ;
  tri   \clks.rst ;
  tri   wchaddr_datain;
  tri   wchaddr_dataout;
  tri   wchaddr_depthleft;
  tri   wchaddr_full;
  tri   wchaddr_empty;
  assign \raddr_ch.ARBURST  [1] = 1'b0;
  assign \raddr_ch.ARLEN  [2] = 1'b0;
  assign \raddr_ch.ARLEN  [3] = 1'b0;
  assign \raddr_ch.ARLEN  [1] = 1'b0;
  assign \raddr_ch.ARLEN  [0] = 1'b0;
  assign \raddr_ch.ARSIZE  [2] = 1'b0;
  assign \raddr_ch.ARSIZE  [1] = 1'b0;
  assign \raddr_ch.ARSIZE  [0] = 1'b0;
  assign \raddr_ch.ARBURST  [0] = 1'b0;

  dma_fifo wchaddr_fifo ( .\clks.clk (\clks.clk ), .\clks.rst (\clks.rst ), 
        .data_in(wchaddr_datain), .data_out(wchaddr_dataout), .depth_left(
        wchaddr_depthleft), .full(wchaddr_full), .empty(wchaddr_empty) );
  dma_fifo wchdata_fifo ( .\clks.clk (\clks.clk ), .\clks.rst (\clks.rst ), 
        .data_in(wchaddr_datain), .data_out(wchaddr_dataout), .depth_left(
        wchaddr_depthleft), .full(wchaddr_full), .empty(wchaddr_empty) );
  CFD4QXL \cur_state_reg[1]  ( .D(n13), .CP(\clks.clk ), .SD(n3), .Q(n7) );
  CIVX2 U5 ( .A(\clks.rst ), .Z(n3) );
  CLDN1QXL arvalid_reg ( .D(N83), .GN(n1), .Q(\raddr_ch.ARVALID ) );
  CLDP1QXL \araddr_reg[31]  ( .G(N99), .D(N81), .Q(\raddr_ch.ARADDR [31]) );
  CLDP1QXL \araddr_reg[30]  ( .G(N99), .D(N79), .Q(\raddr_ch.ARADDR [30]) );
  CLDP1QXL \araddr_reg[29]  ( .G(N99), .D(N77), .Q(\raddr_ch.ARADDR [29]) );
  CLDP1QXL \araddr_reg[28]  ( .G(N99), .D(N75), .Q(\raddr_ch.ARADDR [28]) );
  CLDP1QXL \araddr_reg[27]  ( .G(N99), .D(N73), .Q(\raddr_ch.ARADDR [27]) );
  CLDP1QXL \araddr_reg[26]  ( .G(N99), .D(N71), .Q(\raddr_ch.ARADDR [26]) );
  CLDP1QXL \araddr_reg[25]  ( .G(N99), .D(N69), .Q(\raddr_ch.ARADDR [25]) );
  CLDP1QXL \araddr_reg[24]  ( .G(N99), .D(N67), .Q(\raddr_ch.ARADDR [24]) );
  CLDP1QXL \araddr_reg[23]  ( .G(N99), .D(N65), .Q(\raddr_ch.ARADDR [23]) );
  CLDP1QXL \araddr_reg[22]  ( .G(N99), .D(N63), .Q(\raddr_ch.ARADDR [22]) );
  CLDP1QXL \araddr_reg[21]  ( .G(N99), .D(N61), .Q(\raddr_ch.ARADDR [21]) );
  CLDP1QXL \araddr_reg[20]  ( .G(N99), .D(N59), .Q(\raddr_ch.ARADDR [20]) );
  CLDP1QXL \araddr_reg[19]  ( .G(N99), .D(N57), .Q(\raddr_ch.ARADDR [19]) );
  CLDP1QXL \araddr_reg[18]  ( .G(N99), .D(N55), .Q(\raddr_ch.ARADDR [18]) );
  CLDP1QXL \araddr_reg[17]  ( .G(N99), .D(N53), .Q(\raddr_ch.ARADDR [17]) );
  CLDP1QXL \araddr_reg[16]  ( .G(N99), .D(N51), .Q(\raddr_ch.ARADDR [16]) );
  CLDP1QXL \araddr_reg[15]  ( .G(N99), .D(N49), .Q(\raddr_ch.ARADDR [15]) );
  CLDP1QXL \araddr_reg[14]  ( .G(N99), .D(N47), .Q(\raddr_ch.ARADDR [14]) );
  CLDP1QXL \araddr_reg[13]  ( .G(N99), .D(N45), .Q(\raddr_ch.ARADDR [13]) );
  CLDP1QXL \araddr_reg[12]  ( .G(N99), .D(N43), .Q(\raddr_ch.ARADDR [12]) );
  CLDP1QXL \araddr_reg[11]  ( .G(N99), .D(N41), .Q(\raddr_ch.ARADDR [11]) );
  CLDP1QXL \araddr_reg[10]  ( .G(N99), .D(N39), .Q(\raddr_ch.ARADDR [10]) );
  CLDP1QXL \araddr_reg[9]  ( .G(N99), .D(N37), .Q(\raddr_ch.ARADDR [9]) );
  CLDP1QXL \araddr_reg[8]  ( .G(N99), .D(N35), .Q(\raddr_ch.ARADDR [8]) );
  CLDP1QXL \araddr_reg[7]  ( .G(N99), .D(N33), .Q(\raddr_ch.ARADDR [7]) );
  CLDP1QXL \araddr_reg[6]  ( .G(N99), .D(N31), .Q(\raddr_ch.ARADDR [6]) );
  CLDP1QXL \araddr_reg[5]  ( .G(N99), .D(N29), .Q(\raddr_ch.ARADDR [5]) );
  CLDP1QXL \araddr_reg[4]  ( .G(N99), .D(N27), .Q(\raddr_ch.ARADDR [4]) );
  CLDP1QXL \araddr_reg[3]  ( .G(N99), .D(N25), .Q(\raddr_ch.ARADDR [3]) );
  CLDP1QXL \araddr_reg[2]  ( .G(N99), .D(N23), .Q(\raddr_ch.ARADDR [2]) );
  CLDP1QXL \araddr_reg[1]  ( .G(N99), .D(N21), .Q(\raddr_ch.ARADDR [1]) );
  CLDP1QXL \araddr_reg[0]  ( .G(N99), .D(N19), .Q(\raddr_ch.ARADDR [0]) );
  CIVX2 U8 ( .A(N83), .Z(n6) );
  CND2X1 U44 ( .A(n6), .B(n9), .Z(N99) );
  CIVXL U3 ( .A(n7), .Z(n1) );
  CND2X1 U45 ( .A(n7), .B(n5), .Z(n9) );
  COND4CX1 U11 ( .A(rd), .B(n7), .C(n5), .D(n9), .Z(n12) );
  CNR2IXL U33 ( .B(haddr[10]), .A(n10), .Z(N39) );
  CNR2IXL U23 ( .B(haddr[20]), .A(n10), .Z(N59) );
  CNR2IXL U22 ( .B(haddr[21]), .A(n10), .Z(N61) );
  CNR2IXL U20 ( .B(haddr[23]), .A(n10), .Z(N65) );
  CNR2IXL U28 ( .B(haddr[15]), .A(n10), .Z(N49) );
  CNR2IXL U37 ( .B(haddr[6]), .A(n10), .Z(N31) );
  CNR2IXL U17 ( .B(haddr[26]), .A(n10), .Z(N71) );
  CNR2IXL U34 ( .B(haddr[9]), .A(n10), .Z(N37) );
  CNR2IXL U21 ( .B(haddr[22]), .A(n10), .Z(N63) );
  CNR2IXL U19 ( .B(haddr[24]), .A(n10), .Z(N67) );
  CNR2IXL U29 ( .B(haddr[14]), .A(n10), .Z(N47) );
  CNR2IXL U36 ( .B(haddr[7]), .A(n10), .Z(N33) );
  CNR2IXL U16 ( .B(haddr[27]), .A(n10), .Z(N73) );
  CNR2IXL U24 ( .B(haddr[19]), .A(n10), .Z(N57) );
  CNR2IXL U25 ( .B(haddr[18]), .A(n10), .Z(N55) );
  CNR2IXL U32 ( .B(haddr[11]), .A(n10), .Z(N41) );
  CNR2IXL U35 ( .B(haddr[8]), .A(n10), .Z(N35) );
  CNR2IXL U15 ( .B(haddr[28]), .A(n10), .Z(N75) );
  CNR2IXL U18 ( .B(haddr[25]), .A(n10), .Z(N69) );
  CNR2IXL U26 ( .B(haddr[17]), .A(n10), .Z(N53) );
  CNR2IXL U30 ( .B(haddr[13]), .A(n10), .Z(N45) );
  CNR2IXL U27 ( .B(haddr[16]), .A(n10), .Z(N51) );
  CNR2IXL U31 ( .B(haddr[12]), .A(n10), .Z(N43) );
  CNR2IXL U41 ( .B(haddr[2]), .A(n10), .Z(N23) );
  CNR2IXL U43 ( .B(haddr[0]), .A(n10), .Z(N19) );
  CNR2IXL U42 ( .B(haddr[1]), .A(n10), .Z(N21) );
  CNR2IXL U12 ( .B(haddr[31]), .A(n10), .Z(N81) );
  CNR2IXL U38 ( .B(haddr[5]), .A(n10), .Z(N29) );
  CNR2IXL U14 ( .B(haddr[29]), .A(n10), .Z(N77) );
  CNR2IXL U40 ( .B(haddr[3]), .A(n10), .Z(N25) );
  CNR2IXL U39 ( .B(haddr[4]), .A(n10), .Z(N27) );
  CNR2IXL U13 ( .B(haddr[30]), .A(n10), .Z(N79) );
  CFD2XL \cur_state_reg[0]  ( .D(n12), .CP(\clks.clk ), .CD(n3), .Q(
        \cur_state[0] ), .QN(n5) );
  CND2X1 U54 ( .A(\cur_state[0] ), .B(n7), .Z(n10) );
  CNR2IX1 U55 ( .B(rd), .A(n10), .Z(N83) );
  CAN2X1 U56 ( .A(n7), .B(n6), .Z(n13) );
endmodule

