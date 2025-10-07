# Documentation for <u>mem</u>

1. **Summary**

    - This block multiplies the input data by a Hamming window to reduce spectral leakage before performing an FFT.

2. **Parameters**

    - Q_IN: Bit width of the data (default: 15)
    - Q_COEFF: Bit width of the data (default: 15)
    - Q_OUT: Bit width of the data (default: 15)
    - N: Number of samples in a frame (default: 256)

3. **inputs and Outputs**
    - Inputs:
        - clk: Clock signal
        - reset: Reset signal (active high)
        - valid_in: Indicates when data_in is valid
        - valid_packet: Indicates when a full packet of input data is valid and ready for processing
        - data_in: Input data from the previous block (Q_IN bits)
    - Outputs:
        - valid_request: Indicates that the block is ready to receive new input data
        - valid_out: Indicates when data_out is valid
        - data_out_0: Output data to the next block (Q_OUT bits)
        - data_out_1: Output data to the next block (Q_OUT bits)

4. **Behavior**
    - Have a look in the testbench to understand the behavior of the block.
    

5. **Notes**
    - Try with prev and next block
