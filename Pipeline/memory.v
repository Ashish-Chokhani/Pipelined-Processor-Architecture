module memory(input clk,input [1:0] M_stat,input [3:0] M_icode,M_dstE,M_dstM,
              input [63:0] M_valA,M_valE, output reg [1:0] m_stat,W_stat,
              output reg [3:0] W_icode,W_dstE,W_dstM,output reg [63:0] m_valM,W_valE,W_valM);

    reg [63:0] M8[0:255];

//   // initializing with random values
// integer i;
// initial 
// begin
//     for(i = 0; i < 255; i = i + 1)
//     begin
//         M8[i]=i;
//     end
// end

    always@*
    begin
        m_stat = M_stat;
        if((M_valE>=256 && (M_icode==4'h4 || M_icode==4'h5 || M_icode==4'h8 || M_icode==4'hB)) || (M_valA>=256 && (M_icode==4'h9 || M_icode==4'hB)))
            m_stat = 2'b11;
    end

    always@*
    begin
        case(M_icode)
            4'h5:  
            begin
                m_valM = M8[M_valE];   // mrmovq
            end

            4'h9:  
            begin
                m_valM = M8[M_valA];   // ret
            end

            4'hB:  
            begin
                m_valM = M8[M_valA];   // popq
            end
        endcase
    end

    always@(posedge clk)
    begin 
        case(M_icode)
            4'h4:  
            begin
                M8[M_valE] <= M_valA;  // rmmovq
            end

            4'h8:  
            begin
                M8[M_valE] <= M_valA;  // call
            end

            4'hA:  
            begin
                M8[M_valE] <= M_valA;  // pushq
            end
            
        endcase
    end

    always@(posedge clk)
    begin
            W_icode <= M_icode;
            W_dstE <= M_dstE;
            W_dstM <= M_dstM;
            W_stat <= m_stat;
            W_valE <= M_valE;
            W_valM <= m_valM;
    end
endmodule