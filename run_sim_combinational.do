quit -sim
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

vcom -2008 present_sbox.vhd
vcom -2008 present_p_layer.vhd
vcom -2008 present_sbox_layer.vhd
vcom -2008 AddRoundKey.vhd
vcom -2008 present_round.vhd
vcom -2008 present_key_step.vhd
vcom -2008 present_combinational.vhd
vcom -2008 tb_present_combinational.vhd

#Simulacao e ondas
vsim -voptargs=+acc work.tb_present_combinational
add wave -radix hex /tb_present_combinational/key_initial
add wave -radix hex /tb_present_combinational/plaintext
add wave -radix hex /tb_present_combinational/ciphertext

run -all
wave zoom full