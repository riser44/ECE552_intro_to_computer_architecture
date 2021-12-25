//********************************
//Owned by : nmohapatra@wisc.edu
//********************************


module reg16b (clk, rst, en, in, out);
  // --- Inputs and Outputs ---
  input clk, rst;
  input en; // flag for write
  input [15:0] in; // write
  output [15:0] out; // read

  // --- Wire ---
  wire [15:0] writeEN;

  // --- Code ---
  // dff
  dff DFF[15:0] (.q(out), .d(writeEN), .clk(clk), .rst(rst));

  // mux
  mux2_1 MUX[15:0] (.InA(out), .InB(in), .S(en), .Out(writeEN));
endmodule

