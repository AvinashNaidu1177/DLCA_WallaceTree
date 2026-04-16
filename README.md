🚀 4×4 Wallace Tree Multiplier (Verilog)

This project implements a 4×4 Wallace Tree Multiplier in Verilog along with a complete testbench for functional verification.

It demonstrates how partial products can be efficiently reduced using half adders and full adders to achieve faster multiplication compared to traditional methods.

📌 Features
✅ 4-bit × 4-bit multiplication
✅ Wallace Tree reduction technique
✅ Optimized adder usage (reduced gate count)
✅ Fully verified using exhaustive testbench (256 cases)
✅ Waveform dump support (.vcd file)
🧠 Concept Overview

A Wallace Tree Multiplier improves multiplication speed by:

Generating partial products
Reducing them in parallel using:
Half Adders (HA)
Full Adders (FA)
Performing a final addition to produce the result

Unlike ripple-based multiplication, this reduces the number of sequential addition stages.

🏗️ Architecture
1. Partial Product Generation

Each bit of input A is ANDed with each bit of input B.

pp[i][j] = A[i] & B[j]

This creates a 4×4 matrix of partial products.

2. Reduction Stages

The Wallace tree reduces columns of bits:

Layer 1: Initial compression using HAs and FAs
Layer 2: Further reduction to two rows
Final Stage: Two vectors are added to produce output
3. Final Output

The final product is obtained using:

P = vec_s + vec_c

Where:

vec_s = sum bits
vec_c = carry bits
⚙️ Modules
🔹 Half Adder
Adds 2 bits
Outputs: Sum, Carry
🔹 Full Adder
Adds 3 bits (including carry-in)
Outputs: Sum, Carry
🔹 Wallace Multiplier (wallace_4x4)
Core module implementing multiplication logic
🔹 Testbench (tb_wallace_4x4)
Tests all 256 input combinations
Compares output with A * B
🧪 Testbench Details
Iterates through all values of A and B (0–15)
Checks correctness using:
if (P === A * B)
Displays:
Pass count
Fail count

Dumps waveform file:

wallace_4x4.vcd
📊 Optimization Summary
Version	Half Adders	Full Adders	Approx Gates
Original	2	7	~73
Optimized	6	4	~66
✅ Improvements
Reduced gate count
Cleaner structure using generate blocks
Better readability and maintainability

💡 Future Improvements
Implement Dadda Tree multiplier
Replace ripple adder with CLA
Extend to 8×8 or 16×16 multiplier
FPGA implementation for hardware validation
