library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_present_iterative is
end entity tb_present_iterative;

architecture sim of tb_present_iterative is
    component present_iterative is
        port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            start       : in  std_logic;
            plaintext   : in  std_logic_vector(63 downto 0);
            key_initial : in  std_logic_vector(79 downto 0);
            ciphertext  : out std_logic_vector(63 downto 0);
            done        : out std_logic
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;

    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal start       : std_logic := '0';
    signal plaintext   : std_logic_vector(63 downto 0) := (others => '0');
    signal key_initial : std_logic_vector(79 downto 0) := (others => '0');
    signal ciphertext  : std_logic_vector(63 downto 0);
    signal done        : std_logic;
begin

    clk <= not clk after CLK_PERIOD / 2;

    uut : present_iterative
        port map (
            clk         => clk,
            reset       => reset,
            start       => start,
            plaintext   => plaintext,
            key_initial => key_initial,
            ciphertext  => ciphertext,
            done        => done
        );

    stim_proc : process
        file vec_file      : text open read_mode is "golden_vectors.txt";
        variable line_buf      : line;
        variable v_key         : std_logic_vector(79 downto 0);
        variable v_plain       : std_logic_vector(63 downto 0);
        variable v_expected    : std_logic_vector(63 downto 0);
        variable good_read     : boolean;
        variable vec_count     : integer := 0;
    begin
        -- Reset inicial limpo
        reset <= '1';
        start <= '0';
        wait for 2 * CLK_PERIOD;
        reset <= '0';
        wait until rising_edge(clk);

        while not endfile(vec_file) loop
            readline(vec_file, line_buf);

            -- Ignora linhas vazias ou comentários iniciados com '#'
            if line_buf'length > 0 and line_buf(line_buf'left) /= '#' then
                vec_count := vec_count + 1;

                hread(line_buf, v_key, good_read);
                assert good_read report "Falha ao ler key na linha " & integer'image(vec_count) severity failure;

                hread(line_buf, v_plain, good_read);
                assert good_read report "Falha ao ler plaintext na linha " & integer'image(vec_count) severity failure;

                hread(line_buf, v_expected, good_read);
                assert good_read report "Falha ao ler ciphertext esperado na linha " & integer'image(vec_count) severity failure;

                -- Aplica estímulo
                key_initial <= v_key;
                plaintext   <= v_plain;
                start       <= '1';
                wait until rising_edge(clk);
                start       <= '0';

                -- Aguarda conclusão com timeout de segurança
                wait until done = '1' for 80 * CLK_PERIOD;
                assert done = '1'
                    report "TIMEOUT aguardando done no vetor #" & integer'image(vec_count)
                    severity failure;

                wait for 1 ns; -- garante estabilização combinacional após borda

                assert ciphertext = v_expected
                    report "Divergencia no vetor #" & integer'image(vec_count)
                    severity error;

                report "Vetor #" & integer'image(vec_count) & " OK" severity note;

                wait until rising_edge(clk);
            end if;
        end loop;

        report "Todos os " & integer'image(vec_count) & " vetores foram processados." severity note;
        wait;
    end process;

end architecture sim;