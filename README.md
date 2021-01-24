# GAL16V8 - Generic Array Logic

## Introduction

This project was created for self educational purposes and is used to simulate a GAL16V8.
To realize this, the circuit was programmed using [Dgitial](https://github.com/hneemann/Digital) a circuit simulator and VHDL.

## About GAL16V8

The GAL is a programmable logic device with which one can program
boolean, combinatorial or sequential circuits using source code.
The GAL16V8 has 16 inputs of which 8 are in and outputs as well as a clock and enable.

## How to use

1. Convert the .pld file to JEDEC with [GALasm](https://github.com/daveho/GALasm)  
   Optionally Digital can be used to create the JEDEC file see documentation
2. Convert the .jed file to hex with jedec2hex.py.

### Using VHDL
1. Input the .hex file path in the generic map of GAL16V8.vhd
2. Simulate with vhdl-2008

### Using [Dgitial](https://github.com/hneemann/Digital)
1. Open GAL16V8_Test.dig and change the hex file (Counter.hex default)   
Edit > Circuit specific settings > Advanced > Content of ROM's > Edit > Fuses > File > load
2. Change the inputs and outputs if required. (DO NOT CHANGE GND & VCC PINS) used for programming.
3. Start simulation, wait till Ready led is on. (programmed)
