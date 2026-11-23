
library ieee;
use ieee.std_logic_1164.all;

entity present_key_schedule is
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        enable        : in  std_logic;

        key_initial   : in  std_logic_vector(79 downto 0);
        round_counter : in  std_logic_vector(4 downto 0);

        round_key     : out std_logic_vector(63 downto 0);
        key_current   : out std_logic_vector(79 downto 0)
    );
end entity present_key_schedule;

architecture rtl of present_key_schedule is

    signal key_reg     : std_logic_vector(79 downto 0);
    signal key_rotated : std_logic_vector(79 downto 0);
    signal sbox_out    : std_logic_vector(3 downto 0);
    signal key_sboxed  : std_logic_vector(79 downto 0);
    signal key_next    : std_logic_vector(79 downto 0);

begin

    -- 1. Extrair a chave da rodada atual
    round_key <= key_reg(79 downto 16);

    -- 2. Rotacionar a chave 61 bits para a esquerda
    key_rotated <= key_reg(18 downto 0) & key_reg(79 downto 19);

    -- 3. Aplicar S-box aos quatro bits mais significativos
    sbox_key : entity work.present_sbox
        port map (
            data_in  => key_rotated(79 downto 76),
            data_out => sbox_out
        );

    -- 4. Substituir os quatro bits superiores
    key_sboxed <= sbox_out & key_rotated(75 downto 0);

    -- 5. XOR do contador nos bits 19 até 15
    key_next <= key_sboxed(79 downto 20) &
                (key_sboxed(19 downto 15) xor round_counter) &
                key_sboxed(14 downto 0);

    -- 6. Registrador de chave
    process(clk)
    begin

        if rising_edge(clk) then

            if reset = '1' then
                key_reg <= (others => '0');

            elsif enable = '1' then

                if round_counter = "00000" then
                    key_reg <= key_initial;
                else
                    key_reg <= key_next;
                end if;

            end if;

        end if;

    end process;

    -- 7. Disponibilizar a chave completa atual
    key_current <= key_reg;

end architecture rtl;


