library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity present_key_step is
    port (
        key_in    : in  std_logic_vector(79 downto 0);
        round_idx : in  std_logic_vector(4 downto 0);
        round_key : out std_logic_vector(63 downto 0);
        key_next  : out std_logic_vector(79 downto 0)
    );
end entity present_key_step;

architecture rtl of present_key_step is

    component present_sbox is
        port (
            data_in  : in  std_logic_vector(3 downto 0);
            data_out : out std_logic_vector(3 downto 0)
        );
    end component;

    signal key_rot   : std_logic_vector(79 downto 0);
    signal sbox_out  : std_logic_vector(3 downto 0);
    signal key_sbox  : std_logic_vector(79 downto 0);

begin

    -- A subchave da rodada atual sao os 64 bits mais significativos
    round_key <= key_in(79 downto 16);

    -- 1. Rotacao circular de 61 bits para a esquerda
    key_rot <= key_in(18 downto 0) & key_in(79 downto 19);

    -- 2. S-box nos 4 bits mais significativos (79 downto 76)
    sbox_inst : present_sbox
        port map (
            data_in  => key_rot(79 downto 76),
            data_out => sbox_out
        );

    key_sbox <= sbox_out & key_rot(75 downto 0);

    -- 3. XOR do contador de rodada (1 a 31) nos bits 19 downto 15
    key_next(79 downto 20) <= key_sbox(79 downto 20);
    key_next(19 downto 15) <= key_sbox(19 downto 15) xor round_idx;
    key_next(14 downto 0)  <= key_sbox(14 downto 0);

end architecture rtl;