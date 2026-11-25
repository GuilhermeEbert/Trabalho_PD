library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package present_key_step_pkg is
    -- Aplica 1 passo do Key Schedule do PRESENT-80:
    -- Recebe a chave de 80 bits atual e o indice da rodada (1..31),
    -- retorna a proxima chave de 80 bits.
    function present_key_update(
        key_in    : std_logic_vector(79 downto 0);
        round_idx : integer
    ) return std_logic_vector;
end package present_key_step_pkg;

package body present_key_step_pkg is
    function key_sbox4(x : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case x is
            when x"0" => return x"C";
            when x"1" => return x"5";
            when x"2" => return x"6";
            when x"3" => return x"B";
            when x"4" => return x"9";
            when x"5" => return x"0";
            when x"6" => return x"A";
            when x"7" => return x"D";
            when x"8" => return x"3";
            when x"9" => return x"E";
            when x"A" => return x"F";
            when x"B" => return x"8";
            when x"C" => return x"4";
            when x"D" => return x"7";
            when x"E" => return x"1";
            when x"F" => return x"2";
            when others => return x"0";
        end case;
    end function;

    function present_key_update(
        key_in    : std_logic_vector(79 downto 0);
        round_idx : integer
    ) return std_logic_vector is
        variable rot       : std_logic_vector(79 downto 0);
        variable sboxed    : std_logic_vector(79 downto 0);
        variable k_next    : std_logic_vector(79 downto 0);
        variable rc_vec    : std_logic_vector(4 downto 0);
    begin
        -- Rotacao de 61 bits para a esquerda em vetor de 80 bits:
        -- [79..19] vai para [60..0], [18..0] vai para [79..61]
        rot := key_in(18 downto 0) & key_in(79 downto 19);

        -- S-box nos 4 bits mais significativos
        sboxed := key_sbox4(rot(79 downto 76)) & rot(75 downto 0);

        -- XOR do contador de rodada (5 bits) nos bits 19 downto 15
        rc_vec := std_logic_vector(to_unsigned(round_idx, 5));
        k_next := sboxed(79 downto 20) &
                  (sboxed(19 downto 15) xor rc_vec) &
                  sboxed(14 downto 0);

        return k_next;
    end function;
end package body present_key_step_pkg;