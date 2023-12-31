`include "fetch_update.v"
module fetch(input clk,D_stall,D_bubble,M_cnd,input [3:0] M_icode,W_icode,input [63:0] F_predPC,M_valA,W_valM,
            output reg [3:0] D_icode,D_ifun,D_rA,D_rB,output reg [63:0] D_valC,D_valP,f_predPC,
            output reg [1:0] D_stat);

    // F_predPC;                        // Program Counter
    //Instruction;                // Instructionuction to be executed
    // icode;                     // icode: Instructionuction Code - 4 Bytes
    // ifun;                      // ifun: Function Code - Bytes
    // rA;                        // rA register/memory addresses - 4 Bytes
    // rB;                        // rB register/memory addresses - 4 Bytes
    // valC;                      // 8 byte values. Used for finding incremented PC, valP.
    // valP;                      // Incremented PC
    // Valid_Memory = 1;          // Flag: Check if Memory is full.
    // Valid_Instruction = 1;     // Flag: Check if Instruction is valid.

    reg valid_memory=1,valid_instruction=1; 
    reg [1:0] stat; 
    reg [3:0] icode, ifun,rA, rB;
    reg [7:0] M[0:4096];                         
    reg [63:0] valC,valP,PC;                                             
    reg [0:79] instruction;                                      


    initial 
    begin
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

    //OPq
    M[86]=8'b01100011; //6 fn
    M[87]=8'b00100100; //rA rB
  
  //jmp
    M[88]=8'b01110000; //7 fn
    M[89]=8'b00000000; //Dest
    M[90]=8'b00000000; //Dest
    M[91]=8'b00000000; //Dest
    M[92]=8'b00000000; //Dest
    M[93]=8'b00000000; //Dest
    M[94]=8'b00000000; //Dest
    M[95]=8'b00000000; //Dest
    M[96]=8'b00000000; //Dest
    M[97]=8'b01101000; //Dest

  //pushq
    M[99]=8'b10100001; //A
    M[100]=8'b00101111; //rA F

  //popq
    M[101]=8'b10110001; //A
    M[102]=8'b00101111; //rA F

  //nop
    M[103]=8'b00010000; // 1 0

  // //halt
  //   M[113]=8'b00000000; // 0 0

     //irmovq
    M[104]=8'b00110000; //3 0
    M[105]=8'b11110011; //F rB
    M[106]=8'b00000000; //V
    M[107]=8'b00000000; //V
    M[108]=8'b00000000; //V
    M[109]=8'b00000000; //V
    M[110]=8'b00000000; //V
    M[111]=8'b00000000; //V
    M[112]=8'b00000000; //V
    M[113]=8'b00011111; //V=31

    // //pushq
    // M[114]=8'b10100001; //A
    // M[115]=8'b00101111; //rA F

//   //popq
//     M[126]=8'b10110001; //A
//     M[127]=8'b00101111; //rA F

  //halt
    M[114]=8'b00000000;



//   //call
//     M[113]=8'b10000000; // 8 0
//     M[114]=8'b00000000; //Dest
//     M[115]=8'b00000000; //Dest
//     M[116]=8'b00000000; //Dest
//     M[117]=8'b00000000; //Dest
//     M[118]=8'b00000000; //Dest
//     M[119]=8'b00000000; //Dest
//     M[120]=8'b00000000; //Dest
//     // M[121]=8'b00000000; //Dest
//     M[121]=8'b01111011; //Dest
    
//     M[122]=8'b00000000; // 0 0 Halt
//     M[123]=8'b01100011; //6 fn OPq
//     M[124]=8'b00100100; //rA rB

//   //ret
//     M[125]=8'b10010000; // 9 0

  // //halt
  //   M[127]=8'b00000000; // 0 0

  // 1. STALLING, DATA FORWARDING 

    // irmovq $10,%rdx
    // M[128]=8'b00110000; //3 0
    // M[129]=8'b11110010; //F rB=2
    // M[130]=8'b00000000;           
    // M[131]=8'b00000000;           
    // M[132]=8'b00000000;           
    // M[133]=8'b00000000;          
    // M[134]=8'b00000000;          
    // M[135]=8'b00000000;          
    // M[136]=8'b00000000;
    // M[137]=8'b00001010; //V=10

    // // irmovq  $3,%rax
    // M[138]=8'b00110000; //3 0
    // M[139]=8'b11110000; //F rB=0
    // M[140]=8'b00000000;           
    // M[141]=8'b00000000;           
    // M[142]=8'b00000000;           
    // M[143]=8'b00000000;          
    // M[144]=8'b00000000;          
    // M[145]=8'b00000000;          
    // M[146]=8'b00000000;
    // M[147]=8'b00000011; //V=3

    // // addq %rdx,%rax
    // M[148]=8'b01100000; //6 0
    // M[149]=8'b00100000; //rA=2 rB=0

    // // 2. LOAD/USE HAZARD 

    // //irmovq $128, %rdx
    // M[150]=8'b00110000; //3 0
    // M[151]=8'b11110010; //F rB=2
    // M[152]=8'b00000000;           
    // M[153]=8'b00000000;           
    // M[154]=8'b00000000;           
    // M[155]=8'b00000000;          
    // M[156]=8'b00000000;          
    // M[157]=8'b00000000;          
    // M[158]=8'b00000000;
    // M[159]=8'b10000000; //V=128

    // //irmovq $3, %rcx
    // M[160]=8'b00110000; //3 0
    // M[161]=8'b11110001; //F rB=1
    // M[162]=8'b00000000;           
    // M[163]=8'b00000000;           
    // M[164]=8'b00000000;           
    // M[165]=8'b00000000;          
    // M[166]=8'b00000000;          
    // M[167]=8'b00000000;          
    // M[168]=8'b00000000;
    // M[169]=8'b00000011; //V=3

    // //rmmovq %rcx, 0(%rdx)
    // M[170]=8'b01000000; //4 0
    // M[171]=8'b00010010; //rA=1 rB=2
    // M[172]=8'b00000000; //D
    // M[173]=8'b00000000; //D
    // M[174]=8'b00000000; //D
    // M[175]=8'b00000000; //D
    // M[176]=8'b00000000; //D
    // M[177]=8'b00000000; //D
    // M[178]=8'b00000000; //D
    // M[179]=8'b00000000; //D=0

    // //irmovq $10, %rbx
    // M[180]=8'b00110000; //3 0
    // M[181]=8'b11110011; //F rB=3
    // M[182]=8'b00000000;           
    // M[183]=8'b00000000;           
    // M[184]=8'b00000000;           
    // M[185]=8'b00000000;          
    // M[186]=8'b00000000;          
    // M[187]=8'b00000000;          
    // M[188]=8'b00000000;
    // M[189]=8'b00001010; //V=10

    // //mrmovq 0(%rdx), %rax
    // M[190]=8'b01010000; //5 0
    // M[191]=8'b00100000; //rA=2 rB=0
    // M[192]=8'b00000000; //D
    // M[193]=8'b00000000; //D
    // M[194]=8'b00000000; //D
    // M[195]=8'b00000000; //D
    // M[196]=8'b00000000; //D
    // M[197]=8'b00000000; //D
    // M[198]=8'b00000000; //D
    // M[199]=8'b00000000; //D=0

    // //addq %rbx, %rax
    // M[200]=8'b01100000; //6 0
    // M[201]=8'b00110000; //rA=3 rB=0

    // // 3. BRACH MISPREDICTION 

    // //     xorq %rax,%rax
    // M[20]=8'b01100011; //6 3
    // M[21]=8'b00000000; //rA=0 rB=0

    // //     jne  t             # Not taken
    // M[86]=8'b01110100; //7 4
    // M[87]=8'b00100000; //D
    // M[88]=8'b00000000; //D
    // M[89]=8'b00000000; //D
    // M[90]=8'b00000000; //D
    // M[91]=8'b00000000; //D
    // M[92]=8'b00000000; //D
    // M[93]=8'b00000000; //D
    // M[94]=8'b00000000; //D //Set destination NOT YET SET 

    // //     irmovq $1, %rax    # Fall through
    // M[20]=8'b00110000; //3 0
    // M[21]=8'b11110000; //F rB=0
    // M[22]=8'b00000000;           
    // M[23]=8'b00000000;           
    // M[24]=8'b00000000;           
    // M[25]=8'b00000000;          
    // M[26]=8'b00000000;          
    // M[27]=8'b00000000;          
    // M[28]=8'b00000000;
    // M[29]=8'b00000001; //V=1

    // //     nop
    // M[12]=8'b00010000; // 1 0

    // //     nop
    // M[12]=8'b00010000; // 1 0

    // //     nop
    // M[12]=8'b00010000; // 1 0

    // //     halt
    // M[12]=8'b00000000; // 0 0

    // // t:  irmovq $3, %rdx    # Target
    // M[20]=8'b00110000; //3 0
    // M[21]=8'b11110010; //F rB=2
    // M[22]=8'b00000000;           
    // M[23]=8'b00000000;           
    // M[24]=8'b00000000;           
    // M[25]=8'b00000000;          
    // M[26]=8'b00000000;          
    // M[27]=8'b00000000;          
    // M[28]=8'b00000000;
    // M[29]=8'b00000011; //V=3

    // //     irmovq $4, %rcx    # Should not execute
    // M[20]=8'b00110000; //3 0
    // M[21]=8'b11110001; //F rB=1
    // M[22]=8'b00000000;           
    // M[23]=8'b00000000;           
    // M[24]=8'b00000000;           
    // M[25]=8'b00000000;          
    // M[26]=8'b00000000;          
    // M[27]=8'b00000000;          
    // M[28]=8'b00000000;
    // M[29]=8'b00000100; //V=4

    // //     irmovq $5, %rdx    # Should not execute
    // M[20]=8'b00110000; //3 0
    // M[21]=8'b11110010; //F rB=2
    // M[22]=8'b00000000;           
    // M[23]=8'b00000000;           
    // M[24]=8'b00000000;           
    // M[25]=8'b00000000;          
    // M[26]=8'b00000000;          
    // M[27]=8'b00000000;          
    // M[28]=8'b00000000;
    // M[29]=8'b00000101; //V=5

    // 4. RETURN 

    // irmovq Stack,%rsp  # Intialize stack pointer

    // call p             # Procedure call
    // M[20]=8'b10000000; 8 0
    // M[87]=8'b00100000; //D
    // M[88]=8'b00000000; //D
    // M[89]=8'b00000000; //D
    // M[90]=8'b00000000; //D
    // M[91]=8'b00000000; //D
    // M[92]=8'b00000000; //D
    // M[93]=8'b00000000; //D
    // M[94]=8'b00000000; //D //Set destination NOT YET SET 

    // irmovq $5,%rsi     # Return point
    // M[20]=8'b00110000; //3 0
    // M[21]=8'b11110110; //F rB=6
    // M[22]=8'b00000000;           
    // M[23]=8'b00000000;           
    // M[24]=8'b00000000;           
    // M[25]=8'b00000000;          
    // M[26]=8'b00000000;          
    // M[27]=8'b00000000;          
    // M[28]=8'b00000000;
    // M[29]=8'b00000101; //V=5

    // // halt
    // M[12]=8'b00000000; // 0 0

    
    // // p:  irmovq $1,%rdi    # procedure
    // M[20]=8'b00110000; //3 0
    // M[21]=8'b11110111; //F rB=7
    // M[22]=8'b00000000;           
    // M[23]=8'b00000000;           
    // M[24]=8'b00000000;           
    // M[25]=8'b00000000;          
    // M[26]=8'b00000000;          
    // M[27]=8'b00000000;          
    // M[28]=8'b00000000;
    // M[29]=8'b00000001; //V=1

    // //     ret
    // M[20]=8'b10010000; //9 0

    // //     irmovq $2,%rax     # Should not be executed
    // M[20]=8'b00110000; //3 0
    // M[21]=8'b11110000; //F rB=0
    // M[22]=8'b00000000;           
    // M[23]=8'b00000000;           
    // M[24]=8'b00000000;           
    // M[25]=8'b00000000;          
    // M[26]=8'b00000000;          
    // M[27]=8'b00000000;          
    // M[28]=8'b00000000;
    // M[29]=8'b00000010; //V=2

    // //     irmovq $3,%rcx     # Should not be executed
    // M[20]=8'b00110000; //3 0
    // M[21]=8'b11110001; //F rB=1
    // M[22]=8'b00000000;           
    // M[23]=8'b00000000;           
    // M[24]=8'b00000000;           
    // M[25]=8'b00000000;          
    // M[26]=8'b00000000;          
    // M[27]=8'b00000000;          
    // M[28]=8'b00000000;
    // M[29]=8'b00000011; //V=3

    // //     irmovq $4,%rdx     # Should not be executed
    // M[20]=8'b00110000; //3 0
    // M[21]=8'b11110010; //F rB=2
    // M[22]=8'b00000000;           
    // M[23]=8'b00000000;           
    // M[24]=8'b00000000;           
    // M[25]=8'b00000000;          
    // M[26]=8'b00000000;          
    // M[27]=8'b00000000;          
    // M[28]=8'b00000000;
    // M[29]=8'b00000100; //V=4

    // //     irmovq $5,%rbx     # Should not be executed
    // M[20]=8'b00110000; //3 0
    // M[21]=8'b11110011; //F rB=3
    // M[22]=8'b00000000;           
    // M[23]=8'b00000000;           
    // M[24]=8'b00000000;           
    // M[25]=8'b00000000;          
    // M[26]=8'b00000000;          
    // M[27]=8'b00000000;          
    // M[28]=8'b00000000;
    // M[29]=8'b00000101; //V=5
    end

 always@(icode,valid_instruction,valid_memory)
 begin
    //Setting stat register
        if(icode==4'b0000)   //Halt
        stat = 2'b10;

        else if(valid_instruction==0)  //INS
        stat = 2'b00;

        else if(valid_memory==0)  //ADR
        begin
        stat = 2'b11;
        end

        else
        stat = 2'b01;    //AOK
 end

    always@(posedge clk)
    begin
        if(!D_stall)
        begin
        if(!D_bubble)
        begin
            D_icode <= icode;
            D_ifun <= ifun;
            D_rA <= rA;              // Checking if there is bubble or not
            D_rB <= rB;
            D_stat <= stat;
            D_valP <= valP;
            D_valC <= valC;
        end
        else
        begin
            D_icode <= 4'b0001;
            D_ifun <= 4'b0000;
            D_rA <= 4'b0000;
            D_rB <= 4'b0000;
            D_stat <= 2'b01;
            D_valP <= 64'b0;
            D_valC <= 64'b0;
        end
        end
    end


    always@* 
    begin 

        if(PC>4096)
        begin
            valid_memory = 0;
        end
        else
        begin
            valid_memory=1;
            valid_instruction=1;
        end

        instruction = {M[PC],M[PC+1],M[PC+2],M[PC+3],M[PC+4],M[PC+5],M[PC+6],M[PC+7],M[PC+8],M[PC+9]};

        icode = instruction[0:3];
        ifun = instruction[4:7];

        case (icode)
        4'h0:
        begin
                valP=PC;          // halt
        end

        4'h1:
        begin
            valP=PC+64'd1;       // nop
        end

        4'h2:
        begin                   // cmovq
            rA=instruction[8:11];
            rB=instruction[12:15];
            valP=PC+64'd2;
        end

        4'h3:
        begin                  // irmovq
            rA = instruction[8:11];
            rB = instruction[12:15];
            valC =instruction[16:79];
            valP=PC+64'd10;
        end
        4'h4:begin                  // rmmovq
            rA = instruction[8:11];
            rB = instruction[12:15];
            valC =instruction[16:79];
            valP=PC+64'd10;
        end
        4'h5:
        begin                  // mrmovq
            rA = instruction[8:11];
            rB = instruction[12:15];
            valC =instruction[16:79];
            valP=PC+64'd10;
        end
        4'h6:
        begin                  // OPq
            rA=instruction[8:11];
            rB=instruction[12:15];
            valP=PC+64'd2;
        end

        4'h7:
        begin                  //jxx
            valC=instruction[8:79];
            valP=PC+64'd9;
        end
        
        4'h8:
        begin                  //call
            valC=instruction[8:71];
            valP=PC+64'd9;
        end

        4'h9:
           valP=PC+64'd1;        //ret     

        4'hA:
        begin                  //pushq
            rA=instruction[8:11];
            rB=instruction[12:15];
            valP=PC+64'd2;
        end

        4'hB:
        begin                  //popq
            rA=instruction[8:11];
            rB=instruction[12:15];
            valP=PC+64'd2;
        end

        default:      // invalid instr
            valid_instruction=1'b0;
        endcase

    end

    always@*
    begin
        if(M_cnd==0 && M_icode==4'h7)  // not taken jump
            PC = M_valA;
        else if(W_icode==4'h9)      // Return statement encountered
            PC = W_valM;
        else
            PC = F_predPC;       
    end

always@*
begin
 //Predicting PC
        if(icode==4'h7 || icode==4'h8)
        begin
            f_predPC=valC;
        end
        else
        begin
            f_predPC=valP;
        end
end

endmodule