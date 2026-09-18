# PARAMETERIZED SYSTOLIC ARRAY FOR MATRIX MULTIPLICATION

![Language](https://img.shields.io/badge/Language-Verilog%20HDL-blue.svg)
![Tools](https://img.shields.io/badge/Tools-Xilinx%20Vivado-orange.svg)
![Type](https://img.shields.io/badge/Type-Hardware%20Accelerator-green.svg)

## 1. Introduction
**Systolic Array** is an architecture that consists of multiple processing units (PEs). These PEs operate simultaneously and pass data to their neighbors, forming a system that works rhythmically. In this project, we implement a 2x2 matrix multiplier using systolic workflow, featuring 4 Multiply-Accumulate (MAC) processing elements. This design allows total operating time to decrease significantly compared to sequential methods. Additionally, the module is scalable for further projects that require matrix multiplication with $2^n$ dimensions.

--- 

## 2. Architecture Overview

### 2.1. Hierarchy Design
The hierarchy design is divided into 3 levels:

![systolic array hierarchy](Figure/hierarchy.svg)

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
│   └── hierarchy.svg
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
| **TC_01** | Reset Signal | Verifies hardware reset clears all internal registers and outputs. | $A = [[1, 2], [3, 4]]$<br>$B = [[0, 1], [1, 0]]$, `rst=1` | $C = [[0, 0], [0, 0]]$ | `PASSED` |
| **TC_02** | Basic Matrices | Validates standard 2x2 matrix multiplication. | $A = [[1, 2], [3, 4]]$<br>$B = [[4, 3], [2, 1]]$ | $C = [[8, 5], [20, 13]]$ | `PASSED` |
| **TC_03** | Zero Matrix | Verifies zero property <br>($A \times 0 = 0$). | $A = [[1, 2], [3, 4]]$<br>$B = [[0, 0], [0, 0]]$ | $C = [[0, 0], [0, 0]]$ | `PASSED` |
| **TC_04** | Identity Matrix | Verifies identity matrix property <br>($A \times I_2 = A$). | $A = [[1, 2], [3, 4]]$<br>$B = [[1, 0], [0, 1]]$ | $C = [[1, 2], [3, 4]]$ | `PASSED` |
| **TC_05** | Inverse Matrix | Validates 2's complement negative values <br>($A \times A^{-1} = I_2$). | $A = [[1, 2], [2, 3]]$<br>$B = [[-3, 2], [2, -1]]$ | $C = [[1, 0], [0, 1]]$ | `PASSED` |
| **TC_06** | Enable Signal | Tests `en` disable logic mid-execution to ensure input latching integrity. | Ignores input updates when `en=0` (`ready` low) | Retains $C = [[1, 0], [0, 1]]$ | `PASSED` |
| **TC_07** | Maximum Value | Verifies 17-bit accumulator overflow protection with max INT8 positive values (`+127`). | $A = [[127, 127], [127, 127]]$<br>$B = [[127, 127], [127, 127]]$ | $C = [[32258, 32258], [32258, 32258]]$ | `PASSED` |
| **TC_08** | Minimum Value | Tests sign-extension and accumulator range with min INT8 negative values (`-128`). | $A = [[-128, -128], [-128, -128]]$<br>$B = [[-128, -128], [-128, -128]]$ | $C = [[32768, 32768], [32768, 32768]]$ | `PASSED` |

---


## 5. Synthesis Results

* Target board: Arty Z7-20
* Stage: Post-Implementation

| Performance Criteria | Synthesized Value |
| :---: | :---: |
| LUT |  |
| FF |  |
| BRAM | |
| DSP | |
| IO |  |
| Worst Negative Slack (WNS) | |
| Total Power | |
| Junction Temperature | |

---

## 6. Demo instruction

This project includes unit testbenches for individual RTL modules and a top-level CPU testbench running all program testcases (`systolic_array_tb.v`). Test results are automatically verified via terminal and signals can be tracked from waveform.

### Prerequisites

* **AMD/Xilinx Vivado**
* **Git**
---

### Step 1: Clone the Repository

Open your terminal or command prompt and clone the repository:

```bash
git clone [https://github.com/nhatnamhuynh/systolic-array-2x2.git](https://github.com/nhatnamhuynh/systolic-array-2x2.git)
cd systolic-array-2x2
```

---

### Step 2: Set Up the Vivado Project

1. Launch **Vivado**.
2. Click **Create Project** -> Name your project and click **Next**.
3. Select **RTL Project** (leave *Do not specify sources at this time* unchecked).
4. **Add Source Files:**
   * Click **Add Files** and select all `.v` files inside the `RTL/` directory (`pe.v`, `pe_grid.v`, `systolic_array_top.v`).
   * Set `systolic_array_top.v` as the Top Module.
5. Select your target FPGA board/part and click **Finish**.
6. **Add Simulation Sources:** In the Vivado **Sources** panel, expand **Simulation Sources** -> Right-click the `sim_1` -> **Add Sources...**.
   * Click **Add Files** and select all `.v` files inside the `Testbench/` directory (`pe_tb.v`, `pe_grid_tb`, `systolic_array_tb.v`).

---

### Step 3: Run Unit Tests (Module-Level)

To test individual modules:

1. In the Vivado **Sources** panel, expand **Simulation Sources** -> `sim_1`.
2. Right-click the desired module testbench (e.g., `pe.v`) and select **Set as Top**.
3. In the left Flow Navigator, click **Run Simulation** -> **Run Behavioral Simulation**.
4. Check the **Tcl Console**:
   * Inspect the `if/else` print statements verifying module outputs against expected values.
5. Inspect the **Waveform Window** to verify signal timings, state transitions, and flag assertions.

---

### Step 4: Run CPU Tests (Top-Level)

To verify complete execution across the entire pipeline:

1. In **Simulation Sources**, right-click `systolic_array_tb.v` and select **Set as Top**.
2. Click **Run Simulation** -> **Run Behavioral Simulation**.
3. Observe the **Tcl Console Output**:
   * Review the terminal output logs for pass/fail status.
4. **Inspect CPU Waveforms:**
   * Key signals to add to the Waveform viewer: `clk`, `rst`, `clr`, `ready`, `inA`, `inB`, `acc_out_*`.
