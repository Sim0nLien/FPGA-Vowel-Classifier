import cocotb
from cocotb.triggers import Timer
import random

Q_IN = 15
Q_COEFF = 15
Q_OUT = 15
SCALE = 1 << Q_COEFF

def butterfly_ref(a_real, a_imag, b_real, b_imag, W_real, W_imag):
    bw_real = (b_real * W_real - b_imag * W_imag) >> Q_COEFF
    bw_imag = (b_real * W_imag + b_imag * W_real) >> Q_COEFF
    y0_real = a_real + bw_real
    y0_imag = a_imag + bw_imag
    y1_real = a_real - bw_real
    y1_imag = a_imag - bw_imag
    mask = (1 << (Q_OUT + 1)) - 1
    def to_signed(val):
        if val & (1 << Q_OUT):
            val -= (1 << (Q_OUT + 1))
        return val
    return map(to_signed, [y0_real & mask, y0_imag & mask, y1_real & mask, y1_imag & mask])


@cocotb.test()
async def test_basic_values(dut):
    a_real = 1000
    a_imag = -500
    b_real = 2000
    b_imag = 1000
    W_real = int(0.7071 * SCALE)
    W_imag = int(-0.7071 * SCALE)

    dut.a_real.value = a_real
    dut.a_imag.value = a_imag
    dut.b_real.value = b_real
    dut.b_imag.value = b_imag
    dut.W_real.value = W_real
    dut.W_imag.value = W_imag

    await Timer(1, units="ns")

    y0_real_exp, y0_imag_exp, y1_real_exp, y1_imag_exp = butterfly_ref(
        a_real, a_imag, b_real, b_imag, W_real, W_imag
    )

    assert dut.y0_real.value.signed_integer == y0_real_exp, f"y0_real mismatch: got {dut.y0_real.value.signed_integer}, expected {y0_real_exp}"
    assert dut.y0_imag.value.signed_integer == y0_imag_exp, f"y0_imag mismatch"
    assert dut.y1_real.value.signed_integer == y1_real_exp, f"y1_real mismatch"
    assert dut.y1_imag.value.signed_integer == y1_imag_exp, f"y1_imag mismatch"


@cocotb.test()
async def test_random_values(dut):
    for _ in range(500):
        a_real = random.randint(-(1 << Q_IN), (1 << Q_IN) - 1)
        a_imag = random.randint(-(1 << Q_IN), (1 << Q_IN) - 1)
        b_real = random.randint(-(1 << Q_IN), (1 << Q_IN) - 1)
        b_imag = random.randint(-(1 << Q_IN), (1 << Q_IN) - 1)
        W_real = random.randint(-(1 << Q_COEFF), (1 << Q_COEFF) - 1)
        W_imag = random.randint(-(1 << Q_COEFF), (1 << Q_COEFF) - 1)

        dut.a_real.value = a_real
        dut.a_imag.value = a_imag
        dut.b_real.value = b_real
        dut.b_imag.value = b_imag
        dut.W_real.value = W_real
        dut.W_imag.value = W_imag

        await Timer(1, units="ns")

        y0_real_exp, y0_imag_exp, y1_real_exp, y1_imag_exp = butterfly_ref(
            a_real, a_imag, b_real, b_imag, W_real, W_imag
        )

        assert dut.y0_real.value.signed_integer == y0_real_exp, f"y0_real mismatch for {a_real=}, {b_real=}"
        assert dut.y0_imag.value.signed_integer == y0_imag_exp, f"y0_imag mismatch"
        assert dut.y1_real.value.signed_integer == y1_real_exp, f"y1_real mismatch"
        assert dut.y1_imag.value.signed_integer == y1_imag_exp, f"y1_imag mismatch"
