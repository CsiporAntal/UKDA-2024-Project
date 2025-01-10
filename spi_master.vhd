-- spi_master.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master is
    Port (
        clk        : in  std_logic;                      -- System clock (100 MHz)
        reset      : in  std_logic;                      -- Active-high reset
        start      : in  std_logic;                      -- Start signal
        miso       : in  std_logic;                      -- SPI input data (Master In Slave Out)
        sck        : out std_logic;                      -- SPI clock 
        cs         : out std_logic;                      -- Chip Select (active low)
        adc_data   : out std_logic_vector(11 downto 0);  -- 12-bit ADC data
        data_ready : out std_logic                       -- Data ready signal
    );
end spi_master;

architecture Behavioral of spi_master is

    ----------------------------------------------------------------------------
    --  Parameters
    ----------------------------------------------------------------------------
    constant SYS_CLK_FREQ : integer := 100_000_000;  -- 100 MHz
    -- Adjust SPI clock to 25 MHz 
    constant SPI_CLK_FREQ : integer := 25_000_000;
    -- Toggling a clock requires dividing by 2:
    constant DIVISOR      : integer := SYS_CLK_FREQ / (SPI_CLK_FREQ * 2); -- 2

    ----------------------------------------------------------------------------
    --  State Machine Definition
    ----------------------------------------------------------------------------
    type state_type is (IDLE, START_XFER, TRANSFER, DONE);
    signal current_state, next_state : state_type := IDLE;

    ----------------------------------------------------------------------------
    --  Internal Signals
    ----------------------------------------------------------------------------
    signal clk_divider      : integer range 0 to DIVISOR-1 := 0;
    signal spi_clk_reg      : std_logic := '1';  -- Start high, per PmodMIC requirement
    signal bit_counter      : integer range 0 to 16 := 0;
    signal shift_reg        : std_logic_vector(15 downto 0) := (others => '0');
    signal adc_data_reg     : std_logic_vector(11 downto 0) := (others => '0');
    signal data_ready_reg   : std_logic := '0';
    signal cs_reg           : std_logic := '1';  -- Active low

begin
    ----------------------------------------------------------------------------
    --  Generate SPI Clock from System Clock
    ----------------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            clk_divider   <= 0;
            spi_clk_reg   <= '1';
        elsif rising_edge(clk) then
            if clk_divider = DIVISOR-1 then
                clk_divider <= 0;
                spi_clk_reg <= not spi_clk_reg;
            else
                clk_divider <= clk_divider + 1;
            end if;
        end if;
    end process;

    sck <= spi_clk_reg;

    ----------------------------------------------------------------------------
    --  Synchronous FSM + Data Capture (single clock domain: spi_clk_reg)
    ----------------------------------------------------------------------------
    -- We sample/shift data on the falling edge of spi_clk_reg. 
    -- We also do the state transitions on the rising edge of spi_clk_reg to 
    -- avoid racing the shift.  
    ----------------------------------------------------------------------------

    -- 1) Synchronous process: On rising_edge of SPI clock
    fsm_reg: process(spi_clk_reg, reset)
    begin
        if reset = '1' then
            current_state   <= IDLE;
            bit_counter     <= 0;
                shift_reg       <= (others => '0');
                data_ready_reg  <= '0';
                cs_reg          <= '1';
                adc_data_reg    <= (others => '0');
        elsif rising_edge(spi_clk_reg) then
            current_state <= next_state;

            case current_state is

                when IDLE =>
                    -- Remain in IDLE until start=1; do nothing else here
                    null;

                when START_XFER =>
                    cs_reg          <= '0';  -- activate
                    bit_counter     <= 0;
                    shift_reg       <= (others => '0');
                    data_ready_reg  <= '0';

                when TRANSFER =>
                    if bit_counter < 16 then
                        bit_counter <= bit_counter + 1;
                    end if;

                when DONE =>
                    cs_reg          <= '1';  -- deactivate
                    data_ready_reg  <= '1';  -- latch that data is valid
                    -- Extract 12 bits if top nibble is "0000"
                    if shift_reg(15 downto 12) = "0000" then
                        adc_data_reg <= shift_reg(11 downto 0);
                    else
                        adc_data_reg <= (others => '0');
                    end if;

                when others =>
                    null;
            end case;
        end if;
    end process;

    -- 2) Combinational next-state logic
    fsm_next: process(current_state, start, bit_counter)
    begin
        next_state <= current_state;  -- Use <= for signal assignment
        case current_state is

            when IDLE =>
                if start = '1' then
                    next_state <= START_XFER;
                end if;

            when START_XFER =>
                next_state <= TRANSFER;

            when TRANSFER =>
                if bit_counter = 16 then
                    next_state <= DONE;
                end if;

            when DONE =>
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    ----------------------------------------------------------------------------
    --  Capture MISO on falling edge of SPI clock
    ----------------------------------------------------------------------------
    process(clk, reset)
        variable spi_clk_prev: std_logic := '1';
    begin
        if reset = '1' then
            shift_reg    <= (others => '0');
            spi_clk_prev := '1';
        elsif rising_edge(clk) then
            -- detect falling edge of spi_clk_reg
            if (spi_clk_prev = '1') and (spi_clk_reg = '0') then
                if current_state = TRANSFER and bit_counter < 16 then
                    -- Shift left, insert new bit
                    shift_reg <= shift_reg(14 downto 0) & miso;
                end if;
            end if;
            spi_clk_prev := spi_clk_reg;
        end if;
    end process;

    ----------------------------------------------------------------------------
    --  Outputs
    ----------------------------------------------------------------------------
    cs         <= cs_reg;
    data_ready <= data_ready_reg;
    adc_data   <= adc_data_reg;

end Behavioral;
