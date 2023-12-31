`include "Add.v"

module Sub(output [63:0] Sout,output Cout, OF ,input [63:0] A, B,input Cin);

    wire [63:0] B_c;

    genvar i;

    for(i = 0; i < 64; i = i + 1) 
    begin
        not(B_c[i], B[i]);
    end  

    Add Subtract(Sout,Cout,OF, A, B_c, Cin);

endmodule