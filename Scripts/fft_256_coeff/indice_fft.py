import numpy as np
import matplotlib.pyplot as plt
import os





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
        print(result[stage, :])
    return result


N = 256
result = complete_indice(8, 256)

PATH = f"../../Srcs/MFCC/frame_fft_block/fft/"

print("#run.... ")
if __name__ == "__main__":
    print("end")
    for stage in range(1,9):
        os.makedirs(PATH, exist_ok=True)
        for j in range(2):
            NAME_PATH_REAL = os.path.join(PATH, f"fft_stage_{stage  + j}/indice_{1 - j}.mem")
            with open(NAME_PATH_REAL, "w") as f:
                for group in result[stage - 1]:
                    val_1 = group[1]
                    val_0 = group[0]
                    f.write(f"{int(val_0) & 0xFF:02X}\n")
                    f.write(f"{int(val_1) & 0xFF:02X}\n")
