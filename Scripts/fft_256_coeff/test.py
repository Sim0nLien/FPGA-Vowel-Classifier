import numpy as np
import matplotlib.pyplot as plt

def butterfly(a, b, W):
    y0 = a + W * b
    y1 = a - W * b
    return y0, y1

def bit_reversal_indices(N):
    n_bits = int(np.log2(N))
    return np.array([int('{:0{w}b}'.format(i, w=n_bits)[::-1], 2) for i in range(N)])

def coeff_stage(N, stage):
    m = 2 ** (stage + 1)
    half_m = m // 2
    exponents = np.arange(half_m)
    coeffs = np.exp(-2j * np.pi * exponents / m)
    return coeffs

def fft_cooley_tukey(x, plot_each_stage=False):
    N = len(x)
    X = x[bit_reversal_indices(N)].astype(complex)
    stages = int(np.log2(N))

    if plot_each_stage:
        plt.figure(figsize=(12, 8))
        plt.subplot(stages + 1, 1, 1)
        plt.plot(np.abs(X))
        plt.title("Étape 0 : après bit-reversal")
        plt.tight_layout()

    for stage in range(stages):
        m = 2 ** (stage + 1)
        half_m = m // 2
        W_m = coeff_stage(N, stage)
        for k in range(0, N, m):
            for j in range(half_m):
                t, u = butterfly(X[k+j], X[k+j+half_m], W_m[j])
                X[k+j] = t
                X[k+j+half_m] = u

        # 🔹 Affichage de l'amplitude à chaque étape
        if plot_each_stage:
            plt.subplot(stages + 1, 1, stage + 2)
            plt.plot(np.abs(X))
            plt.title(f"Étape {stage + 1}")
            plt.tight_layout()

    if plot_each_stage:
        plt.suptitle("Évolution de la FFT (amplitude à chaque étape)", y=1.02, fontsize=14)
        plt.show()

    return X


# === Test ===
N = 256
signal = np.ones(N)
windowed = signal * np.hamming(N)

result = fft_cooley_tukey(windowed, plot_each_stage=True)

# 🔹 Affichage du spectre final
plt.figure(figsize=(8,4))
plt.plot(np.abs(result))
plt.title("Amplitude spectrale finale (FFT complète)")
plt.xlabel("Indice de fréquence")
plt.ylabel("|X[k]|")
plt.show()
