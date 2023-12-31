//`include "Add.v"
`include "Sub.v"
`include "Xor.v"
`include "And.v"

module ALU(output reg [63:0] Sout,output Cout,output reg OF,input [63:0] A, B,input [1:0] state);

wire [63:0] out_Add, out_Sub, out_And, out_Xor;
wire AddOF,SubOF;

Add ADD(out_Add, Cout, AddOF, A, B,1'b0);
Sub SUB(out_Sub, Cout,SubOF,A,B,1'b1);
And AND(out_And, A, B);
Xor XOR(out_Xor, A, B);

always @*
begin
    case(state)
    2'b00 : begin
               Sout = out_Add;
               OF = AddOF;
            end
    2'b01 : begin
               Sout = out_Sub;
               OF =SubOF;
            end
    2'b10 : Sout = out_And;
    2'b11 : Sout = out_Xor;
    endcase
end
endmodule