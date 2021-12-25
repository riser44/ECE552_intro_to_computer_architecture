//********************************
//Owned by : nmohapatra@wisc.edu
//********************************

module proc (
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here */

  // --- Wires --- 
  wire err_execute, err_decode;

  // Fetch
  wire [15:0] instr;
  wire halt;
  wire [15:0] newPC; //The actual PC to be considered for fetching the next instr from Instr Memory. Dependent on Branch and jumps
  wire [15:0] nextPC;//nextPC = PC+2 (real increment by 2 done in fetch)


  // Decode
  wire [15:0] SExt5, ZExt5, SExt8, ZExt8, SExt11;
  wire SExt;
  wire [15:0] A, B;
  wire [1:0] sourceALU;
  wire nA, nB, Cin;
  wire siic;

  // Execute
  wire [15:0] aluResult;
  wire enJAL;

  // WB
  wire [15:0] readData, writeData;
  wire memWrite;
  wire mem_to_reg;

  // --- Code ---
  assign err = 1'b0;

  fetch fetch0 (
    .newPC		(newPC), 	//input	[15:0]
    .halt		(halt), 	//input	
    .clk		(clk), 		//input
    .rst		(rst), 		//input
    .nextPC		(nextPC), 	//output [15:0]
    .instr		(instr)		//output [15:0]
  );

  decode decode0 (
    .instr		(instr), 	//input [15:0]
    .writeData		(writeData), 	//input	[15:0]
    .clk		(clk), 		//input
    .rst		(rst),		//input
    .SExt5		(SExt5), 	//output [15:0]	
    .ZExt5		(ZExt5), 	//output [15:0]	
    .SExt8		(SExt8), 	//output [15:0]	
    .ZExt8		(ZExt8), 	//output [15:0]	
    .SExt11		(SExt11),	//output [15:0] 	
    .SExt		(SExt),		//output
    .A			(A), 		//output [15:0]
    .B			(B), 		//output [15:0]
    .sourceALU		(sourceALU), 	//output [1:0]
    .memWrite		(memWrite), 	//output
    .mem_to_reg		(mem_to_reg), 	//output
    .nA			(nA), 		//output	
    .nB			(nB), 		//output	
    .Cin		(Cin), 		//output	
    .halt		(halt)		//output	
  );

  execute execute0 (
    .instr		(instr),	//input	[15:0] 
    .A			(A), 		//input	[15:0]
    .B			(B),    	//input	[15:0]	 
    .nextPC		(nextPC),	//input	[15:0] 	
    .SExt5		(SExt5),	//input	[15:0] 	
    .ZExt5		(ZExt5),	//input	[15:0] 	
    .SExt8		(SExt8),	//input	[15:0] 	
    .ZExt8		(ZExt8),	//input	[15:0] 	
    .SExt11		(SExt11), 	//input	[15:0]	
    .SExt		(SExt),		//input
    .sourceALU		(sourceALU), 	//input	[1:0]
    .nA			(nA), 		//input
    .nB			(nB), 		//input
    .Cin		(Cin), 		//input
    .aluResult		(aluResult), 	//output [15:0]
    .newPC		(newPC), 	//output [15:0]
    .enJAL		(enJAL)		//output
  );

  memory memory0 (
    .writeData		(B), 		//input [15:0] 
    .aluResult		(aluResult), 	//input [15:0]
    .memRead		(mem_to_reg),	//input 
    .memWrite		(memWrite),	//input 
    .halt		(halt), 	//input
    .clk		(clk),		//input 
    .rst		(rst),		//input 
    .readData		(readData)	//output [15:0]
  );

  write_back wb0 (
    .aluResult		(aluResult),	//input [15:0] 
    .readData		(readData),	//input	[15:0] 
    .nextPC		(nextPC),	//input	[15:0] 
    .enJAL		(enJAL),	//input 
    .mem_to_reg		(mem_to_reg),	//input 
    .writeData		(writeData)	//output [15:0]
  );
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
