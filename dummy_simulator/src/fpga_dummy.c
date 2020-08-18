/**
 * @brief Red Pitaya DUMMY FPGA controller.
 *
 * @Author Marcelo Luda <marceluda@gmail.com>
 *
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in C programming language.
 * Please visit http://en.wikipedia.org/wiki/C_(programming_language)
 * for more details on the language used herein.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include "fpga_dummy.h"

/**
 * GENERAL DESCRIPTION:
 *
 * This module initializes and provides for other SW modules the access to the
 * FPGA PID module.
 *
 * This module maps physical address of the DUMMY core to the logical address,
 * which can be used in the GNU/Linux user-space. To achieve this DUMMY_BASE_ADDR
 * from CPU memory space is translated automatically to logical address with the
 * function mmap().
 * Before this module is used external SW module must call fpga_dummy_init().
 * When this module is no longer needed fpga_dummy_exit() should be called.
 */

/** The FPGA register structure (defined in fpga_dummy.h) */
dummy_reg_t *g_dummy_reg     = NULL;

/** The memory file descriptor used to mmap() the FPGA space */
int g_dummy_fd = -1;


/*----------------------------------------------------------------------------*/
/**
 * @brief Internal function used to clean up memory.
 *
 * This function un-maps FPGA registers, closes memory file
 * descriptor and cleans all memory allocated by this module.
 *
 * @retval 0 Success
 * @retval -1 Failure, error is printed to standard error output.
 */
int __dummy_cleanup_mem(void)
{
    /* If registry structure is NULL we do not need to un-map and clean up */
    if(g_dummy_reg) {
        if(munmap(g_dummy_reg, DUMMY_BASE_SIZE) < 0) {
            fprintf(stderr, "munmap() failed: %s\n", strerror(errno));
            return -1;
        }
        g_dummy_reg = NULL;
    }

    if(g_dummy_fd >= 0) {
        close(g_dummy_fd);
        g_dummy_fd = -1;
    }
    return 0;
}

// [FPGARESET DOCK]
/** Reset all DUMMY */
void reset_locks(void)
{
    if (g_dummy_reg) {
        g_dummy_reg->oscA_sw              =      0;
        g_dummy_reg->oscB_sw              =      0;
        g_dummy_reg->osc_ctrl             =      3;
        g_dummy_reg->trig_sw              =      0;
        g_dummy_reg->out1_sw              =      1;
        g_dummy_reg->out2_sw              =      0;
        g_dummy_reg->slow_out1_sw         =      0;
        g_dummy_reg->slow_out2_sw         =      0;
        g_dummy_reg->slow_out3_sw         =      0;
        g_dummy_reg->slow_out4_sw         =      0;
        g_dummy_reg->in1                  =      0;
        g_dummy_reg->in2                  =      0;
        g_dummy_reg->out1                 =      0;
        g_dummy_reg->out2                 =      0;
        g_dummy_reg->slow_out1            =      0;
        g_dummy_reg->slow_out2            =      0;
        g_dummy_reg->slow_out3            =      0;
        g_dummy_reg->slow_out4            =      0;
        g_dummy_reg->oscA                 =      0;
        g_dummy_reg->oscB                 =      0;
        g_dummy_reg->entrada              =      0;
        g_dummy_reg->lpf_on               =      1;
        g_dummy_reg->lpf_val              =      6;
        g_dummy_reg->hpf_on               =      0;
        g_dummy_reg->hpf_val              =      0;
        g_dummy_reg->peak_pos             =      0;
        g_dummy_reg->sg_amp               =   4192;
        g_dummy_reg->sg_width             =   8191;
        g_dummy_reg->sg_base              =      0;
        g_dummy_reg->noise_enable         =      0;
        g_dummy_reg->noise_amp            =   1024;
        g_dummy_reg->drift_enable         =      0;
        g_dummy_reg->drift_time           =     13;
        g_dummy_reg->val_fun              =      0;
        g_dummy_reg->noise_std            =      0;
        g_dummy_reg->read_ctrl            =      0;
    }
}
// [FPGARESET DOCK END]


/*----------------------------------------------------------------------------*/
/**
 * @brief Maps FPGA memory space and prepares register variables.
 *
 * This function opens memory device (/dev/mem) and maps physical memory address
 * DUMMY_BASE_ADDR (of length DUMMY_BASE_SIZE) to logical addresses. It initializes
 * the pointer g_dummy_reg to point to FPGA DUMMY.
 * If function fails FPGA variables must not be used.
 *
 * @retval 0  Success
 * @retval -1 Failure, error is printed to standard error output.
 */
int fpga_dummy_init(void)
{
    /* Page variables used to calculate correct mapping addresses */
    void *page_ptr;
    long page_addr, page_off, page_size = sysconf(_SC_PAGESIZE);

    /* If module was already initialized, clean all internals */
    if(__dummy_cleanup_mem() < 0)
        return -1;

    /* Open /dev/mem to access directly system memory */
    g_dummy_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if(g_dummy_fd < 0) {
        fprintf(stderr, "open(/dev/mem) failed: %s\n", strerror(errno));
        return -1;
    }

    /* Calculate correct page address and offset from DUMMY_BASE_ADDR and
     * DUMMY_BASE_SIZE
     */
    page_addr = DUMMY_BASE_ADDR & (~(page_size-1));
    page_off  = DUMMY_BASE_ADDR - page_addr;

    /* Map FPGA memory space to page_ptr. */
    page_ptr = mmap(NULL, DUMMY_BASE_SIZE, PROT_READ | PROT_WRITE,
                          MAP_SHARED, g_dummy_fd, page_addr);
    if((void *)page_ptr == MAP_FAILED) {
        fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
         __dummy_cleanup_mem();
        return -1;
    }

    /* Set FPGA DUMMY module pointers to correct values. */
    g_dummy_reg = page_ptr + page_off;

    /* Reset all controllers */
    //reset_dummy();

    return 0;
}


/*----------------------------------------------------------------------------*/
/**
 * @brief Cleans up FPGA PID module internals.
 *
 * This function closes the memory file descriptor, unmaps the FPGA memory space
 * and cleans also all other internal things from FPGA DUMMY module.
 * @retval 0 Success
 * @retval -1 Failure
 */
int fpga_dummy_exit(void)
{
    /* Reset all controllers */
    //reset_dummy();

    return __dummy_cleanup_mem();
}
