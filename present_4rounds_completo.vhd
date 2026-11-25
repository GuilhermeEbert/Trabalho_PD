library ieee;
use ieee.std_logic_1164.all;

entity present_4rounds_completo is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        plaintext   : in  std_logic_vector(63 downto 0);
        key_initial : in  std_logic_vector(79 downto 0);
        ciphertext  : out std_logic_vector(63 downto 0);
        done        : out std_logic
    );
end entity present_4rounds_completo;

architecture structural of present_4rounds_completo is
    component present_4rounds is
        port (
            state_in   : in  std_logic_vector(63 downto 0);
            key_in     : in  std_logic_vector(79 downto 0);
            base_round : in  integer range 1 to 31;
            num_rounds : in  integer range 3 to 4;

            state_out  : out std_logic_vector(63 downto 0);
            key_out    : out std_logic_vector(79 downto 0)
        );
    end component;

    type state_type is (IDLE, LOAD, EXEC, DONE_ST);

    signal current_state : state_type;
    signal step_idx      : integer range 0 to 7;

    signal state_reg     : std_logic_vector(63 downto 0);
    signal key_reg       : std_logic_vector(79 downto 0);

    signal base_round    : integer range 1 to 31;
    signal num_rounds    : integer range 3 to 4;
    signal state_next    : std_logic_vector(63 downto 0);
    signal key_next      : std_logic_vector(79 downto 0);
begin

    base_round <= 4 * step_idx + 1 when step_idx < 7 else 29;
    num_rounds <= 4 when step_idx < 7 else 3;

    u_block : present_4rounds
        port map (
            state_in   => state_reg,
            key_in     => key_reg,
            base_round => base_round,
            num_rounds => num_rounds,
            state_out  => state_next,
            key_out    => key_next
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= IDLE;
                step_idx      <= 0;
                state_reg     <= (others => '0');
                key_reg       <= (others => '0');
            else
                case current_state is
                    when IDLE =>
                        current_state <= LOAD;

                    when LOAD =>
                        state_reg     <= plaintext;
                        key_reg       <= key_initial;
                        step_idx      <= 0;
                        current_state <= EXEC;

                    when EXEC =>
                        state_reg <= state_next;
                        key_reg   <= key_next;
                        if step_idx < 7 then
                            step_idx      <= step_idx + 1;
                            current_state <= EXEC;
                        else
                            current_state <= DONE_ST;
                        end if;

                    when DONE_ST =>
                        current_state <= DONE_ST;
                end case;
            end if;
        end if;
    end process;

    ciphertext <= state_reg xor key_reg(79 downto 16);
    done       <= '1' when current_state = DONE_ST else '0';

end architecture structural;