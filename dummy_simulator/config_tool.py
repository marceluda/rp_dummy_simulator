#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from numpy import unique,ceil
import os
import enum
from datetime import datetime
import re
import argparse
from glob import glob
import fileinput

from config_lib import *

import configparser


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Process arguments


if '__file__' in globals():
    scriptFolder = os.path.dirname(os.path.realpath(__file__))
else:
    scriptFolder = 'rp_dummy/dummy'


folder = scriptFolder

# Save original working directory for later
cwd = os.getcwd()

# Change to configuration folder
os.chdir(folder)

AppName = folder.split( os.sep )[-1]
if not AppName[0:6]=='dummy_':
    print('not dummy_NAME folder')
    exit(1)


print('Working folder: '+folder)
print('App Name      : '+AppName)



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Process arguments


if __name__ == '__main__':

    # Parse arguments
    parser = argparse.ArgumentParser(
                description='Configure the Dummy app files to ease the Web Browser <--> C controller <--> FPGA registers comunication'
            )

    parser.add_argument("-v", "--do-verilog", dest='do_verilog', action="store_true",
                        help="configure verilog files")
    parser.add_argument("-m", "--do-main"   , dest='do_main'   , action="store_true",
                        help="configure C files")
    parser.add_argument("-w", "--do-html"   , dest='do_html'   , action="store_true",
                        help="configure web HTML index file")
    parser.add_argument("-p", "--do-python" ,  dest='do_py'    , action="store_true",
                        help="configure HTML index file")
    parser.add_argument("-t", "--do-tcl" ,  dest='do_tcl'    , action="store_true",
                        help="configure TCL configuration file")
    parser.add_argument("-a", "--all"       ,  dest='do_all'   , action="store_true",
                        help="configure all the files")

    args = parser.parse_args()

    if args.do_all:
        args.do_verilog = True
        args.do_main    = True
        args.do_html    = True
        args.do_py      = True
        args.do_tcl     = True

    if not ( args.do_verilog or args.do_main or args.do_html or args.do_py ):
        print('nothing to do')
        parser.print_help()
        exit(0)

print('\n')


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Process FPGA registers



f = fpga_registers()

# Oscilloscope
grp='scope'
f.add( name="oscA_sw"            , group=grp , val=    0, rw=True ,  nbits= 5, min_val=          0, max_val=         31, fpga_update=True , signed=False, desc="switch for muxer oscA" )
f.add( name="oscB_sw"            , group=grp , val=    0, rw=True ,  nbits= 5, min_val=          0, max_val=         31, fpga_update=True , signed=False, desc="switch for muxer oscB" )
f.add( name="osc_ctrl"           , group=grp , val=    3, rw=True ,  nbits= 2, min_val=          0, max_val= 4294967295, fpga_update=True , signed=False, desc="oscilloscope control\n[osc2_filt_off,osc1_filt_off]" )
f.add( name="trig_sw"            , group=grp , val=    0, rw=True ,  nbits= 8, min_val=          0, max_val=        255, fpga_update=True , signed=False, desc="Select the external trigger signal" )

# Outputs
grp='outputs'
f.add( name="out1_sw"            , group=grp , val=    1, rw=True ,  nbits= 4, min_val=          0, max_val=         15, fpga_update=True , signed=False, desc="switch for muxer out1" )
f.add( name="out2_sw"            , group=grp , val=    0, rw=True ,  nbits= 4, min_val=          0, max_val=         15, fpga_update=True , signed=False, desc="switch for muxer out2" )
f.add( name="slow_out1_sw"       , group=grp , val=    0, rw=True ,  nbits= 4, min_val=          0, max_val=         15, fpga_update=True , signed=False, desc="switch for muxer slow_out1" )
f.add( name="slow_out2_sw"       , group=grp , val=    0, rw=True ,  nbits= 4, min_val=          0, max_val=         15, fpga_update=True , signed=False, desc="switch for muxer slow_out2" )
f.add( name="slow_out3_sw"       , group=grp , val=    0, rw=True ,  nbits= 4, min_val=          0, max_val=         15, fpga_update=True , signed=False, desc="switch for muxer slow_out3" )
f.add( name="slow_out4_sw"       , group=grp , val=    0, rw=True ,  nbits= 4, min_val=          0, max_val=         15, fpga_update=True , signed=False, desc="switch for muxer slow_out4" )

