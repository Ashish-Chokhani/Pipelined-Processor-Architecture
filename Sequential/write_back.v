module write_back(input clk,cnd,input [3:0] icode,rA,rB,
              input [63:0] valE,valM,output reg [63:0] rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,
              r8,r9,r10,r11,r12,r13,r14
               );

reg [63:0] R[0:14];

// writeback 
always@(posedge clk) 
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
      if(cnd)
        R[rB]=valE;
    end

    4'h3: //irmovq
    begin
      R[rB]=valE;
    end

    4'h4: //rmmovq
    begin
    end

    4'h5: //mrmovq
    begin
      R[rA] = valM;
    end
    
    4'h6: //OPq
    begin
      R[rB] = valE;
    end

    4'h7: //jXX
    begin
    end

    4'h8: //call
    begin
      R[4] = valE;
    end

    4'h9: //ret
    begin
      R[4] = valE;
    end
    
    4'hA: //pushq
    begin
      R[4] = valE;
    end

    4'hB: //popq
    begin
      R[4] = valE;
      R[rA] = valM;
    end

    endcase

    rax <= R[0];
    rcx <= R[1];
    rdx <= R[2];
    rbx <= R[3];
    rsp <= R[4];
    rbp <= R[5];
    rsi <= R[6];
    rdi <= R[7];
    r8 <= R[8];
    r9 <= R[9];
    r10 <= R[10];
    r11 <= R[11];
    r12 <= R[12];
    r13 <= R[13];
    r14 <= R[14];

end

 
endmodule