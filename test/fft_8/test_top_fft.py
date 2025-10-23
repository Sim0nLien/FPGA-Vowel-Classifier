import cocotb
from cocotb.triggers import RisingEdge, Timer, with_timeout
from cocotb.clock import Clock
import numpy as np
import matplotlib.pyplot as plt

def MSE_np(pred, target):
    return np.square(np.subtract(pred, target)).mean()

N = 8


result_real = []
result_imag = []


signal = np.random.randint(0, 2**8, size=8)

@cocotb.test()
async def test_fft(dut):
    print("Running test_fft ....")
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())
    
    dut.reset.value = 1
    dut.valid_in.value = 0
    dut.data_in.value = 0
    dut.valid_request.value = 0
    dut.valid_packet.value = 0
    
    await Timer(20, unit="ns")
    dut.reset.value = 0
    await Timer(20, unit="ns")
    dut.valid_packet.value = 1
    await RisingEdge(dut.clk)
    dut.valid_packet.value = 0
    
    for i in range(8):
        await with_timeout(RisingEdge(dut.valid_request), 200, 'ns')
        dut.data_in.value = int(signal[i])
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
        dut.valid_in.value = 0

    for i in range(4):
        await with_timeout(RisingEdge(dut.valid_out), 3000, 'ns')
        result_r_0 = dut.data_fft_real_0.value.signed_integer
        result_r_1 = dut.data_fft_real_1.value.signed_integer
        result_i_0 = dut.data_fft_imag_0.value.signed_integer
        result_i_1 = dut.data_fft_imag_1.value.signed_integer

        result_real.append(result_r_0)
        result_real.append(result_r_1)
        result_imag.append(result_i_0)
        result_imag.append(result_i_1)

    result_real_np = np.array(result_real)
    result_imag_np = np.array(result_imag)

    result_real_np = result_real_np / np.max(result_real_np)
    result_imag_np = result_imag_np / np.max(result_imag_np)

    print(result_real_np)
    print(result_imag_np)

    print("Output valid received")


    print("signal :", signal)
    fft_ref = np.fft.fft(np.array(signal))
    print(fft_ref)
    fft_ref = fft_ref / np.max(np.abs(fft_ref))  # normalisation
    print(fft_ref)

    predict_real = np.real(fft_ref)
    predict_imag = np.imag(fft_ref)

    print("real :", predict_real)
    print("imag :",predict_imag)


    pred_real = MSE_np(predict_real, result_real_np)
    pred_imag = MSE_np(predict_imag, result_imag_np)
    
    print("MSE", pred_real, pred_imag)
    assert pred_real < 2 and pred_imag < 2, f"MSE too high"
    





