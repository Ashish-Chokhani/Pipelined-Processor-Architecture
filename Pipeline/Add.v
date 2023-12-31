`include "full_adder.v"

module Add (output [63:0] Sout,output Cout, OF,input [63:0] A, B,input Cin);

    wire [64:0] Carry;
	assign Carry[0] = Cin;

	genvar i;

	generate for(i = 0; i < 64; i = i+1) 
        begin
            full_adder fa(Sout[i], Carry[i+1],A[i],B[i], Carry[i]);
        end
    endgenerate

    assign Cout = Carry[64];
	xor (OF, Carry[64], Carry[63]);

endmodule