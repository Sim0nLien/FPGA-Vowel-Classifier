import cocotb
from cocotb.triggers import Timer
import random

Q_IN = 15
Q_COEFF = 15
Q_OUT = 15
SCALE = 1 << Q_COEFF


def butterfly_no_imag_ref(a_real, b_real, W_real):
    """Référence Python du module butterfly sans imaginaire"""
    bw_real = (b_real * W_real) >> Q_COEFF
    y0_real = a_real + bw_real
    y1_real = a_real - bw_real

    mask = (1 << (Q_OUT + 1)) - 1

    def to_signed(val):
        if val & (1 << Q_OUT):
            val -= (1 << (Q_OUT + 1))
        return val

    return map(to_signed, [y0_real & mask, y1_real & mask])


@cocotb.test()
async def test_basic_values(dut):
    """Test simple avec des valeurs connues"""
    a_real = 1000
    b_real = 2000
    W_real = int(0.7071 * SCALE)  # cos(π/4) environ

    dut.a_real.value = a_real
    dut.b_real.value = b_real
    dut.W_real.value = W_real

    await Timer(1, units="ns")

    y0_real_exp, y1_real_exp = butterfly_no_imag_ref(a_real, b_real, W_real)

    got_y0 = dut.y0_real.value.signed_integer
    got_y1 = dut.y1_real.value.signed_integer

    assert got_y0 == y0_real_exp, f"y0_real mismatch: got {got_y0}, expected {y0_real_exp}"
    assert got_y1 == y1_real_exp, f"y1_real mismatch: got {got_y1}, expected {y1_real_exp}"

    print(f"Test passed for inputs: a_real={a_real}, b_real={b_real}, W_real={W_real}")
    print(f"Outputs: y0_real={got_y0}, y1_real={got_y1}")


@cocotb.test()
async def test_random_values(dut):
    """Test sur 500 valeurs aléatoires"""
    for i in range(500):
        a_real = random.randint(-(1 << Q_IN), (1 << Q_IN) - 1)
        b_real = random.randint(-(1 << Q_IN), (1 << Q_IN) - 1)
        W_real = random.randint(-(1 << Q_COEFF), (1 << Q_COEFF) - 1)

        dut.a_real.value = a_real
        dut.b_real.value = b_real
        dut.W_real.value = W_real

        await Timer(1, units="ns")

        y0_real_exp, y1_real_exp = butterfly_no_imag_ref(a_real, b_real, W_real)

        got_y0 = dut.y0_real.value.signed_integer
        got_y1 = dut.y1_real.value.signed_integer

        assert got_y0 == y0_real_exp, (
            f"[{i}] y0_real mismatch: got {got_y0}, expected {y0_real_exp}, "
            f"inputs: a_real={a_real}, b_real={b_real}, W_real={W_real}"
        )
        assert got_y1 == y1_real_exp, (
            f"[{i}] y1_real mismatch: got {got_y1}, expected {y1_real_exp}, "
            f"inputs: a_real={a_real}, b_real={b_real}, W_real={W_real}"
        )

        print(f"[{i}] Test passed for inputs: a_real={a_real}, b_real={b_real}, W_real={W_real}")
        print(f"    Outputs: y0_real={got_y0}, y1_real={got_y1}")
    print("All random tests passed.")
