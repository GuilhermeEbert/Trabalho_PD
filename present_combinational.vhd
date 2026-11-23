library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity present_combinational is
    port (
        plaintext   : in  std_logic_vector(63 downto 0);
        key_initial : in  std_logic_vector(79 downto 0);
        ciphertext  : out std_logic_vector(63 downto 0)
    );
end entity present_combinational;

architecture structural of present_combinational is

    component present_round is
        port (
            state_in  : in  std_logic_vector(63 downto 0);
            round_key : in  std_logic_vector(63 downto 0);
            state_out : out std_logic_vector(63 downto 0)
        );
    end component;

    component present_key_step is
        port (
            key_in    : in  std_logic_vector(79 downto 0);
            round_idx : in  std_logic_vector(4 downto 0);
            round_key : out std_logic_vector(63 downto 0);
            key_next  : out std_logic_vector(79 downto 0)
        );
    end component;

    type state_array_t is array (0 to 31) of std_logic_vector(63 downto 0);
    type key_array_t   is array (0 to 31) of std_logic_vector(79 downto 0);
    type rkey_array_t  is array (0 to 30) of std_logic_vector(63 downto 0);

    signal state_pipe : state_array_t;
    signal key_pipe   : key_array_t;
    signal round_keys : rkey_array_t;

begin

    -- Entradas iniciais da cadeia combinacional
    state_pipe(0) <= plaintext;
    key_pipe(0)   <= key_initial;

    -- 31 rodadas desenroladas em cascata
    gen_rounds : for i in 0 to 30 generate

        key_step_inst : present_key_step
            port map (
                key_in    => key_pipe(i),
                round_idx => std_logic_vector(to_unsigned(i + 1, 5)),
                round_key => round_keys(i),
                key_next  => key_pipe(i + 1)
            );

        round_inst : present_round
            port map (
                state_in  => state_pipe(i),
                round_key => round_keys(i),
                state_out => state_pipe(i + 1)
            );

    end generate gen_rounds;

    -- XOR final com K32 (64 bits mais significativos de key_pipe(31))
    ciphertext <= state_pipe(31) xor key_pipe(31)(79 downto 16);

end architecture structural;