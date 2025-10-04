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


def extract_sound_features(file_path, Q):
    y, sr = librosa.load(PATH_FOLDER + file_path, sr=None)
    max_y = np.max(np.abs(y))
    y = y * (2 ** (Q) - 1) / max_y 
    y_fixed = np.rint(y)
    return y_fixed, y, sr


def MSE_np(pred, target):
    return np.square(np.subtract(pred, target)).mean()

#######
# PARAM
#######

# Coeff

coeff = 0.97

# Qbits

Q_in = 15
Q_coeff = 15

# Data parameters

vowel = ["a", "e", "i", "o", "u"]
speaker = np.arange(1, 4)
sample = np.arange(1, 10)

test_path = "ha_1_ (1).wav"

data_round, data, _ = extract_sound_features(test_path, Q_in)

RMSE_list = []
list_result = []
list_expected = []
# plt.plot(np.abs((data * 2 ** Q_in) - data_round), label = "original")
# plt.legend()
# plt.show()

@cocotb.test()
async def test_lowpass(dut):

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())


    # Reset
    dut.reset.value = 1
    dut.data_in.value = 0
    dut.valid_in.value = 0
    await Timer(20, unit="ns")
    dut.reset.value = 0
    
    await RisingEdge(dut.clk)

    for i in range(10000):
        
        dut.valid_in.value = 1
        dut.data_in.value = int(data_round[i])

        await RisingEdge(dut.clk)
        dut.valid_in.value = 0

        await with_timeout(RisingEdge(dut.valid_out), 100, 'ns')

        result = dut.data_out.value.signed_integer

        expected = data[i] - (data[i - 1] * 0.97) if i > 0 else data[i]


        list_result.append(result)
        list_expected.append(expected)

        RMSE_list.append((np.sqrt(abs(result - expected)) if (result - expected) != 0 else 0) ** 2)
        plt.plot(i, abs(expected - result), 'ro')

    print(f"Mean RMSE: {np.mean(np.array(RMSE_list))}")
    assert np.mean(RMSE_list) < 1, f"RMSE too high: {np.mean(RMSE_list)}"

    plt.plot(list_expected, label = "expected")
    plt.plot(list_result, label = "result")
    plt.legend()
    plt.show()


        #  Première donnée
        # print(f"Value_1 : {vecteur_test[2 * i]}, Value_2 : {vecteur_test[2 * i + 1]}")
        # print(f"Time delay : {time[i]} clk")
        # dut.data_1.value = int(vecteur_test[2 * i])
        # dut.valid_1.value = 1
        # await RisingEdge(dut.clk)
        # dut.valid_1.value = 0

        # await Timer(10 * time[i], unit="ns")

        # # Deuxième donnée
        # print(f"Sending second data: {vecteur_test[2 * i + 1]}")
        # dut.data_2.value = int(vecteur_test[2 * i + 1])
        # dut.valid_2.value = 1
        # await RisingEdge(dut.clk)
        # dut.valid_2.value = 0



        # print(f"Expected sum: {expected_sum}, Got sum: {got_sum}")

        # assert got_sum == expected_sum, \
        #     f"Adder failed for {vecteur_test[2*i]} - {vecteur_test[2*i+1]}: expected {expected_sum}, got {got_sum}"


        # assert got_sum == expected_sum, \
        #     f"Adder failed for {vecteur_test[2 * i]} - {vecteur_test[2 * i + 1]}: expected {expected_sum}, got {got_sum}"

        # cocotb.log.info(f"Tested {vecteur_test[2 * i]} - {vecteur_test[2 * i + 1]}, got {got_sum}")

        # # Enregistrement (création du dossier si besoin)
        # os.makedirs("Results", exist_ok=True)
        # # with open("Results/log_vhd.txt", "a") as f:
        # #     f.write(f"{format(got_sum, '032b')}\n")
        # with open("Results/log_result.txt", "a") as f:
        #     if got_sum == expected_sum:
        #         f.write("PASS\n")  # Green PASS
        #     else:
        #         f.write("FAIL\n")  # Red FAIL
        #     f.write(f"data_test: {vecteur_test[2 * i]}, {vecteur_test[2 * i + 1]} => data_out: {got_sum}\n")
        #     f.write(f"Expected sum: {expected_sum}, Got sum: {got_sum}\n")





# async def test_lowpass(dut):
#     """Test principal avec timeout global"""


#     # Timeout global : tout le test doit finir en moins de 5 µs
#     await with_timeout(run_stimuli(dut), 100, 'us')







