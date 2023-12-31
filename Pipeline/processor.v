`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "pipe_control.v"

module processor;
  wire [1:0] D_stat,E_stat,M_stat,m_stat,W_stat;
  wire [3:0] D_icode,D_ifun,D_rA,D_rB,d_srcA,d_srcB,E_icode,E_ifun,E_srcA,E_srcB,E_dstE,E_dstM,e_dstE,
             M_icode,M_dstE,M_dstM,W_icode,W_dstE,W_dstM;
  wire [63:0] f_predPC,D_valC,D_valP,E_valA,E_valB,E_valC,e_valE,M_valA,M_valE,m_valM,W_valE,W_valM,
              rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14;
  wire D_bubble,D_stall,E_bubble,e_cnd,M_bubble,M_cnd,W_stall;

  reg clk;
  reg [1:0] stat = 2'b01; 
  reg [63:0] F_predPC;

  initial 
    begin 
       clk = 0;  
       forever #5 clk = ~clk;
    end

  initial 
  begin
      $dumpfile("pipe_processor.vcd");
      $dumpvars(0,processor);
      F_predPC=64'd64;
      $monitor("clk=%d f_predPC=%d F_predPC=%d D_icode=%d,E_icode=%d, M_icode=%d rdi=%d,rsi=%d rsp=%d\n",clk,f_predPC,F_predPC, D_icode,E_icode,M_icode,rdi,rsi,rsp);
  end


  always@(W_stat)
  begin
    stat = W_stat;
  end  

  always@(stat) 
  begin
    case(stat)
    2'b00:
    begin
      $display("INS Error");
      $finish;
    end

    2'b01:
    begin
    end

    2'b10:
    begin
      $display("Halting");
      $finish;
    end

    2'b11: 
    begin
      $display("ADR Error");
      $finish;
    end
  endcase
  end

fetch fetch(.clk(clk),.D_stall(D_stall),.D_bubble(D_bubble),.M_cnd(M_cnd),
            .M_icode(M_icode),.W_icode(W_icode),.F_predPC(F_predPC),.M_valA(M_valA),.W_valM(W_valM),
            .D_icode(D_icode),.D_ifun(D_ifun),.D_rA(D_rA),.D_rB(D_rB),.D_valC(D_valC),.D_valP(D_valP),
            .f_predPC(f_predPC),.D_stat(D_stat));

decode decode(.clk(clk),.E_bubble(E_bubble),.D_stat(D_stat),.D_icode(D_icode),.D_ifun(D_ifun),.D_rA(D_rA),.D_rB(D_rB),
              .e_dstE(e_dstE),.M_dstE(M_dstE),.M_dstM(M_dstM),.W_icode(W_icode),
              .W_dstE(W_dstE),.W_dstM(W_dstM),.D_valC(D_valC),.D_valP(D_valP),.e_valE(e_valE),.M_valE(M_valE),.m_valM(m_valM),
              .W_valE(W_valE),.W_valM(W_valM),.E_stat(E_stat),.E_icode(E_icode),.E_ifun(E_ifun),.E_srcA(E_srcA),.E_srcB(E_srcB),
              .E_dstE(E_dstE),.E_dstM(E_dstM),.d_srcA(d_srcA),.d_srcB(d_srcB),.E_valA(E_valA),.E_valB(E_valB),.E_valC(E_valC),
              .rax(rax),.rcx(rcx),.rdx(rdx),.rbx(rbx),.rsp(rsp),
              .rbp(rbp),.rsi(rsi),.rdi(rdi),.r8(r8),.r9(r9),
              .r10(r10),.r11(r11),.r12(r12),.r13(r13),.r14(r14));

execute execute(.clk(clk),.E_stat(E_stat),.m_stat(m_stat),.E_icode(E_icode),.E_ifun(E_ifun),.E_dstE(E_dstE),.E_dstM(E_dstM),
                .E_valA(E_valA),.E_valB(E_valB),.E_valC(E_valC),.M_cnd(M_cnd),.e_cnd(e_cnd),.M_stat(M_stat),
                .e_dstE(e_dstE),.M_icode(M_icode),.M_dstE(M_dstE),.M_dstM(M_dstM),
                .e_valE(e_valE),.M_valA(M_valA),.M_valE(M_valE));


memory memory(.clk(clk),.M_stat(M_stat),.M_icode(M_icode),.M_dstE(M_dstE),.M_dstM(M_dstM),
              .M_valA(M_valA),.M_valE(M_valE),.m_stat(m_stat),.W_stat(W_stat),
              .W_icode(W_icode),.W_dstE(W_dstE),.W_dstM(W_dstM),
              .m_valM(m_valM),.W_valE(W_valE),.W_valM(W_valM));

  pipe_control pipe_control(.e_cnd(e_cnd),.D_icode(D_icode),.d_srcA(d_srcA),.d_srcB(d_srcB),
                            .E_icode(E_icode),.E_dstM(E_dstM),.M_icode(M_icode),
                            .D_stall(D_stall),.D_bubble(D_bubble),.E_bubble(E_bubble));

  always @(posedge clk) 
  begin
  F_predPC <= f_predPC;
  end

endmodule