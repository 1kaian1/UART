-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Jan Kai Marek (xmarekj00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_FSM is
    port(
       CLK                  : in std_logic;
       RST                  : in std_logic;
       DIN                  : in std_logic;
       CLK_CYCLE_CNT        : in std_logic_vector(4 downto 0);
       CLK_CYCLE_CNT_ACTIVE : out std_logic;
       DATA_BIT_CNT         : in std_logic_vector(3 downto 0);
       DATA_BIT_CNT_ACTIVE  : out std_logic
    );
end entity;

architecture behavioral of UART_RX_FSM is
    type fsm_states is (IDLE, WAITING_FOR_FIRST_BIT, READING_DATA, WAITING_FOR_STOP_BIT);
    signal current_state : fsm_states := IDLE;
begin

    -- ACTIVATING PORTS
    CLK_CYCLE_CNT_ACTIVE <= '1' when current_state = WAITING_FOR_FIRST_BIT or current_state = READING_DATA or current_state = WAITING_FOR_STOP_BIT else '0';
    DATA_BIT_CNT_ACTIVE <= '1' when current_state = READING_DATA else '0';

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
                        current_state <= WAITING_FOR_FIRST_BIT;
                    end if;
                    
                when WAITING_FOR_FIRST_BIT =>
                    if CLK_CYCLE_CNT = "10111" then
                        current_state <= READING_DATA;
                    end if;
                    
                when READING_DATA =>
                    if DATA_BIT_CNT = "1000" then
                        current_state <= WAITING_FOR_STOP_BIT;
                    end if;
                    
                when WAITING_FOR_STOP_BIT =>
                    if (DIN = '1') and (CLK_CYCLE_CNT = "01111") then
                        current_state <= IDLE;
                    end if;
                    
                when others =>
                    null;
            end case;

        end if;

    end process;

end architecture;