//********************************
//Owned by : nmohapatra@wisc.edu
//********************************
module cla4(A, B, Cin, sum, Cout, Pout, Gout);
  // --- Inputs ---
  input [3:0] A, B;
  input Cin;

  // --- Outputs ---
  output [3:0] sum;
  output Cout, Pout, Gout;

  // --- Wires ---
  wire [3:0] C, P, G;

  // --- Code ---
  // Prop
  assign P = A | B;
  assign Pout = &P;

  // Gen
  assign G = A & B;
  assign Gout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);

  // Carry
  assign C[0] = Cin;
  assign C[1] = G[0] | (P[0] & C[0]);
  assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
  assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
  assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C[0]);

  // find sum
  assign sum = A ^ B ^ C;
endmodule
