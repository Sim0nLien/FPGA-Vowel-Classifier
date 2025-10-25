import numpy as np
import matplotlib.pyplot as plt
import os




def indice_stage(n_stage, n_data):
    ans = []
    n_subdiv = n_data // (2**n_stage)
    for i in range(n_subdiv):
        for j in range(2**n_stage//2):
            ans.append(j*2+2**n_stage*i)
        for j in range(2**n_stage//2):
            ans.append(j*2+1+2**n_stage*i)
    return ans


N = 256
list_valeur = np.arange(0,256)

PATH = f"../../Srcs/MFCC/frame_fft_block/fft/"


if __name__ == "__main__":
    print("end")
    for i in range(2,9):
        indice = indice_stage(i,256)
        print(indice)

        os.makedirs(PATH, exist_ok=True)

        NAME_PATH_REAL = os.path.join(PATH, f"fft_stage_{i}/indice.mem")

        with open(NAME_PATH_REAL, "w") as f:
            for val in indice:
                f.write(f"{int(val) & 0xFF:02X}\n")