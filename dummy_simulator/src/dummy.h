/**
 * @brief Red Pitaya LOCK Controller
 *
 * @Author Marcelo Luda <marceluda@gmail.com>
 *
 *
 *
 * This part of code is written in C programming language.
 * Please visit http://en.wikipedia.org/wiki/C_(programming_language)
 * for more details on the language used herein.
 */

#ifndef __DUMMY_H
#define __DUMMY_H

#include "main.h"

int dummy_init(void);
int dummy_exit(void);

int dummy_update(rp_app_params_t *params);
int dummy_update_main(rp_app_params_t *params);

int dummy_freeze_regs(void);
int dummy_restore_regs(void);

extern int save_read_ctrl ;


#endif // __DUMMY_H
