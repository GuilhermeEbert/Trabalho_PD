library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity present_fsm is
    port (
        clk   : in std_logic;
        reset : in std_logic;

        round_count : in std_logic_vector(4 downto 0);

        state_load         : out std_logic;
        state_write_enable : out std_logic;

        key_enable     : out std_logic;
        counter_enable : out std_logic;
        counter_reset  : out std_logic;

        key_round_counter : out std_logic_vector(4 downto 0);

        finalize : out std_logic;
        done     : out std_logic
    );
end entity present_fsm;

architecture rtl of present_fsm is

    type state_type is (
        IDLE,
        LOAD,
        ROUND,
        UPDATE,
        FINAL,
        FINISHED
    );

    signal current_state : state_type;
    signal next_state    : state_type;

begin

    -- Registrador de estados sincrono
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= IDLE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;

    -- Logica de proximo estado
    process(current_state, reset, round_count)
    begin
        next_state <= current_state;

        case current_state is
            when IDLE =>
                if reset = '0' then
                    next_state <= LOAD;
                end if;

            when LOAD =>
                next_state <= ROUND;

            when ROUND =>
                next_state <= UPDATE;

            when UPDATE =>
                -- Apos atualizar da rodada 30 para a 31 (round_count = "11111"), vai para FINAL
                if round_count = "11111" then
                    next_state <= FINAL;
                else
                    next_state <= ROUND;
                end if;

            when FINAL =>
                next_state <= FINISHED;

            when FINISHED =>
                if reset = '1' then
                    next_state <= IDLE;
                end if;
        end case;
    end process;

    -- Logica de saidas de controle
    process(current_state)
    begin
        state_load         <= '0';
        state_write_enable <= '0';
        key_enable         <= '0';
        counter_enable     <= '0';
        counter_reset      <= '0';
        finalize           <= '0';
        done               <= '0';

        case current_state is
            when IDLE =>
                null;

            when LOAD =>
                state_load         <= '1';
                state_write_enable <= '1';
                key_enable         <= '1';
                counter_reset      <= '1';

            when ROUND =>
                null;

            when UPDATE =>
                state_write_enable <= '1';
                key_enable         <= '1';
                counter_enable     <= '1';

            when FINAL =>
                finalize <= '1';

            when FINISHED =>
                done <= '1';
        end case;
    end process;

    -- Indice da rodada (1 a 31) usado na atualizacao do key schedule
    process(current_state, round_count)
    begin
        key_round_counter <= round_count;

        if current_state = LOAD then
            key_round_counter <= "00000";
        elsif current_state = UPDATE then
            key_round_counter <= std_logic_vector(unsigned(round_count) + 1);
        end if;
    end process;

end architecture rtl;