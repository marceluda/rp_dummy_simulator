`timescale 1ns / 1ps


//(* keep_hierarchy = "yes" *)
module fun_icdf
(
    input clk,rst,
    input signed    [11-1:0] in,   // input
    output signed   [14-1:0] out   // output
);
    // Addr for memory slots



    wire         [11-1:0]  pos ;
    reg  signed  [14-1:0]  out_reg ;
    wire signed  [14-1:0]  out_fun ;

    reg signed [14-1:0] icdf [1024-1:0]; // vector for amplitude value
    initial
    begin
        $readmemb("icdf_data.dat", icdf); // read memory binary code from data_sin.dat
    end

    assign pos = in >= 11'b0 ? in  : -in ;

    assign out_fun = icdf[pos[10-1:0]];


    always @(posedge clk)
        if (rst)
        begin
            out_reg       <=   14'b0    ;
        end
        else
        begin
            out_reg       <=   out_fun   ;
        end

    assign out  = in[10]? - out_reg  : out_reg ;

endmodule

    //  fun_icdf i_fun_icdf  ( .clk(clk), .rst(rst), .in( IN11 ),  .out( OUT14 ) );
