
library ieee;
use ieee.std_logic_1164.all;

entity present_round is
    port (
        state_in  : in  std_logic_vector(63 downto 0);
        round_key : in  std_logic_vector(63 downto 0);

        state_out : out std_logic_vector(63 downto 0)
    );
end entity present_round;


architecture structural of present_round is
    signal output_addroundkey : std_logic_vector(63 downto 0);
    signal output_sbox:std_logic_vector(63 downto 0);

    --instanciacao do componente sbox
    component present_sbox_layer is
    port (
        state_in  : in  std_logic_vector(63 downto 0);
        state_out : out std_logic_vector(63 downto 0)
    );
    end component;

    --instanciacao do componente addroundkey
    component AddRoundKey is
    port
    (
        state_in  : in  std_logic_vector(63 downto 0);
        round_key : in  std_logic_vector(63 downto 0);
        state_out : out std_logic_vector(63 downto 0)
    );
    end component;

    component present_p_layer is
    port (
        state_in  : in  std_logic_vector(63 downto 0);
        state_out : out std_logic_vector(63 downto 0)
    );
    end component;
begin
    add_key : AddRoundKey
    port map(state_in  => state_in,round_key => round_key,state_out =>output_addroundkey);
    sbox_layer : present_sbox_layer
    port map(state_in =>output_addroundkey,state_out =>output_sbox);
    p_layer : present_p_layer
    port map(state_in  =>output_sbox,state_out => state_out);
end architecture structural;
