# SYSTOLIC ARRAY 2X2 FOR MATRIX MULTIPLICATION

![Language](https://img.shields.io/badge/Language-Verilog%20HDL-blue.svg)
![Tools](https://img.shields.io/badge/Tools-Xilinx%20Vivado-orange.svg)
![Type](https://img.shields.io/badge/Type-Hardware%20Accelerator-green.svg)

## 1. Introduction
Systolic array is an architecture that consists of multiple processing units (PEs). These PEs operate simultaneously and pass data to their neighbors, forming a system that works rhythmically. In this project, we implement a 2x2 matrix multiplier using systolic workflow, allowing total operating time to decrease significantly compared to sequential methods. Additionally, this module is scalable for further projects that require matrix multiplication with $2^n$ dimensions.

--- 

## 2. Architecture Overview

### 2.1. Hierarchy Design
The hierarchy design is divided into 3 levels:

![systolic array hierarchy](Picture/hierarchy.png)

### 2.2. Signal specification
| Signal Name | Width | Description |
| :--- | :---: | :--- |
| `clk` / `rst`/`en` | 1-bit | Global clock, active-HIGH synchronous reset, and active-HIGH enable signal. |
| `ready` | 1-bit | End of execution flag. |
| `inA_flat` / `inB_flat` | 32-bit | Input matrices, flattened into a little-endian vector. |
| `acc_out_0`, `acc_out_1`, `acc_out_2`, `acc_out_3` | 17-bit | Entries of resulting matrix. |

### 2.3. System Workflow
