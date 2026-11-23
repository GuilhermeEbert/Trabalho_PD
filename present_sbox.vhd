
library ieee;
use ieee.std_logic_1164.all;

entity present_sbox is
    port (
        data_in  : in  std_logic_vector(3 downto 0);
        data_out : out std_logic_vector(3 downto 0)
    );
end entity present_sbox;

architecture rtl of present_sbox is
begin

    process(data_in)
    begin
        case data_in is

            when "0000" =>
                data_out <= "1100";

            when "0001" =>
                data_out <= "0101";

            when "0010" =>
                data_out <= "0110";

            when "0011" =>
                data_out <= "1011";

            when "0100" =>
                data_out <= "1001";

            when "0101" =>
                data_out <= "0000";

            when "0110" =>
                data_out <= "1010";

            when "0111" =>
                data_out <= "1101";

            when "1000" =>
                data_out <= "0011";

            when "1001" =>
                data_out <= "1110";

            when "1010" =>
                data_out <= "1111";

            when "1011" =>
                data_out <= "1000";

            when "1100" =>
                data_out <= "0100";

            when "1101" =>
                data_out <= "0111";

            when "1110" =>
                data_out <= "0001";

            when "1111" =>
                data_out <= "0010";

            when others =>
                data_out <= "0000";

        end case;
    end process;

end architecture rtl;

