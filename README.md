# SYSTOLIC ARRAY 2x2 FOR MATRIX MULTIPLICATION

![Language](https://img.shields.io/badge/Language-Verilog%20HDL-blue.svg)
![Tools](https://img.shields.io/badge/Tools-Xilinx%20Vivado-orange.svg)
![Type](https://img.shields.io/badge/Type-Hardware%20Accelerator-green.svg)

## 1. Introduction
**Systolic Array** is an architecture that consists of multiple processing units (PEs). These PEs operate simultaneously and pass data to their neighbors, forming a system that works rhythmically. In this project, we implement a 2x2 matrix multiplier using systolic workflow, allowing total operating time to decrease significantly compared to sequential methods. Additionally, this module is scalable for further projects that require matrix multiplication with $2^n$ dimensions.

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
The top module controls the whole execution following these steps:
1. Receive `en` signal, clear current results, load input matrices into each row/col data registers with designated order. Higher-indexed rows/cols have padding zeros to wait for the previous to enter the array.
2. Execution begins, and data starts flowing. Each PEs multiplies, accumulates and passes data to the next one, from upper left to lower right.
3. Internal `counter` variable increments after each clock cycle until reaching 4. Afterwards, it resets back to zero, `ready` signal goes high to indicate that output matrix is available.
4. The system comes to IDLE state, waiting for the next multiplication to be enabled.
---
The table below summerize the operations during each cycle.

| `counter` | Action | Data Input State | `clr` | `ready` |
| :---: | :--- | :--- | :---: | :---: |
| 0 | **IDLE** | Wait for `en` signal | `1'b1` | `1'b1` |
| 1 | **Latch & Skew** | Latch inputs; send $a_{00}, b_{00}$; zero-pad higher rows/cols | `1'b1` | `1'b0` |
| 2 – 3 | **Compute & Shift** | Shift `temp_row` and `temp_col` into PE grid | `1'b0` | `1'b0` |
| 4 $\rightarrow$ 0 | **Done** | Last accumulation; reset counter | `1'b0` | `1'b1` |

## 3. Code Tree

```text
systolic-array-2x2/
├── RTL/
│   ├── systolic_array_top.v                    
│   ├── pe_grid_2x2.v
│   └── pe.v
├── Testbench/                             
│   ├── systolic_array_tb.v                    
│   ├── grid_tb.v
│   └── pe_tb.v
├── Figure/
│   └── hierarchy.png
├── Waveform/
│   ├── top_waveform.png
│   ├── grid_waveform.png
│   └── pe_waveform.png
├── .gitignore                  
└── README.md
```

---