# WT Gen

Simple rails application for creating procedurally generated Wavetables (compatible with Phase Plant and Serum). This application does not require a database.

## Public Instance
- [bass2space Instance](https://wtgen.bass2.space)
- [dankNET Instance](https://wtgen.danknet.space)

## Setup

To run this, install ruby 3.1.2 and the bundler gem, clone this repo, cd into the directory and run:
```
bundle install
```

Afterwards, start the application with:
```
rails server -b 0.0.0.0
```

## Modules
If you wish to run the wavetable generators without a web frontend, the ruby modules used to generate the wavetables are located in the [lib](lib) directory.

- [Sound](lib/sound.rb) is responsible for generating basic waveforms, normalizing audio and actually writing the WAV file. This is also where some parameters like Sample Rate and Frame Size is defined.
- [WaveStacking](lib/algorithms/wave_stacking.rb) contains the Wave Stacking algorithm, depends on Sound.
- [PseudoPWM](lib/algorithms/pseudo_pwm.rb) contains the Pseudo PWM algorithm, depends on Sound.

This software is licensed under the [MIT License](LICENSE).