create_clock -name {clk_itrv} -period 5.000 -waveform { 0.000 2.500 } [get_ports {clk_itrv}]

derive_clock_uncertainty