/**
 * @brief Red Pitaya LOCK FPGA controller.
 *
 * @Author Marcelo Luda <marceluda@gmail.com>
 *
 *
 *
 * This part of code is written in C programming language.
 * Please visit http://en.wikipedia.org/wiki/C_(programming_language)
 * for more details on the language used herein.
 */

#ifndef _FPGA_DUMMY_H_
#define _FPGA_DUMMY_H_

#include <stdint.h>

/** @defgroup fpga_dummy_h LOCK Controller
 * @{
 */

/** Base LOCK FPGA address */
#define DUMMY_BASE_ADDR 0x40600000
/** Base LOCK FPGA core size */
#define DUMMY_BASE_SIZE 0x190

/** @brief LOCK FPGA registry structure.
 *
 * This structure is direct image of physical FPGA memory. When accessing it all
 * reads/writes are performed directly from/to FPGA LOCK registers.
 */
// [FPGAREG DOCK]
typedef struct dummy_reg_t {

    /** @brief Offset 20'h00000 - oscA_sw
      *  switch for muxer oscA
      *
      *  bits [31: 5] - Reserved
      *  bits [ 4: 0] - Data
      */
    uint32_t oscA_sw;
    
    /** @brief Offset 20'h00004 - oscB_sw
      *  switch for muxer oscB
      *
      *  bits [31: 5] - Reserved
      *  bits [ 4: 0] - Data
      */
    uint32_t oscB_sw;
    
    /** @brief Offset 20'h00008 - osc_ctrl
      *  oscilloscope control
      *  [osc2_filt_off,osc1_filt_off]
      *
      *  bits [31: 2] - Reserved
      *  bits [ 1: 0] - Data
      */
    uint32_t osc_ctrl;
    
    /** @brief Offset 20'h0000C - trig_sw
      *  Select the external trigger signal
      *
      *  bits [31: 8] - Reserved
      *  bits [ 7: 0] - Data
      */
    uint32_t trig_sw;
    
    /** @brief Offset 20'h00010 - out1_sw
      *  switch for muxer out1
      *
      *  bits [31: 4] - Reserved
      *  bits [ 3: 0] - Data
      */
    uint32_t out1_sw;
    
    /** @brief Offset 20'h00014 - out2_sw
      *  switch for muxer out2
      *
      *  bits [31: 4] - Reserved
      *  bits [ 3: 0] - Data
      */
    uint32_t out2_sw;
    
    /** @brief Offset 20'h00018 - slow_out1_sw
      *  switch for muxer slow_out1
      *
      *  bits [31: 4] - Reserved
      *  bits [ 3: 0] - Data
      */
    uint32_t slow_out1_sw;
    
    /** @brief Offset 20'h0001C - slow_out2_sw
      *  switch for muxer slow_out2
      *
      *  bits [31: 4] - Reserved
      *  bits [ 3: 0] - Data
      */
    uint32_t slow_out2_sw;
    
    /** @brief Offset 20'h00020 - slow_out3_sw
      *  switch for muxer slow_out3
      *
      *  bits [31: 4] - Reserved
      *  bits [ 3: 0] - Data
      */
    uint32_t slow_out3_sw;
    
    /** @brief Offset 20'h00024 - slow_out4_sw
      *  switch for muxer slow_out4
      *
      *  bits [31: 4] - Reserved
      *  bits [ 3: 0] - Data
      */
    uint32_t slow_out4_sw;
    
    /** @brief Offset 20'h00028 - in1
      *  Input signal IN1
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  in1;
    
    /** @brief Offset 20'h0002C - in2
      *  Input signal IN2
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  in2;
    
    /** @brief Offset 20'h00030 - out1
      *  signal for RP RF DAC Out1
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  out1;
    
    /** @brief Offset 20'h00034 - out2
      *  signal for RP RF DAC Out2
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  out2;
    
    /** @brief Offset 20'h00038 - slow_out1
      *  signal for RP slow DAC 1
      *
      *  bits [31:12] - Reserved
      *  bits [11: 0] - Data
      */
    uint32_t slow_out1;
    
    /** @brief Offset 20'h0003C - slow_out2
      *  signal for RP slow DAC 2
      *
      *  bits [31:12] - Reserved
      *  bits [11: 0] - Data
      */
    uint32_t slow_out2;
    
    /** @brief Offset 20'h00040 - slow_out3
      *  signal for RP slow DAC 3
      *
      *  bits [31:12] - Reserved
      *  bits [11: 0] - Data
      */
    uint32_t slow_out3;
    
    /** @brief Offset 20'h00044 - slow_out4
      *  signal for RP slow DAC 4
      *
      *  bits [31:12] - Reserved
      *  bits [11: 0] - Data
      */
    uint32_t slow_out4;
    
    /** @brief Offset 20'h00048 - oscA
      *  signal for Oscilloscope Channel A
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  oscA;
    
    /** @brief Offset 20'h0004C - oscB
      *  signal for Oscilloscope Channel B
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  oscB;
    
    /** @brief Offset 20'h00050 - entrada
      *  Added automatically by script
      *
      *  bits [31: 3] - Reserved
      *  bits [ 2: 0] - Data
      */
    uint32_t entrada;
    
    /** @brief Offset 20'h00054 - lpf_on
      *  Added automatically by script
      *
      *  bits [31: 1] - Reserved
      *  bit  [0]     - Data
      */
    uint32_t lpf_on;
    
    /** @brief Offset 20'h00058 - lpf_val
      *  Added automatically by script
      *
      *  bits [31: 4] - Reserved
      *  bits [ 3: 0] - Data
      */
    uint32_t lpf_val;
    
    /** @brief Offset 20'h0005C - hpf_on
      *  Added automatically by script
      *
      *  bits [31: 1] - Reserved
      *  bit  [0]     - Data
      */
    uint32_t hpf_on;
    
    /** @brief Offset 20'h00060 - hpf_val
      *  Added automatically by script
      *
      *  bits [31: 4] - Reserved
      *  bits [ 3: 0] - Data
      */
    uint32_t hpf_val;
    
    /** @brief Offset 20'h00064 - peak_pos
      *  Added automatically by script
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  peak_pos;
    
    /** @brief Offset 20'h00068 - sg_amp
      *  Added automatically by script
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  sg_amp;
    
    /** @brief Offset 20'h0006C - sg_width
      *  Added automatically by script
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  sg_width;
    
    /** @brief Offset 20'h00070 - sg_base
      *  Added automatically by script
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  sg_base;
    
    /** @brief Offset 20'h00074 - noise_enable
      *  Added automatically by script
      *
      *  bits [31: 1] - Reserved
      *  bit  [0]     - Data
      */
    uint32_t noise_enable;
    
    /** @brief Offset 20'h00078 - noise_amp
      *  Added automatically by script
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  noise_amp;
    
    /** @brief Offset 20'h0007C - drift_enable
      *  Added automatically by script
      *
      *  bits [31: 1] - Reserved
      *  bit  [0]     - Data
      */
    uint32_t drift_enable;
    
    /** @brief Offset 20'h00080 - drift_time
      *  Added automatically by script
      *
      *  bits [31: 4] - Reserved
      *  bits [ 3: 0] - Data
      */
    uint32_t drift_time;
    
    /** @brief Offset 20'h00084 - val_fun
      *  Added automatically by script
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  val_fun;
    
    /** @brief Offset 20'h00088 - noise_std
      *  Added automatically by script
      *
      *  bits [31:14] - Reserved
      *  bits [13: 0] - Data
      */
    int32_t  noise_std;
    
    /** @brief Offset 20'h0008C - read_ctrl
      *  [unused,start_clk,Freeze]
      *
      *  bits [31: 3] - Reserved
      *  bits [ 2: 0] - Data
      */
    uint32_t read_ctrl;
    

} dummy_reg_t;
// [FPGAREG DOCK END]


/** @} */

/* Description of the following variables or function declarations is in
 * fpga_lock.c
 */
  extern dummy_reg_t    *g_dummy_reg;

int fpga_dummy_init(void);
int fpga_dummy_exit(void);

#endif // _FPGA_DUMMY_H_
