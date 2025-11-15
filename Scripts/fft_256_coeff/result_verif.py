import numpy as np
import matplotlib.pyplot as plt

import numpy as np

def butterfly(a, b, W):
    y0 = a + (b * W) / 2**15
    y1 = a - (b * W) / 2**15
    return y0, y1


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


def coeff_stage(N, nb_stage):
    result = np.zeros((nb_stage, N), dtype=complex)
    for stage in range(nb_stage):
        m = 2 ** (stage + 1)
        half_m = m // 2
        exponents = np.arange(half_m)
        twiddles = np.exp(-2j * np.pi * exponents / m)
        # Répéter les coefficients pour obtenir un vecteur de longueur N
        repeated = np.tile(twiddles, N // half_m)
        result[stage, :] = repeated[:N]  # Tronque au cas où
    return result



def bit_reverse(x, n_bits):
    result = 0
    for i in range(n_bits):
        bit = (x >> i) & 1
        result |= bit << (n_bits - 1 - i)
    return result

def cos_entier(freq, fs=8000, N=1000):
    t = np.arange(N) / fs
    x = np.cos(2 * np.pi * freq * t)
    x = x * 1000
    x = np.round(x).astype(int)
    x = np.clip(x, -1000, 1000)
    return x

def adapt(value, Q_bits):
    scale = 2 ** Q_bits
    return np.round(np.clip(value, -1, 1 - 1/scale) * scale)

fs = 40e3

Q = 15

N = 256
nb_stage = 8
signal = cos_entier(1000, fs)
signal = signal[128  :128 + 256]
# signal = np.ones(256) * 1000 a
hamming = np.hamming(256)

list_valeur = np.arange(0,256)
signal_ham = signal * hamming
print(np.column_stack((np.arange(len(signal_ham)), signal_ham)))

indice = complete_indice(nb_stage, N)

list_result = np.zeros((nb_stage + 1, 256), dtype=complex)
list_indice = np.zeros((nb_stage + 1, 128, 2))

mix_init = bit_reverse(np.arange(0,256),8)

list_result[0, :] = signal_ham
list_result[0, :] = list_result[0, mix_init]

list_coeff = coeff_stage(N, nb_stage)
list_coeff = adapt(list_coeff, 15)

x_scale = np.arange(0,256)
x_scale = x_scale / max(x_scale) * fs

plt.plot(signal)

for i in range(nb_stage):
    print(i)
    print("rslt : ", list_result[i, 0:20], list_result[i,120:128])
    print("coeff : ", list_coeff[i,0:20])
    for k in range(N//2):
        idx_0 = int(indice[i, k, 0])
        idx_1 = int(indice[i, k, 1])
        list_result[i + 1, idx_0], list_result[i + 1, idx_1] = butterfly(list_result[i , idx_0], list_result[i, idx_1], list_coeff[i, k])
        if k < 10 or k > 122 :
            print("k :", k, list_result[i , idx_0], list_result[i, idx_1], list_coeff[i, k])
            print("k :", k, list_result[i + 1, idx_0], list_result[i + 1, idx_1])
    # if i == nb_stage - 1 :
    plt.plot(x_scale, list_result[i + 1,:], label = f'{i}')

np.savetxt("coeff.csv", list_coeff, delimiter=",", fmt="%d")
np.savetxt("mon_tableau.csv", list_result, delimiter=",", fmt="%d")
plt.legend()
plt.show()


