//********************************
//Owned by : nmohapatra@wisc.edu
//********************************

module decode (
	 instr,
	 writeData,
	 clk,
	 rst,
	 SExt5,
	 ZExt5,
	 SExt8,
	 ZExt8,
	 SExt11,
	 SExt,
	 A,
	 B,
	 sourceALU,
	 memWrite,
	 mem_to_reg,
	 nA,
	 nB,
	 Cin,
	 halt);
  // --- Inputs --- //
  input [15:0] instr;
  input [15:0] writeData;
  input clk, rst;

  // --- Outputs --- //
  output [15:0] SExt5, ZExt5, SExt8, ZExt8, SExt11;
  output SExt;
  output [15:0] A, B;
  output [1:0] sourceALU;
  output memWrite, mem_to_reg;
  output nA, nB, Cin;
  output halt;

  // --- Wires --- //
  wire ctrl_err, rf_err;
  wire regWrite;
  wire [1:0] regDestination;
  wire [2:0] writeregsel;

  // CPU control logic
  control CONTROL (
		 .instr			(instr),
		 .sourceALU		(sourceALU),
		 .regDestination	(regDestination),
		 .memWrite		(memWrite),
		 .regWrite		(regWrite),
		 .mem_to_reg		(mem_to_reg),
		 .nA			(nA),
		 .nB			(nB),
		 .Cin			(Cin),
		 .SExt			(SExt),
		 .halt			(halt)
		);
  // Get data from chosen reg
  mux4_1_3b SEL_REG (
		 .InA			(instr[4:2]),
		 .InB			(instr[7:5]),
		 .InC			(instr[10:8]),
		 .InD			(3'b111),
		 .S			(regDestination),
		 .Out			(writeregsel)
		);
  rf regFile0 (
		 .read1data		(A),
		 .read2data		(B),
		 .clk			(clk),
		 .rst			(rst),
		 .read1regsel		(instr[10:8]),
		 .read2regsel		(instr[7:5]),
		 .writeregsel		(writeregsel),
		 .writedata		(writeData),
		 .write			(regWrite)
		);

  // Extend
  assign SExt5 = {{11{instr[4]}}, instr[4:0]};
  assign ZExt5 = {{11{1'b0}}, instr[4:0]};
  assign SExt8 = {{8{instr[7]}}, instr[7:0]};
  assign ZExt8 = {{8{1'b0}}, instr[7:0]};
  assign SExt11 = {{5{instr[10]}}, instr[10:0]};
endmodule
