module eth_tx(AXI_clks.to_rtl clks,
              AXI_rd_addr_ch.slave_if r_ach,
              AXI_rd_data_ch.slave_if r_dch,
              AXI_wr_addr_ch.slave_if w_ach,
              AXI_wr_data_ch.slave_if w_dch,
              AXI_wr_resp_ch.slave_if w_rspch );

  wire [31:0] reg_write_addr;
  wire [63:0] reg_write_data;
  wire wr_en;
  clink_regs linkregs;
   //dma_controller_tx tx_regs
                            
 dma_controller_tx dma_reg_tx(
                         .clks (clks),
                         .slave_addr(reg_write_addr),
                         .slave_data(reg_write_data),
                         .wr_en(wr_en),
                         .linkregs (linkregs));
                            
                            
                            
                            
   AXI_slave         axi_slave       ( .clks (clks),
                                       .r_ach(r_ach),
                                       .r_dch(r_dch),
                                       .w_ach(w_ach),
                                       .w_dch(w_dch),
                                       .w_rspch(w_rspch),
                                       .reg_write_data(reg_write_data), 
                                       .reg_write_addr(reg_write_addr),
                                       .wr_en(wr_en));
                  
 endmodule 