# Other signals
grp='inout'
f.add( name="in1"                , group=grp , val=    0, rw=False,  nbits=14, min_val=      -8192, max_val=       8191, fpga_update=True , signed=True , desc="Input signal IN1" )
f.add( name="in2"                , group=grp , val=    0, rw=False,  nbits=14, min_val=      -8192, max_val=       8191, fpga_update=True , signed=True , desc="Input signal IN2" )
f.add( name="out1"               , group=grp , val=    0, rw=False,  nbits=14, min_val=      -8192, max_val=       8191, fpga_update=True , signed=True , desc="signal for RP RF DAC Out1" )
f.add( name="out2"               , group=grp , val=    0, rw=False,  nbits=14, min_val=      -8192, max_val=       8191, fpga_update=True , signed=True , desc="signal for RP RF DAC Out2" )
f.add( name="slow_out1"          , group=grp , val=    0, rw=False,  nbits=12, min_val=      -2048, max_val=       2047, fpga_update=True , signed=False, desc="signal for RP slow DAC 1" )
f.add( name="slow_out2"          , group=grp , val=    0, rw=False,  nbits=12, min_val=      -2048, max_val=       2047, fpga_update=True , signed=False, desc="signal for RP slow DAC 2" )
f.add( name="slow_out3"          , group=grp , val=    0, rw=False,  nbits=12, min_val=      -2048, max_val=       2047, fpga_update=True , signed=False, desc="signal for RP slow DAC 3" )
f.add( name="slow_out4"          , group=grp , val=    0, rw=False,  nbits=12, min_val=      -2048, max_val=       2047, fpga_update=True , signed=False, desc="signal for RP slow DAC 4" )
f.add( name="oscA"               , group=grp , val=    0, rw=False,  nbits=14, min_val=      -8192, max_val=       8191, fpga_update=True , signed=True , desc="signal for Oscilloscope Channel A" )
f.add( name="oscB"               , group=grp , val=    0, rw=False,  nbits=14, min_val=      -8192, max_val=       8191, fpga_update=True , signed=True , desc="signal for Oscilloscope Channel B" )


# Automated added registers
grp="dummy"
f.add( name="entrada"           , group=grp , val=    0, rw=  True, nbits=3   , min_val=          0, max_val=          7, fpga_update=  True, signed= False, desc="Added automatically by script" )
f.add( name="lpf_on"            , group=grp , val=    1, rw=  True, nbits=1   , min_val=          0, max_val=          1, fpga_update=  True, signed= False, desc="Added automatically by script" )
f.add( name="lpf_val"           , group=grp , val=    6, rw=  True, nbits=4   , min_val=          0, max_val=         15, fpga_update=  True, signed= False, desc="Added automatically by script" )
f.add( name="hpf_on"            , group=grp , val=    0, rw=  True, nbits=1   , min_val=          0, max_val=          1, fpga_update=  True, signed= False, desc="Added automatically by script" )
f.add( name="hpf_val"           , group=grp , val=    0, rw=  True, nbits=4   , min_val=          0, max_val=         15, fpga_update=  True, signed= False, desc="Added automatically by script" )
f.add( name="peak_pos"          , group=grp , val=    0, rw=  True, nbits=14  , min_val=      -8192, max_val=       8191, fpga_update=  True, signed=  True, desc="Added automatically by script" )
f.add( name="sg_amp"            , group=grp , val= 4192, rw=  True, nbits=14  , min_val=      -8192, max_val=       8191, fpga_update=  True, signed=  True, desc="Added automatically by script" )
f.add( name="sg_width"          , group=grp , val= 8191, rw=  True, nbits=14  , min_val=      -8192, max_val=       8191, fpga_update=  True, signed=  True, desc="Added automatically by script" )
f.add( name="sg_base"           , group=grp , val=    0, rw=  True, nbits=14  , min_val=      -8192, max_val=       8191, fpga_update=  True, signed=  True, desc="Added automatically by script" )
f.add( name="noise_enable"      , group=grp , val=    0, rw=  True, nbits=1   , min_val=          0, max_val=          1, fpga_update=  True, signed= False, desc="Added automatically by script" )
f.add( name="noise_amp"         , group=grp , val= 1024, rw=  True, nbits=14  , min_val=      -8192, max_val=       8191, fpga_update=  True, signed=  True, desc="Added automatically by script" )
f.add( name="drift_enable"      , group=grp , val=    0, rw=  True, nbits=1   , min_val=          0, max_val=          1, fpga_update=  True, signed= False, desc="Added automatically by script" )
f.add( name="drift_time"        , group=grp , val=   13, rw=  True, nbits=4   , min_val=          0, max_val=         15, fpga_update=  True, signed= False, desc="Added automatically by script" )
f.add( name="val_fun"           , group=grp , val=    0, rw= False, nbits=14  , min_val=      -8192, max_val=       8191, fpga_update= False, signed=  True, desc="Added automatically by script" )
f.add( name="noise_std"         , group=grp , val=    0, rw= False, nbits=14  , min_val=      -8192, max_val=       8191, fpga_update= False, signed=  True, desc="Added automatically by script" )




