/**
 * $Id: generate.h 882 2013-12-16 12:46:01Z crt.valentincic $
 *
 * @brief Red Pitaya simple signal/function generator with pre-defined
 *        signal types.
 *
 * @Author Jure Menart <juremenart@gmail.com>
 *         
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in C programming language.
 * Please visit http://en.wikipedia.org/wiki/C_(programming_language)
 * for more details on the language used herein.
 */

#ifndef __GENERATE_H
#define __GENERATE_H

#include "main.h"
#include "calib.h"

/** @defgroup generate_h Arbitrary Signal Generator
 * @{
 */

/** Signal types */
typedef enum awg_signal_e {
    eSignalSine = 0,     /* Sinusoidal waveform. */
    eSignalSquare,       /* Square waveform. */
    eSignalTriangle,     /* Triangular waveform. */
    eSignalFile          /* Waveform read from file */
} awg_signal_t;

/** AWG FPGA parameters */
typedef struct awg_param_s {
    int32_t  offsgain;   /* AWG offset & gain. */
    uint32_t wrap;       /* AWG buffer wrap value. */
    uint32_t step;       /* AWG step interval. */
} awg_param_t;

/** @} */

/* The dummy_simulator FPGA has no ASG: in fpga/rtl/red_pitaya_top.v i_asg is commented out and
 * sys_bus slot 2 (0x402xxxxx) is a stub (ack=1, rdata=0). With 0, generate_* never touch that
 * address range (no mmap, no writes). Set to 1 only if i_asg is re-enabled in the RTL. */
#define GEN_FPGA_HAS_ASG 0

int generate_init(rp_calib_params_t *calib_params);
int generate_exit(void);

int generate_update(rp_app_params_t *params);

#endif // __GENERATE_H
