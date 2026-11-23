library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_present_combinational is
end entity tb_present_combinational;

architecture sim of tb_present_combinational is

    component present_combinational is
        port (
            plaintext   : in  std_logic_vector(63 downto 0);
            key_initial : in  std_logic_vector(79 downto 0);
            ciphertext  : out std_logic_vector(63 downto 0)
        );
    end component;

    signal plaintext   : std_logic_vector(63 downto 0) := (others => '0');
    signal key_initial : std_logic_vector(79 downto 0) := (others => '0');
    signal ciphertext  : std_logic_vector(63 downto 0);

    function slv_to_hex(slv : std_logic_vector) return string is
        constant hex_chars : string(1 to 16) := "0123456789ABCDEF";
        variable padded    : std_logic_vector(((slv'length + 3) / 4) * 4 - 1 downto 0) := (others => '0');
        variable result    : string(1 to ((slv'length + 3) / 4));
        variable nibble    : integer;
    begin
        padded(slv'length - 1 downto 0) := slv;
        for i in result'range loop
            nibble := to_integer(unsigned(padded(padded'left - (i - 1) * 4 downto padded'left - i * 4 + 1)));
            result(i) := hex_chars(nibble + 1);
        end loop;
        return result;
    end function;

begin

    uut : present_combinational
        port map (
            plaintext   => plaintext,
            key_initial => key_initial,
            ciphertext  => ciphertext
        );

    stim_proc : process
        file vec_file       : text open read_mode is "golden_vectors.txt";
        variable line_buf   : line;
        variable v_key      : std_logic_vector(79 downto 0);
        variable v_plain    : std_logic_vector(63 downto 0);
        variable v_expected : std_logic_vector(63 downto 0);
        variable good_read  : boolean;
        variable vec_count  : integer := 0;
    begin
        while not endfile(vec_file) loop
            readline(vec_file, line_buf);

            if line_buf'length > 0 and line_buf(line_buf'left) /= '#' then
                vec_count := vec_count + 1;

                hread(line_buf, v_key, good_read);
                assert good_read
                    report "Falha ao ler key na linha " & integer'image(vec_count)
                    severity failure;

                hread(line_buf, v_plain, good_read);
                assert good_read
                    report "Falha ao ler plaintext na linha " & integer'image(vec_count)
                    severity failure;

                hread(line_buf, v_expected, good_read);
                assert good_read
                    report "Falha ao ler ciphertext esperado na linha " & integer'image(vec_count)
                    severity failure;

                -- Aplica entradas combinacionais
                key_initial <= v_key;
                plaintext   <= v_plain;

                -- Aguarda estabilizacao dos delta cycles / propagacao
                wait for 20 ns;

                assert ciphertext = v_expected
                    report "ERRO no vetor #" & integer'image(vec_count) &
                           " | Obtido: " & slv_to_hex(ciphertext) &
                           " | Esperado: " & slv_to_hex(v_expected)
                    severity error;

                report "Vetor #" & integer'image(vec_count) &
                       " OK | Ciphertext: " & slv_to_hex(ciphertext)
                    severity note;
            end if;
        end loop;

        report "============================================" severity note;
        report "TODOS OS " & integer'image(vec_count) & " VETORES COMBINACIONAIS APROVADOS!" severity note;
        report "============================================" severity note;

        wait;
    end process;

end architecture sim;