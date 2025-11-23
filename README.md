# Dual-Architecture 8-bit Register File Design

## 1. Project Introduction
This project focuses on the design and verification of an 8-register, 8-bit Register File, a critical component in processor datapaths used for temporary storage of operands. The primary goal of this project was to implement the same hardware specification using two distinct VHDL modeling styles—**Behavioral** and **Structural**—to demonstrate the differences between high-level abstraction and gate-level design.

Both implementations are verified against each other using a self-checking testbench to ensure functional equivalence.

## 2. Technical Specifications
The Register File was designed according to the following hardware requirements:

* **Architecture:** 8 Registers x 8 Bits.
* **Addressing:** 3-bit address bus (indices 0 to 7).
* **Clocking:** Synchronous Write operation (Triggered on Rising Edge).
* **Reset:** Asynchronous Active-High Reset (Clears all register contents to `0x00`).
* **Ports:**
    * **Write Port (1):** Updates the register specified by `write_addr` with `write_data` when `write_enable` is high.
    * **Read Ports (2):** Asynchronous output. `read_data0` and `read_data1` immediately reflect the contents of registers at `read_addr0` and `read_addr1` respectively.

## 3. Implementation Details

### A. Behavioral Model (`RegisterFile_Memory.vhd`)
This implementation utilizes a high level of abstraction, relying on the synthesizer to infer the underlying memory structure.
* **Storage Mechanism:** The register bank is modeled using a VHDL `array` type (`array (0 to 7) of STD_LOGIC_VECTOR(7 downto 0)`).
* **Logic:** The write operation is encapsulated in a single process sensitive to the clock, while read operations are performed using concurrent signal assignments. This approach represents how modern memory is typically described for FPGA synthesis.

### B. Structural Model (`RegisterFile_DFF.vhd`)
This implementation builds the register file from the ground up using low-level primitives, offering a view closer to the actual silicon layout.
* **Storage Elements:** The design explicitly instantiates 64 **D Flip-Flops** (8 registers × 8 bits per register) using the custom `DFF` component.
* **Write Decoding:** A manual decoding logic (`write_enable_decoded`) is implemented to convert the 3-bit `write_addr` into individual enable signals for each of the 8 registers.
* **Input Multiplexing:** A `generate` loop creates 2:1 multiplexer logic for every register bit. This logic decides whether the DFF preserves its current state or accepts new data from the write bus based on the decoded write enable signal.

## 4. Verification Methodology (`RegisterFile_TB.vhd`)
Verification is performed using a "Golden Model" approach. The Behavioral implementation is treated as the reference (Golden Model), and the Structural implementation is the Unit Under Test (UUT).

* **Self-Checking Logic:** The testbench drives identical inputs (Clock, Reset, Address, Data) to both modules simultaneously.
* **Comparison:** On every clock cycle, the testbench compares the outputs `read_data0` and `read_data1` from both the Behavioral and Structural models.
* **Logging:** The simulation writes a cycle-by-cycle log to `sim_output.txt`. If a mismatch occurs, an error is reported; otherwise, the simulation concludes with a success message.

## 5. File Manifest
* **`DFF.vhd`**: Standard 1-bit D Flip-Flop with asynchronous reset.
* **`RegisterFile_Memory.vhd`**: Behavioral implementation (Reference Model).
* **`RegisterFile_DFF.vhd`**: Structural implementation (Gate-level Model).
* **`RegisterFile_TB.vhd`**: Self-checking testbench.
* **`run_sim.do`**: Tcl script for ModelSim/QuestaSim automation.

## 6. Simulation Instructions
A `run_sim.do` script is provided to automate the compilation and simulation environment setup in ModelSim or QuestaSim.

**Steps to run:**
1.  Launch ModelSim/QuestaSim.
2.  Set your working directory to the folder containing these source files.
3.  Type the following command in the Transcript window:
    ```tcl
    do run_sim.do
    ```

**Script Actions:**
The script performs the following actions automatically:
1.  Creates the `work` library.
2.  Compiles the `DFF` component first (dependency).
3.  Compiles both Register File architectures.
4.  Compiles the Testbench.
5.  Initializes the simulation with `vsim`.
6.  Adds all relevant signals to the Wave window.
7.  Runs the simulation for 200ns.

Upon completion, check the Transcript window. You should see:
> **"SUCCESS: Both implementations produce identical results!"**
