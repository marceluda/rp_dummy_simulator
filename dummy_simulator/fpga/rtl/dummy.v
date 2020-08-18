`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// This parts are automatic set definitions                                     //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//(* dont_touch = "true" *)
//(* keep = "true" *)
//(* use_dsp48 = "yes" *)
//(* fsm_encoding = "gray" *)


//(* keep_hierarchy = "yes" *)
module dummy(
    input clk,rst,
    // inputs
    input  signed   [14-1:0] in1,in2,
    input                    external_trigger,   // External triger input

    // outputs
    output signed   [14-1:0] out1,out2,
    output signed   [14-1:0] osc1,osc2,
    output                   trigger,            // Oscilloscope trigger output
    output                   digital_modulation, // Modulation for digital otuput
    output reg      [24-1:0] pwm_cfg_a,pwm_cfg_b,pwm_cfg_c,pwm_cfg_d,
    output reg      [32-1:0] osc_ctrl,

    // system bus
    input           [32-1:0] sys_addr        ,  //!< bus address
    input           [32-1:0] sys_wdata       ,  //!< bus write data
    input           [ 4-1:0] sys_sel         ,  //!< bus write byte select
    input                    sys_wen         ,  //!< bus write enable
    input                    sys_ren         ,  //!< bus read enable
    output reg      [32-1:0] sys_rdata       ,  //!< bus read data
    output reg               sys_err         ,  //!< bus error indicator
    output reg               sys_ack            //!< bus acknowledge signal
    );

    // Module starts here  *********************************************


    // [WIREREG DOCK]
    // dummy --------------------------
    reg                  lpf_on,hpf_on,noise_enable,drift_enable;
    reg         [ 3-1:0] entrada,read_ctrl;
    reg         [ 4-1:0] lpf_val,hpf_val,drift_time;
    reg  signed [14-1:0] peak_pos,sg_amp,sg_width,sg_base,noise_amp;
    wire signed [14-1:0] val_fun,noise_std;
    
    // inout --------------------------
    wire        [12-1:0] slow_out1,slow_out2,slow_out3,slow_out4;
    wire signed [14-1:0] oscA,oscB;
    
    // outputs --------------------------
    reg         [ 4-1:0] out1_sw,out2_sw,slow_out1_sw,slow_out2_sw,slow_out3_sw,slow_out4_sw;
    
    // scope --------------------------
    reg         [ 5-1:0] oscA_sw,oscB_sw;
    reg         [ 8-1:0] trig_sw;
    
    // [WIREREG DOCK END]

    wire signed [14-1:0] slow_out1_14,slow_out2_14,slow_out3_14,slow_out4_14 ;
    wire        [16-1:0] slow_out1_au,slow_out2_au,slow_out3_au,slow_out4_au ;
    wire        [24-1:0] slow_out1_aux,slow_out2_aux,slow_out3_aux,slow_out4_aux ;

    //////////////////////////////////////////////////////////////////////////////////
    //                                                                              //
    // Start writting your modules HERE                                             //
    //                                                                              //
    //////////////////////////////////////////////////////////////////////////////////


    // Useful bus wires already defined :
    //   in1       --> 14 bits   signed bus (     -8192 --> 8191      ) , ADC from input 1
    //   in2       --> 14 bits   signed bus (     -8192 --> 8191      ) , ADC from input 2

    //   entrada   -->  3 bits unsigned bus (         0 --> 7         )
    //   lpf_on    -->  1 bits unsigned bus (         0 --> 1         )
    //   lpf_val   -->  4 bits unsigned bus (         0 --> 15        )
    //   hpf_on    -->  1 bits unsigned bus (         0 --> 1         )
    //   hpf_val   -->  4 bits unsigned bus (         0 --> 15        )
    //   peak_pos  --> 14 bits   signed bus (     -8192 --> 8191      )
    //   sg_amp    --> 14 bits   signed bus (     -8192 --> 8191      )
    //   sg_width  --> 14 bits   signed bus (     -8192 --> 8191      )
    //   noise_enable-->  1 bits unsigned bus (         0 --> 1         )
    //   noise_amp --> 14 bits   signed bus (     -8192 --> 8191      )
    //   drift_enable-->  1 bits unsigned bus (         0 --> 1         )
    //   drift_time-->  4 bits unsigned bus (         0 --> 15        )
    //   val_fun   --> 14 bits   signed bus (     -8192 --> 8191      )
    //   noise_std --> 14 bits   signed bus (     -8192 --> 8191      )




    // For output signals, configure the out1_sw_m and out2_sw_m multiplexers below

    // -----------------------------------------------------------------------------------------
    // First of all, ALWAYS, write down cable definitions
    // -----------------------------------------------------------------------------------------

    wire  signed [14-1:0] signal_in , signal_lpf, signal_hpf , pico_out , salida , rand_norm; // Señal de control del fenómeno
    wire  signed [14-1:0] pico_in, noise,in_sum,in_diff,pico_in_wo_offset,base;
    wire  signed [15-1:0] in_sum_15,in_diff_15;
    wire  signed [16-1:0] pico_in_sum , salida_sum;
    wire  signed [27-1:0] fun_out_tmp,pico_in_27,noise_27, base_27;
    wire         [32-1:0] rand_out ;

    wire                  max_ramp ;
    wire  signed [14-1:0] ramp,pico_simul_out,val_simul , simul, simul_in , simul_in_wo_offset,simul_base;
    wire  signed [16-1:0] simul_in_sum, simul_sum ;
    wire  signed [27-1:0] fun_simul_out , simul_in_27,simul_base_27;


    wire  signed [14-1:0] drift ;


    // -----------------------------------------------------------------------------------------
    // NOW CONNECT CABLES AND MODULES
    // -----------------------------------------------------------------------------------------


        // Input Channel 1 : OscA
        muxer_reg3  #(.RES(14)) i_muxer3_signal_in (
            // input
            .clk(clk), .rst(rst),
            .sel  ( entrada   ), // select cable
            .in0  ( in1       ),
            .in1  ( in2       ),
            .in2  ( in_sum     ),
            .in3  ( in_diff     ),
            .in4  ( 14'b0     ),
            .in5  ( 14'b0     ),
            .in6  ( 14'b0     ),
            .in7  ( 14'b0     ),

            // output
            .out ( signal_in  )
        );

        assign base_27 = sg_base* signal_in ;
        assign base    = base_27 >>> 14 ;


        filtro_pasabajos #(.R(14),.TAU_OFFSET(4)) i_filtro_pasabajos_A (.clk(clk),.rst(rst), .tau( lpf_val   ), .dis( ~lpf_on ), .in(  signal_in  ),.out(  signal_lpf  ) );

        filtro_pasaaltos #(.R(14),.TAU_OFFSET(0)) i_filtro_pasaaltos_A (.clk(clk),.rst(rst), .tau( hpf_val   ), .dis( ~hpf_on ), .in(  signal_lpf  ),.out(  signal_hpf  ) );


        assign pico_in_27            = signal_hpf * sg_width ;
        assign pico_in_wo_offset     = pico_in_27>>>13 ;

        assign pico_in_sum           = peak_pos + pico_in_wo_offset +   $signed(drift) ;

        satprotect #(.Ri(15),.Ro(14),.SAT(14)) i_satprotect_pico_in_sum  ( .in(pico_in_sum),  .out(pico_in) );


        fun_pico i_fun_pico_A  ( .clk(clk), .rst(rst), .in( pico_in ),  .out( pico_out ) );

        rand_gen_uni i_rand_gen_uni_A  ( .clk(clk), .rst(rst), .run( noise_enable ),  .out( rand_out ) );
        fun_icdf i_fun_icdf  ( .clk(clk), .rst(rst), .in( $signed(rand_out[32-1:21]) ),  .out( rand_norm ) );

        assign noise_27    = rand_norm * noise_amp ;
        assign noise       = noise_enable ? noise_27>>> 13  :  14'b0 ;

        assign fun_out_tmp =  pico_out * $signed( sg_amp ) ;

        assign val_fun     = $signed( fun_out_tmp[27-1:13] ) ;

        assign salida_sum  =  val_fun + noise + base ;
        //assign salida      =  $signed( fun_out_tmp[27-1:13] ) ;

        satprotect #(.Ri(16),.Ro(14),.SAT(14)) i_satprotect_salida  ( .in(salida_sum),  .out(salida) );

        assign in_sum_15  = in1 + in2 ;
        assign in_diff_15 = in1 - in2 ;

        satprotect #(.Ri(15),.Ro(14),.SAT(14)) i_satprotect_in_sum   ( .in(in_sum_15),   .out(in_sum) );
        satprotect #(.Ri(15),.Ro(14),.SAT(14)) i_satprotect_in_diff  ( .in(in_diff_15),  .out(in_diff) );


        // Let's make a copy of the signal with continuous scan  ----------------------------------------------------

        UniversalCounter #( .N(14) ) i_UniversalCounter_NAME (
        	.clk(clk), .reset(rst),
        	// inputs
        	.en     (             1'b1 ), // 1 es enable / encendido
        	.up     (             1'b1 ), // 1 es sumar, 0 es restar
        	.syn_clr(             1'b0 ), // 1 es resetear el contador
        	.load   (         max_ramp ), // 1 es cargar el valor de entrada d en la memoria interna
        	.d      (        0 ), // BUS de entrada para inicializar un valor
        	// outputs
        	.q       (    ramp ),   // Salida del contador
        	.max_tick(    max_ramp     ),   // Señal de máximo
        	.min_tick(         )    // Señal de mínimo
        );



        assign simul_in_27            = $signed(ramp) * sg_width ;

        assign simul_base_27 = sg_base* ramp ;
        assign simul_base    = simul_base_27 >>> 14 ;

        assign simul_in_wo_offset     = simul_in_27>>>13 ;
        assign simul_in_sum           = peak_pos + simul_in_wo_offset +  $signed(drift) ;

        satprotect #(.Ri(15),.Ro(14),.SAT(14)) i_satprotect_pico_simul_in ( .in(simul_in_sum),  .out(simul_in) );

        fun_pico i_fun_pico_B  ( .clk(clk), .rst(rst), .in(simul_in ),  .out( pico_simul_out ) );
        assign fun_simul_out =  pico_simul_out * $signed( sg_amp ) ;

        assign val_simul     = $signed( fun_simul_out[27-1:13] ) ;

        assign simul_sum  =  val_simul + noise + simul_base ;

        satprotect #(.Ri(16),.Ro(14),.SAT(14)) i_satprotect_simul  ( .in(simul_sum),  .out(simul) );



        // drift part:
        wire          max_drift , min_drift, drift_way_next ;
        reg           drift_way ;
        reg  [16-1:0] cnt       ;
        wire [16-1:0] cnt_next ,  cnt_max    ;
        wire [14-1:0] drift_o     ;

        UniversalCounter #( .N(14) ) i_UniversalCounter_drift (
            .clk(clk), .reset(rst),
            // inputs
            .en     (         (cnt==16'b0) & drift_enable ), // 1 es enable / encendido
            .up     (              drift_way ), // 1 es sumar, 0 es restar
            .syn_clr(              1'b0 ), // 1 es resetear el contador
            .load   (    ~drift_enable      ), // 1 es cargar el valor de entrada d en la memoria interna
            .d      (         14'b0     ), // BUS de entrada para inicializar un valor
            // outputs
            .q       (    drift_o         ),   // Salida del contador
            .max_tick(    max_drift     ),   // Señal de máximo
            .min_tick(    min_drift     )    // Señal de mínimo
        );


        always @(posedge clk)
        if (rst) begin
            drift_way  <= 1'b1 ;
            cnt        <= 16'b0 ;
        end
        else begin
            drift_way  <= drift_way_next ;
            cnt        <= cnt_next ;
        end

        assign drift_way_next = max_drift ? 1'b0 :
                                min_drift ? 1'b1 : drift_way  ;

        assign cnt_max  = 16'b01 << drift_time ;
        assign cnt_next = cnt==cnt_max ? 16'b0 : cnt+16'd1 ;

        assign drift = drift_enable ? (drift_o >>> 1) - 14'd4095 : 14'b0  ;



    //////////////////////////////////////////////////////////////////////////////////
    //                                                                              //
    // The next lines are for already defined controls                              //
    // Use it to change cables that goes to Oscilloscope or Outputs                 //
    //                                                                              //
    //////////////////////////////////////////////////////////////////////////////////


    // -----------------------------------------------------------------------------------------
    // Oscilloscope INPUT channels
    // -----------------------------------------------------------------------------------------

    // Input Channel 1 : OscA
    muxer_reg5  #(.RES(14)) i_muxer5_scope1 (
        // input
        .clk(clk), .rst(rst),
        .sel  ( oscA_sw ), // select cable
        .in0  ( ramp     ),
        .in1  ( signal_in       ),
        .in2  ( in1       ),
        .in3  ( in2     ),
        .in4  ( signal_lpf     ),
        .in5  ( signal_hpf    ),
        .in6  ( val_fun     ),
        .in7  ( salida    ),
        .in8  ( rand_norm     ),
        .in9  ( noise    ),
        .in10 ( ramp     ),
        .in11 ( simul     ),
        .in12 ( drift     ),
        .in13 ( base     ),
        .in14 ( 14'b0     ),
        .in15 ( 14'b0     ),
        .in16 ( 14'b0     ),
        .in17 ( 14'b0     ),
        .in18 ( 14'b0     ),
        .in19 ( 14'b0     ),
        .in20 ( 14'b0     ),
        .in21 ( 14'b0     ),
        .in22 ( 14'b0     ),
        .in23 ( 14'b0     ),
        .in24 ( 14'b0     ),
        .in25 ( 14'b0     ),
        .in26 ( 14'b0     ),
        .in27 ( 14'b0     ),
        .in28 ( 14'b0     ),
        .in29 ( 14'b0     ),
        .in30 ( 14'b0     ),
        .in31 ( 14'b0     ),

        // output
        .out ( oscA  )
    );

    // Input Channel 2 : OscB
    muxer_reg5  #(.RES(14)) i_muxer5_scope2 (
        // input
        .clk(clk), .rst(rst),
        .sel  ( oscB_sw ), // select cable
        .in0  ( simul     ),
        .in1  ( salida       ),
        .in2  ( in1       ),
        .in3  ( in2     ),
        .in4  ( signal_lpf     ),
        .in5  ( signal_hpf    ),
        .in6  ( val_fun     ),
        .in7  ( salida    ),
        .in8  ( rand_norm     ),
        .in9  ( noise    ),
        .in10 ( ramp     ),
        .in11 ( simul     ),
        .in12 ( drift     ),
        .in13 ( base     ),
        .in14 ( 14'b0     ),
        .in15 ( 14'b0     ),
        .in16 ( 14'b0     ),
        .in17 ( 14'b0     ),
        .in18 ( 14'b0     ),
        .in19 ( 14'b0     ),
        .in20 ( 14'b0     ),
        .in21 ( 14'b0     ),
        .in22 ( 14'b0     ),
        .in23 ( 14'b0     ),
        .in24 ( 14'b0     ),
        .in25 ( 14'b0     ),
        .in26 ( 14'b0     ),
        .in27 ( 14'b0     ),
        .in28 ( 14'b0     ),
        .in29 ( 14'b0     ),
        .in30 ( 14'b0     ),
        .in31 ( 14'b0     ),

        // output
        .out ( oscB  )
    );

    assign osc1 = oscA;
    assign osc2 = oscB;

    // -----------------------------------------------------------------------------------------
    // Fast OUTPUTs selector (for RF signals)
    // -----------------------------------------------------------------------------------------

    // Output OUT1
    muxer4  #(.RES(14)) out1_sw_m (
        // input
        .sel  ( out1_sw           ), // select cable
        .in0  ( 14'b0     ),
        .in1  ( salida       ),
        .in2  ( in1       ),
        .in3  ( in2     ),
        .in4  ( signal_lpf     ),
        .in5  ( signal_hpf     ),
        .in6  ( noise     ),
        .in7  ( ramp    ),
        .in8  ( simul     ),
        .in9  ( 14'b0     ),
        .in10 ( 14'b0     ),
        .in11 ( 14'b0     ),
        .in12 ( 14'b0     ),
        .in13 ( 14'b0     ),
        .in14 ( 14'b0     ),
        .in15 ( 14'b0     ),
        // output
        .out ( out1   )
    );

    // Output OUT2
    muxer4  #(.RES(14)) out2_sw_m (
        // input
        .sel  ( out2_sw          ), // select cable
        .in0  ( 14'b0     ),
        .in1  ( salida       ),
        .in2  ( in1       ),
        .in3  ( in2     ),
        .in4  ( signal_lpf     ),
        .in5  ( signal_hpf     ),
        .in6  ( noise     ),
        .in7  ( ramp    ),
        .in8  ( simul     ),
        .in9  ( 14'b0     ),
        .in10 ( 14'b0     ),
        .in11 ( 14'b0     ),
        .in12 ( 14'b0     ),
        .in13 ( 14'b0     ),
        .in14 ( 14'b0     ),
        .in15 ( 14'b0     ),
        // output
        .out ( out2  )
    );


    // -----------------------------------------------------------------------------------------
    // Slow OUTPUTs selectors (for expansion pins)
    // -----------------------------------------------------------------------------------------

    // Configuration for slow_outputs
    always @(posedge clk)
    if (rst) begin
        pwm_cfg_a  <= 24'h0 ;
        pwm_cfg_b  <= 24'h0 ;
        pwm_cfg_c  <= 24'h0 ;
        pwm_cfg_d  <= 24'h0 ;
    end
    else begin
        pwm_cfg_a  <= pwm_cfg_a_w ;
        pwm_cfg_b  <= pwm_cfg_b_w ;
        pwm_cfg_c  <= pwm_cfg_c_w ;
        pwm_cfg_d  <= pwm_cfg_d_w ;
    end

    // Slow DACs outputs *************
    // map to 0 - 1.8 V

    //assign slow_out1_au  =  $signed(slow_out1_14) + $signed(15'd8192)  ;
    //assign slow_out2_au  =  $signed(slow_out2_14) + $signed(15'd8192)  ;
    assign slow_out3_au  =  $signed(slow_out3_14) + $signed(15'd8192)  ;
    assign slow_out4_au  =  $signed(slow_out4_14) + $signed(15'd8192)  ;

    //assign slow_out1_aux = slow_out1_au * 8'd156 ;
    //assign slow_out2_aux = slow_out2_au * 8'd156 ;

    pipe_mult #(.R(16),.level(4)) i_mult_slow_out3_aux (.clk(clk), .a(slow_out3_au) , .b(16'd156), .pdt(slow_out3_aux));
    pipe_mult #(.R(16),.level(4)) i_mult_slow_out4_aux (.clk(clk), .a(slow_out4_au) , .b(16'd156), .pdt(slow_out4_aux));
    //assign slow_out3_aux = slow_out3_au * 8'd156 ;
    //assign slow_out4_aux = slow_out4_au * 8'd156 ;

    //assign slow_out1     = slow_out1_aux[22-1:10];
    //assign slow_out2     = slow_out2_aux[22-1:10];
    assign slow_out3     = slow_out3_aux[22-1:10];
    assign slow_out4     = slow_out4_aux[22-1:10];



    /* DISABLED BY LOLO -- Reapir
    muxer4  #(.RES(14)) slow_out1_sw_m (
        // input
        .sel  ( slow_out1_sw ), // select cable
        .in0  ( 14'b10000000000000),
        .in1  ( in1               ), // in1
        .in2  ( in2               ), // in1-in2
        .in3  ( in1_m_in2[14-1:0] ), // in3
        .in4  ( sin_ref           ), // in4
        .in5  ( cos_1f            ), // in5
        .in6  ( cos_2f            ), // in6
        .in7  ( cos_3f            ), // in7
        .in8  ( sq_ref            ), // in8
        .in9  ( sq_phas           ), // in9
        .in10 ( ramp_A            ), // in10
        .in11 ( pidA_out          ), // in11
        .in12 ( ctrl_A            ), // in12
        .in13 ( ctrl_B            ), // in13
        .in14 ( error             ), // in14
        .in15 ( aux_A             ), // in15
        // output
        .out ( slow_out1_14  )
    );

    muxer4  #(.RES(14)) slow_out2_sw_m (
        // input
        .sel  ( slow_out2_sw ), // select cable
        .in0  ( 14'b10000000000000),
        .in1  ( in1               ), // in1
        .in2  ( in2               ), // in1-in2
        .in3  ( in1_m_in2[14-1:0] ), // in3
        .in4  ( cos_ref           ), // in4
        .in5  ( cos_1f            ), // in5
        .in6  ( cos_2f            ), // in6
        .in7  ( cos_3f            ), // in7
        .in8  ( sq_quad           ), // in8
        .in9  ( sq_phas           ), // in9
        .in10 ( ramp_B            ), // in10
        .in11 ( pidA_out          ), // in11
        .in12 ( ctrl_A            ), // in12
        .in13 ( ctrl_B            ), // in13
        .in14 ( error             ), // in14
        .in15 ( aux_B             ), // in15
        // output
        .out ( slow_out2_14  )
    );
    */
    assign     slow_out1_14 = 14'b10000000000000 ;
    assign     slow_out2_14 = 14'b10000000000000 ;


    muxer_reg4  #(.RES(14)) slow_out3_sw_m (
        // input
        .clk(clk), .rst(rst),
        .sel  ( slow_out3_sw ), // select cable
        .in0  ( 14'b10000000000000),
        .in1  ( in1               ), // in1
        .in2  ( in2               ), // in1-in2
        .in3  ( 14'b0             ), // in3
        .in4  ( 14'b0             ), // in4
        .in5  ( 14'b0             ), // in5
        .in6  ( 14'b0             ), // in6
        .in7  ( 14'b0             ), // in7
        .in8  ( 14'b0             ), // in8
        .in9  ( 14'b0             ), // in9
        .in10 ( 14'b0             ), // in10
        .in11 ( 14'b0             ), // in11
        .in12 ( 14'b0             ), // in12
        .in13 ( 14'b0             ), // in13
        .in14 ( 14'b0             ), // in14
        .in15 ( 14'b0             ), // in15
        // output
        .out ( slow_out3_14  )
    );


    muxer_reg4  #(.RES(14)) slow_out4_sw_m (
        // input
        .clk(clk), .rst(rst),
        .sel  ( slow_out4_sw ), // select cable
        .in0  ( 14'b10000000000000),
        .in1  ( in1               ), // in1
        .in2  ( in2               ), // in1-in2
        .in3  ( 14'b0             ), // in3
        .in4  ( 14'b0             ), // in4
        .in5  ( 14'b0             ), // in5
        .in6  ( 14'b0             ), // in6
        .in7  ( 14'b0             ), // in7
        .in8  ( 14'b0             ), // in8
        .in9  ( 14'b0             ), // in9
        .in10 ( 14'b0             ), // in10
        .in11 ( 14'b0             ), // in11
        .in12 ( 14'b0             ), // in12
        .in13 ( 14'b0             ), // in13
        .in14 ( 14'b0             ), // in14
        .in15 ( 14'b0             ), // in15
        // output
        .out ( slow_out4_14  )
    );

    // Slow DACs decoders
    aDACdecoder i_aDACdecoder_a (  .clk(clk), .rst(rst), .in(slow_out1),  .out(pwm_cfg_a_w)  );
    aDACdecoder i_aDACdecoder_b (  .clk(clk), .rst(rst), .in(slow_out2),  .out(pwm_cfg_b_w)  );
    aDACdecoder i_aDACdecoder_c (  .clk(clk), .rst(rst), .in(slow_out3),  .out(pwm_cfg_c_w)  );
    aDACdecoder i_aDACdecoder_d (  .clk(clk), .rst(rst), .in(slow_out4),  .out(pwm_cfg_d_w)  );


    // -----------------------------------------------------------------------------------------
    // External Trigger  selection
    // -----------------------------------------------------------------------------------------

    assign  trigger_signals = {  1'b0   ,
                                 ramp[14-1]   ,
                                 1'b0   ,
                                 1'b0   ,
                                 1'b0   ,
                                 1'b0   ,
                                 1'b0   ,
                                 external_trigger
                              } ;

    trigger_input  #(.R(8),.N(3)) i_trigger_input (
        // input
        .clk(clk), .rst(rst),
        .trig_in ( trigger_signals ),
        .trig_sel( trig_sw         ),
        // output
        .trig_tick(trigger)
    ) ;





    // -----------------------------------------------------------------------------------------
    // Registers and wire comunications with CPU memory
    // -----------------------------------------------------------------------------------------


    // [FPGA MEMORY DOCK]
    //---------------------------------------------------------------------------------
    //
    //  System bus connection
    
    // SO --> MEMORIA --> FPGA
    
    always @(posedge clk)
    if (rst) begin
        oscA_sw                <=   5'd0     ; // switch for muxer oscA
        oscB_sw                <=   5'd0     ; // switch for muxer oscB
        osc_ctrl               <=   2'd3     ; // oscilloscope control // [osc2_filt_off,osc1_filt_off]
        trig_sw                <=   8'd0     ; // Select the external trigger signal
        out1_sw                <=   4'd1     ; // switch for muxer out1
        out2_sw                <=   4'd0     ; // switch for muxer out2
        slow_out1_sw           <=   4'd0     ; // switch for muxer slow_out1
        slow_out2_sw           <=   4'd0     ; // switch for muxer slow_out2
        slow_out3_sw           <=   4'd0     ; // switch for muxer slow_out3
        slow_out4_sw           <=   4'd0     ; // switch for muxer slow_out4
        entrada                <=   3'd0     ; // Added automatically by script
        lpf_on                 <=   1'd1     ; // Added automatically by script
        lpf_val                <=   4'd6     ; // Added automatically by script
        hpf_on                 <=   1'd0     ; // Added automatically by script
        hpf_val                <=   4'd0     ; // Added automatically by script
        peak_pos               <=  14'd0     ; // Added automatically by script
        sg_amp                 <=  14'd4192  ; // Added automatically by script
        sg_width               <=  14'd8191  ; // Added automatically by script
        sg_base                <=  14'd0     ; // Added automatically by script
        noise_enable           <=   1'd0     ; // Added automatically by script
        noise_amp              <=  14'd1024  ; // Added automatically by script
        drift_enable           <=   1'd0     ; // Added automatically by script
        drift_time             <=   4'd13    ; // Added automatically by script
        read_ctrl              <=   3'd0     ; // [unused,start_clk,Freeze]
    end else begin
        if (sys_wen) begin
            if (sys_addr[19:0]==20'h00000)  oscA_sw               <=  sys_wdata[ 5-1: 0] ; // switch for muxer oscA
            if (sys_addr[19:0]==20'h00004)  oscB_sw               <=  sys_wdata[ 5-1: 0] ; // switch for muxer oscB
            if (sys_addr[19:0]==20'h00008)  osc_ctrl              <=  sys_wdata[ 2-1: 0] ; // oscilloscope control // [osc2_filt_off,osc1_filt_off]
            if (sys_addr[19:0]==20'h0000C)  trig_sw               <=  sys_wdata[ 8-1: 0] ; // Select the external trigger signal
            if (sys_addr[19:0]==20'h00010)  out1_sw               <=  sys_wdata[ 4-1: 0] ; // switch for muxer out1
            if (sys_addr[19:0]==20'h00014)  out2_sw               <=  sys_wdata[ 4-1: 0] ; // switch for muxer out2
            if (sys_addr[19:0]==20'h00018)  slow_out1_sw          <=  sys_wdata[ 4-1: 0] ; // switch for muxer slow_out1
            if (sys_addr[19:0]==20'h0001C)  slow_out2_sw          <=  sys_wdata[ 4-1: 0] ; // switch for muxer slow_out2
            if (sys_addr[19:0]==20'h00020)  slow_out3_sw          <=  sys_wdata[ 4-1: 0] ; // switch for muxer slow_out3
            if (sys_addr[19:0]==20'h00024)  slow_out4_sw          <=  sys_wdata[ 4-1: 0] ; // switch for muxer slow_out4
          //if (sys_addr[19:0]==20'h00028)  in1                   <=  sys_wdata[14-1: 0] ; // Input signal IN1
          //if (sys_addr[19:0]==20'h0002C)  in2                   <=  sys_wdata[14-1: 0] ; // Input signal IN2
          //if (sys_addr[19:0]==20'h00030)  out1                  <=  sys_wdata[14-1: 0] ; // signal for RP RF DAC Out1
          //if (sys_addr[19:0]==20'h00034)  out2                  <=  sys_wdata[14-1: 0] ; // signal for RP RF DAC Out2
          //if (sys_addr[19:0]==20'h00038)  slow_out1             <=  sys_wdata[12-1: 0] ; // signal for RP slow DAC 1
          //if (sys_addr[19:0]==20'h0003C)  slow_out2             <=  sys_wdata[12-1: 0] ; // signal for RP slow DAC 2
          //if (sys_addr[19:0]==20'h00040)  slow_out3             <=  sys_wdata[12-1: 0] ; // signal for RP slow DAC 3
          //if (sys_addr[19:0]==20'h00044)  slow_out4             <=  sys_wdata[12-1: 0] ; // signal for RP slow DAC 4
          //if (sys_addr[19:0]==20'h00048)  oscA                  <=  sys_wdata[14-1: 0] ; // signal for Oscilloscope Channel A
          //if (sys_addr[19:0]==20'h0004C)  oscB                  <=  sys_wdata[14-1: 0] ; // signal for Oscilloscope Channel B
            if (sys_addr[19:0]==20'h00050)  entrada               <=  sys_wdata[ 3-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h00054)  lpf_on                <= |sys_wdata[32-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h00058)  lpf_val               <=  sys_wdata[ 4-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h0005C)  hpf_on                <= |sys_wdata[32-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h00060)  hpf_val               <=  sys_wdata[ 4-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h00064)  peak_pos              <=  sys_wdata[14-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h00068)  sg_amp                <=  sys_wdata[14-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h0006C)  sg_width              <=  sys_wdata[14-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h00070)  sg_base               <=  sys_wdata[14-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h00074)  noise_enable          <= |sys_wdata[32-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h00078)  noise_amp             <=  sys_wdata[14-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h0007C)  drift_enable          <= |sys_wdata[32-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h00080)  drift_time            <=  sys_wdata[ 4-1: 0] ; // Added automatically by script
          //if (sys_addr[19:0]==20'h00084)  val_fun               <=  sys_wdata[14-1: 0] ; // Added automatically by script
          //if (sys_addr[19:0]==20'h00088)  noise_std             <=  sys_wdata[14-1: 0] ; // Added automatically by script
            if (sys_addr[19:0]==20'h0008C)  read_ctrl             <=  sys_wdata[ 3-1: 0] ; // [unused,start_clk,Freeze]
        end
    end
    //---------------------------------------------------------------------------------
    // FPGA --> MEMORIA --> SO
    wire sys_en;
    assign sys_en = sys_wen | sys_ren;
    
    always @(posedge clk, posedge rst)
    if (rst) begin
        sys_err <= 1'b0  ;
        sys_ack <= 1'b0  ;
    end else begin
        sys_err <= 1'b0 ;
        
        casez (sys_addr[19:0])
            20'h00000 : begin sys_ack <= sys_en;  sys_rdata <= {  27'b0                   ,          oscA_sw  }; end // switch for muxer oscA
            20'h00004 : begin sys_ack <= sys_en;  sys_rdata <= {  27'b0                   ,          oscB_sw  }; end // switch for muxer oscB
            20'h00008 : begin sys_ack <= sys_en;  sys_rdata <= {  30'b0                   ,         osc_ctrl  }; end // oscilloscope control // [osc2_filt_off,osc1_filt_off]
            20'h0000C : begin sys_ack <= sys_en;  sys_rdata <= {  24'b0                   ,          trig_sw  }; end // Select the external trigger signal
            20'h00010 : begin sys_ack <= sys_en;  sys_rdata <= {  28'b0                   ,          out1_sw  }; end // switch for muxer out1
            20'h00014 : begin sys_ack <= sys_en;  sys_rdata <= {  28'b0                   ,          out2_sw  }; end // switch for muxer out2
            20'h00018 : begin sys_ack <= sys_en;  sys_rdata <= {  28'b0                   ,     slow_out1_sw  }; end // switch for muxer slow_out1
            20'h0001C : begin sys_ack <= sys_en;  sys_rdata <= {  28'b0                   ,     slow_out2_sw  }; end // switch for muxer slow_out2
            20'h00020 : begin sys_ack <= sys_en;  sys_rdata <= {  28'b0                   ,     slow_out3_sw  }; end // switch for muxer slow_out3
            20'h00024 : begin sys_ack <= sys_en;  sys_rdata <= {  28'b0                   ,     slow_out4_sw  }; end // switch for muxer slow_out4
            20'h00028 : begin sys_ack <= sys_en;  sys_rdata <= {  {18{in1[13]}}           ,              in1  }; end // Input signal IN1
            20'h0002C : begin sys_ack <= sys_en;  sys_rdata <= {  {18{in2[13]}}           ,              in2  }; end // Input signal IN2
            20'h00030 : begin sys_ack <= sys_en;  sys_rdata <= {  {18{out1[13]}}          ,             out1  }; end // signal for RP RF DAC Out1
            20'h00034 : begin sys_ack <= sys_en;  sys_rdata <= {  {18{out2[13]}}          ,             out2  }; end // signal for RP RF DAC Out2
            20'h00038 : begin sys_ack <= sys_en;  sys_rdata <= {  20'b0                   ,        slow_out1  }; end // signal for RP slow DAC 1
            20'h0003C : begin sys_ack <= sys_en;  sys_rdata <= {  20'b0                   ,        slow_out2  }; end // signal for RP slow DAC 2
            20'h00040 : begin sys_ack <= sys_en;  sys_rdata <= {  20'b0                   ,        slow_out3  }; end // signal for RP slow DAC 3
            20'h00044 : begin sys_ack <= sys_en;  sys_rdata <= {  20'b0                   ,        slow_out4  }; end // signal for RP slow DAC 4
            20'h00048 : begin sys_ack <= sys_en;  sys_rdata <= {  {18{oscA[13]}}          ,             oscA  }; end // signal for Oscilloscope Channel A
            20'h0004C : begin sys_ack <= sys_en;  sys_rdata <= {  {18{oscB[13]}}          ,             oscB  }; end // signal for Oscilloscope Channel B
            20'h00050 : begin sys_ack <= sys_en;  sys_rdata <= {  29'b0                   ,          entrada  }; end // Added automatically by script
            20'h00054 : begin sys_ack <= sys_en;  sys_rdata <= {  31'b0                   ,           lpf_on  }; end // Added automatically by script
            20'h00058 : begin sys_ack <= sys_en;  sys_rdata <= {  28'b0                   ,          lpf_val  }; end // Added automatically by script
            20'h0005C : begin sys_ack <= sys_en;  sys_rdata <= {  31'b0                   ,           hpf_on  }; end // Added automatically by script
            20'h00060 : begin sys_ack <= sys_en;  sys_rdata <= {  28'b0                   ,          hpf_val  }; end // Added automatically by script
            20'h00064 : begin sys_ack <= sys_en;  sys_rdata <= {  {18{peak_pos[13]}}      ,         peak_pos  }; end // Added automatically by script
            20'h00068 : begin sys_ack <= sys_en;  sys_rdata <= {  {18{sg_amp[13]}}        ,           sg_amp  }; end // Added automatically by script
            20'h0006C : begin sys_ack <= sys_en;  sys_rdata <= {  {18{sg_width[13]}}      ,         sg_width  }; end // Added automatically by script
            20'h00070 : begin sys_ack <= sys_en;  sys_rdata <= {  {18{sg_base[13]}}       ,          sg_base  }; end // Added automatically by script
            20'h00074 : begin sys_ack <= sys_en;  sys_rdata <= {  31'b0                   ,     noise_enable  }; end // Added automatically by script
            20'h00078 : begin sys_ack <= sys_en;  sys_rdata <= {  {18{noise_amp[13]}}     ,        noise_amp  }; end // Added automatically by script
            20'h0007C : begin sys_ack <= sys_en;  sys_rdata <= {  31'b0                   ,     drift_enable  }; end // Added automatically by script
            20'h00080 : begin sys_ack <= sys_en;  sys_rdata <= {  28'b0                   ,       drift_time  }; end // Added automatically by script
            20'h00084 : begin sys_ack <= sys_en;  sys_rdata <= {  {18{val_fun[13]}}       ,          val_fun  }; end // Added automatically by script
            20'h00088 : begin sys_ack <= sys_en;  sys_rdata <= {  {18{noise_std[13]}}     ,        noise_std  }; end // Added automatically by script
            20'h0008C : begin sys_ack <= sys_en;  sys_rdata <= {  29'b0                   ,        read_ctrl  }; end // [unused,start_clk,Freeze]
            default   : begin sys_ack <= sys_en;  sys_rdata <=  32'h0        ; end
        endcase
    end
    // [FPGA MEMORY DOCK END]

endmodule
