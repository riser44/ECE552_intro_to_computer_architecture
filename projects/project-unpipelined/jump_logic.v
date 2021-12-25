//********************************
//Owned by : nmohapatra@wisc.edu
//********************************

module jump_logic (
			op, 
			enJMP, 
			enJR, 
			enJAL
			);
  // --- Inputs --- //
  input [4:0] op;

  // --- Outputs --- //
  output reg enJMP;
  output reg enJR;
  output reg enJAL;

  // --- Code --- //
  always @(*) begin
    case (op)
      // J
      5'b00100: begin
        enJMP = 1'b1;
        enJR = 1'b0;
        enJAL = 1'b0;
      end
      // JR
      5'b00101: begin
        enJMP = 1'b0;
        enJR = 1'b1;
        enJAL = 1'b0;
      end
      // JAL
      5'b00110: begin
        enJMP = 1'b1;
        enJR = 1'b0;
        enJAL = 1'b1;
      end
      // JALR
      5'b00111: begin
        enJMP = 1'b0;
        enJR = 1'b1;
        enJAL = 1'b1;
      end
      default: begin
        enJMP = 1'b0;
        enJR = 1'b0;
        enJAL = 1'b0;
      end
    endcase
  end
endmodule
