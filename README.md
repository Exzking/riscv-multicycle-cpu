# RISC-V Multicycle Processor (RV32I)

## Overview
This project implements a 32-bit RV32I RISC-V processor in SystemVerilog using a single-multicycle datapath and an FSM-based control unit.

## Supported Instructions
- ADD, SUB, AND, OR
- ADDI
- LW, SW
- BEQ
- JAL

## Architecture
- Single - Multicycle datapath
- FSM-based controller
- Separate instruction and data memories (Harvard-style)

## Verification
The processor is verified using a self-checking SystemVerilog testbench. Instruction-level simulations confirm correct register and memory operations.

## Tools
- SystemVerilog
- Vivado Simulator
