`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Función de Signo
//
// Extrae el signo del número de la entrada in
//
//////////////////////////////////////////////////////////////////////////////////

/* Descripción:

Cuando in >= 0 coloca +1 en las salidas.
Cuando in <  0 coloca -1 en las salidas.

La salida out tiene una resolución de R bits (14 por defecto).
La salida out2bits tiene una resolución de 2 bits (el mínimo para definir +-1).

*/


//(* keep_hierarchy = "yes" *) 
module signo #(
   parameter     R   = 14
)
(
    //input clk,rst,
    input  signed [R-1:0] in,        // valor de entrada
    output signed [R-1:0] out,       // +1 o -1 en un cable igual al del entrada
    output signed [  1:0] out2bits   // +1 o -1 en un cable de dos bits
    );
    
    assign out      = in[R-1] ? {R{ 1'b1 }} : {  {R-1{ 1'b0 }} , 1'b1  } ;
    assign out2bits = in[R-1] ?       2'b11 :       2'b01                ;
    
    
endmodule

/* 
Instantiation example:

signo #( .R(14) ) i_signo ( .in( IN ), .out( OUT ) , .out2bits( OUT2 ) );

signo             i_signo ( .in( IN ), .out( OUT ) , .out2bits( OUT2 ) );

*/


