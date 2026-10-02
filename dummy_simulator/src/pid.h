/**
 * @brief Red Pitaya PID Controller
 *
 * @Author Ales Bardorfer <ales.bardorfer@redpitaya.com>
 *         
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in C programming language.
 * Please visit http://en.wikipedia.org/wiki/C_(programming_language)
 * for more details on the language used herein.
 */

#ifndef __PID_H
#define __PID_H

#include "main.h"

/* The dummy_simulator FPGA has no PID block: in fpga/rtl/red_pitaya_top.v i_pid is commented out
 * and sys_bus slot 3 (0x403xxxxx) is a stub (ack=1, rdata=0). With 0, pid_* never touch that
 * address range. Set to 1 only if i_pid is re-enabled in the RTL. */
#define PID_FPGA_HAS_PID 0

int pid_init(void);
int pid_exit(void);

int pid_update(rp_app_params_t *params);

#endif // __PID_H
