from cocotb.triggers import RisingEdge, Timer, with_timeout
from cocotb.clock import Clock
import numpy as np
import matplotlib.pyplot as plt


@cocotb.test()
async def test_fft(cocotb):
    print("Running test_fft")