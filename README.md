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

| Test ID | Test Name  | Verification Objective | Input Vectors ($A \times B$) | Expected Output ($C$) | Status |
| :---: | :--- | :---  | :---: | :---: | :---: |
| **TC_01** | Reset Signal | Verifies hardware reset clears all internal registers and outputs. | $\begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix} \times \begin{bmatrix} 0 & 1 \\ 1 & 0 \end{bmatrix}, \text{rst}=1$ | $\begin{bmatrix} 0 & 0 \\ 0 & 0 \end{bmatrix}$ | `PASS` |
| **TC_02** | Basic Matrices  | Validates standard 2x2 matrix multiplication. | $\begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix} \times \begin{bmatrix} 4 & 3 \\ 2 & 1 \end{bmatrix}$ | $\begin{bmatrix} 8 & 5 \\ 20 & 13 \end{bmatrix}$ | `PASS` |
| **TC_03** | Zero Matrix | Verifies zero property ($A \times 0 = 0$). | $\begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix} \times \begin{bmatrix} 0 & 0 \\ 0 & 0 \end{bmatrix}$ | $\begin{bmatrix} 0 & 0 \\ 0 & 0 \end{bmatrix}$ | `PASS` |
| **TC_04** | Identity Matrix | Verifies identity matrix property ($A \times I_2 = A$). | $\begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix} \times \begin{bmatrix} 1 & 0 \\ 0 & 1 \end{bmatrix}$ | $\begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix}$ | `PASS` |
| **TC_05** | Inverse Matrix | Validates 2's complement negative values ($A \times A^{-1} = I_2$). | $\begin{bmatrix} 1 & 2 \\ 2 & 3 \end{bmatrix} \times \begin{bmatrix} -3 & 2 \\ 2 & -1 \end{bmatrix}$ | $\begin{bmatrix} 1 & 0 \\ 0 & 1 \end{bmatrix}$ | `PASS` |
| **TC_06** | Enable Signal | Tests `en` disable logic mid-execution to ensure input latching integrity. | Ignores input updates when `en=0` (`ready` low) | Retains $\begin{bmatrix} 1 & 0 \\ 0 & 1 \end{bmatrix}$ | `PASS` |
| **TC_07** | Maximum Value | Verifies 17-bit accumulator overflow protection with max INT8 positive values (`+127`). | $\begin{bmatrix} 127 & 127 \\ 127 & 127 \end{bmatrix} \times \begin{bmatrix} 127 & 127 \\ 127 & 127 \end{bmatrix}$ | $\begin{bmatrix} 32258 & 32258 \\ 32258 & 32258 \end{bmatrix}$ | `PASS` |
| **TC_08** | Minimum Value | Tests sign-extension and accumulator range with min INT8 negative values (`-128`). | $\begin{bmatrix} -128 & -128 \\ -128 & -128 \end{bmatrix} \times \begin{bmatrix} -128 & -128 \\ -128 & -128 \end{bmatrix}$ | $\begin{bmatrix} 32768 & 32768 \\ 32768 & 32768 \end{bmatrix}$ | `PASS` |

---