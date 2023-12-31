module decode(input clk,E_bubble,input [1:0] D_stat,
              input [3:0] D_icode,D_ifun,D_rA,D_rB,e_dstE,M_dstE,M_dstM,W_icode,W_dstE,W_dstM,
              input [63:0] D_valC,D_valP,e_valE,M_valE,m_valM,W_valE,W_valM,
              output reg [1:0] E_stat,output reg [3:0] E_icode,E_ifun,
              E_srcA,E_srcB,E_dstE,E_dstM,d_srcA,d_srcB,
              output reg[63:0] E_valA,E_valB,E_valC,rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,
              r8,r9,r10,r11,r12,r13,r14
              );

  reg [63:0] d_valA,d_valB;
  reg [3:0] d_dstE,d_dstM;
  reg [63:0] R[0:14];

 integer i=0;
// initializing with random values
initial 
begin
    for(i = 0; i < 15; i = i + 1)
    begin
      if(i!=4)
        R[i]=i+1;
      else
        R[i]=0;
    end
end

  initial
  begin
    d_srcA = 4'hF;
    d_srcB = 4'hF;
    d_dstE = 4'hF;
    d_dstM = 4'hF;
  end

  always@*
    begin
    case (D_icode) 
      4'h0:
      begin
      end

      4'h1:
      begin
      end     

      4'h2: //cmovq
      begin
        d_valA=R[D_rA];
        d_valB=64'b0;
      end    

      4'h3: //irmovq
      begin
        d_valB=64'b0;
      end   

      4'h4: //rmmovq
      begin
        d_valA=R[D_rA];
        d_valB=R[D_rB];
      end

      4'h5: //mrmovq
      begin
        d_valB=R[D_rB];
      end

      4'h6: //OPq
      begin
        d_valA=R[D_rA];
        d_valB=R[D_rB];
      end

      4'h7:
      begin
      end 

      4'h8: //call
      begin
        d_valB=R[4]; 
      end

      4'h9: //ret
      begin
        d_valA=R[4]; 
        d_valB=R[4];
      end

      4'hA: //pushq
      begin
        d_valA=R[D_rA];
        d_valB=R[4];
      end    
      
      4'hB: //popq
      begin
        d_valA=R[4]; 
        d_valB=R[4];
      end
    endcase
    end

  always@*
  begin
    case (D_icode)
      4'h0:
      begin
      end    

      4'h1:
      begin
      end    

      4'h2:
      begin
        d_srcA = D_rA;
        d_dstE = D_rB;
      end

      4'h3: 
      begin
        d_dstE = D_rB;
      end

      4'h4: 
      begin
        d_srcA = D_rA;
        d_srcB = D_rB;
      end

      4'h5: 
      begin
        d_srcB = D_rB;
        d_dstM = D_rA;
      end

      4'h6: 
      begin
        d_srcA = D_rA;
        d_srcB = D_rB;
        d_dstE = D_rB;
      end

      4'h7:
      begin
      end    

      4'h8:
      begin
        d_srcB = 4'h4;
        d_dstE = 4'h4;
      end

      4'h9:
      begin
        d_srcA = 4'h4;
        d_srcB = 4'h4;
        d_dstE = 4'h4;
      end

      4'hA: 
      begin
        d_srcA = D_rA;
        d_srcB = 4'h4;
        d_dstE = 4'h4;
      end

      4'hB: 
      begin
        d_srcA = 4'h4;
        d_srcB = 4'h4;
        d_dstE = 4'h4;
        d_dstM = D_rA;
      end
    endcase
  end
    
    always@*
    begin
    if(D_icode==4'h7 | D_icode == 4'h8)
      d_valA = D_valP;

    if(M_dstM!=4'hF)
    begin
      if(d_srcA==M_dstM)
       d_valA = m_valM;
      if(d_srcB==M_dstM) 
      d_valB = m_valM;
    end

    else if(e_dstE!=4'hF)
    begin
    if(d_srcA==e_dstE)
      d_valA = e_valE;
    if(d_srcB==e_dstE)      // Forwarding A and B
      d_valB = e_valE;
    end

    else if(W_dstM!=4'hF)
    begin
      if(d_srcA==W_dstM)
       d_valA = W_valM;
      if(d_srcB==W_dstM) 
      d_valB = W_valM;
    end

    else if(W_dstE!=4'hF)
    begin
      if(d_srcA==W_dstE)
       d_valA = W_valE;
      if(d_srcB==W_dstE)
      d_valB = W_valE;
    end

    else if( M_dstE!=4'hF)
    begin
      if(d_srcA==M_dstE)
       d_valB = M_valE;
      if(d_srcB==M_dstE)
      d_valB = M_valE;
    end
  end


  always@(posedge clk)
  begin 
    if(!E_bubble)
    begin
      E_icode <= D_icode;
      E_ifun <= D_ifun;
      E_stat <= D_stat;
      E_srcA <= d_srcA;
      E_srcB <= d_srcB;
      E_dstE <= d_dstE;
      E_dstM <= d_dstM;
      E_valC <= D_valC;
      E_valA <= d_valA;
      E_valB <= d_valB;
    end
    else
    begin
      $display("Stalling");
      E_icode <= 4'b0001;
      E_ifun <= 4'b0000;
      E_stat <= 2'b01;
      E_srcA <= 4'hF;
      E_srcB <= 4'hF;
      E_dstE <= 4'hF;
      E_dstM <= 4'hF;
      E_valC <= 4'b0000;
      E_valA <= 4'b0000;
      E_valB <= 4'b0000;
    end


  end


// writeback 
  always@(posedge clk) 
  begin
    case (W_icode)
    4'h0:
    begin
    end

    4'h1:
    begin
    end

    4'h2: //cmovxx
    begin
      R[W_dstE]=W_valE;
    end

    4'h3: //irmovq
    begin
      R[W_dstE]=W_valE;
    end

    4'h5: //mrmovq
    begin
      R[W_dstM] = W_valM;
    end

    4'h6: //OPq
    begin
      R[W_dstE] = W_valE;
    end

    4'h7:
    begin
    end

    4'h8: //call
    begin
      R[W_dstE] = W_valE;
    end

    4'h9: //ret
    begin
      R[W_dstE] = W_valE;
    end

    4'hA: //pushq
    begin
      R[W_dstE] = W_valE;
    end

    4'hB: //popq
    begin
      R[W_dstE] = W_valE;
      R[W_dstM] = W_valM;
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