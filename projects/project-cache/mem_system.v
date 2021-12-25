/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;
   
   output [15:0] DataOut;
   output Done;
   output Stall;
   output CacheHit;
   output err;

   // needed wires
   wire err_c, err_m;
   wire stall_dummy, wr_m, rd_m, hit_c, dirty_c, valid_c, enable_ct, cmp_ct, wr_ct, valid_in_ct, final_state;
   wire [3:0] Busy_dummy;
   wire [15:0] data_out_m, data_in_m, addr_in_m, data_in_ct, DataOut_cache, DataOut_ct, dataout_temp;
   wire [4:0] tag_out_c, tag_ct;
   wire [7:0] index_ct;
   wire [2:0] offset_ct;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out_c),
                          .data_out             (DataOut_cache),
                          .hit                  (hit_c),
                          .dirty                (dirty_c),
                          .valid                (valid_c),
                          .err                  (err_c),
                          // Inputs
                          .enable               (enable_ct),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (tag_ct),
                          .index                (index_ct),
                          .offset               (offset_ct),
                          .data_in              (data_in_ct),
                          .comp                 (cmp_ct),
                          .write                (wr_ct),
                          .valid_in             (valid_in_ct));

   four_bank_mem mem(// Outputs
       	                  .data_out          (data_out_m),
       	                  .stall             (stall_dummy),
       	                  .busy              (Busy_dummy),
       	                  .err               (err_m),
       	                  // Inputs
       	                  .clk               (clk),
       	                  .rst               (rst),
       	                  .createdump        (createdump),
       	                  .addr              (addr_in_m),
       	                  .data_in           (data_in_m),
       	                  .wr                (wr_m),
       	                  .rd                (rd_m));

   
   // your code here
cache_controller ctrl(
			// Input from system
		       	  .clk		(clk), 
			  .rst		(rst), 
			  .creat_dump	(createdump), 
			  .Data_latch	(dataout_temp), 
			  // Input from mem
			  .Addr		(Addr), 
			  .DataIn	(DataIn), 
			  .Rd		(Rd), 
			  .Wr		(Wr),
			  // Input from cache
			  .hit		(hit_c), 
			  .dirty	(dirty_c), 
			  .tag_out	(tag_out_c), 
			  .DataOut_cache(DataOut_cache), 
			  .valid	(valid_c),
			  // Input from four bank
			  .DataOut_mem	(data_out_m),
			  // Output to cache
			  .enable_ct	(enable_ct), 
			  .index_cache	(index_ct),
			  .offset_cache	(offset_ct), 
			  .cmp_ct	(cmp_ct),
			  .wr_cache	(wr_ct), 
			  .tag_cache	(tag_ct),
			  .DataIn_ct	(data_in_ct), 
			  .valid_in_ct	(valid_in_ct),
			  // Output to fourbank
			  .Addr_mem	(addr_in_m), 
			  .DataIn_mem	(data_in_m),
			  .wr_mem	(wr_m), 
			  .rd_mem	(rd_m),
			  // Output to system
			  .Done		(Done), 
			  .CacheHit	(CacheHit), 
			  .Stall_sys	(Stall), 
			  .DataOut_ct	(DataOut_ct), 
			  .final_state	(final_state)
);

assign err = err_c | err_m;
wire err_reg;
reg_16 #(.SIZE(16)) latch_DataOut(.readData(dataout_temp), .err(err_reg), .clk(clk), .rst(rst), .writeData(DataOut_ct), .writeEn(1'b1));

assign DataOut = final_state ? (DataOut_ct) : (dataout_temp);

endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
