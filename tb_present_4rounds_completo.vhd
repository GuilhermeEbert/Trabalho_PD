library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_present_4rounds_completo is
end entity tb_present_4rounds_completo;

architecture sim of tb_present_4rounds_completo is

    component present_4rounds_completo is
        port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            plaintext   : in  std_logic_vector(63 downto 0);
            key_initial : in  std_logic_vector(79 downto 0);
            ciphertext  : out std_logic_vector(63 downto 0);
            done        : out std_logic
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;

    signal clk         : std_logic := '0';
    signal reset       : std_logic := '1';
    signal plaintext   : std_logic_vector(63 downto 0) := (others => '0');
    signal key_initial : std_logic_vector(79 downto 0) := (others => '0');
    signal ciphertext  : std_logic_vector(63 downto 0);
    signal done        : std_logic;

begin

    clk <= not clk after CLK_PERIOD / 2;

    uut : present_4rounds_completo
        port map (
            clk         => clk,
            reset       => reset,
            plaintext   => plaintext,
            key_initial => key_initial,
            ciphertext  => ciphertext,
            done        => done
        );

    stim_proc : process
        file vec_file       : text open read_mode is "golden_vectors.txt";
        variable line_buf   : line;
        variable out_line   : line;
        variable v_key      : std_logic_vector(79 downto 0);
        variable v_plain    : std_logic_vector(63 downto 0);
        variable v_expected : std_logic_vector(63 downto 0);
        variable good_read  : boolean;
        variable vec_count  : integer := 0;
        variable pass_count : integer := 0;
    begin
        reset <= '1';
        wait for 2 * CLK_PERIOD;

        while not endfile(vec_file) loop
            readline(vec_file, line_buf);

            -- Ignora linhas vazias ou comentarios iniciados com '#'
            if line_buf'length > 0 and line_buf(line_buf'left) /= '#' then
                vec_count := vec_count + 1;

                hread(line_buf, v_key, good_read);
                assert good_read report "Falha ao ler key na linha " & integer'image(vec_count) severity failure;

                hread(line_buf, v_plain, good_read);
                assert good_read report "Falha ao ler plaintext na linha " & integer'image(vec_count) severity failure;

                hread(line_buf, v_expected, good_read);
                assert good_read report "Falha ao ler ciphertext esperado na linha " & integer'image(vec_count) severity failure;

                -- Garante reset e estimulos estaveis antes de liberar a FSM
                reset       <= '1';
                key_initial <= v_key;
                plaintext   <= v_plain;
                wait for 2 * CLK_PERIOD;
                wait until rising_edge(clk);
                reset <= '0';

                -- Aguarda conclusao com timeout de seguranca
                wait until done = '1' for 30 * CLK_PERIOD;
                assert done = '1'
                    report "TIMEOUT aguardando done no vetor #" & integer'image(vec_count)
                    severity failure;

                wait for 1 ns;

                -- Imprime comparacao visual Esperado vs Obtido em hexadecimal
                write(out_line, string'("Vetor #"));
                write(out_line, vec_count);
                write(out_line, string'(" | Esperado: 0x"));
                hwrite(out_line, v_expected);
                write(out_line, string'(" | Obtido: 0x"));
                hwrite(out_line, ciphertext);

                if ciphertext = v_expected then
                    pass_count := pass_count + 1;
                    write(out_line, string'(" -> [OK]"));
                    writeline(output, out_line);
                else
                    write(out_line, string'(" -> [DIVERGENTE]"));
                    writeline(output, out_line);
                    report "Divergencia no vetor #" & integer'image(vec_count) severity error;
                end if;

                -- Prepara proximo vetor com reset ativo
                reset <= '1';
                wait for CLK_PERIOD;
            end if;
        end loop;

        report "Resumo: " & integer'image(pass_count) & " de " &
               integer'image(vec_count) & " vetores passaram." severity note;
        wait;
    end process;

end architecture sim;