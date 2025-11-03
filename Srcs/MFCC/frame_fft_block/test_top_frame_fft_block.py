import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
import numpy as np
import matplotlib.pyplot as plt


def complete_indice(nb_stage, N):
    result = np.zeros((nb_stage, N//2, 2))
    for stage in range(0, nb_stage):
        count = 0
        m = 2 ** (stage + 1)
        half_m = m // 2        
        for k in range(0, N, m):
            for j in range(half_m):
                result[stage, count, 0] = k+j
                result[stage, count, 1] = k+j+half_m
                count = count + 1
    return result


def adapt(value, Q_bits):
    scale = 2 ** Q_bits
    return np.round(np.clip(value, -1, 1 - 1/scale) * scale).astype(np.int16)

def MSE_np(pred, target):
    return np.square(np.subtract(pred, target)).mean()


def traitement(signal, N, fs, group):
    frame = np.arange((group - 1) * N//2,(group - 1) * N//2 + 256, dtype = int)
    hamming_data = np.hamming(N)
    signal_process = signal[frame] * hamming_data
    return np.fft.fftfreq(N, d = 1 / fs), np.fft.fft(signal_process)

def post_traitement(signal, N, fs, number):
    freqs = np.zeros(N)
    for k in range(N):
        if k <= N//2:
            freqs[k] = k * fs / N
        else:
            freqs[k] = (k - N) * fs / N
    frames = signal[number * N:number * N + N] 
    return freqs, frames

def cos_entier(freq, fs=8000, N=256):
    t = np.arange(N) / fs
    x = np.cos(2 * np.pi * freq * t)
    x = x * 1000
    x = np.round(x).astype(int)
    x = np.clip(x, -1000, 1000)
    return x


fs = 40e3

Q = 15
signal = cos_entier(1000, fs, 1000)

N = 256

result_real_list = []
result_imag_list = []
expected_0_list = []
expected_1_list = []

list_indice = complete_indice(8, 256)

indice_end = list_indice[7]
indice_end = indice_end.reshape(1, 256)[0].astype(int)
print(signal)
print(len(signal))
x_result, y_result =  traitement(signal, N, fs, 3)


async def driver(dut, signal):
    for i, sample in enumerate(signal):
        dut.data_in.value = int(sample)
        dut.valid_in.value = 1

        await RisingEdge(dut.clk)

        dut.valid_in.value = 0

        for _ in range(10):
            await RisingEdge(dut.clk)

    dut._log.info("Driver: envoi terminé.")


async def receiver(dut, result_0_list, result_1_list):
    while True:
        await RisingEdge(dut.clk)
        if dut.valid_out.value:
            val_real_0 = int(dut.data_fft_real_0.value.signed_integer)
            val_real_1 = int(dut.data_fft_real_1.value.signed_integer)
            val_imag_0 = int(dut.data_fft_imag_0.value.signed_integer)
            val_imag_1 = int(dut.data_fft_imag_1.value.signed_integer)
            result_real_list.append(val_real_0)
            result_real_list.append(val_real_1)
            result_imag_list.append(val_imag_0)
            result_imag_list.append(val_imag_1)
            # dut._log.info(f"Receiver: reçu val_real_0 = {val_real_0}, val_real_1 = {val_real_1}, val_imag_0 = {val_imag_0}, val_imag_1 = {val_imag_1}")


@cocotb.test()
async def test_window(dut):
    dut._log.info("=== Lancement du test_frame_fft_block ===")

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # Reset
    dut.reset.value = 1
    dut.data_in.value = 0
    dut.valid_in.value = 0
    await Timer(20, unit="ns")
    dut.reset.value = 0
    await RisingEdge(dut.clk)

    cocotb.start_soon(driver(dut, signal))
    cocotb.start_soon(receiver(dut, result_real_list, result_imag_list))

    for _ in range(15000):
        await RisingEdge(dut.clk)


    x_freq, post_result_real = post_traitement(result_real_list, N, fs, 4)
    _ , post_result_imag = post_traitement(result_imag_list, N, fs, 4)
    # print(len())
    # print(len())
    plt.plot(x_result, np.real(y_result))
    plt.plot(x_freq, np.array(post_result_real)[indice_end])
    # plt.plot(x_freq, np.array(post_result_imag)[indice_end])
    plt.show()
    print(indice_end)


