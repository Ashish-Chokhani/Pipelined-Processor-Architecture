`include "fetch.v"
`include "decode.v"
`include "execute.v"

module execute_tb;
  reg clk;
  reg [63:0] PC;
  reg [2:0] in_CC;
  wire [3:0] icode,ifun,rA,rB;
  wire [2:0] out_CC;
  wire valid_memory, valid_instruction,cnd;
  wire [63:0] valA, valB,valP,valC, valM,valE,rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14; 
  reg [7:0] M[0:65536];
  reg [0:79] instruction;

  fetch fetch(.PC(PC),.instruction(instruction),.icode(icode),.ifun(ifun),.rA(rA),.rB(rB),
              .valC(valC),.valP(valP),.valid_memory(valid_memory),.valid_instruction(valid_instruction));
  
  decode decode(.icode(icode),.rA(rA),.rB(rB),
                .valA(valA),.valB(valB)
                );

   execute execute(.icode(icode),.ifun(ifun),.valA(valA),.valB(valB),.valC(valC),.in_CC(in_CC),.cnd(cnd),
                  .out_CC(out_CC),.valE(valE)); 
  
always@(PC) 
  begin
    instruction={M[PC],M[PC+1],M[PC+2],M[PC+3],M[PC+4],M[PC+5],M[PC+6],M[PC+7],M[PC+8],M[PC+9]};
  end

 initial 
    begin 
       clk = 0;  
       forever #5 clk = ~clk;
    end

  // always #10 PC = valP;
  always @(posedge clk) PC<=valP;

    always @(posedge clk)
    begin
    if(icode==6)
    begin
      in_CC = out_CC;
    end
    end

  initial 
  begin
  $monitor("clk=%d PC=%d icode=%b ifun=%b cnd=%d in_CC=%b out_CC=%b rA=%b rB=%b,valA=%d,valB=%d,valC=%d,valE=%d\n",clk,PC,icode,ifun,cnd,in_CC,out_CC,rA,rB,valA,valB,valC,valE);
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

  //popq
    M[98]=8'b10110001; //A
    M[99]=8'b00101111; //rA F

  //nop
    M[100]=8'b00010000; // 1 0

  //halt
    M[101]=8'b00000000; // 0 0
end
endmodule
