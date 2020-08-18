//////////////////////////////////////////////////////////////////////////////////
//
// Suma 2**N valores de la entrada.
// Caundo pasan 2**N ticks del reloj actualiza las salidas con:
//   - sum  : la suma de los 2**N valores de entrada adquiridos
//   - mean : el promedio de los valores adquiridos
// Los valores de la salida permaneceran hasta que pasen nuevamente 2**N ticks de reloj
//
//////////////////////////////////////////////////////////////////////////////////


module sum_2N
#(parameter R=8 , N=3)
(
	input  clk, rst,
	input  wire signed  [R-1  :0] in,   // input val
	output reg  signed  [R+N-1:0] sum,  // sum  val
	output reg  signed  [R-1  :0] mean, // mean val
	output wire                   tick  // output tick
);

//signal declaration
reg        [N-1  :0] cnt;
reg        [N-1  :0] cnt_next;

reg signed [R-1  :0] mean_next;
reg signed [R+N-1:0] summ, summ_next, sum_next;

wire         state;

localparam  // 2 posible states
        summing     = 1'd0,
        store       = 1'd1;

// body
always @(posedge clk)
	if (rst) begin
                cnt           <=  {N{1'b0}} ;
                mean          <=  {R{1'b0}} ;
                summ          <=  {R+N{1'b0}} ;
                sum           <=  {R+N{1'b0}} ;

        end
	else begin
		cnt           <=   cnt_next;
                mean          <=   mean_next ;
                summ          <=   summ_next ;
                sum           <=   sum_next ;
        end


assign state = &cnt ;

// next-state logic
always @*
begin
        if(state==1'b0) begin
                cnt_next      = cnt +1'b1  ;
                mean_next     = mean;
                summ_next     = $signed(summ) + $signed(in) ;
                sum_next      = sum ;
        end
        else begin
                cnt_next      = {N{1'b0}};
                mean_next     = $signed(summ[R+N-1:N]);
                summ_next     = $signed( { {N{1'b0}}  , in } ) ;
                sum_next      = summ ;
        end
end


// output logic

assign tick = (cnt=={N{1'b0}}) ;


endmodule


/*
Ejemplo de instanciación:

sum_2N #( .R(14), .N(4) ) i_sum_2N_NAME (
	.clk(clk), .rst(rst),
	// inputs
	.in    ( INPUT_BUS ), // Bus de entrada
	// outputs
	.sum  (  SUMA     ),   // Suma de 10000 valores de entrada de INPUT_BUS
	.mean ( PROMEDIO  ),   // Promedio de 10000 valores de entrada de INPUT_BUS
	.tick (           )    // Vale 1 cuando se actualiza la salida
);

*/
