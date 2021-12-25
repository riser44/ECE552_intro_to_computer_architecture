module cache_controller(
	// Input from system
	clk,rst,creat_dump,Data_latch,
	// Input from mem
	Addr,DataIn,Rd,Wr,
	// Input from cache
	hit,dirty,tag_out,DataOut_cache,valid,
	// Input from four bank
	DataOut_mem,
	// Output to cache
	enable_ct,index_cache,
	offset_cache,cmp_ct,
	wr_cache,tag_cache,
	DataIn_ct,valid_in_ct,
	// Output to fourbank
	Addr_mem,DataIn_mem,
	wr_mem,rd_mem,
	// Output to system
	Done,CacheHit,Stall_sys, DataOut_ct, final_state
);

// Input, output
input clk, rst, creat_dump, Wr, Rd, hit, dirty, valid;
input [15:0] Addr, DataIn, DataOut_mem, DataOut_cache, Data_latch;
input [4:0] tag_out;

output reg enable_ct, cmp_ct, wr_cache, valid_in_ct, wr_mem, rd_mem, Done, CacheHit, Stall_sys, final_state;
output reg[15:0] DataIn_ct, Addr_mem, DataIn_mem, DataOut_ct;
output reg[7:0] index_cache;
output reg[2:0] offset_cache;
output reg[4:0] tag_cache;


// define states
localparam IDLE = 4'b0000; // 0 
localparam DONE = 4'b0001; // 1
localparam CMP_RD_0 = 4'b0010; // 2
localparam CMP_WT_0 = 4'b0011; // 3
localparam ACC_RD_0 = 4'b0100; // 4
localparam ACC_RD_1 = 4'b0101; // 5
localparam ACC_RD_2 = 4'b0110; // 6
localparam ACC_RD_3 = 4'b0111; // 7
localparam ACC_WT_0 = 4'b1000; // 8
localparam ACC_WT_1 = 4'b1001; // 9
localparam ACC_WT_2 = 4'b1010; // a
localparam ACC_WT_3 = 4'b1011; // b
localparam ACC_WT_4 = 4'b1100; // c
localparam ACC_WT_5 = 4'b1101; // d

// ff for state machine
wire err_reg;
wire [3:0] state, state_q;
reg [3:0] next_state;
reg_16 #(.SIZE(4)) state_fsm(.readData(state_q), .err(err_reg), .clk(clk), .rst(rst), .writeData(next_state), .writeEn(1'b1));
assign state = rst ? IDLE : state_q;

wire trueHit_q;
reg trueHit;
reg_16 #(.SIZE(1)) hit_track(.readData(trueHit_q), .err(err_reg), .clk(clk), .rst(rst), .writeData(trueHit), .writeEn(1'b1));

wire isWr_q;
reg isWr;
reg_16 #(.SIZE(1)) Wr_track(.readData(isWr_q), .err(err_reg), .clk(clk), .rst(rst), .writeData(isWr), .writeEn(1'b1));

wire isRd_q;
reg isRd;
reg_16 #(.SIZE(1)) Rd_track(.readData(isRd_q), .err(err_reg), .clk(clk), .rst(rst), .writeData(isRd), .writeEn(1'b1));


