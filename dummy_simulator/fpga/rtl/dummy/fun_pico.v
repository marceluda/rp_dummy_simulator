`timescale 1ns / 1ps


//(* keep_hierarchy = "yes" *)
module fun_pico
(
    input clk,rst,
    input signed    [14-1:0] in,   // input
    output signed   [14-1:0] out   // output
);
    // Addr for memory slots


    wire signed [14-1:0] out_pico ;
    wire signed [14-1:0] pos_absolute;

    wire        [11-1:0] pos ;

    reg signed  [14-1:0]  out_reg ;

    reg signed [14-1:0] pico [2048-1:0]; // vector for amplitude value
    initial
    begin
        $readmemb("pico_data.dat", pico); // read memory binary code from data_sin.dat
    end

    //assign pos_plus = in  + 14'd8192 ;
    assign pos_absolute  = in >= $signed(14'b0) ? in : -in ;



    assign pos = pos_absolute > 14'd2047 ? 11'd2047 : pos_absolute[11-1:0] ;

    assign pos_abs = { 3'b0  , pos };
    //satprotect #(.Ri(15),.Ro(14),.SAT(14)) i_satprotect_pos_plus  ( .in(pos_plus),  .out(pos) );

    assign out_pico = pico[pos];


    always @(posedge clk)
        if (rst)
        begin
            out_reg       <=   14'b0    ;
        end
        else
        begin
            out_reg       <=   out_pico   ;
        end

    assign out  = $signed(out_reg) ;

endmodule

    //  fun_pico i_fun_pico_A  ( .clk(clk), .rst(rst), .in( IN ),  .out( OUT ) );
