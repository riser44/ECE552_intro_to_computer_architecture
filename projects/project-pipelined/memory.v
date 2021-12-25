//********************************
//Owned by : nmohapatra@wisc.edu
//********************************


module memory (
		writeData, 
		aluResult, 
		memRead, 
		memWrite, 
		halt, 
		clk, 
		rst, 
		readData
		);
  // --- Inputs ---
  input [15:0] writeData;
  input [15:0] aluResult;
  input memRead, memWrite;
  input halt;
  input clk, rst;

  // --- Outputs ---
  output [15:0] readData;

  // --- Wires ---
  wire memReadorWrite;

  // --- Code ---
  assign memReadorWrite = memRead | memWrite;

  // Data Memory
  memory2c DATA_MEM (.data_out(readData), .data_in(writeData), .addr(aluResult), .enable(memReadorWrite), .wr(memWrite), .createdump(halt), .clk(clk), .rst(rst));
endmodule