#grp='aux_signals'
#f.add( name="cnt_clk"            , group=grp , val=    0, rw=False,  nbits=32, min_val=          0, max_val= 4294967295, fpga_update=False, signed=False, desc="Clock count" )
#f.add( name="cnt_clk2"           , group=grp , val=    0, rw=False,  nbits=32, min_val=          0, max_val= 4294967295, fpga_update=False, signed=False, desc="Clock count" )
f.add( name="read_ctrl"          , group=grp , val=    0, rw=True ,  nbits= 3, min_val=          0, max_val=          7, fpga_update=True , signed=False, desc="[unused,start_clk,Freeze]" )
#
## aux
#grp='mix'
#f.add( name="aux_A"              , group=grp , val=    0, rw=True ,  nbits=14, min_val=      -8192, max_val=       8191, fpga_update=True , signed=True , desc="auxiliar value of 14 bits" )
#f.add( name="aux_B"              , group=grp , val=    0, rw=True ,  nbits=14, min_val=      -8192, max_val=       8191, fpga_update=True , signed=True , desc="auxiliar value of 14 bits" )


for r in f:
    if r.ro:
        r.fpga_update=False

for i in ['osc_ctrl','in1','in2','out1','out2']:
    f[i].write_def=False



if __name__ == '__main__' and args.do_verilog:
    print('do_verilog')
    f.update_verilog_files(folder)
    print('\n')



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Process C code for MAIN

m = main_registers(num_base=81)

for r in f:
    m.add(r)

m.insert_reg("dummy_osc_ctrl",
             main_register(name="dummy_osc1_filt_off", val=1, rw=True,
                           nbits=1, group="scope",
                           min_val=0, max_val=1, signed=False,
                           desc="oscilloscope control osc1_filt_off",
                           fpga_update=True,
                           c_update='(float) ((g_dummy_reg->osc_ctrl      )& 0x01)'
                           )
             )
m.insert_reg("dummy_osc_ctrl",
             main_register(name="dummy_osc2_filt_off", val=1, rw=True,
                           nbits=1, group="scope",
                           min_val=0, max_val=1, signed=False,
                           desc="oscilloscope control osc2_filt_off",
                           fpga_update=True,
                           c_update='(float) ((g_dummy_reg->osc_ctrl >> 1 )& 0x01)'
                           )
             )

m.insert_reg("dummy_osc_ctrl",
             main_register(name="dummy_osc_raw_mode", val=0, rw=True,
                           nbits=1, group="scope",
                           min_val=0, max_val=1, signed=False,
                           desc="Set oscilloscope mode in Raw (int unit instead of Volts)",
                           fpga_update=False
                           )
             )

m.insert_reg("dummy_osc_ctrl",
             main_register(name="dummy_osc_lockin_mode", val=0, rw=True,
                           nbits=1, group="scope",
                           min_val=0, max_val=1, signed=False,
                           desc="Set oscilloscope mode in lock-in (ch1 as R [V|int], ch2 as Phase [rad])",
                           fpga_update=False
                           )
             )

