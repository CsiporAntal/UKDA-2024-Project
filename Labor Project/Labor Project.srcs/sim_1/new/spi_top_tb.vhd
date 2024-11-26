library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_top_tb is
end spi_top_tb;

architecture Behavioral of spi_top_tb is

  -- Komponens deklaráció
  component spi_top
    Port (
      clk   : in  std_logic;
      reset : in  std_logic;
      miso  : in  std_logic;
      cs    : out std_logic;
      sck   : out std_logic;
      leds  : out std_logic_vector(7 downto 0)
    );
  end component;

  -- Jelek deklarálása
  signal clk_tb   : std_logic := '0';
  signal reset_tb : std_logic := '1';
  signal miso_tb  : std_logic := '0';
  signal cs_tb    : std_logic;
  signal sck_tb   : std_logic;
  signal leds_tb  : std_logic_vector(7 downto 0);

  -- Órajel periódus
  constant clk_period : time := 10 ns;  -- 100 MHz órajel

begin

  -- Órajel generálása
  clk_process : process
  begin
    while true loop
      clk_tb <= '0';
      wait for clk_period / 2;
      clk_tb <= '1';
      wait for clk_period / 2;
    end loop;
  end process;

  -- DUT instanciálása
  spi_top_inst : spi_top
    port map (
      clk   => clk_tb,
      reset => reset_tb,
      miso  => miso_tb,
      cs    => cs_tb,
      sck   => sck_tb,
      leds  => leds_tb
    );

  -- Reset jel stimulálása
  stimulus_process : process
  begin
    reset_tb <= '1';
    wait for 100 ns;
    reset_tb <= '0';  -- Reset felengedése

    -- Szimuláció futtatása 10 ms-ig
    wait for 10 ms;

    -- Szimuláció befejezése
    wait;
  end process;

  -- MISO jel stimulálása
  miso_process : process
    variable bit_counter : integer := 0;
  begin
    -- Várakozás a reset felengedéséig
    wait until reset_tb = '0';

    -- Végtelen ciklus a MISO jel szimulálásához
    while true loop
      -- Várakozás a CS aktív alacsony szintjére
      wait until cs_tb = '0';

      -- Az SPI kommunikáció szimulálása
      for bit_counter in 0 to 15 loop
        -- Várakozás az SCK negatív élére
        wait until falling_edge(sck_tb);

        if bit_counter < 4 then
          miso_tb <= '0';  -- Els? 4 bit vezet? nulla
        else
          miso_tb <= '1';  -- Szimulált adatbit (változtatható)
        end if;
      end loop;
    end loop;
  end process;

end Behavioral;
