# ===========================================================
# Questa Simulation Script for Register File Project
# Author: Hossam
# ===========================================================

vdel -all
vlib work
vmap work work

# Compile DFF first!
vcom -2008 DFF.vhd

# Then compile the Register Files
vcom -2008 RegisterFile_DFF.vhd
vcom -2008 RegisterFile_Memory.vhd

# Finally, compile the Testbench
vcom -2008 RegisterFile_TB.vhd

# Launch simulation
vsim work.RegisterFile_TB

# Add all signals to waveform
add wave *

# Run full simulation
run  200ns

# Zoom waveform to full
wave zoom full
