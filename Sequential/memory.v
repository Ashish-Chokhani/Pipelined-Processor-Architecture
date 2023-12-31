module memory(input clk,input wire [3:0] icode,input wire [63:0] valA, valB, valP, valE,output reg [63:0] valM);

reg [63:0]  M[0:127];

integer i=0;

initial 
begin
    for(i = 0; i < 127; i = i + 1)
    begin
        M[i]=i+1;
    end
end

always @(*)
begin
    case(icode)
    4'h5: //mrmovq
    begin 
        valM = M[valE];
    end

    4'h9: //ret
    begin 
        valM = M[valA];
    end

    4'hB: //popq
    begin 
        valM = M[valA];
    end
    endcase
end

always @(posedge clk) 
begin
    case(icode)
    4'h4: //rmmovq
    begin 
        M[valE] = valA; 
    end

    4'h8: //call
    begin 
        M[valE] = valP; 
    end

    4'hA: //pushq
    begin 
        M[valE] = valA; 
    end
    endcase
end

endmodule