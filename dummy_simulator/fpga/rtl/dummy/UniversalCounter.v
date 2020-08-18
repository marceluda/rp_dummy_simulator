//////////////////////////////////////////////////////////////////////////////////
//
// Contador Universal
// Cuando en==1 cuenta de a uno los ticks del reloj clk
//
//////////////////////////////////////////////////////////////////////////////////

/* Descripción:

Cuando en==1:
	si up==1 ---> suma  1 al valor de la memoria interna en cada tick de CLK
	si up==0 ---> resta 1 al valor de la memoria interna en cada tick de CLK

Cuando en==0  : el valor se detiene.

Si syn_clr==1 : se pone la memoria interna en CERO

Si load==1    : se carga el valor de d en la memoria interna


En la salida q se puede leer el valor de la memoria interna

Cuando la memoria interna llega a su valor máximo ( ej: para 4 bits, r_reg==1111 )
se coloca en max_tick un 1

Cuando la memoria interna llega a su valor mínimo ( ej: para 4 bits, r_reg==0000 )
se coloca en min_tick un 1

*/

module UniversalCounter
#(parameter N=8)
(
	input wire clk, reset, en, up, syn_clr , load,
	input wire [N-1:0] d,
	output wire max_tick, min_tick,
	output wire [N-1:0] q
);

//signal declaration
reg [N-1:0] r_reg;
reg [N-1:0] r_next;

// body
// register
always @(posedge clk, posedge reset)
	if (reset)
		r_reg <= 0; // {N{1b'0}}
	else
		r_reg <= r_next;


// next-state logic (alwaydeado)
always @*
begin
	if (syn_clr)
		r_next=0;
	else if (load & ~syn_clr)
		r_next=d;
	else
		if (up&en)
			r_next = r_reg + 1;
		else if ((~up)&en)
			r_next = r_reg - 1;
		else
			r_next = r_reg;
end


// output logic
assign q = r_reg;
assign max_tick = (r_reg==2**N-1) ? 1'b1 : 1'b0;
assign min_tick = (r_reg==0);

endmodule


/*
Instantiation example:

UniversalCounter #( .N(14) ) i_UniversalCounter_NAME (
	.clk(clk), .reset(rst),
	// inputs
	.en     (             1'b1 ), // 1 es enable / encendido
	.up     (             1'b1 ), // 1 es sumar, 0 es restar
	.syn_clr(             1'b0 ), // 1 es resetear el contador
	.load   (             1'b0 ), // 1 es cargar el valor de entrada d en la memoria interna
	.d      ( BUS_VALOR_INICIO ), // BUS de entrada para inicializar un valor
	// outputs
	.q       (  SALIDA ),   // Salida del contador
	.max_tick(         ),   // Señal de máximo
	.min_tick(         )    // Señal de mínimo
);
*/
