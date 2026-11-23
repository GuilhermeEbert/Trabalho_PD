library ieee;
use ieee.std_logic_1164.all;

entity AddRoundKey is
    port
    (
        state_in  : in  std_logic_vector(63 downto 0);
        round_key : in  std_logic_vector(63 downto 0);
        state_out : out std_logic_vector(63 downto 0)
    );
end entity AddRoundKey;
architecture rtl of AddRoundKey is
begin
	state_out <=state_in xor round_key;
end rtl;
