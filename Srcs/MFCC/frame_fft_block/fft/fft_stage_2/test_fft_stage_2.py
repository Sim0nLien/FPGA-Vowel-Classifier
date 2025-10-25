# test_fft_stage_1.py
import numpy as np
import cocotb
from cocotb.triggers import RisingEdge, Timer, with_timeout
from cocotb.clock import Clock

@cocotb.test()
async def test_fft_stage_1_basic(dut):
    """Test basique du module fft_stage_1."""

    # Lancer l’horloge
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.reset.value = 1
    dut.valid_in.value = 0
    dut.data_in_real_0.value = 0
    dut.data_in_imag_0.value = 0
    dut.data_in_real_1.value = 0
    dut.data_in_imag_1.value = 0
    await Timer(20, unit="ns")
    dut.reset.value = 0
    await RisingEdge(dut.clk)

    # Données d'entrée simulées
    data_real = np.arange(0,256)
    data_imag = np.arange(0,256)

    # Envoi des données
    dut._log.info("Envoi des données d’entrée...")
    for i in range(256//2):

        await RisingEdge(dut.clk)
        print(i)

        dut.data_in_real_0.value = int(data_real[2 * i])
        dut.data_in_imag_0.value = int(data_imag[2 * i])
        dut.data_in_real_1.value = int(data_real[2 * i + 1])
        dut.data_in_imag_1.value = int(data_imag[2 * i + 1])

        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
        dut.valid_in.value = 0

    # Attente des sorties
    dut._log.info("Attente des sorties valides...")
    output_samples = []
    for _ in range(50):  # fenêtre max
        
        await with_timeout(RisingEdge(dut.valid_out), 200, 'ns')
        
        re_out_0 = dut.data_out_real_0.value.signed_integer
        im_out_0 = dut.data_out_imag_0.value.signed_integer
        re_out_1 = dut.data_out_real_1.value.signed_integer
        im_out_1 = dut.data_out_imag_1.value.signed_integer

        coeff_re = dut.coeff_out_real.value.signed_integer
        coeff_im = dut.coeff_out_imag.value.signed_integer
        output_samples.append((re_out_0, im_out_0, coeff_re, coeff_im))
        dut._log.info(f"Sortie valide 0 : data=({re_out_0}, {im_out_0}), coeff=({coeff_re}, {coeff_im})")
        dut._log.info(f"Sortie valide 1 : data=({re_out_1}, {im_out_1})")

        # Vérifications de base
    assert len(output_samples) > 0, "Aucune sortie valide détectée !"
    dut._log.info(f"Nombre de sorties valides : {len(output_samples)}")

    # Exemple de vérification légère (à adapter selon ton comportement attendu)
    for i, (re, im, c_re, c_im) in enumerate(output_samples):
        assert isinstance(re, int) and isinstance(im, int)
    dut._log.debug(f"Échantillon {i}: re={re}, im={im}, coeff=({c_re},{c_im})")

    dut._log.info("✅ Test terminé avec succès.")
