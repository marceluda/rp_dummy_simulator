# Simulator of spectral peak response for Red Pitaya

The App lets you use the device as a test unit for the development and fine-tuning
of controls systems and acquisition systems.
It can be configured to receive a **control signal** on an input port (ex. `in2` or `in2`)
and give a **response** on an output por (ex. `out1` or `out2`).
The simulated signal is a [lorentizian Peak](https://en.wikipedia.org/wiki/Spectral_line_shape#Lorentzian).

## The features of the App

  * Implementation of Low Pass Filter and High Pass Filter for the input control signal
  * The shape of the peak can be controlled with several parameters
    * *Position*: Value of the control signal where the peak is centered at.
    * *Height* of peak . Negative value is a negative peak.
    * *Width / Finesse of the Peak*
    * *Baseline* slope: a linear base line where the peak is mounted on.
  * You can add white gaussian noise to the response signal, with variable amplitude
  * You can simulate a slow drift of the peak position

## Operation

There are two ways of operation:

### Internal visualization
Any time, in any moment, you can watch the configured peak signal by choosing the chanels on the Scope:
  * `OscA`: Simulated Ramp
  * `OscB`: Simulated Output

Then you can choose the best parameters for your model without external scanning.

### External scanning
Connect the other device you want to test for acquisition and control.

  * `Control Input`: Choose the input signal for the control voltage. ex.: `in1`.
     Probably you would want to configure a Ramp-scan on this port.
  * Assign `Output` wire to one of the `Out1`/`Out2` ports.
  * `OscA`: Choose `Input Signal`
  * `OscB`: Choose `Output`

  Now, operate the device you want to test. You can see on the Oscilloscope all the time the voltage
  signal the device is sending to the simulator and the response of the system.

# Download and install

You can download the compiled version from:
[dummy_simulator-0.1.0-1-devbuild.tar.gz](https://marceluda.github.io/rp_lock-in_pid/Derivated/dummy_simulator-0.1.0-1-devbuild.tar.gz)

Upload App to Red Pitaya device.
UnZip / UnTar the App folder. Execute from terminal (on GNU/Linux):

`./upload_app.sh rp-XXXXXX.local`

Replace `rp-XXXXXX.local` by your RP localname or IP address

Also, you can use your own SSH client and upload the lock_in+pid_harmonic folder the the
RedPiaya folder: `/opt/redpitaya/www/apps`
