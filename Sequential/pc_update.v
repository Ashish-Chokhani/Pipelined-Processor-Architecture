module pc_update(input clk,cnd,input [3:0] icode,input [63:0] valC,valM,valP,output reg [63:0] PC);

always@(posedge clk)
begin
    case(icode)
        4'h0: PC <= 0;
        4'h7: PC <= cnd ? valC:valP;
        4'h8: PC <= valC;
        4'h9: PC <= valM;
        default: PC <= valP;
    endcase
end
endmodule