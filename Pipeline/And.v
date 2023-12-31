module And(output [63:0] out,input [63:0] A,B);

    genvar i;

    for(i = 0; i < 64; i = i + 1) 
    begin
        and(out[i], A[i], B[i]);
    end

endmodule