m.del_reg("dummy_osc_ctrl")

m["dummy_osc1_filt_off"].fpga_reg="osc_ctrl"
m["dummy_osc2_filt_off"].fpga_reg="osc_ctrl"

r=f["osc_ctrl"]; r.c_update='(((int)params[{:s}].value)<<1) + ((int)params[{:s}].value)'.format( m["dummy_osc2_filt_off"].cdef , m["dummy_osc1_filt_off"].cdef )

m.fix_c_update(f)



#%%

if __name__ == '__main__' and args.do_main:
    print('do_main')
    m.update_c_files(folder,f)
    print('\n')


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Process HTML controls


h = html_registers(num_base=81)

for i in m:
    h.add(i)



h.guess_control_type()

# Print control type
# h.print_control_type()

h['dummy_osc_raw_mode'   ].type   = 'button'
h['dummy_osc_lockin_mode'].type   = 'button'

h['dummy_oscA_sw'        ].type    = 'select'
h['dummy_oscB_sw'        ].type    = 'select'
h['dummy_trig_sw'        ].type    = 'select'
h['dummy_out1_sw'        ].type    = 'select'
h['dummy_out2_sw'        ].type    = 'select'
h['dummy_slow_out3_sw'   ].type    = 'select'
h['dummy_slow_out4_sw'   ].type    = 'select'

# Automated added HTML controllers
h['dummy_entrada'          ].type    = 'select'
h['dummy_lpf_on'           ].type    = 'button'
h['dummy_lpf_val'          ].type    = 'select'
h['dummy_hpf_on'           ].type    = 'button'
h['dummy_hpf_val'          ].type    = 'select'
h['dummy_peak_pos'         ].type    = 'number'
h['dummy_sg_amp'           ].type    = 'number'
h['dummy_sg_width'         ].type    = 'number'
h['dummy_noise_enable'     ].type    = 'checkbox'
h['dummy_noise_amp'        ].type    = 'number'
h['dummy_drift_enable'     ].type    = 'checkbox'
h['dummy_drift_time'       ].type    = 'select'
h['dummy_val_fun'          ].type    = 'monitor'
h['dummy_noise_std'        ].type    = 'monitor'

h['dummy_sg_base'          ].type    = 'number'




for r in h:
    print('    '+r.name.ljust(25)+' is of type '+r.type)


h.auto_set_controls('fpga/rtl/dummy.v','dummy')



h['dummy_osc1_filt_off'   ].control.text='Ch1'
h['dummy_osc2_filt_off'   ].control.text='Ch2'
h['dummy_osc_raw_mode'    ].control.text = 'Raw&nbsp;Mode'
h['dummy_osc_lockin_mode' ].control.text = 'R|Phase&nbsp;Mode'



h['dummy_oscA_sw'].control.enable = [True]*14 + [False]*18
h['dummy_oscB_sw'].control.enable = [True]*14 + [False]*18



h['dummy_out1_sw'].control.enable = [True]*9 + [False]*7
h['dummy_out2_sw'].control.enable = [True]*9 + [False]*7


# Automatic configuration of HTML controllers
#h['dummy_entrada'          ].control      = select(idd='dummy_entrada'          , items=[ str(y) for y in range(8) ] )
h['dummy_lpf_on'           ].control.text = 'Activate LPF'
#h['dummy_lpf_val'          ].control      = select(idd='dummy_lpf_val'          , items=[ str(y) for y in range(16) ] )
h['dummy_hpf_on'           ].control.text = 'Activate HPF'
#h['dummy_hpf_val'          ].control      = select(idd='dummy_hpf_val'          , items=[ str(y) for y in range(16) ] )
h['dummy_noise_enable'     ].control.text = 'Siwitch Noise'
h['dummy_drift_enable'     ].control.text = 'Siwitch Drift'
#h['dummy_drift_time'       ].control      = select(idd='dummy_drift_time'       , items=[ str(y) for y in range(16) ] )


# h["lock_sg_amp1"  ].control = select(idd="lock_sg_amp1"   ,items=['x1','x2','x4','x8','x16','x32','x64','x128','x256','x512'])

