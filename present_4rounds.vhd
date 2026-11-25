library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity present_4rounds is
    port (
        state_in   : in  std_logic_vector(63 downto 0);
        key_in     : in  std_logic_vector(79 downto 0);
        base_round : in  integer range 1 to 31;
        num_rounds : in  integer range 3 to 4;

        state_out  : out std_logic_vector(63 downto 0);
        key_out    : out std_logic_vector(79 downto 0)
    );
end entity present_4rounds;

architecture rtl of present_4rounds is
    component present_round is
        port (
            state_in  : in  std_logic_vector(63 downto 0);
            round_key : in  std_logic_vector(63 downto 0);
            state_out : out std_logic_vector(63 downto 0)
        );
    end component;

    component present_key_step_4rounds is
        port (
            key_in        : in  std_logic_vector(79 downto 0);
            round_counter : in  std_logic_vector(4 downto 0);
            key_out       : out std_logic_vector(79 downto 0)
        );
    end component;

    signal s1, s2, s3, s4 : std_logic_vector(63 downto 0);
    signal k1, k2, k3, k4 : std_logic_vector(79 downto 0);
begin

    r1 : present_round
        port map (
            state_in  => state_in,
            round_key => key_in(79 downto 16),
            state_out => s1
        );
    ku1 : present_key_step_4rounds
        port map (
            key_in        => key_in,
            round_counter => std_logic_vector(to_unsigned(base_round, 5)),
            key_out       => k1
        );

    r2 : present_round
        port map (
            state_in  => s1,
            round_key => k1(79 downto 16),
            state_out => s2
        );
    ku2 : present_key_step_4rounds
        port map (
            key_in        => k1,
            round_counter => std_logic_vector(to_unsigned(base_round + 1, 5)),
            key_out       => k2
        );

    r3 : present_round
        port map (
            state_in  => s2,
            round_key => k2(79 downto 16),
            state_out => s3
        );
    ku3 : present_key_step_4rounds
        port map (
            key_in        => k2,
            round_counter => std_logic_vector(to_unsigned(base_round + 2, 5)),
            key_out       => k3
        );

    r4 : present_round
        port map (
            state_in  => s3,
            round_key => k3(79 downto 16),
            state_out => s4
        );
    ku4 : present_key_step_4rounds
        port map (
            key_in        => k3,
            round_counter => std_logic_vector(to_unsigned(base_round + 3, 5)),
            key_out       => k4
        );

    state_out <= s4 when num_rounds = 4 else s3;
    key_out   <= k4 when num_rounds = 4 else k3;

end architecture rtl;