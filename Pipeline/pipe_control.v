module pipe_control(input e_cnd,input [3:0] D_icode,d_srcA,d_srcB,E_icode,E_dstM,M_icode,
                    output reg D_stall, D_bubble, E_bubble);

    initial
    begin
        D_bubble = 0;
        E_bubble = 0;
        D_stall = 0;
    end

    always@*
    begin
        if(D_icode == 4'h9 || E_icode == 4'h9 || M_icode == 4'h9)
        begin
            D_bubble = 1;
        end

        else if(E_icode == 4'h5 || E_icode == 4'hB)
        begin
            if(d_srcA==d_srcB || E_dstM==d_srcA)
            begin
            D_stall = 1;
            E_bubble = 1;
            end
        end

        else if(E_icode==4'h7 && e_cnd==0)
        begin
            D_bubble = 1;
            E_bubble = 1;
        end
    end

endmodule