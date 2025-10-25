import cocotb
from cocotb.triggers import RisingEdge, Timer, with_timeout
from cocotb.clock import Clock
import numpy as np


@cocotb.test()
async def test_fft_stage_1(dut):
    """Test complet du module fft_stage"""

    # Création de l’horloge : 10 ns -> 100 MHz
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Initialisation
    dut.reset.value = 1
    dut.valid_in.value = 0
    dut.valid_packet.value = 0
    dut.data_in_real.value = 0

    # Reset pendant quelques cycles
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.reset.value = 0

    cocotb.log.info("🔧 Début du test FFT Stage")

    # ---- Envoi d’un premier paquet ----
    # Simulation d’un bloc de données valides avec un valid_packet actif
    test_data_real = np.arange(0,256,dtype=int)

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    dut.valid_packet.value = 1
    await RisingEdge(dut.clk)
    dut.valid_packet.value = 0
    await RisingEdge(dut.clk)


    await with_timeout(RisingEdge(dut.valid_request), 200, 'ns')
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # On commence à envoyer les données
    for i in range(len(test_data_real)):

        dut.valid_in.value = 1
        dut.data_in_real.value = int(test_data_real[i])
        await RisingEdge(dut.clk)
        dut.valid_in.value = 0
        
        if i < len(test_data_real) - 1:
            await with_timeout(RisingEdge(dut.valid_request), 200, 'ns')
        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)



    cocotb.log.info("✅ Test FFT Stage terminé avec succès")
