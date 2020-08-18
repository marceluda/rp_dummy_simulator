/**
 * $Id: red_pitaya_pid_block.v 961 2014-01-21 11:40:39Z matej.oblak $
 *
 * Based on "Red Pitaya PID controller".
 *
 * This part of code is written in Verilog hardware description language (HDL).
 * Please visit http://en.wikipedia.org/wiki/Verilog
 * for more details on the language used herein.
 */





module integrator
(
   // data
   input                     clk_i           ,  // clock
   input                     rstn_i          ,  // reset integrator memory
   input  signed  [ 14-1: 0] dat_i           ,  // input data
   output signed  [ 14-1: 0] dat_o           ,  // output data

   // DIV settings
   input          [  4-1: 0] ISR             ,  // ISR for Integration

   // settings
   input signed   [ 14-1: 0] set_ki_i        ,  // Ki
   input                     int_rst_i          // integrator reset
);

/*
localparam PSR=10;
localparam ISR=26;
localparam DSR=10;
*/

wire  [ 14-1: 0] sat_i ;

assign sat_i = 14'd13 ;

/*

Modo de uso

set_sp_i
set_kp_i  --> kp_reg
set_ki_i  --> int_shr
set_kd_i  --> kd_reg_s

PSR  12
ISR  18
DSR  10


Proporcional:
kp_reg =error * set_kp_i / 2**PSR

Integrador
int_shr = int_reg / 2**ISR
int_reg = int_reg + error * set_ki_i

Derivador:
kd_reg_s = kd_reg - kd_reg_r
kd_reg = error * set_kd_i / 2**DSR
kd_reg_r es el del tick de clk anterior

*/


//---------------------------------------------------------------------------------
reg signed [ 15-1: 0] error        ;

always @(posedge clk_i) begin
   if (rstn_i == 1'b1) begin
      error <= 15'h0 ;
   end
   else begin
      error <= $signed(dat_i) ;
   end
end




//---------------------------------------------------------------------------------
//  Integrator

reg          [    8-1: 0] sat_int       ;      // Saturation control
reg   signed [   29-1: 0] ki_mult       ;      // error * ki
wire  signed [   64-1: 0] int_sum,int_sum_sat; // error * ki + Memory
reg   signed [   63-1: 0] int_reg       ;      // Memory
wire  signed [   63-1: 0] int_shr       ;      // Memory / 2**ISR  ---> THIS GOES TO PID OUT
reg   signed [   63-1: 0] int_shr_reg   ;      // Memory aux
//reg          [    5-1: 0] ISR_sat       ;      // Saturation aux

//wire  signed [   47-1: 0] int_shr1       ;      //

always @(posedge clk_i) begin
   if (rstn_i == 1'b1) begin
      ki_mult     <= 29'b0;
      int_reg     <= 63'b0;
      int_shr_reg <= 63'b0;
      sat_int     <=  8'b0;
   end
   else begin
      ki_mult <= $signed(error) * $signed(set_ki_i) ;

      if (int_rst_i)
         begin
            int_reg     <= 63'h0; // reset
            int_shr_reg <= 63'h0; // reset
            sat_int     <=  8'b0;
         end
      else
         begin
            int_reg     <= int_sum_sat[63-1: 0];
            case (ISR)
               4'd0     : begin int_shr_reg <= int_sum_sat[63-1: 0];                               sat_int <= sat_i[8-1:0]+ 5'd0  ;        end
               4'd1     : begin int_shr_reg <= {  {3{int_sum_sat[63-1]}} , int_sum_sat[63-1:3] };  sat_int <= sat_i[8-1:0]+ 5'd3  ;        end
               4'd2     : begin int_shr_reg <= {  {6{int_sum_sat[63-1]}} , int_sum_sat[63-1:6] };  sat_int <= sat_i[8-1:0]+ 5'd6  ;        end
               4'd3     : begin int_shr_reg <= { {10{int_sum_sat[63-1]}} , int_sum_sat[63-1:10]};  sat_int <= sat_i[8-1:0]+ 5'd10 ;        end
               4'd4     : begin int_shr_reg <= { {13{int_sum_sat[63-1]}} , int_sum_sat[63-1:13]};  sat_int <= sat_i[8-1:0]+ 5'd13 ;        end
               4'd5     : begin int_shr_reg <= { {16{int_sum_sat[63-1]}} , int_sum_sat[63-1:16]};  sat_int <= sat_i[8-1:0]+ 5'd16 ;        end
               4'd6     : begin int_shr_reg <= { {20{int_sum_sat[63-1]}} , int_sum_sat[63-1:20]};  sat_int <= sat_i[8-1:0]+ 5'd20 ;        end
               4'd7     : begin int_shr_reg <= { {23{int_sum_sat[63-1]}} , int_sum_sat[63-1:23]};  sat_int <= sat_i[8-1:0]+ 5'd23 ;        end
               4'd8     : begin int_shr_reg <= { {26{int_sum_sat[63-1]}} , int_sum_sat[63-1:26]};  sat_int <= sat_i[8-1:0]+ 5'd26 ;        end
               4'd9     : begin int_shr_reg <= { {30{int_sum_sat[63-1]}} , int_sum_sat[63-1:30]};  sat_int <= sat_i[8-1:0]+ 5'd30 ;        end
               default  : begin int_shr_reg <= int_sum_sat[63-1: 0] ;                              sat_int <= sat_i[8-1:0]+ 5'd0  ;        end
            endcase
         end
   end
end

assign int_sum     = $signed(ki_mult) + $signed(int_reg) ;
assign int_shr     = int_shr_reg ;


sat14 #(.RES(64)) i_sat14_int ( .in(int_sum), .lim( { 56'b0 , sat_int }  ), .out(int_sum_sat) );






//---------------------------------------------------------------------------------
//  Sum together - saturate output
wire signed [   14-1: 0] pid_out     ;

satprotect #(.Ri(64),.Ro(14),.SAT(14)) i_satprotect_pid_sum ( .in($signed(int_shr)), .out(pid_out) );

assign dat_o = $signed(pid_out[ 14-1: 0]) ;


endmodule



/*
Instantiation example:

integrator i_integrator_NAME (
  .clk_i        (  clk            ),  // clock
  .rstn_i       (  rst            ),  // reset - active low
  .dat_i        (  outBin         ),  // input data
  .dat_o        (  Bout           ),  // output data
  .ISR          (  4'd26    ),
  .set_ki_i     (  Bki      ),  // Ki
  .int_rst_i    (  Brst     )   // integrator reset
);



*/
