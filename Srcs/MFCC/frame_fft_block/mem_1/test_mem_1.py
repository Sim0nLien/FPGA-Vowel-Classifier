import cocotb
from cocotb.triggers import RisingEdge, Timer, with_timeout
from cocotb.clock import Clock
import numpy as np


N = 256
Q_DATA = 15


@cocotb.test()
async def test_mem_1(dut):

    # Horloge
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # RESET
    dut.reset.value = 1
    dut.valid_window.value = 0
    dut.valid_fft.value = 0
    dut.data_in_0.value = 0
    dut.data_in_1.value = 0
    await Timer(50, units="ns")
    dut.reset.value = 0
    await RisingEdge(dut.clk)

    ##############################
    # PHASE 1 : Écriture (window)
    ##############################

    for mem_cycle in range(3):  # trois blocs successifs
        print(f"\n--- Envoi bloc {mem_cycle} ---")
        for i in range(N):
            dut.data_in_0.value = i + 1 + mem_cycle * 1000
            dut.data_in_1.value = -(i + 1 + mem_cycle * 1000)
            dut.valid_window.value = 1
            await RisingEdge(dut.clk)
            dut.valid_window.value = 0
            if i != N - 1:
                await RisingEdge(dut.clk)

        # attendre paquet_ready
        await with_timeout(RisingEdge(dut.paquet_ready), 2_000, 'ns')
        print(f">>> paquet_ready détecté après bloc {mem_cycle}")

    ##############################
    # PHASE 2 : Lecture (FFT)
    ##############################

    print("\n--- Lecture des blocs ---")

    for mem_cycle in range(3):
        dut.valid_fft.value = 1
        for i in range(N):
            await with_timeout(RisingEdge(dut.valid_out), 2_000, 'ns')
            val = dut.data_out.value.signed_integer
            print(f"[Bloc {mem_cycle} | idx {i:03}] data_out = {val}")
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)
        dut.valid_fft.value = 0
        await Timer(50, units="ns")

    print("\n✅ Test terminé sans erreur.")
