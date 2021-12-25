//********************************
//Owned by : nmohapatra@wisc.edu
//********************************


module cla16 (A, B, Cin, sum, Cout, Pout, Gout);
  // --- Inputs---
  input [15:0] A, B;
  input Cin;

  // --- Outputs ---
  output [15:0] sum;
  output Cout, Pout, Gout;

  // --- Wires ---
  wire [15:0] carry_out;
  wire [3:0] P, G, C;

  // --- Code ---
  // instantiate cla4
  cla4 cla0 (.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .sum(sum[3:0]), .Cout(C[0]), .Pout(P[0]), .Gout(G[0]));
  cla4 cla1 (.A(A[7:4]), .B(B[7:4]), .Cin(C[0]), .sum(sum[7:4]), .Cout(C[1]), .Pout(P[1]), .Gout(G[1]));
  cla4 cla2 (.A(A[11:8]), .B(B[11:8]), .Cin(C[1]), .sum(sum[11:8]), .Cout(C[2]), .Pout(P[2]), .Gout(G[2]));
  cla4 cla3 (.A(A[15:12]), .B(B[15:12]), .Cin(C[2]), .sum(sum[15:12]), .Cout(Cout), .Pout(P[3]), .Gout(G[3]));

  // Prop
  assign Pout = &P;

  // Gen
  assign Gout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & (G[1] | (P[1] & G[0])));
endmodule
