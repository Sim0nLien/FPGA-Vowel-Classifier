SIM ?= icarus
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES = fft_stage_1/fft_stage_1.v \
				  fft_stage_2/fft_stage_2.v \
				  fft_stage_3/fft_stage_3.v \
				  fft_stage_4/fft_stage_4.v \
				  fft_stage_5/fft_stage_5.v \
				  fft_stage_6/fft_stage_6.v \
				  fft_stage_7/fft_stage_7.v \
				  fft_stage_8/fft_stage_8.v \
				  butterfly_unit/butterfly_unit.v \
				  butterfly_unit_no_imag/butterfly_unit_no_imag.v \
				  top_fft.v
TOPLEVEL = top_fft
MODULE = test_top_fft

include $(shell cocotb-config --makefiles)/Makefile.sim
