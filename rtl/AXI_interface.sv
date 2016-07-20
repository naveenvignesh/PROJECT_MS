interface AXI_clks;
  logic clk,rst;
  
  modport to_rtl(input clk,input rst);
  modport from_tb(output clk,output rst);

endinterface 
interface AXI_rd_addr_ch;
  wire[3:0]   ARID;
  wire[31:0]  ARADDR;
  wire[3:0]   ARLEN;
  wire[2:0]   ARSIZE;
  wire[1:0]   ARBURST;
  wire[1:0]  ARLOCK;
  wire[3:0]  ARCACHE;
  wire[2:0]  ARPROT;
  wire  ARQOS;
  wire  ARREGION;
  wire  ARUSER;
  wire  ARVALID;
  wire  ARREADY;

modport slave_if(input ARID,input ARADDR,input ARLEN,input ARSIZE,
                 input ARBURST,input ARLOCK,input ARCACHE,input ARPROT,
                 input ARQOS,input ARREGION,input ARUSER,input ARVALID,
                 output ARREADY);
modport master_if(output ARID,output ARADDR,output ARLEN,output ARSIZE,
                  output ARBURST,output ARLOCK,  output ARCACHE,output ARPROT,
                  output ARQOS,  output ARREGION,output ARUSER,output ARVALID,
                  output ARREADY);
endinterface 
interface AXI_rd_data_ch;
  wire[3:0]   RID;
  wire[63:0]  RDATA;
  wire[1:0]   RRESP;
  wire        RLAST;
  wire        RUSER;
  wire        RVAILD;
  wire        RREADY;
  
  modport slave_if (output RID,output RDATA,output RRESP,output RLAST,
                    output RVAILD,input RREADY);
  modport master_if(input RID,input RDATA,input RRESP,input RLAST,
		    input RUSER,input RVAILD,output RREADY);  

endinterface 

interface AXI_wr_data_ch;
  wire [3:0]  WID;
  wire [63:0] WDATA;
  wire        WLAST;
  wire        WVALID;
  wire        WREADY;

  modport slave_if(input  WID,input  WDATA,input WLAST,input WVALID,output WREADY);
  modport master_if(output  WID,output  WDATA,output WLAST,output WVALID,input WREADY);

endinterface 

interface AXI_wr_addr_ch;
  wire [3:0]  AWID;
  wire [31:0] AWADDR;
  wire [3:0]  AWLEN;
  wire [2:0]  AWSIZE;
  wire [1:0]  AWBURST;
  wire [1:0]  AWLOCK;
  wire [1:0]  AWCACHE;
  wire [2:0]  AWPROT;
  wire        AWVALID;
  wire        AWREADY;

  modport slave_if (input AWID,input AWADDR,input AWLEN,input AWSIZE,
                    input  AWBURST,input AWLOCK,input AWCACHE,input  AWPROT,
                    input AWVALID,output AWREADY);
  modport master_if(output AWID,output AWADDR,output AWLEN,output AWSIZE,
                    output  AWBURST,output AWLOCK,output AWCACHE,output AWPROT,
                    output AWVALID,input AWREADY);

endinterface 

interface AXI_wr_resp_ch;
 wire[3:0] BID;
 wire[1:0] BRESP;
 wire      BUSER;
 wire      BVALID;
 wire      BREADY;

 modport slave_if(output BID,output BRESP,output BUSER,output BVALID,input BREADY);
 modport master_if(input BID,input BRESP,input BUSER,input BVALID,output BREADY);

endinterface

