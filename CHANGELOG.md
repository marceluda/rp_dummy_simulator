
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
