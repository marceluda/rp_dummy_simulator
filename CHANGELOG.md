
# Devbuild  changes

## 0.1.0.0-devbuild
  - Start

## v0.1.1
  - ADDED support for ecosystem 2.0 of RedPitaya (fpga.sh, fpga.bif, fpga.bit.bin built with bootgen, nginx.conf with no-cache for index.html)
  - ADDED root Makefile (builds the App and the zip/tar.gz packages in archive/)
  - FIXED the three controllers (normal, DEBUG, RELOAD) being identical: the DEBUG/RELOAD changes are now applied before compiling
  - Ecosystem 2.0 web fixes, ported from rp_lock-in_pid_h_hf v0.3.8
    - FIXED E3: parameters are sent in chunks of at most 600 B (only changed and finite values, with retries)
    - App status is probed safely before polling /data (with cautious mode); the App is started robustly (with retries and verification)
    - ADDED "took control" detection when another client claims the board
    - ADDED save and restore of the App state in the browser
    - FIXED Config -> load
    - FIXED second of two quick consecutive changes being lost while a POST was in flight
    - FIXED field editing (edit timer per field, indicators not frozen, Escape)
    - FIXED Enter with an out-of-range value sending two POSTs (Enter is prevented, forms use novalidate)
    - FIXED mouse wheel: no longer sends single_btn, right sign with SHIFT, no duplicated POST on a focused field
  - FIXED main.c: GUI_XMIN/GUI_XMAX are taken from rp_main_params (partial POSTs); controller linked with -lm -lpthread
  - FIXED SIGBUS when unloading the App: the ASG slot stub in the RTL was commented out (no ack on the bus)
  - The controller no longer touches the ASG and PID blocks, which do not exist in this FPGA
  - FIXED unloading message ("Unloading scope (with dummy extensions)")

## v0.1.2
  - FIXED endless loop of POSTs (~15/s, it exhausted the nginx file descriptors) when a NaN reached the parameters
    (e.g. a selector left without selection by an incomplete config): it counted as a change that was never sent
    - Values that are not finite numbers (NaN, undefined, null, Infinity) are never a pending change
    - Config -> load keeps the current value of the keys missing in the config (no empty selectors)
    - The selectors never copy NaN to the parameters
    - Guard in sendParams(): no POST without a real change less than 200 ms after the previous one, and at most
      10 POST/s (a warning is logged in the console)

## v0.1.3
  - ADDED "Scan floor" option of Ext Trig (value 64 of dummy_trig_sw): the Scope External trigger fires at the floor
    of the Simulated Ramp (when it jumps from its maximum to its minimum, period 131 us). No FPGA rebuild in this
    version: it did not work yet, because trigger_signals was an implicit 1-bit net in the RTL (fixed in v0.1.4)
  - Ext Trig only offers None (0), Pin (1) and Scan floor (64); the unused inputs (2, 4, 8, 16, 32, 128) are gone
  - Defaults when the App starts without a saved state: Trigger Source = External, Mode = Normal, Ext Trig = Scan floor.
    The controller writes trig_sw at start (the FPGA resets it to 0); the RELOAD controller keeps the FPGA value

## v0.1.4
  - FPGA rebuilt. FIXED Ext Trig "Scan floor": `trigger_signals` was not declared in `dummy.v`, so Verilog made it an
    implicit 1-bit net and only bit 0 (Pin) reached `trigger_input` (Synth 8-689). Declared as 8 bits
  - FPGA reset value of `trig_sw` = 64 (Scan floor), as the default of the controller (also in `config_tool.py`)
  - Scope external trigger debounce (`set_deb_len`, 0x40100090) reset value 12500 clk = 100 us (was 62500 = 0.5 ms),
    shorter than the 131 us period of the Simulated Ramp: every floor is a valid trigger edge (with 0.5 ms only one
    floor out of 4 was). Pin: edges closer than 100 us are ignored (bounces); max rate 10 kHz (was 2 kHz). The
    register can still be written (e.g. `monitor 0x40100090 62500` restores 0.5 ms)
  - Other implicit nets / width mismatches of the RTL fixed: `pwm_cfg_{a,b,c,d}_w` (24 bits; Slow out3/out4 = in1/in2
    work now, Slow out1/out2 stay at 0 V), `pos_abs` (`fun_pico.v`, unused), saturation of the peak position sums with
    16-bit input (`satprotect` Ri 16: a sum out of +-16383 wrapped around and could show a false peak, now it saturates),
    `slow_out*_aux` 32 bits. Undriven nets driven explicitly with 0 (`slow_out1/2`, `noise_std`, `digital_modulation`)
  - Removed dead code of the lock-in template (click handler of the missing #btn_set_trig button, which set
    dummy_trig_sw = 2, and its plotclick handler)
