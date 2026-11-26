# 1. Define o relogio externo de referencia (50 MHz -> periodo de 20 ns)
create_clock -name {CLK} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLK}]

# 2. Deriva automaticamente os clocks da ALTPLL (c0 = CLK_SYS e c1 = CLK_MUL)
derive_pll_clocks

# 3. Calcula automaticamente jitter e incerteza entre os dominios da PLL
derive_clock_uncertainty