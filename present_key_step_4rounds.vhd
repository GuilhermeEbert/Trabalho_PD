library ieee;
use ieee.std_logic_1164.all;

entity present_key_step_4rounds is
    port (
        key_in        : in  std_logic_vector(79 downto 0);
        round_counter : in  std_logic_vector(4 downto 0);
        key_out       : out std_logic_vector(79 downto 0)
    );
end entity present_key_step_4rounds;

architecture rtl of present_key_step_4rounds is
    component present_sbox is
        port (
            data_in  : in  std_logic_vector(3 downto 0);
            data_out : out std_logic_vector(3 downto 0)
        );
    end component;

    signal key_rotated : std_logic_vector(79 downto 0);
    signal sbox_out    : std_logic_vector(3 downto 0);
    signal key_sboxed  : std_logic_vector(79 downto 0);
begin

    -- Rotacao de 61 bits para a esquerda em vetor de 80 bits
    key_rotated <= key_in(18 downto 0) & key_in(79 downto 19);

    u_sbox : present_sbox
        port map (
            data_in  => key_rotated(79 downto 76),
            data_out => sbox_out
        );

    key_sboxed <= sbox_out & key_rotated(75 downto 0);

    -- XOR do contador de rodada (5 bits) nos bits 19 downto 15
    key_out <= key_sboxed(79 downto 20) &
               (key_sboxed(19 downto 15) xor round_counter) &
               key_sboxed(14 downto 0);

end architecture rtl;