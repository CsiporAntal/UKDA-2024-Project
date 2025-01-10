-- spi_top.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_top is
    Port (
        clk        : in  std_logic;                      -- FPGA system clock (100 MHz)
        reset      : in  std_logic;                      -- Active-high reset
        miso       : in  std_logic;                      -- PmodMIC MISO
        cs         : out std_logic;                      -- PmodMIC CS
        sck        : out std_logic;                      -- PmodMIC SCK
        leds       : out std_logic_vector(7 downto 0);   -- Additional LED outputs (optional)
        seg        : out std_logic_vector(6 downto 0);   -- 7-segment segments (A-G)
        an         : out std_logic_vector(2 downto 0);   -- 7-segment anodes (for three digits)
        adc_data   : out std_logic_vector(11 downto 0);  -- 12-bit ADC data (exposed to testbench)
        data_ready : out std_logic;                      -- Data ready signal (exposed to testbench)
        start      : in  std_logic                       -- Start signal (new port)
    );
end spi_top;

architecture Behavioral of spi_top is

    ----------------------------------------------------------------------------
    --  Component Declarations
    ----------------------------------------------------------------------------

    component spi_master is
        Port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            start      : in  std_logic;
            miso       : in  std_logic;
            sck        : out std_logic;
            cs         : out std_logic;
            adc_data   : out std_logic_vector(11 downto 0);
            data_ready : out std_logic
        );
    end component;

    component DataBuffer is
        Generic (
            N : integer := 256  -- Number of samples
        );
        Port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            data_in     : in  std_logic_vector(11 downto 0);
            data_out    : out std_logic_vector(11 downto 0);
            buffer_full : out std_logic
        );
    end component;

    component RMS_Calculator is
        Generic (
            N : integer := 256
        );
        Port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            buffer_full : in  std_logic;
            data_in     : in  unsigned(11 downto 0);
            rms_out     : out unsigned(23 downto 0)
        );
    end component;

    component Volume_Calculator is
        Port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            rms_in     : in  unsigned(23 downto 0);
            volume_out : out unsigned(7 downto 0)
        );
    end component;

    component BinToBCD is
        Port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            binary_in : in  unsigned(7 downto 0);
            bcd_out   : out unsigned(11 downto 0)
        );
    end component;

    component SevenSegMultiplexer is
        Port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            bcd_digits : in  unsigned(11 downto 0);
            seg_out    : out std_logic_vector(6 downto 0);
            an         : out std_logic_vector(2 downto 0)
        );
    end component;

    ----------------------------------------------------------------------------
    --  Internal Signals
    ----------------------------------------------------------------------------
    signal adc_data_signal       : std_logic_vector(11 downto 0);
    signal data_ready_signal     : std_logic;
    signal buffer_out_signal     : std_logic_vector(11 downto 0);
    signal buffer_full_signal    : std_logic;
    signal rms_signal            : unsigned(23 downto 0);
    signal volume_signal         : unsigned(7 downto 0);
    signal bcd_volume_signal     : unsigned(11 downto 0);

    -- Start Trigger Signal (connected to external start)
    -- No need for an internal start signal as it's now connected externally

begin

    ----------------------------------------------------------------------------
    --  SPI Master Instance
    ----------------------------------------------------------------------------
    spi_master_inst : spi_master
        port map (
            clk        => clk,
            reset      => reset,
            start      => start,                          -- Connected to external start
            miso       => miso,
            sck        => sck,
            cs         => cs,
            adc_data   => adc_data_signal,
            data_ready => data_ready_signal
        );

    ----------------------------------------------------------------------------
    --  Data Buffer Instance
    ----------------------------------------------------------------------------
    data_buffer_inst : DataBuffer
        generic map (
            N => 256
        )
        port map (
            clk         => clk,
            reset       => reset,
            data_in     => adc_data_signal,
            data_out    => buffer_out_signal,
            buffer_full => buffer_full_signal
        );

    ----------------------------------------------------------------------------
    --  RMS Calculator Instance
    ----------------------------------------------------------------------------
    rms_calculator_inst : RMS_Calculator
        generic map (
            N => 256
        )
        port map (
            clk         => clk,
            reset       => reset,
            buffer_full => buffer_full_signal,
            data_in     => unsigned(buffer_out_signal),
            rms_out     => rms_signal
        );

    ----------------------------------------------------------------------------
    --  Volume Calculator Instance
    ----------------------------------------------------------------------------
    volume_calculator_inst : Volume_Calculator
        port map (
            clk        => clk,
            reset      => reset,
            rms_in     => rms_signal,
            volume_out => volume_signal
        );

    ----------------------------------------------------------------------------
    --  Binary to BCD Converter Instance
    ----------------------------------------------------------------------------
    bin_to_bcd_inst : BinToBCD
        port map (
            clk        => clk,
            reset      => reset,
            binary_in  => volume_signal,
            bcd_out    => bcd_volume_signal
        );

    ----------------------------------------------------------------------------
    --  7-Segment Multiplexer Instance
    ----------------------------------------------------------------------------
    seven_seg_mux_inst : SevenSegMultiplexer
        port map (
            clk        => clk,
            reset      => reset,
            bcd_digits => bcd_volume_signal,
            seg_out    => seg,
            an         => an
        );

    ----------------------------------------------------------------------------
    --  Expose adc_data and data_ready to the testbench
    ----------------------------------------------------------------------------
    adc_data   <= adc_data_signal;
    data_ready <= data_ready_signal;

    -- Optional: Drive LEDs with some signals if desired (or tie them low)
    leds <= (others => '0');

end Behavioral;
