`include "ALU.v"
module execute(input [3:0] icode,ifun,input [63:0] valA,valB,valC,input [2:0] in_CC,output reg cnd,output reg [63:0] valE,output reg [2:0] out_CC);

wire cout,ZF, SF, OF,_OF;
assign ZF = in_CC[0];
assign SF = in_CC[1];
assign OF = in_CC[2];

wire [63:0] valE_;
reg [1:0] control;
reg [63:0] _valAC1;

always@*
begin
    case(icode)
        4'h2:
        begin
            control <= 2'b0;
            _valAC1 <= valA;
        end

        4'h3:
        begin
            control <= ifun[1:0];
            _valAC1 <= valC;
        end

        4'h4: 
        begin
            control <= ifun[1:0];
            _valAC1 <= valC;
        end

        4'h5:
        begin
            control <= ifun[1:0];
            _valAC1 <= valC;
        end

        4'h6:
        begin
            control <= ifun[1:0];
            _valAC1 <= valA;
        end

        4'h8:
        begin
            control <= 2'b1;
            _valAC1 <= 64'd1;
        end

        4'h9:
        begin
            control <= 2'b0;
            _valAC1 <= 64'd1;
        end

        4'hA:
        begin
            control <= 2'b1;
            _valAC1 <= 64'd1;
        end

        4'hB:
        begin
            control <= 2'b0;
            _valAC1 <= 64'd1;
        end

        default:
            valE = 0;
    endcase
end

ALU ALU(valE_,cout,_OF,_valAC1,valB,control);

always @*
begin
    valE<=valE_;
    
    if(icode == 4'h6)
    begin
        out_CC[2] <= _OF;
        out_CC[1] <= valE[63];
        out_CC[0] <= valE ? 0:1;
    end
end

always @*
begin
    case (ifun)
        4'h0: cnd = 1;                       // unconditional
        4'h1: cnd = (OF^SF)|ZF;              // le/ng
        4'h2: cnd = OF^SF;                   // l/nge
        4'h3: cnd = ZF;                      // e/z
        4'h4: cnd = ~ZF;                     // ne/nz
        4'h5: cnd = ~(SF^OF);                // ge/nl
        4'h6: cnd = ~(SF^OF)&~ZF;            // g/nle

        default:
        cnd=0;
    endcase
end

endmodule