
library ieee;
use ieee.std_logic_1164.all;

entity present_state_register is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        enable   : in  std_logic;
        data_in  : in  std_logic_vector(63 downto 0);
        data_out : out std_logic_vector(63 downto 0)
    );
end entity present_state_register;

architecture rtl of present_state_register is

    signal state_reg : std_logic_vector(63 downto 0);

begin

    process(clk)
    begin

        if rising_edge(clk) then

            if reset = '1' then
                state_reg <= (others => '0');

            elsif enable = '1' then
                state_reg <= data_in;

            end if;

        end if;

    end process;

    data_out <= state_reg;

end architecture rtl;
