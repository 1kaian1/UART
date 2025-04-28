-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Jan Kai Marek (xmarekj00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;

-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    signal clk_cycle_cnt        : std_logic_vector(4 downto 0) := "00001";
    signal clk_cycle_cnt_active : std_logic := '0';
    signal data_bit_cnt         : std_logic_vector(3 downto 0) := "0000";
    signal data_bit_cnt_active  : std_logic := '0';
    signal dout_reg             : std_logic_vector(7 downto 0) := "00000000";
begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        CLK_CYCLE_CNT => clk_cycle_cnt,
        CLK_CYCLE_CNT_ACTIVE => clk_cycle_cnt_active,
        DATA_BIT_CNT => data_bit_cnt,
        DATA_BIT_CNT_ACTIVE => data_bit_cnt_active
    );

    -- PROCESS
    process (CLK)
    begin
        
        -- RESET
        if RST = '1' then
            DOUT_VLD <= '0';
            DOUT <= (others => '0');
            clk_cycle_cnt <= "00001";
            data_bit_cnt <= "0000";

        -- RISING EDGE
        elsif rising_edge(CLK) then

            if clk_cycle_cnt_active = '0' then
                clk_cycle_cnt <= "00001";
            else
                clk_cycle_cnt <= clk_cycle_cnt + 1;
            end if;

            DOUT_VLD <= '0';

            if data_bit_cnt = "1000" then
                if clk_cycle_cnt = "01111" and DIN = '1' then
                    data_bit_cnt <= "0000";
                    DOUT <= dout_reg;
                    DOUT_VLD <= '1';
                end if;
            end if;

            if data_bit_cnt_active = '1' then
                if clk_cycle_cnt >= "10000" then

                    clk_cycle_cnt <= "00001";
                    dout_reg(conv_integer(data_bit_cnt)) <= DIN;
                    data_bit_cnt <= data_bit_cnt + 1;

                end if;
            end if;
        end if;
    end process; 
end architecture;