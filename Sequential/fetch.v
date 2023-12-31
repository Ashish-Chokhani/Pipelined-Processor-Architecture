module fetch(input [63:0] PC,input [0:79] instruction, output reg [3:0] icode,ifun,rA,rB,output reg [63:0] valC,output reg [63:0] valP,output reg valid_memory,valid_instruction);

    // PC;                        // Program Counter
    //Instruction;                // Instructionuction to be executed
    // icode;                     // icode: Instructionuction Code - 4 Bytes
    // ifun;                      // ifun: Function Code - Bytes
    // rA;                        // rA register/memory addresses - 4 Bytes
    // rB;                        // rB register/memory addresses - 4 Bytes
    // valC;                      // 8 byte values. Used for finding incremented PC, valP.
    // valP;                      // Incremented PC
    // Valid_Memory = 0;          // Flag: Check if Memory is full.
    // Valid_Instruction = 1;     // Flag: Check if Instructionuction is valid.

    always@(*) 
    begin 
        if(PC>65536)
        begin
            valid_memory = 0;
        end
        else
        begin
            valid_memory=1;
            valid_instruction=1;
        end

        icode = instruction[0:3];
        ifun = instruction[4:7];

        case (icode)
        4'h0: 
        begin
            valP=PC+64'd1;              // halt
            $finish;
        end

        4'h1: 
        begin
            valP=PC+64'd1;              // nop
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
            valC = instruction[16:79];
            valP=PC+64'd10;
        end

        4'h4:
        begin                  // rmmovq
            rA = instruction[8:11];
            rB = instruction[12:15];
            valC = instruction[16:79];
            valP=PC+64'd10;
        end

        4'h5:
        begin                  // mrmovq
            rA = instruction[8:11];
            rB = instruction[12:15];
            valC = instruction[16:79];
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
            valC=instruction[8:79];
            valP=PC+64'd9;
        end

        4'h9:                       //ret
            valP=PC+64'd1;

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

        default:                    // invalid instructionuction
            valid_instruction=1'b0;
    endcase
    end

endmodule