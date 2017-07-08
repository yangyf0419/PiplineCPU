left_out units:
// register part
    wire [4:0] AddrC;
    assign AddrC = 
        (RegDst == 2'b00)? Rt : 
        (RegDst == 2'b01)? Rd :
        (RegDst == 2'b10)? Ra :
        Xp;