#prepara
quit -sim
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

#compila
vcom -2008 present_sbox.vhd
vcom -2008 present_p_layer.vhd
vcom -2008 present_sbox_layer.vhd
vcom -2008 AddRoundKey.vhd
vcom -2008 present_counter.vhd
vcom -2008 present_state_register.vhd
vcom -2008 present_fsm.vhd
vcom -2008 present_key_schedule.vhd
vcom -2008 present_round.vhd
vcom -2008 present_iterative.vhd
vcom -2008 tb_present_iterative.vhd

#Inicia simulação e ondas
vsim -voptargs=+acc work.tb_present_iterative
add wave -radix hex /tb_present_iterative/clk
add wave -radix hex /tb_present_iterative/reset
add wave -radix hex /tb_present_iterative/start
add wave -radix hex /tb_present_iterative/key_initial
add wave -radix hex /tb_present_iterative/plaintext
add wave -radix hex /tb_present_iterative/ciphertext
add wave -radix hex /tb_present_iterative/done
add wave -radix hex /tb_present_iterative/uut/round_count

run -all
wave zoom full