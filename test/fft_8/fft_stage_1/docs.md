# Documentation for <u>butterfly_unit</u>

1. **Summary**

    - The butterfly unit performs the butterfly operation used in FFT algorithms. It takes two complex inputs and a complex twiddle factor, and produces two complex outputs.

2. **Parameters**
    - Q_IN: Bit width of the data (default: 15)
    - Q_IN: Bit width of the data (default: 15)
    - Q_COEFF: Bit width of the coefficients (default: 15)
    - Q_OUT: Bit width of the output data (default: 15)

3. **inputs and Outputs**
    - Inputs:
        - a_real: Real part of input a (Q_IN bits)
        - a_imag: Imaginary part of input a (Q_IN bits)
        - b_real: Real part of input b (Q_IN bits)
        - b_imag: Imaginary part of input b (Q_IN bits)
        - w_real: Real part of the twiddle factor (Q_COEFF bits)
        - w_imag: Imaginary part of the twiddle factor (Q_COEFF bits)
    - Outputs:
        - y0_real: Real part of output y0 (Q_OUT bits)
        - y0_imag: Imaginary part of output y0 (Q_OUT bits)
        - y1_real: Real part of output y1 (Q_OUT bits)
        - y1_imag: Imaginary part of output y1 (Q_OUT bits)

4. **Behavior**
    - Have a look in the testbench to understand the behavior of the block.
    

5. **Notes**

