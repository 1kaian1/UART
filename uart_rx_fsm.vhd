-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Jan Kai Marek (xmarekj00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_FSM is
    port(
       CLK                   : in std_logic;
       RST                   : in std_logic;
       DIN                   : in std_logic;
       CLK_CYCLE_CNT         : in std_logic_vector(4 downto 0);
       CLK_CYCLE_ACTIVE      : out std_logic;
       BIT_CNT               : in std_logic_vector(3 downto 0);
       DATA_RECIEVE_ACTIVE   : out std_logic;
       DATA_VALIDATE_ACTIVE  : out std_logic
    );
end entity;

architecture behavioral of UART_RX_FSM is
    type fsm_states is (IDLE, WAIT_FOR_FIRST_BIT, READ_DATA, WAIT_FOR_STOP_BIT, VALIDATE_DATA);
    signal current_state : fsm_states := IDLE;

begin

    -- ACTIVATING PORTS
    CLK_CYCLE_ACTIVE <= '1' when current_state = WAIT_FOR_FIRST_BIT or current_state = READ_DATA or current_state = WAIT_FOR_STOP_BIT else '0';
    DATA_VALIDATE_ACTIVE <= '1' when current_state = VALIDATE_DATA else '0';
    DATA_RECIEVE_ACTIVE <= '1' when current_state = READ_DATA else '0';

    -- PROCESS
    process(CLK) begin

        -- RESET
        if RST = '1' then
            current_state <= IDLE;
            
        -- RISING EDGE
        elsif rising_edge(CLK) then

            -- HANDLE STATES
            case current_state is
                when IDLE => 
                    if DIN = '0' then
                        current_state <= WAIT_FOR_FIRST_BIT;
                    end if;
                when WAIT_FOR_FIRST_BIT =>
                    if CLK_CYCLE_CNT = "10111" then
                        current_state <= READ_DATA;
                    end if;
                when READ_DATA =>
                    if BIT_CNT = "1000" then
                        current_state <= WAIT_FOR_STOP_BIT;
                    end if;
                when WAIT_FOR_STOP_BIT =>
                    if DIN = '1' then
                        if CLK_CYCLE_CNT = "01111" then
                            current_state <= VALIDATE_DATA;
                        end if;
                    end if;
                when VALIDATE_DATA =>
                    current_state <= IDLE;
                when others => null;
            end case;

        end if;
    end process;
end architecture;