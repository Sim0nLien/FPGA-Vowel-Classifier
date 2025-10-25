import numpy as np
import os

def adapt(value, Q_bits):
    scale = 2 ** Q_bits
    return np.round(np.clip(value, -1, 1 - 1/scale) * scale).astype(np.int16)


def coeff_stage(N, stage):

    m = 2 ** (stage + 1)
    half_m = m // 2
    stride = N // m

    exponents = np.arange(half_m) * stride
    coeffs = np.exp(-2j * np.pi * exponents / N)

    return coeffs



if __name__ == "__main__":

    Q_data = 15
    N = 256
    stage = 7

    PATH = f"../../Srcs/MFCC/frame_fft_block/fft/fft_stage_{stage + 1}/"
    os.makedirs(PATH, exist_ok=True)

    print(f"Generating FFT coefficients for N={N}, stage={stage + 1}...")

    coeff = coeff_stage(N, stage)
    coeff_real = adapt(coeff.real, Q_data)
    coeff_imag = adapt(coeff.imag, Q_data)

    print("Re:", coeff_real)
    print("Im:", coeff_imag)

    NAME_PATH_REAL = os.path.join(PATH, "real.mem")
    with open(NAME_PATH_REAL, "w") as f:
        for val in coeff_real:
            f.write(f"{int(val) & 0xFFFF:04X}\n")

    NAME_PATH_IMAG = os.path.join(PATH, "imag.mem")
    with open(NAME_PATH_IMAG, "w") as f:
        for val in coeff_imag:
            f.write(f"{int(val) & 0xFFFF:04X}\n")

    print("Files generated:")
    print(" ", NAME_PATH_REAL)
    print(" ", NAME_PATH_IMAG)
