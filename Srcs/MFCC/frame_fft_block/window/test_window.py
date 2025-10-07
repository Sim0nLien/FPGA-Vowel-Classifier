import os
import json
import cocotb
from cocotb.triggers import RisingEdge, Timer, with_timeout
from cocotb.clock import Clock
import numpy as np
from bitstring import Bits
import librosa 
import matplotlib.pyplot as plt


def adapt(value, Q_bits):
    scale = 2 ** Q_bits
    return np.round(np.clip(value, -1, 1 - 1/scale) * scale).astype(np.int16)



def MSE_np(pred, target):
    return np.square(np.subtract(pred, target)).mean()

Q = 15

hamming_value = np.hamming(512)[0:256]

test_1 = np.random.randint(0, 2**15, size=256)

adapted_hamming = adapt(hamming_value, Q)

result_list = []
expected_list = []


@cocotb.test()
async def test_window(dut):

    print("Running test_window")
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())


    # Reset
    dut.reset.value = 1
    dut.data_in.value = 0
    dut.valid_in.value = 0
    dut.valid_packet.value = 0
    
    await Timer(20, unit="ns")
    
    dut.reset.value = 0
   
    await RisingEdge(dut.clk)
    
    dut.valid_packet.value = 1
    
    await RisingEdge(dut.clk)


    dut.valid_packet.value = 0

    for i in range(256):
        
        # print("Sending data : ",  i)

        t = 0

        while(dut.valid_request.value == 0 and t < 100):
           t += 1

        
        for j in range(np.random.randint(1, 3)):
            await RisingEdge(dut.clk)
        
        dut.data_in.value = int(test_1[i])
        dut.valid_in.value = 1
        
        await RisingEdge(dut.clk)
        
        dut.valid_in.value = 0

        await with_timeout(RisingEdge(dut.valid_out), 100, 'ns')
        await RisingEdge(dut.clk)

        print("data out : ", dut.data_out.value)

        result = dut.data_out.value.signed_integer

        expected = test_1[i] * adapted_hamming[i] / (2 ** Q)
        print(test_1[i], adapted_hamming[i])
        print(f"Expected: {expected}, Got: {result}")
        
        result_list.append(result)
        expected_list.append(expected)

    
    metric = MSE_np(result_list, expected_list)
    print(f"MSE: {metric}")
    assert metric < 5, f"MSE too high: {metric}"
    plt.plot(result_list, label = "result")
    plt.plot(expected_list, label = "expected")
    plt.legend()
    plt.show()