h['dummy_entrada'          ].control      = select(idd='dummy_entrada'          , items=[ 'in1', 'in2' , 'in1+in2', 'in1-in2' ]+['']*4 )
h['dummy_entrada'          ].control.enable = [True]*4 + [False]*4




h['dummy_lpf_val'          ].control      = select(idd='dummy_lpf_val'          , items=['128ns | 1MHz ',
                                                                                         '256ns | 622kHz ',
                                                                                         '512ns | 311kHz ',
                                                                                         '1us | 155kHz ',
                                                                                         '2us | 78kHz ',
                                                                                         '4us | 39kHz ',
                                                                                         '8us | 19kHz ',
                                                                                         '16us | 10kHz ',
                                                                                         '33us | 5kHz ',
                                                                                         '66us | 2kHz ',
                                                                                         '131us | 1kHz ',
                                                                                         '262us | 607 Hz ',
                                                                                         '524us | 304 Hz ',
                                                                                         '1ms | 152 Hz ',
                                                                                         '2ms | 76 Hz ',
                                                                                         '4ms | 38 Hz '] )


h['dummy_hpf_val'          ].control      = select(idd='dummy_hpf_val'          , items=['8ns | 20MHz ',
                                                                                         '16ns | 10MHz ',
                                                                                         '32ns | 5MHz ',
                                                                                         '64ns | 2MHz ',
                                                                                         '128ns | 1MHz ',
                                                                                         '256ns | 622kHz ',
                                                                                         '512ns | 311kHz ',
                                                                                         '1us | 155kHz ',
                                                                                         '2us | 78kHz ',
                                                                                         '4us | 39kHz ',
                                                                                         '8us | 19kHz ',
                                                                                         '16us | 10kHz ',
                                                                                         '33us | 5kHz ',
                                                                                         '66us | 2kHz ',
                                                                                         '131us | 1kHz ',
                                                                                         '262us | 607 Hz '] )


h['dummy_drift_time'       ].control      = select(idd='dummy_drift_time'       , items=['524us | 304 Hz ',
                                                                                         '1ms | 152 Hz ',
                                                                                         '2ms | 76 Hz ',
                                                                                         '4ms | 38 Hz ',
                                                                                         '8ms | 19 Hz ',
                                                                                         '17ms | 9 Hz ',
                                                                                         '34ms | 5 Hz ',
                                                                                         '67ms | 2 Hz ',
                                                                                         '134ms | 1 Hz ',
                                                                                         '268ms | 593mHz ',
                                                                                         '537ms | 297mHz ',
                                                                                         '1 s | 148mHz ',
                                                                                         '2 s | 74mHz ',
                                                                                         '4 s | 37mHz ',
                                                                                         '9 s | 19mHz ',
                                                                                         '17 s | 9mHz '] )



h.set_global_configs()

if __name__ == '__main__' and args.do_html:
    print('do_html')
    h.update_html_files(folder)
    print('\n')

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Process Python scripts


f.set_py_global_config()


if __name__ == '__main__' and args.do_py:
    print('do_py')
    f.update_python_files(folder)
    print('\n')

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Re-write TCL scripts

if __name__ == '__main__' and args.do_tcl:
    print('do_tcl')

    tag = ( '# Automatically added dummy modules', '# End of automatic part')
    txt1 = '\n'
    txt2 = '\n'
    for vfile in [ y.replace('fpga/rtl','$path_rtl') for y in glob('fpga/rtl/dummy/*.v') ]:
        txt1 += 'read_verilog'.ljust(34) + vfile + '\n'
        txt2 += 'add_files'.ljust(34) + vfile + '\n'
    print('Writting file: fpga/red_pitaya_vivado.tcl')
    update_file_match(
        filename='fpga/red_pitaya_vivado.tcl',
        tag=tag,
        txt=txt1)
    print('Writting file: fpga/red_pitaya_vivado_project.tcl')
    update_file_match(
        filename='fpga/red_pitaya_vivado_project.tcl',
        tag=tag,
        txt=txt2)
    print('\n')



if __name__ == '__main__':
    print('end')
