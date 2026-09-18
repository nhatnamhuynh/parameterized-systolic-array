# SYSTOLIC ARRAY 2x2 FOR MATRIX MULTIPLICATION

![Language](https://img.shields.io/badge/Language-Verilog%20HDL-blue.svg)
![Tools](https://img.shields.io/badge/Tools-Xilinx%20Vivado-orange.svg)
![Type](https://img.shields.io/badge/Type-Hardware%20Accelerator-green.svg)

## 1. Introduction
**Systolic Array** is an architecture that consists of multiple processing units (PEs). These PEs operate simultaneously and pass data to their neighbors, forming a system that works rhythmically. In this project, we implement a 2x2 matrix multiplier using systolic workflow, featuring 4 Multiply-Accumulate (MAC) processing elements. This design allows total operating time to decrease significantly compared to sequential methods. Additionally, the module is scalable for further projects that require matrix multiplication with $2^n$ dimensions.

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
| `inA_flat` / `inB_flat` | 32-bit | Input matrices, flattened into a little-endian vectors. |
| `acc_out_0`, `acc_out_1`, `acc_out_2`, `acc_out_3` | 17-bit | Entries of resulting matrix. |

### 2.3. System Workflow
The top module controls the whole execution following these steps:
1. Receive `en` signal, clear current results, load input matrices into each row/col data registers with designated order. Higher-indexed rows/cols have padding zeros to wait for the previous to enter the array.
2. Execution begins and data starts flowing. Each PEs multiplies, accumulates and passes data to the next one, from upper left to lower right.
3. Internal `counter` variable increments after each clock cycle until reaching 4. Afterwards, it resets back to zero, `ready` signal goes high to indicate that output matrix is available.
4. The system comes to IDLE state, waiting for the next multiplication to be enabled.

The table below summerizes the operations during each cycle.

| `counter` | Action | Data Input State | `clr` | `ready` |
| :---: | :--- | :--- | :---: | :---: |
| 0 | **IDLE** | Wait for `en` signal | `1'b0` | `1'b1` |
| 1 | **Latch & Skew** | Latch inputs; send $a_{00}, b_{00}$; zero-pad higher rows/cols | `1'b1` | `1'b0` |
| 2/3 | **Compute & Shift** | Shift `temp_row` and `temp_col` into PE grid | `1'b0` | `1'b0` |
| 4 | **Done** | Last accumulation; reset counter | `1'b0` | `1'b0` |

---

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

## 4. Verification Workflow


| Test ID | Test Name | Verification Objective | Input Vectors ($A \times B$) | Expected Output ($C$) | Status |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **TC_01** | Reset Signal | Verifies hardware reset clears all internal registers and outputs. | $A = [[1, 2], [3, 4]]$<br>$B = [[0, 1], [1, 0]]$, `rst=1` | $C = [[0, 0], [0, 0]]$ | `PASS` |
| **TC_02** | Basic Matrices | Validates standard 2x2 matrix multiplication and input data skewing timing. | $A = [[1, 2], [3, 4]]$<br>$B = [[4, 3], [2, 1]]$ | $C = [[8, 5], [20, 13]]$ | `PASS` |
| **TC_03** | Zero Matrix | Verifies zero property ($A \times 0 = 0$). | $A = [[1, 2], [3, 4]]$<br>$B = [[0, 0], [0, 0]]$ | $C = [[0, 0], [0, 0]]$ | `PASS` |
| **TC_04** | Identity Matrix | Verifies identity matrix property ($A \times I_2 = A$). | $A = [[1, 2], [3, 4]]$<br>$B = [[1, 0], [0, 1]]$ | $C = [[1, 2], [3, 4]]$ | `PASS` |
| **TC_05** | Inverse Matrix | Validates 2's complement negative values ($A \times A^{-1} = I_2$). | $A = [[1, 2], [2, 3]]$<br>$B = [[-3, 2], [2, -1]]$ | $C = [[1, 0], [0, 1]]$ | `PASS` |
| **TC_06** | Enable Signal | Tests `en` disable logic mid-execution to ensure input latching integrity. | Ignores input updates when `en=0` (`ready` low) | Retains $C = [[1, 0], [0, 1]]$ | `PASS` |
| **TC_07** | Maximum Value | Verifies 17-bit accumulator overflow protection with max INT8 positive values (`+127`). | $A = [[127, 127], [127, 127]]$<br>$B = [[127, 127], [127, 127]]$ | $C = [[32258, 32258], [32258, 32258]]$ | `PASS` |
| **TC_08** | Minimum Value | Tests sign-extension and accumulator range with min INT8 negative values (`-128`). | $A = [[-128, -128], [-128, -128]]$<br>$B = [[-128, -128], [-128, -128]]$ | $C = [[32768, 32768], [32768, 32768]]$ | `PASS` |

---