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
    signal clk_cycle_active     : std_logic := '0';
    signal bit_cnt              : std_logic_vector(3 downto 0) := "0000";
    signal data_recieve_active  : std_logic := '0';
    signal data_validate_active : std_logic := '0';

    signal dout_reg : std_logic_vector(7 downto 0);

begin
    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        CLK_CYCLE_CNT => clk_cycle_cnt,
        CLK_CYCLE_ACTIVE => clk_cycle_active,
        BIT_CNT => bit_cnt,
        DATA_RECIEVE_ACTIVE => data_recieve_active,
        DATA_VALIDATE_ACTIVE => data_validate_active
    );

    -- PROCESS
    process (CLK) begin
        
        -- RESET
        if RST = '1' then
            DOUT_VLD <= '0';
            DOUT <= (others => '0');
            clk_cycle_cnt <= "00001";
            bit_cnt <= "0000";

        -- RISING EDGE
        elsif rising_edge(CLK) then

            if clk_cycle_active = '0' then
                clk_cycle_cnt <= "00001";
            else
                clk_cycle_cnt <= clk_cycle_cnt + 1;
            end if;

            DOUT_VLD <= '0';

            if bit_cnt = "1000" then
                if data_validate_active = '1' then
                    bit_cnt <= "0000";
                    DOUT <= dout_reg;
                    DOUT_VLD <= '1';
                end if;
            end if;

            if data_recieve_active = '1' then
                if clk_cycle_cnt >= "10000" then
                    clk_cycle_cnt <= "00001";

                    --DOUT(to_integer(unsigned(bit_cnt))) <= DIN;

                    dout_reg(conv_integer(bit_cnt)) <= DIN;
                    bit_cnt <= bit_cnt + 1;

                end if;
            end if;
        end if;
    end process; 
end architecture;