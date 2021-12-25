module reg_16 (
                // Outputs
                readData, err,
                // Inputs
                clk, rst, writeData, writeEn
                );
   
   parameter SIZE = 16;
   
   input         clk, rst, writeEn;
   input[SIZE-1:0]  writeData;

   output         err;
   output [SIZE-1:0] readData;

   /* YOUR CODE HERE */
   wire[SIZE-1:0] in;
   assign in = (writeEn) ? writeData : readData;

   dff ff[SIZE-1:0](.q(readData) ,.d(in), .clk(clk), .rst(rst));   
   
   // err_checker checker(.err(err),.writeData(writeData), .writeEn(writeEn));   
   wire err_temp;
   assign err_temp = ^{writeEn, writeData};
   assign err = (err_temp === 1'bx);

endmodule
