library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- Az 'unsigned' és 'signed' típusokhoz szükséges

entity spi_top is
  Port (
    clk   : in  std_logic;  -- FPGA alapórajel (100 MHz)
    reset : in  std_logic;
    miso  : in  std_logic;  -- Pmod MIC MISO
    cs    : out std_logic;  -- Pmod MIC CS
    sck   : out std_logic;  -- Pmod MIC SCK
    leds  : out std_logic_vector(7 downto 0)  -- Kimenet a LED-ekhez
  );
end spi_top;

architecture Behavioral of spi_top is

  -- SPI mester komponens deklaráció
  component spi_master
    Port (
      clk        : in  std_logic;
      reset      : in  std_logic;
      miso       : in  std_logic;
      sck        : out std_logic;
      cs         : out std_logic;
      adc_data   : out std_logic_vector(11 downto 0);
      data_ready : out std_logic
    );
  end component;

  -- Bels? jelek
  signal adc_data_signal   : std_logic_vector(11 downto 0);
  signal data_ready_signal : std_logic;
  signal avg_data          : unsigned(15 downto 0) := (others => '0');
  signal sum_data          : unsigned(27 downto 0) := (others => '0');
  signal sample_count      : integer := 0;
  constant N               : integer := 256;  -- Átlagolási ablakméret

begin

  -- SPI mester instanciálása
  spi_master_inst : spi_master
    port map (
      clk        => clk,
      reset      => reset,
      miso       => miso,
      sck        => sck,
      cs         => cs,
      adc_data   => adc_data_signal,
      data_ready => data_ready_signal
    );

  -- Mozgó átlag számítása és LED-ek vezérlése
  process(clk)
    variable extended_adc_data : unsigned(15 downto 0);
  begin
    if rising_edge(clk) then
      if reset = '1' then
        sum_data     <= (others => '0');
        avg_data     <= (others => '0');
        sample_count <= 0;
        leds         <= (others => '0');
      elsif data_ready_signal = '1' then
        extended_adc_data := resize(unsigned(adc_data_signal), 16);
        sum_data     <= sum_data + unsigned(extended_adc_data);
        sample_count <= sample_count + 1;
        if sample_count = N then
          avg_data     <= sum_data(27 downto 12) / N;  -- Átlag kiszámítása
          sum_data     <= (others => '0');
          sample_count <= 0;
          -- LED-ek vezérlése az átlagolt érték alapján
          leds <= std_logic_vector(avg_data(15 downto 8));
        end if;
      end if;
    end if;
  end process;

end Behavioral;
