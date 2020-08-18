`timescale 1ns / 1ps


//(* keep_hierarchy = "yes" *)
module rand_gen_uni
(
    input  clk,rst,
    input  run,     // run
    output signed   [32-1:0] out   // output
);
    // Addr for memory slots


    //wire signed [14-1:0] out_pico ;
    //wire signed [14-1:0] pos_absolute;

    //wire        [11-1:0] pos ;

    reg   [32-1:0]  XX,YY,ZZ,WW ;
    wire  [32-1:0]  X_next,Y_next,Z_next,W_next,T ;


    always @(posedge clk)
        if (rst)
        begin
            XX       <=   32'd123456789    ;
            YY       <=   32'd362436069    ;
            ZZ       <=   32'd521288629    ;
            WW       <=   32'd88675123    ;
        end
        else
        begin
            XX       <=   X_next    ;
            YY       <=   Y_next    ;
            ZZ       <=   Z_next    ;
            WW       <=   W_next    ;
        end

    // assign X_next = run ? YY : XX ;
    // assign Y_next = run ? ZZ : YY ;
    // assign Z_next = run ? WW : ZZ ;
    // assign W_next = run ? ( WW ^ { 19'b0 ,WW[32-1:19]} ) ^ ( T ^ { 8'b0 , T[32-1:8] }  ) : WW ;
    // assign T      =  XX ^ { XX[32-1:11], 11'b0 } ;

    assign X_next = run ? YY : XX ;
    assign Y_next = run ? ZZ : YY ;
    assign Z_next = run ? WW : ZZ ;
    assign W_next = run ? ( WW ^ (WW>>19) ) ^ ( T ^ (T>>8)  ) : WW ;
    assign T      =  XX ^ ( XX<<11 ) ;
    assign out  = WW ;

endmodule

    //  rand_gen_uni i_rand_gen_uni_A  ( .clk(clk), .rst(rst), .run( ON_OFF ),  .out( OUT ) );
