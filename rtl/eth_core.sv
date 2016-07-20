module eth_core(AXI_clks.to_rtl clks,
                AXI_rd_addr_ch.slave_if r_ach,
                AXI_rd_data_ch.slave_if r_dch,
                AXI_wr_addr_ch.slave_if w_ach,
                AXI_wr_data_ch.slave_if w_dch,
                AXI_wr_resp_ch.slave_if w_rspch );

eth_tx tx_core   ( clks,
                   r_ach,
                   r_dch,
                   w_ach,
                   w_dch,
                   w_rspch );


endmodule 
