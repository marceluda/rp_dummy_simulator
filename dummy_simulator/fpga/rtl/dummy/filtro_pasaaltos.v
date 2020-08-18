`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Filtro Pasaaltos
// 
//////////////////////////////////////////////////////////////////////////////////

/* Descripción:

Implementa un filtro pasaaltos de primer orden (equivalente a un filtro RC).
La señal de entrada in es filtrada y su resultado sale por la salida out

Parámetros: (solo configurables en tiempo de instanciación/compilación)
  - R          : Resolución (en bits) de los buses/cables de entrada y salida in/out
  - TAU_OFFSET : Punto de partida para la definición del tiempo característico

Entradas:
  - tau     : Control del tiempo característico
  - dis     : Deshabilitar el filtro y dejar pasar la señal sin filtrar
  - in      : Señal de entrada a ser filtrada. Con signo.

Salidas:
  - out     : Salida de la señal filtrada.


Definición del tiempo característico del pasaaltos (T=RC):

    T = 8 ns * 2**(TAU_OFFSET + tau)

Para el valor por defecto TAU_OFFSET=14, la siguiente tabla muestra los
valores del tiempo característico T y la frecuencia de corte Freq
para cada valor asignado al cable tau:

  * Valores para TAU_OFFSET=0
  *   |       tau        |      T      |     Freq     |
  *   |               0  |    8.00 ns  |   19.89 MHz  |
  *   |               1  |   16.00 ns  |    9.95 MHz  |
  *   |               2  |   32.00 ns  |    4.97 MHz  |
  *   |               3  |   64.00 ns  |    2.49 MHz  |
  *   |               4  |  128.00 ns  |    1.24 MHz  |
  *   |               5  |  256.00 ns  |  621.70 kHz  |
  *   |               6  |  512.00 ns  |  310.85 kHz  |
  *   |               7  |    1.02 us  |  155.42 kHz  |
  *   |               8  |    2.05 us  |   77.71 kHz  |
  *   |               9  |    4.10 us  |   38.86 kHz  |
  *   |              10  |    8.19 us  |   19.43 kHz  |
  *   |              11  |   16.38 us  |    9.71 kHz  |
  *   |              12  |   32.77 us  |    4.86 kHz  |
  *   |              13  |   65.54 us  |    2.43 kHz  |
  *   |              14  |  131.07 us  |    1.21 kHz  |
  *   |              15  |  262.14 us  |  607.13  Hz  |
  *

La tabla para valores mas generales está abajo de todo.

*/


module filtro_pasaaltos #(parameter R=14, TAU_OFFSET=0)
    (
    input                  clk,rst,  // Clock and reset
    input         [ 4-1:0] tau,      // Tau, tiempo característico del filtro pasaaltos
    input                  dis,      // Disable bit 
    input  signed [ R-1:0] in,       // Entrada
    output signed [ R-1:0] out       // Salida
    );

    // R resolution of input and output signals
    // Low Pass Filter characteristi time is: 8 ns * 2**tau
    // max tau value = 62-R . For R=14, max tau=48
    //                        For R=28, max tau=34

    localparam S=58; // 45 works great

    reg  signed [S-1 :0] sum;
    wire signed [S   :0] sum_next;
    wire signed [31-1:0] sum_div;
    wire signed [   R:0] indiff;
    wire signed [31-1:0] indiff_pow;
    reg  signed [ R-1:0] last_in;
    wire signed [ R-1:0] last_in_next;

    reg                 step;
    wire                step_next;


    always @(posedge clk) begin
       if (rst) begin
           sum     <=    {S{1'b0}}    ;
           last_in <=    {R{1'b0}}    ;
        end
        else begin
           if ( sum_next[S:S-1] == 2'b01  )  // positive overflow
              sum    <=  {1'b0, {S-1{1'b1}} } ;
           else if ( sum_next[S:S-1] == 2'b10  )  // negative overflow
              sum    <=  {1'b1, {S-1{1'b0}} } ;
           else
              sum    <=  sum_next[S-1:0] ;
            last_in  <= last_in_next;
        end
    end

    assign last_in_next = in;
    assign indiff       =  ($signed(in) - $signed(last_in)) ;
    assign indiff_pow   =  $signed( { indiff, {TAU_OFFSET{1'b0}} }) <<<  tau ;
    assign sum_next     =  $signed(sum) - sum_div   + $signed(indiff_pow) - $signed( indiff )  ;
    assign sum_div      =  $signed(sum[S-1:TAU_OFFSET] ) >>> tau  ;

    assign out = ( dis ) ? in : sum_div[R-1:0] ;

endmodule

/*

Ejemplos de instanciación:

filtro_pasaaltos #(.R(14),.TAU_OFFSET(0)) i_filtro_pasaaltos_NAME (
    .clk(clk), .rst(rst), 
    // inputs
    .tau( 14'd12   ), 
    .dis( 1'b0     ), 
    .in(  IN       ),
    // outputs
    .out(  OUT     ) 
);

filtro_pasaaltos #(.R(14),.TAU_OFFSET(0)) i_filtro_pasaaltos_NAME (.clk(clk),.rst(rst), .tau( 14'd12   ), .dis( 1'b0 ), .in(  IN  ),.out(  OUT  ) );

filtro_pasaaltos i_filtro_pasaaltos_NAME (.clk(clk),.rst(rst), .tau( 14'd12   ), .dis( 1'b0 ), .in(  IN  ),.out(  OUT  ) );


*/


/** Tabla general
  *   | TAU_OFFSET + tau |      T      |     Freq     |
  *   |               0  |    8.00 ns  |   19.89 MHz  |
  *   |               1  |   16.00 ns  |    9.95 MHz  |
  *   |               2  |   32.00 ns  |    4.97 MHz  |
  *   |               3  |   64.00 ns  |    2.49 MHz  |
  *   |               4  |  128.00 ns  |    1.24 MHz  |
  *   |               5  |  256.00 ns  |  621.70 kHz  |
  *   |               6  |  512.00 ns  |  310.85 kHz  |
  *   |               7  |    1.02 us  |  155.42 kHz  |
  *   |               8  |    2.05 us  |   77.71 kHz  |
  *   |               9  |    4.10 us  |   38.86 kHz  |
  *   |              10  |    8.19 us  |   19.43 kHz  |
  *   |              11  |   16.38 us  |    9.71 kHz  |
  *   |              12  |   32.77 us  |    4.86 kHz  |
  *   |              13  |   65.54 us  |    2.43 kHz  |
  *   |              14  |  131.07 us  |    1.21 kHz  |
  *   |              15  |  262.14 us  |  607.13  Hz  |
  *   |              16  |  524.29 us  |  303.56  Hz  |
  *   |              17  |    1.05 ms  |  151.78  Hz  |
  *   |              18  |    2.10 ms  |   75.89  Hz  |
  *   |              19  |    4.19 ms  |   37.95  Hz  |
  *   |              20  |    8.39 ms  |   18.97  Hz  |
  *   |              21  |   16.78 ms  |    9.49  Hz  |
  *   |              22  |   33.55 ms  |    4.74  Hz  |
  *   |              23  |   67.11 ms  |    2.37  Hz  |
  *   |              24  |  134.22 ms  |    1.19  Hz  |
  *   |              25  |  268.44 ms  |  592.90 mHz  |
  *   |              26  |  536.87 ms  |  296.45 mHz  |
  *   |              27  |    1.07  s  |  148.22 mHz  |
  *   |              28  |    2.15  s  |   74.11 mHz  |
  *   |              29  |    4.29  s  |   37.06 mHz  |
  *   |              30  |    8.59  s  |   18.53 mHz  |
  *   |              31  |   17.18  s  |    9.26 mHz  |
  *
  */
  


/*  Python code for reference table:
from numpy import *
import matplotlib.pyplot as plt

units={ -3: 'n', 
        -2: 'u',
        -1: 'm',
         0: ' ',
         1: 'k',
         2: 'M',
         3: 'G'
        }

print('/** Values of tau')
print('  *   | num  |     Tau     |     Freq     |')

for i in arange(16):
    tau =8e-9 * 2**(i+14)
    oom =floor(log10(tau)/3).astype(int)
    val =tau/10.0**(3*oom)
    freq=1/(2*pi*tau)
    foom=floor(log10(freq)/3).astype(int)
    fval=freq/10.0**(3*foom)
    print('  *   |  {:>2d}  |  {:6.2f} {:s}s  '.format(i,val,units[oom])+
          '|  {:6.2f} {:s}Hz  |'.format(fval,units[foom]))
print('  *')


*/
