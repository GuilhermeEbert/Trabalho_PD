library ieee;
use ieee.std_logic_1164.all;

entity present_sbox_layer is
    port (
        state_in  : in  std_logic_vector(63 downto 0);
        state_out : out std_logic_vector(63 downto 0)
    );
end entity present_sbox_layer;

architecture rtl of present_sbox_layer is

    component present_sbox is
        port 
        (
            data_in  : in  std_logic_vector(3 downto 0);
            data_out : out std_logic_vector(3 downto 0)
        );
    end component;

begin
    sbox_0 : present_sbox
	port map(data_in =>state_in(3 downto 0),data_out => state_out(3 downto 0));
    sbox_1 : present_sbox
	port map(data_in =>state_in(7 downto 4),data_out => state_out(7 downto 4));
    sbox_2 : present_sbox
	port map(data_in =>state_in(11 downto 8),data_out => state_out(11 downto 8));
    sbox_3 : present_sbox
	port map(data_in =>state_in(15 downto 12),data_out => state_out(15 downto 12));
    sbox_4 : present_sbox
	port map(data_in =>state_in(19 downto 16),data_out => state_out(19 downto 16));
    sbox_5 : present_sbox
	port map(data_in =>state_in(23 downto 20),data_out => state_out(23 downto 20));
    sbox_6 : present_sbox
	port map(data_in =>state_in(27 downto 24),data_out => state_out(27 downto 24));
    sbox_7 : present_sbox
	port map(data_in =>state_in(31 downto 28),data_out => state_out(31 downto 28));
    sbox_8 : present_sbox
	port map(data_in =>state_in(35 downto 32),data_out => state_out(35 downto 32));
    sbox_9 : present_sbox
	port map(data_in =>state_in(39 downto 36),data_out => state_out(39 downto 36));
    sbox_10 : present_sbox
	port map(data_in =>state_in(43 downto 40),data_out => state_out(43 downto 40));
    sbox_11 : present_sbox
	port map(data_in =>state_in(47 downto 44),data_out => state_out(47 downto 44));
    sbox_12 : present_sbox
	port map(data_in =>state_in(51 downto 48),data_out => state_out(51 downto 48));
    sbox_13 : present_sbox
	port map(data_in =>state_in(55 downto 52),data_out => state_out(55 downto 52));
    sbox_14 : present_sbox
	port map(data_in =>state_in(59 downto 56),data_out => state_out(59 downto 56));
    sbox_15 : present_sbox
	port map(data_in =>state_in(63 downto 60),data_out => state_out(63 downto 60));
end architecture rtl;

