import os
import json
import cocotb
from cocotb.triggers import RisingEdge, Timer, with_timeout
from cocotb.clock import Clock
import numpy as np
from bitstring import Bits
import librosa 
import matplotlib.pyplot as plt

# PATH

PATH_FOLDER = "../../../data/archive/dataset_of_vowels/DATASET_OF_VOWELS/"



import librosa
import numpy as np



def MSE_np(pred, target):
    return np.square(np.subtract(pred, target)).mean()

#######
# PARAM
#######

# Coeff

N = 256

# Qbits

Q_in = 15
Q_coeff = 15

# List

in_data = np.arange(3, 259)

# plt.show()

@cocotb.test()
async def test_mem(dut):

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())


    # Reset
    dut.reset.value = 1
    dut.data_lowpass.value = 0
    dut.valid_lowpass.value = 0
    dut.valid_window.value = 0
    await Timer(20, unit="ns")
    dut.reset.value = 0
    
    await RisingEdge(dut.clk)

    for i in range(255):

        dut.valid_lowpass.value = 1
        dut.data_lowpass.value = int(in_data[i])

        await RisingEdge(dut.clk)
        dut.valid_lowpass.value = 0

        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)        
        await RisingEdge(dut.clk)        
        await RisingEdge(dut.clk)        

    dut.valid_lowpass.value = 1
    dut.data_lowpass.value = int(in_data[i])

    await RisingEdge(dut.clk)
    dut.valid_lowpass.value = 0

    print("wait paquet ready")

    await with_timeout(RisingEdge(dut.paquet_ready), 100, 'ns')

    print("paquet ready")

    for i in range(256):

        dut.valid_window.value = 1
        await RisingEdge(dut.clk)
        dut.valid_window.value = 0

        await RisingEdge(dut.valid_out)
        await RisingEdge(dut.clk)


    
        print(f'valeur sortie: {dut.data_out.value.signed_integer}, valeur attendue: {in_data[i]}')

        await RisingEdge(dut.clk)

        # assert dut.data_out.value.signed_integer == int(in_data[i]), f"Error at index {i}: got {dut.data_out.value.signed_integer}, expected {int(in_data[i])}"
    



