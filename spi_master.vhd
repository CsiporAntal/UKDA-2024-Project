library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity spi_master is
  Port (
    clk        : in  std_logic;  -- Rendszerórajel (például 100 MHz)
    reset      : in  std_logic;  -- Reset jel (magas szint törli az állapotot)
    miso       : in  std_logic;  -- SPI bemeneti adat (Master In Slave Out)
    sck        : out std_logic;  -- SPI órajel
    cs         : out std_logic;  -- Chip Select (SPI eszköz kiválasztása)
    adc_data   : out std_logic_vector(11 downto 0); -- ADC által visszaadott adatok
    data_ready : out std_logic   -- Jelzi, hogy az adat készen áll
  );
end spi_master;

architecture Behavioral of spi_master is

  -- SPI állapotgépe: az SPI kommunikáció különböz? állapotainak meghatározása
  type state_type is (READY, INIT1, WAIT1, INIT2, WAIT2, INIT3, WAIT3, INIT4, WAIT4, INIT5, INIT6, WAIT5, FINALIZE);
  signal current_state, next_state : state_type := READY; -- Jelenlegi és következ? állapot

  -- Órajel
  signal spi_clk     : std_logic := '0'; 
  signal N1        : std_logic_vector(11 downto 0) := (others => '0');
  signal N2        : std_logic_vector(11 downto 0) := (others => '0');
  signal N3        : std_logic_vector(11 downto 0) := (others => '0');
  
  
  -- SPI kommunikációs jelek
  signal start        : std_logic  := '0'; -- Start jel
  signal cs_reg       : std_logic := '1'; -- Chip Select alapértelmezett magas
  signal sck_reg      : std_logic := '0'; -- SPI órajel alapértelmezett alacsony
  signal bit_counter  : integer range 0 to 15 := 0; -- A küldött és fogadott bitek számlálója
  signal adc_data_reg : std_logic_vector(11 downto 0) := (others => '0'); -- ADC adat regisztere
  signal data_ready_reg : std_logic := '0'; -- Jelzi, hogy az adat fogadása befejez?dött
  signal Ri_next : std_logic_vector(11 downto 0) := (others => '0');
  signal Ri : std_logic_vector(11 downto 0) := (others => '0');

begin


  -- Állapot regiszter folyamat: frissíti az aktuális állapotot
  state_register : process(spi_clk, reset)
  begin
    if reset = '1' then
      current_state <= READY; -- Reset esetén az állapot az READY lesz
    elsif rising_edge(spi_clk) then
      current_state <= next_state; -- Állapotfrissítés az SPI órajel emelked? élén
    end if;
  end process;
  
  
  ri_register : process(spi_clk)
  begin
    if spi_clk 'event and spi_clk = '1' then
        Ri <= Ri_next;
    end if;    
  end process;
  
  
  with current_state select
    Ri_next <= ri when READY,
    N1 when INIT1,
    Ri - 1 when WAIT1,
    N2 when INIT2,
    Ri - 1 when WAIT2,
    N3 when INIT3,
    Ri - 1 when WAIT3,
    N3 when INIT4,
    Ri - 1 when WAIT4,
    N3 when INIT5,
    N2 when INIT6,
    Ri - 1 when WAIT5,
    Ri when FINALIZE;
    
    

  -- SPI állapotgép logikája
  spi_logic : process(current_state, bit_counter, start, miso)
  begin
    -- Alapértelmezett kimeneti értékek (minden ciklus elején)
    next_state      <= current_state; -- Következ? állapot alapértelmezésben megegyezik az aktuálissal
    cs_reg          <= '1'; -- Alapértelmezett: Chip Select magas
    sck_reg         <= '0'; -- SPI órajel alapértelmezett alacsony
    data_ready_reg  <= '0'; -- Adatfogadás alapértelmezetten nincs kész
    
    
    
    -- Állapotok kezelése
    case current_state is
      when READY => -- READY állapot
        if start = '1' then
            next_state <= INIT1;
        else
            next_state <= READY;
        end if;
      
      when INIT1 =>
            next_state <= WAIT1;
      
      when WAIT1 =>
            if Ri > 0 then
                next_state <= WAIT1;
            else
                next_state <= INIT1;
            end if;
      
      when INIT2 =>
            next_state <= WAIT2;
      
      when WAIT2 =>
            if Ri > 0 then
                next_state <= WAIT2;
            else
                next_state <= INIT2;
            end if;                    

      when INIT3 =>
            next_state <= WAIT3;
      
      when WAIT3 =>
            if Ri > 0 then
                next_state <= WAIT3;
            else
                next_state <= INIT3;
            end if;
     
      when INIT4 =>
            next_state <= WAIT4;
      
      when WAIT4 =>
            if Ri > 0 then
                next_state <= WAIT4;
            else
                next_state <= INIT4;
            end if;
            
        when INIT5 =>
            next_state <= INIT6;
            
        when INIT6 =>
            next_state <= WAIT5;    

        when WAIT5 =>
            if Ri > 0 then
                next_state <= WAIT5;
            else
                next_state <= FINALIZE;
            end if;                 

                  
       when FINALIZE =>
            next_state <= READY;                
      
        
      
     
      when others => -- Nem definiált állapotok esetén
        next_state <= READY; -- Biztonsági visszaállás IDLE állapotra
    end case;
  end process;

  -- Kimenetek hozzárendelése a bels? regiszterekhez
  sck        <= sck_reg; -- SPI órajel kimenet
  cs         <= cs_reg; -- Chip Select kimenet
  adc_data   <= adc_data_reg; -- ADC adatok kimenete
  data_ready <= data_ready_reg; -- Adatkész jelzés kimenet

end Behavioral;
