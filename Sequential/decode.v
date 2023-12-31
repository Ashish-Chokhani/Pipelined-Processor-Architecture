module decode(input [3:0] icode,rA,rB,
              output reg [63:0] valA,valB);

reg [63:0] R[0:14];

integer i=0;

// initializing with random values
initial 
begin
    for(i = 0; i < 15; i = i + 1)
    begin
        R[i]=i+1;
    end
end

always@*
begin
    case(icode)
    4'h0: //halt
    begin
    end

    4'h1: //nop
    begin
    end

    4'h2: //cmovxx
    begin
        valA=R[rA];
        valB=64'b0;
    end

    4'h3: //irmovq
    begin
        valB=64'b0;
    end

    4'h4: //rmmovq
    begin
        valA=R[rA];
        valB=R[rB];
    end

    4'h5: //mrmovq
    begin
        valB=R[rB];
    end

    4'h6: //OPq
    begin
        valA=R[rA];
        valB=R[rB];
    end

    4'h7: //jxx dest
    begin
    end

    4'h8: //call
    begin
        valB=R[4]; 
    end

    4'h9: //ret
    begin
        valA=R[4]; 
        valB=R[4];
    end

    4'hA: //pushq
    begin
        valA=R[rA];
        valB=R[4];
    end

    4'hB: //popq
    begin
        valA=R[4]; 
        valB=R[4];
    end
    endcase
end

 
endmodule