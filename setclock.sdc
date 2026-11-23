# Criando um clock virtual chamado "virtclk"

create_clock -name {clock} -period 5.000 -waveform { 0.000 2.500 }

# Configurando delay de entrada e de saída

set_input_delay -clock clock 0.1 [all_inputs]

set_output_delay -clock clock 0.1 [all_outputs]
