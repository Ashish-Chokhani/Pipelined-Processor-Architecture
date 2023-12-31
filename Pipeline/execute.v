`include "ALU.v"
module execute(input clk,input [1:0] E_stat,m_stat,
               input [3:0] E_icode,E_ifun,E_dstE,E_dstM,input [63:0] E_valA,E_valB,E_valC,
               output reg M_cnd,output reg e_cnd=1,output reg [1:0] M_stat, output reg [3:0] e_dstE,M_icode,M_dstE,M_dstM,
               output reg [63:0] e_valE,M_valA,M_valE);

  reg [2:0] CC = 3'b000; 

  wire cout,ZF, SF, OF;
  assign ZF = CC[0];
  assign SF = CC[1];
  assign OF = CC[2];

  wire [63:0] valE_;
  reg [1:0] control;
  reg [63:0] _valAC1;

  always@*
  begin
      case(E_icode)
          4'h2:
          begin
              control <= 2'b0;
              _valAC1 <= E_valA;
          end

          4'h3:
          begin
              control <= E_ifun[1:0];
              _valAC1 <= E_valC;
          end

          4'h4: 
          begin
              control <= E_ifun[1:0];
              _valAC1 <= E_valC;
          end

          4'h5:
          begin
              control <= E_ifun[1:0];
              _valAC1 <= E_valC;
          end

          4'h6:
          begin
              control <= E_ifun[1:0];
              _valAC1 <= E_valA;
          end

          4'h8:
          begin
              control <= 2'b1;
              _valAC1 <= 64'd1;
          end

          4'h9:
          begin
              control <= 2'b0;
              _valAC1 <= 64'd1;
          end

          4'hA:
          begin
              control <= 2'b1;
              _valAC1 <= 2*E_valB-64'd1;
          end

          4'hB:
          begin
              control <= 2'b0;
              _valAC1 <= 64'd1;
          end

          default:
              e_valE = 0;
      endcase
  end

  ALU ALU(valE_,cout,_OF,_valAC1,E_valB,control);

  always @*
  begin
      e_valE<=valE_;
      
      if(E_icode != 4'h0 && m_stat==2'b01)
      begin
          CC[2] <= _OF;
          CC[1] <= e_valE[63];
          if(e_valE)
            CC[0] <= 0;
          else
            CC[0] <= 1;
      end
  end

  always @*
  begin
    if(E_icode==2 || E_icode ==7)
    begin
      case (E_ifun)
        4'h0: e_cnd = 1;              // unconditional
        4'h1: e_cnd = (OF^SF)|ZF;     // le
        4'h2: e_cnd = OF^SF;          // l
        4'h3: e_cnd = ZF;             // e
        4'h4: e_cnd = ~ZF;            // ne
        4'h5: e_cnd = ~(SF^OF);       // ge
        4'h6: e_cnd = ~(SF^OF)&~ZF;   // g
        default:
          e_cnd=0;
      endcase
    end
    
    if(e_cnd==1)
      e_dstE = E_dstE;
    else
      e_dstE = 4'hF;
  end

    always@(posedge clk)
  begin
      M_icode <= E_icode;
      M_valE <= e_valE;
      M_valA <= E_valA;
      M_stat <= E_stat;
      M_cnd <= e_cnd;
      M_dstE <= e_dstE;
      M_dstM <= E_dstM;
  end
endmodule