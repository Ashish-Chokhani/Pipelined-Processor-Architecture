module full_adder(output Sout,Cout,input A, B, Cin);

    xor(w1,A,B);
    xor(Sout,w1,Cin);

    and(w2,A,B);
    and(w3,A,Cin);
    and(w4,B,Cin);

    or(w5,w2,w3);
    or(Cout,w5,w4);
    
endmodule