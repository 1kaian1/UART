-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Jan Kai Marek (xmarekj00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_FSM is
    port(
        CLK          : in  std_logic;
        RST          : in  std_logic;
        VLD          : in  std_logic;
        BIT_END      : in  std_logic;
        WORD_END     : in  std_logic;
        RDY          : out std_logic;
        START        : out std_logic;
        STOP         : out std_logic;
        CYCLE_COUNT  : out std_logic;
        DATA_COUNT   : out std_logic
    );
end entity;

architecture behavioral of UART_RX_FSM is
    type state_type is (IDLE_STATE, START_STATE, DATA_STATE, STOP_STATE);
    signal state, next_state : state_type;
begin

    -- Stavový registr
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                state <= IDLE_STATE;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    -- Logika přechodů mezi stavy
    process(state, VLD, BIT_END, WORD_END)
    begin
        case state is

            -- Čeká na VLD pro přechod do stavu SSTART, jinak zůstává v IDLE.
            -- Kdo mění VLD? Co indikuje? Nový bit k dispozici?
            when IDLE_STATE =>
                if VLD = '1' then
                    next_state <= START_STATE;
                else
                    next_state <= IDLE_STATE;
                end if;

            -- Čeká na BIT_END (mid_bit) pro přechod do stavu DATA.
            when START_STATE =>
                if BIT_END = '1' then
                    next_state <= DATA_STATE;
                else
                    next_state <= START_STATE;
                end if;

            -- Čeká na BIT_END (mid_bit) a WORD_END (flag pro konec slova) pro přechod do stavu SSTOP.
            when DATA_STATE =>
                if (BIT_END = '1') and (WORD_END = '1') then
                    next_state <= STOP_STATE;
                else
                    next_state <= DATA_STATE;
                end if;

            -- Čeká na BIT_END pro přechod do stavu IDLE.
            when STOP_STATE =>
                if BIT_END = '1' then
                    next_state <= IDLE_STATE;
                else
                    next_state <= STOP_STATE;
                end if;

            -- Cokoli ostatního jde do IDLE.
            when others =>
                next_state <= IDLE_STATE;
        end case;
    end process;

    -- Moorovy výstupy podle aktuálního stavu
    RDY        <= '1' when state = IDLE_STATE else '0';
    START      <= '1' when state = START_STATE else '0';
    CYCLE_COUNT      <= '1' when (state = START_STATE) or (state = DATA_STATE) or (state = STOP_STATE) else '0';
    DATA_COUNT <= '1' when state = DATA_STATE else '0';
    STOP       <= '1' when (state = STOP_STATE) or (state = IDLE_STATE) else '0';

end architecture;