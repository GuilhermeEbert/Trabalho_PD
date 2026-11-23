
library ieee;
use ieee.std_logic_1164.all;

entity present_p_layer is
    port (
        state_in  : in  std_logic_vector(63 downto 0);
        state_out : out std_logic_vector(63 downto 0)
    );
end entity present_p_layer;

architecture rtl of present_p_layer is

begin

    gen_permutation : for i in 0 to 63 generate

        gen_normal : if i < 63 generate
            state_out((16*i) mod 63) <= state_in(i);
        end generate;

        gen_last : if i = 63 generate
            state_out(63) <= state_in(63);
        end generate;

    end generate;

end architecture rtl;

