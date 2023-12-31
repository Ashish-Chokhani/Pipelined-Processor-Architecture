`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "write_back.v"
`include "memory.v"
`include "pc_update.v"

module pc_update_tb;
  reg clk;
  reg [63:0] PC;
  reg [2:0] in_CC;
  reg [0:79] instruction;
  reg [7:0] M[0:65536];     
  wire valid_instruction, valid_memory,cnd;
  wire [2:0] out_CC;
  wire [3:0] icode,ifun,rA,rB;
  wire [63:0] valA,valB,valC,valE,valM,valP,rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14,new_PC;


  always@(valid_memory,valid_instruction,icode)
    begin
    if(valid_instruction==0)
    begin
      $display("INS Error");
      $finish;
    end
    else if(valid_memory==0)
    begin
      $display("ADR Error");
      $finish;
    end
    else if(icode==4'b0000)
    begin
      $display("Halting");
      $finish;
    end
  end  

  initial 
    begin 
       clk = 0;  
       forever #5 clk = ~clk;
    end

  always @(posedge clk)
  begin
    if(icode==6)
    begin
      in_CC = out_CC;
    end
  end

  always@(PC) 
  begin
    instruction={M[PC],M[PC+1],M[PC+2],M[PC+3],M[PC+4],M[PC+5],M[PC+6],M[PC+7],M[PC+8],M[PC+9]};
  end

  always @* PC = new_PC;


  fetch fetch(.PC(PC),.instruction(instruction),.icode(icode),.ifun(ifun),.rA(rA),.rB(rB),
              .valC(valC),.valP(valP),.valid_memory(valid_memory),.valid_instruction(valid_instruction));

  decode decode(.icode(icode),.rA(rA),.rB(rB),
                .valA(valA),.valB(valB)
                );

  execute execute(.icode(icode),.ifun(ifun),.valA(valA),.valB(valB),.valC(valC),.in_CC(in_CC),.cnd(cnd),
                  .valE(valE),.out_CC(out_CC)); 

  memory memory(.valM(valM),.clk(clk),.icode(icode),.valE(valE),.valA(valA),.valP(valP));

  write_back write_back(.clk(clk),.cnd(cnd),.icode(icode),.rA(rA),.rB(rB),
                         .valE(valE),.valM(valM),.rax(rax),.rcx(rcx),.rdx(rdx),.rbx(rbx),.rsp(rsp),
                         .rbp(rbp),.rsi(rsi),.rdi(rdi),.r8(r8),.r9(r9),
                         .r10(r10),.r11(r11),.r12(r12),.r13(r13),.r14(r14)
                         );

  pc_update pc_update(.clk(clk),.cnd(cnd),.icode(icode),.valC(valC),.valM(valM),.valP(valP),.PC(new_PC));



initial 
begin
    $monitor("clk=%d PC=%d icode=%b ifun=%b\n",clk,PC,icode,ifun);
    PC=64'd64;

  //cmovxx
    M[64]=8'b00100000; //2 fn
    M[65]=8'b00100011; //rA rB

  //irmovq
    M[66]=8'b00110000; //3 0
    M[67]=8'b11110011; //F rB
    M[68]=8'b00000000; //V
    M[69]=8'b00000000; //V
    M[70]=8'b00000000; //V
    M[71]=8'b00000000; //V
    M[72]=8'b00000000; //V
    M[73]=8'b00000000; //V
    M[74]=8'b00000000; //V
    M[75]=8'b00011111; //V=31

  //rmmovq
    M[76]=8'b01000000; //4 0
    M[77]=8'b00100100; //rA rB
    M[78]=8'b00000000; //D
    M[79]=8'b00000000; //D
    M[80]=8'b00000000; //D
    M[81]=8'b00000000; //D
    M[82]=8'b00000000; //D
    M[83]=8'b00000000; //D
    M[84]=8'b00000000; //D
    M[85]=8'b00000101; //D

  //mrmovq
    M[86]=8'b01010000; //5 0
    M[87]=8'b00100100; //rA rB
    M[88]=8'b00000000; //D
    M[89]=8'b00000000; //D
    M[90]=8'b00000000; //D
    M[91]=8'b00000000; //D
    M[92]=8'b00000000; //D
    M[93]=8'b00000000; //D
    M[94]=8'b00000000; //D
    M[95]=8'b00000100; //D

  //OPq
    M[96]=8'b01100011; //6 fn
    M[97]=8'b00100100; //rA rB
  
  //jmp
    M[98]=8'b01110000; //7 fn
    M[99]=8'b00000000; //Dest
    M[100]=8'b00000000; //Dest
    M[101]=8'b00000000; //Dest
    M[102]=8'b00000000; //Dest
    M[103]=8'b00000000; //Dest
    M[104]=8'b00000000; //Dest
    M[105]=8'b00000000; //Dest
    M[106]=8'b00000000; //Dest
    M[107]=8'b01110001; //Dest

  //call

  //ret


  //pushq
    M[108]=8'b10100001; //A
    M[109]=8'b00101111; //rA F

  //popq
    M[110]=8'b10110001; //A
    M[111]=8'b00101111; //rA F

  //nop
    M[112]=8'b00010000; // 1 0

  //halt
    M[113]=8'b00000000; // 0 0
end
endmodule