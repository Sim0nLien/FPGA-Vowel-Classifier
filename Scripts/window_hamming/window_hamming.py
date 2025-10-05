import numpy as np
import matplotlib.pyplot as plt

def adapt(value, Q_bits):
    scale = 2 ** Q_bits
    return np.round(np.clip(value, -1, 1 - 1/scale) * scale).astype(np.int16)

N = 512
w = np.hamming(N)
Q_in = 15
w_q = adapt(w[0:256], Q_in)

plt.plot(w_q)
plt.show()


with open("../../Srcs/MFCC/window/window_hamming.mem", "w") as f:
    for val in w_q:
        f.write(f"{val & 0xFFFF:04X}\n")
