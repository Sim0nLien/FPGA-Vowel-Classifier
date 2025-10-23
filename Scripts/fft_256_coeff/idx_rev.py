import numpy as np
import matplotlib.pyplot as plt
import os




def bit_reverse(x, n_bits):
    result = 0
    for i in range(n_bits):
        bit = (x >> i) & 1
        result |= bit << (n_bits - 1 - i)
    return result


N = 256
list_valeur = np.arange(0,256)


PATH = f"../../Srcs/MFCC/frame_fft_block/fft/fft_stage_1"


if __name__ == "__main__":
    print("end")

    list_valeur = bit_reverse(list_valeur, 8)
    
    os.makedirs(PATH, exist_ok=True)

    NAME_PATH_REAL = os.path.join(PATH, "indice.mem")

    with open(NAME_PATH_REAL, "w") as f:
        for val in list_valeur:
            f.write(f"{int(val) & 0xFF:02X}\n")