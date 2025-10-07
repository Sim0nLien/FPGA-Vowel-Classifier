# Documentation for <u>mem</u>

1. **Summary**

    - This block get the value from the lowpass filter and store them in a memory. When a fullpacket of 256 values is stored, it provides information to the next block. and then send the values one by one when the next block is ready to receive them. This bloc has 3 memory of 512 values to be able to receive a new packet while sending the previous one.

2. **Parameters**
    - Q_DATA: Bit width of the data (default: 15)
    - N: Number of samples in a frame (default: 256)

3. **inputs and Outputs**
    - Inputs:
        - clk: Clock signal
        - reset: Reset signal (active high)
        - valid_window: Indicates when data_lowpass is valid
        - valid_fft: Signal to start sending data to the next block
        - data_in_0: Input data from the lowpass filter (Q_DATA bits)
        - data_in_1: Input data from the lowpass filter (Q_DATA bits)
    - Outputs:
        - paquet_ready : Indicates that a full packet of data is ready
        - valid_out: Indicates when data_out is valid
        - data_out: Output data to the next block (Q_DATA bits)

4. **Behavior**
    - Have a look in the testbench to understand the behavior of the block.
    

5. **Notes**
    - Improve robustness for outputs.
    - Ensure proper synchronization between input and output signals.
