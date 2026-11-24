
library ieee;
use ieee.std_logic_1164.all;

entity present_iterative is
    port (
        clk         : in std_logic;
        reset       : in std_logic;

        plaintext   : in std_logic_vector(63 downto 0);
        key_initial : in std_logic_vector(79 downto 0);

        ciphertext  : out std_logic_vector(63 downto 0);
        done        : out std_logic
    );
end entity present_iterative;


architecture structural of present_iterative is

    ------------------------------------------------
    -- DECLARACAO DOS COMPONENTES
    ------------------------------------------------

    component present_fsm is
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
    end component;

    component present_counter is
        port (
            clk    : in std_logic;
            reset  : in std_logic;
            enable : in std_logic;

            count : out std_logic_vector(4 downto 0);
            done  : out std_logic
        );
    end component;

    component present_key_schedule is
        port (
            clk           : in std_logic;
            reset         : in std_logic;
            enable        : in std_logic;
            key_initial   : in std_logic_vector(79 downto 0);
            round_counter : in std_logic_vector(4 downto 0);

            round_key   : out std_logic_vector(63 downto 0);
            key_current : out std_logic_vector(79 downto 0)
        );
    end component;

    component present_state_register is
        port (
            clk      : in std_logic;
            reset    : in std_logic;
            enable   : in std_logic;
            data_in  : in std_logic_vector(63 downto 0);
            data_out : out std_logic_vector(63 downto 0)
        );
    end component;

    component present_round is
        port (
            state_in  : in std_logic_vector(63 downto 0);
            round_key : in std_logic_vector(63 downto 0);
            state_out : out std_logic_vector(63 downto 0)
        );
    end component;


    ------------------------------------------------
    -- DECLARACAO DOS SINAIS INTERNOS
    ------------------------------------------------

    -- Sinais da FSM
    signal state_load         : std_logic;
    signal state_write_enable : std_logic;

    signal key_enable     : std_logic;
    signal counter_enable : std_logic;
    signal counter_reset  : std_logic;

    signal key_round_counter : std_logic_vector(4 downto 0);

    signal finalize : std_logic;
    signal fsm_done : std_logic;

    -- Sinais do contador
    signal round_count : std_logic_vector(4 downto 0);
    signal counter_reset_total : std_logic;

    -- Sinais do registrador de estado
    signal state_current : std_logic_vector(63 downto 0);
    signal state_next    : std_logic_vector(63 downto 0);
    signal state_register_input : std_logic_vector(63 downto 0);

    -- Sinais do Key Schedule
    signal round_key   : std_logic_vector(63 downto 0);
    signal key_current : std_logic_vector(79 downto 0);

    -- Sinal nao utilizado do contador
    signal counter_done : std_logic;


begin

    ------------------------------------------------
    -- 1. FSM
    ------------------------------------------------

    controller : present_fsm
        port map (
            clk => clk,
            reset => reset,

            round_count => round_count,

            state_load => state_load,
            state_write_enable => state_write_enable,

            key_enable => key_enable,
            counter_enable => counter_enable,
            counter_reset => counter_reset,

            key_round_counter => key_round_counter,

            finalize => finalize,
            done => fsm_done
        );


    ------------------------------------------------
    -- 2. CONTADOR DE RODADAS
    ------------------------------------------------

    counter_reset_total <= reset or counter_reset;

    counter : present_counter
        port map (
            clk => clk,
            reset => counter_reset_total,
            enable => counter_enable,

            count => round_count,
            done => counter_done
        );


    ------------------------------------------------
    -- 3. KEY SCHEDULE
    ------------------------------------------------

    key_generator : present_key_schedule
        port map (
            clk => clk,
            reset => reset,
            enable => key_enable,

            key_initial => key_initial,
            round_counter => key_round_counter,

            round_key => round_key,
            key_current => key_current
        );


    ------------------------------------------------
    -- 4. MULTIPLEXADOR DO REGISTRADOR DE ESTADO
    ------------------------------------------------

    state_register_input <= plaintext
        when state_load = '1'
        else state_next;


    ------------------------------------------------
    -- 5. REGISTRADOR DE ESTADO
    ------------------------------------------------

    state_register : present_state_register
        port map (
            clk => clk,
            reset => reset,
            enable => state_write_enable,

            data_in => state_register_input,
            data_out => state_current
        );


    ------------------------------------------------
    -- 6. RODADA PRESENT
    ------------------------------------------------

    round_unit : present_round
        port map (
            state_in => state_current,
            round_key => round_key,
            state_out => state_next
        );


    ------------------------------------------------
    -- 7. XOR FINAL COM K32
    ------------------------------------------------

    ciphertext <= state_current xor round_key;


    ------------------------------------------------
    -- 8. SINAL DE CONCLUSAO
    ------------------------------------------------

    done <= fsm_done;

end architecture structural;

