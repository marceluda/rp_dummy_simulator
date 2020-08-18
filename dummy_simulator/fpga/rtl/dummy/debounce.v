//////////////////////////////////////////////////////////////////////////////////
//
//
//  Maquina de estados que implementa un módulo de debounce:
//  Ante un cambio en la entrada, el cambio es reflejado en la salida
//  sólo sí se mantiene el nuevo valor por mas de un tiempo T determinado
//
//
//////////////////////////////////////////////////////////////////////////////////


/* Descripción de funcionamiento

Cuando in=0 y de pronto pasa a valer in=1 :
si el n=1 perdura por más de 2**N0 ticks de reloj ( 2**N0 * 8 ns ) 
  - se establece la salida db_level=1 
  - se envía por un único tick de reloj un pulso de 1 en db_tick

Cuando in=1 y de pronto pasa a valer in=0 :
si el n=0 perdura por más de 2**N1 ticks de reloj ( 2**N1 * 8 ns ) 
  - se establece la salida db_level=0 
  
Esto permite configurar tiempos de espera para la subida y la bajada diferentes.

N0 y N1 son parámetros fijados en tiempo de compilación y no cambian una ves implementado el circuito.

*/


module debounce #(parameter N0=7 , N1=4)
   (
    input wire clk, reset,
    input wire in,
    output reg db_level, db_tick
   );
   
   /*
    *  N0=7 ---> 8 ns * 2**7 ---> 1024 ns ~ 1us
    *  N1=2 ---> 8 ns * 2**2 --->   32 ns 
    */
   
   // symbolic state declaration
   localparam  [1:0]
               zero  = 2'b00,
               wait0 = 2'b01,
               one   = 2'b10,
               wait1 = 2'b11;
   
   // signal declaration
   reg [N0-1:0] q_reg, q_next;
   reg [1:0] state_reg, state_next;

   // body
   // fsmd state & data registers
    always @(posedge clk, posedge reset)
       if (reset)
          begin
             state_reg <= zero;
             q_reg <= 0;
          end
       else
          begin
             state_reg <= state_next;
             q_reg <= q_next;
          end

   // next-state logic & data path functional units/routing
   always @*
   begin
      state_next = state_reg;   // default state: the same
      q_next = q_reg;           // default q: unchnaged
      db_tick = 1'b0;           // default output: 0
      case (state_reg)
         zero:
            begin
               db_level = 1'b0;
               if (in)
                  begin
                     state_next = wait1;
                     q_next = {N0{1'b1}}; // load 1..1
                  end
            end
         wait1:
            begin
               db_level = 1'b0;
               if (in)
                  begin
                     q_next = q_reg - 1;
                     if (q_next==0)
                        begin
                           state_next = one;
                           db_tick = 1'b1;
                        end
                  end
               else // in==0
                  state_next = zero;
            end
         one:
            begin
               db_level = 1'b1;
               if (~in)
                  begin
                     state_next = wait0;
                     q_next = { {N0-N1{1'b0}}  , {N1{1'b1}}  }; // load 1..1
                  end
            end
         wait0:
            begin
               db_level = 1'b1;
               if (~in)
                  begin
                     q_next = q_reg - 1;
                     if (q_next==0)
                        state_next = zero;
                  end
               else // in==1
                  state_next = one;

            end
         default: state_next = zero;
      endcase
   end

endmodule


/* 
Instantiation example:

debounce #(.N0(7) , N1(4)) i_debounce_NAME ( .clk(clk), .reset(rst), .in(IN), .db_level(OUT), .db_tick (OUT_TICK)  );

*/