reg err_fsm;
// FSM
always @* 
	begin
		enable_ct = 1'b0;
		index_cache = 8'bxxxx_xxxx;
		offset_cache = 3'bxxx;
		cmp_ct = 1'b0;
		wr_cache = 1'b0;
		tag_cache = 5'bxxxx_x;
		DataIn_ct = 16'bxxxx_xxxx_xxxx_xxxx;
		valid_in_ct = 1'b0;
		Addr_mem = 16'bxxxx_xxxx_xxxx_xxxx;
		DataIn_mem = 16'bxxxx_xxxx_xxxx_xxxx; 
		wr_mem = 1'b0;
		rd_mem = 1'b0;
		Done = 1'b0;
		CacheHit = 1'b0;
		Stall_sys = 1'b1;
		err_fsm = 1'b0;
		final_state = 1'b0;

		case(state)
			default: err_fsm = 1'b1;
			IDLE:
				begin
					Stall_sys = 1'b0;
                    isWr = 1'b0;
                    isRd = 1'b0;
					next_state = Rd ? (CMP_RD_0) : (Wr ? (CMP_WT_0) : (state));
				end
			CMP_RD_0:
				begin
					enable_ct = 1'b1;
					cmp_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = Addr[2:0];
					tag_cache = Addr[15:11];
					DataOut_ct = DataOut_cache;
					trueHit = 1'b1;
                    isRd = 1'b1;
					next_state = hit ? (valid ? (DONE) : (ACC_WT_0)) : (dirty ? (valid ? (ACC_RD_0) : (ACC_WT_0)) : (ACC_WT_0));
				end
			CMP_WT_0:
				begin
					enable_ct = 1'b1;
					cmp_ct = 1'b1;
					wr_cache = 1'b1;
					DataIn_ct = DataIn;
					index_cache = Addr[10:3];
					offset_cache = Addr[2:0];
					tag_cache = Addr[15:11];
					trueHit = 1'b1;
                    isWr = 1'b1;
					next_state = hit ? (valid ? (DONE) : (ACC_WT_0)) : (dirty ? (valid ? (ACC_RD_0) : (ACC_WT_0)) : (ACC_WT_0));
				end
			DONE:
				begin
					Done = 1'b1;
					CacheHit = trueHit_q ? 1'b1 : 1'b0;
					next_state = IDLE;
				end
			ACC_RD_0:
				begin
					enable_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b000;
					Addr_mem = {tag_out,Addr[10:3],3'b000};
					DataIn_mem = DataOut_cache;
					wr_mem = 1'b1;
					next_state = ACC_RD_1;
				end
			ACC_RD_1:
				begin
					enable_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b010;
					Addr_mem = {tag_out,Addr[10:3],3'b010};
					DataIn_mem = DataOut_cache;
					wr_mem = 1'b1;
					next_state = ACC_RD_2;
				end
			ACC_RD_2:
				begin
					enable_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b100;
					Addr_mem = {tag_out,Addr[10:3],3'b100};
					DataIn_mem = DataOut_cache;
					wr_mem = 1'b1;
					next_state = ACC_RD_3;
				end
			ACC_RD_3:
				begin
					enable_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b110;
					Addr_mem = {tag_out,Addr[10:3],3'b110};
					DataIn_mem = DataOut_cache;
					wr_mem = 1'b1;
					next_state = ACC_WT_0;
				end
			ACC_WT_0:
				begin
					enable_ct = 1'b1;
					rd_mem = 1'b1;
					Addr_mem = {Addr[15:3],3'b000};
					trueHit = 1'b0;
					next_state = ACC_WT_1;
				end
			ACC_WT_1:
				begin
					enable_ct = 1'b1;
					rd_mem = 1'b1;
					Addr_mem = {Addr[15:3],3'b010};
					next_state = ACC_WT_2;
				end
			ACC_WT_2:
				begin
				    // read from mem
					enable_ct = 1'b1;
					rd_mem = 1'b1;
					Addr_mem = {Addr[15:3],3'b100};
					// wrt to cache
					wr_cache = 1'b1;
					valid_in_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b000;
					tag_cache = Addr[15:11];
					DataIn_ct = (Wr & (Addr[2:0] === 3'b000)) ? DataIn : DataOut_mem;
					DataOut_ct = (Rd & (Addr[2:0] === 3'b000)) ? DataOut_mem : Data_latch;
					next_state = ACC_WT_3;
				end
			ACC_WT_3:
				begin
				    // read from mem
					enable_ct = 1'b1;
					rd_mem = 1'b1;
					Addr_mem = {Addr[15:3],3'b110};
					// wrt to cache
					wr_cache = 1'b1;
					valid_in_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b010;
					tag_cache = Addr[15:11];
					DataIn_ct = (Wr & (Addr[2:0] === 3'b010)) ? DataIn : DataOut_mem;
					DataOut_ct = (Rd & (Addr[2:0] === 3'b010)) ? DataOut_mem : Data_latch;
					next_state = ACC_WT_4;
				end
			ACC_WT_4:
				begin
					// wrt to cache
					enable_ct = 1'b1;
					wr_cache = 1'b1;
					valid_in_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b100;
					tag_cache = Addr[15:11];
					DataIn_ct = (Wr & (Addr[2:0] === 3'b100)) ? DataIn : DataOut_mem;
					DataOut_ct = (Rd & (Addr[2:0] === 3'b100)) ? DataOut_mem : Data_latch;
					next_state = ACC_WT_5;
				end
			ACC_WT_5:
				begin
					// wrt to cache
					enable_ct = 1'b1;
					cmp_ct = isWr_q ? 1'b1 : 1'b0; 
					wr_cache = 1'b1;
					valid_in_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b110;
					tag_cache = Addr[15:11];
					DataIn_ct = (isWr_q & (Addr[2:0] === 3'b110)) ? DataIn : DataOut_mem;
					DataOut_ct = (isRd_q & (Addr[2:0] === 3'b110)) ? DataOut_mem : Data_latch;
                    Done = 1'b1;
					next_state = IDLE;
					final_state = 1'b1; 
				end
		endcase
	end


endmodule
