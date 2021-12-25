//********************************
//Owned by : nmohapatra@wisc.edu
//********************************
  //when halt = 1'b1, PC= Same PC, don't increment
  //When halt=1'b0, PC= PC+2/BranchOp/JumpOp

module reg16b (clk, rst, en, in, out);
  // --- Inputs and Outputs ---
  input clk, rst;
  input en; // en = ~halt: when en =1: Out=InB=newPC (The actual PC to be considered for fetching the next instr from Instr Memory. Dependent on Branch and jumps)
	    //en=writeSel[*]
  input [15:0] in; 
  output [15:0] out;

  // --- Wire ---
  wire [15:0] writeEN;

  // --- Code ---
  // dff
  dff DFF[15:0] (.q(out), .d(writeEN), .clk(clk), .rst(rst));

  // mux
  mux2_1 MUX[15:0] (.InA(out), .InB(in), .S(en), .Out(writeEN));
endmodule
