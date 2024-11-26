library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- Az 'unsigned' és 'signed' típusokhoz szükséges

entity spi_master is
  Port (
    clk        : in  std_logic;      -- FPGA alapórajel (pl. 100 MHz)
    reset      : in  std_logic;
    miso       : in  std_logic;      -- MISO - adat az ADC-t?l
    sck        : out std_logic;      -- SPI órajel
    cs         : out std_logic;      -- Chip Select (aktív alacsony)
    adc_data   : out std_logic_vector(11 downto 0);  -- 12 bites ADC adat
    data_ready : out std_logic       -- Jelzi, ha új adat érkezett
  );
end spi_master;

architecture Behavioral of spi_master is

  -- Órajelosztó jelei
  signal clk_divider : unsigned(6 downto 0) := (others => '0');
  signal spi_clk     : std_logic := '0';

  -- SPI kommunikáció jelei
  signal sck_reg        : std_logic := '0';
  signal cs_reg         : std_logic := '1';  -- Aktív alacsony, kezdetben magas
  signal bit_counter    : integer range 0 to 15 := 0;
  signal adc_data_reg   : std_logic_vector(11 downto 0) := (others => '0');
  signal data_ready_reg : std_logic := '0';

begin

  -- Órajelosztó processz (100 MHz -> 1 MHz SPI órajel)
  clk_divider_process : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        clk_divider <= (others => '0');
        spi_clk     <= '0';
      else
        if clk_divider = 49 then  -- 100 MHz / (2 * 50) = 1 MHz
          clk_divider <= (others => '0');
          spi_clk     <= not spi_clk;
        else
          clk_divider <= clk_divider + 1;
        end if;
      end if;
    end if;
  end process;

  -- SPI állapotgép
  spi_master_process : process(spi_clk, reset)
  begin
    if reset = '1' then
      cs_reg         <= '1';
      sck_reg        <= '0';
      bit_counter    <= 0;
      adc_data_reg   <= (others => '0');
      data_ready_reg <= '0';
    elsif rising_edge(spi_clk) then
      if cs_reg = '1' then
        cs_reg <= '0';  -- CS lehúzása, kommunikáció indítása
        bit_counter <= 0;
        data_ready_reg <= '0';
      else
        if bit_counter < 16 then
          sck_reg <= '1';  -- SCK magas
          -- MISO mintavételezése a SCK pozitív élén
          if bit_counter >= 4 then  -- Els? 4 bit vezet? nulla
            adc_data_reg(15 - bit_counter) <= miso;
          end if;
          bit_counter <= bit_counter + 1;
        else
          sck_reg <= '0';  -- SCK alacsony
          cs_reg <= '1';   -- CS magas, kommunikáció vége
          data_ready_reg <= '1';  -- Új adat érkezett
        end if;
      end if;
    end if;
  end process;

  -- Kimenetek hozzárendelése
  sck        <= sck_reg;
  cs         <= cs_reg;
  adc_data   <= adc_data_reg;
  data_ready <= data_ready_reg;

end Behavioral;
