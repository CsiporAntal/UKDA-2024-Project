-- spi_top_tb.vhd
-- Testbench for spi_top module to simulate SPI communication

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_top_tb is
    -- Testbench entities do not have ports
end spi_top_tb;

architecture Behavioral of spi_top_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component spi_top
        Port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            miso       : in  std_logic;
            cs         : out std_logic;
            sck        : out std_logic;
            leds       : out std_logic_vector(7 downto 0);
            seg        : out std_logic_vector(6 downto 0);
            an         : out std_logic_vector(2 downto 0);
            adc_data   : out std_logic_vector(11 downto 0);  -- Exposed ADC data
            data_ready : out std_logic;                      -- Exposed data ready signal
            start      : in  std_logic                       -- Start signal
        );
    end component;

    -- Signals to connect to UUT
    signal clk        : std_logic := '0';
    signal reset      : std_logic := '0';
    signal miso       : std_logic;  -- Removed initial assignment to avoid multiple drivers
    signal cs         : std_logic;
    signal sck        : std_logic;
    signal leds       : std_logic_vector(7 downto 0);
    signal seg        : std_logic_vector(6 downto 0);
    signal an         : std_logic_vector(2 downto 0);
    signal adc_data   : std_logic_vector(11 downto 0);  -- Declared for monitoring
    signal data_ready : std_logic;                       -- Declared for monitoring
    signal start      : std_logic := '0';               -- Internal signal to trigger start

    -- Clock period definitions
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz

    -- SPI Slave Data
    constant DATA_TO_SEND : std_logic_vector(15 downto 0) := "0000001000110100"; -- Example data (0x0234)
    signal bit_index        : integer := 0; -- To track bit transmission

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: spi_top
        port map (
            clk        => clk,
            reset      => reset,
            miso       => miso,
            cs         => cs,
            sck        => sck,
            leds       => leds,
            seg        => seg,
            an         => an,
            adc_data   => adc_data,
            data_ready => data_ready,
            start      => start                           -- Connected to internal start signal
        );

    ----------------------------------------------------------------------------
    --  Clock Generation Process
    ----------------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;  -- 5 ns
        clk <= '1';
        wait for CLK_PERIOD/2;  -- 5 ns
    end process;

    ----------------------------------------------------------------------------
    --  Stimulus Process
    ----------------------------------------------------------------------------
    stim_proc: process
    begin		
        -- Initialize Inputs
        reset <= '1';
        start <= '0';
        wait for 20 ns;	
        reset <= '0';
        wait for 90 ns; -- Now at 110 ns

        -- First SPI Transaction
        start <= '1';
        wait for 40 ns;    -- Hold high for one full sck period (40 ns)
        start <= '0';
        wait for 500 ns;

        -- Second SPI Transaction
        start <= '1';
        wait for 40 ns;    -- Hold high for one full sck period (40 ns)
        start <= '0';
        wait for 500 ns;

        -- Finish simulation
        wait;
    end process;

    ----------------------------------------------------------------------------
    --  SPI Slave Simulation Process
    ----------------------------------------------------------------------------
    miso_process: process
    begin
        -- Wait for the rising edge of sck, then update miso
        wait until rising_edge(sck);     
        miso <= DATA_TO_SEND(15 - bit_index);
        bit_index <= (bit_index + 1) mod 16;
    end process;


    ----------------------------------------------------------------------------
    --  Monitoring Process
    ----------------------------------------------------------------------------
    monitor_proc: process(clk)
    begin
        if rising_edge(clk) then
            if data_ready = '1' then
                -- Convert adc_data to integer and report
                assert (adc_data = "001000110100")
                    severity note;
            end if;
        end if;
    end process;

end Behavioral;
