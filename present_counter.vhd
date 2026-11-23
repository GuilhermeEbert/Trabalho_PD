library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity present_counter is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        enable : in std_logic;

        count : out std_logic_vector(4 downto 0);
        done  : out std_logic
    );
end entity present_counter;

architecture rtl of present_counter is
    signal count_reg : unsigned(4 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then

            if reset = '1' then
                count_reg <= (others => '0');

            elsif enable = '1' then

                if count_reg < 31 then
                    count_reg <= count_reg + 1;
                end if;

            end if;

        end if;
    end process;

    count <= std_logic_vector(count_reg);

    done <= '1' when count_reg = 31 else '0';

end architecture rtl;
