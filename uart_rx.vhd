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

-- Architecture implementation
architecture behavioral of UART_RX is

    signal cycle_cnt : std_logic_vector(4 downto 0); -- 4 bitů (počítání cyklů)
    signal data_cnt  : std_logic_vector(2 downto 0); -- 3 bity (počítání bitů 0-7)
    signal din_reg   : std_logic_vector(7 downto 0); -- 8 bitů

    signal vld : std_logic;

    signal bit_end : std_logic;
    signal bit_mid : std_logic;
    signal word_end : std_logic;

    signal ready_flag, start_flag, stop_flag, count_flag, data_count_flag : std_logic;
    signal din_sync_0, din_sync_1 : std_logic;

begin

    -- Instance FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK        => CLK,
        RST        => RST,
        VLD        => vld,
        BIT_END    => bit_end,
        WORD_END   => word_end,
        RDY        => ready_flag,
        START      => start_flag,
        STOP       => stop_flag,
        CYCLE_COUNT      => count_flag,
        DATA_COUNT => data_count_flag
    );

    -----------------------------------------------------------

    -- Počítání cyklů
    process(CLK)

    begin

        if rising_edge(CLK) then
            if RST = '1' or count_flag = '0' or cycle_cnt = "10000" then -- nejsem si vůbec jistý, tohle možná bude potřeba opravit
                cycle_cnt <= (others => '0');
            else
                cycle_cnt <= cycle_cnt + 1;
            end if;
        end if;

    end process;

    bit_mid <= '1' when cycle_cnt = "01000" else '0';
    bit_end <= '1' when cycle_cnt = "10000" else '0';

    -----------------------------------------------------------

    -- Synchronizace DIN signálu s hodinovým signálem CLK
    process(CLK)
    begin

        -- Nechybí tady někde ready_flag?
        if rising_edge(CLK) then
            if RST = '1' then
                din_sync_0 <= '1';
                din_sync_1 <= '1';

                din_reg <= (others => '0');

            elsif bit_mid = '1' and ready_flag = '1' then -- možná má být tady ready_flag
                din_sync_0 <= DIN;
                din_sync_1 <= din_sync_0;

                if din_sync_1 = '0' then
                    vld <= '1';
                else
                    vld <= '0';
                end if;

            elsif bit_end = '1' and data_count_flag = '1' then
                din_reg <= din_reg(6 downto 0) & din_sync_1;

            elsif bit_end = '1' and word_end = '1' then
                DOUT <= din_reg;
            
            elsif bit_end = '1' and stop_flag = '1' then
                DOUT_VLD <= '1';

            else                                            -- netuším, jestli tohle tady má být
                din_sync_0 <= din_sync_0; -- udržení stavu  -- netuším, jestli tohle tady má být
                din_sync_1 <= din_sync_1; -- udržení stavu  -- netuším, jestli tohle tady má být
            end if;
        end if;

    end process;

    -----------------------------------------------------------

    -- Počítání datových bitů (8 datových bitů)
    process(CLK)
    begin

        if rising_edge(CLK) then
            if RST = '1' or data_count_flag = '0' then
                data_cnt <= (others => '0');
            elsif data_count_flag = '1' and bit_end = '1' then
                data_cnt <= data_cnt + 1;
            end if;
        end if;
        
    end process;

    word_end <= '1' when data_cnt = "111" else '0';


end architecture;