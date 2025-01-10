library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SevenSegMultiplexer is
    Port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        bcd_digits : in  unsigned(11 downto 0);  -- Three BCD digits
        seg_out    : out std_logic_vector(6 downto 0); -- Segments A-G
        an         : out std_logic_vector(2 downto 0)  -- Anodes for three digits
    );
end SevenSegMultiplexer;

architecture Behavioral of SevenSegMultiplexer is

    ----------------------------------------------------------------------------
    -- This design instantiates 3 BCD->7Seg decoders.
    ----------------------------------------------------------------------------

    type seg_array_type is array (0 to 2) of std_logic_vector(6 downto 0);
    signal seg_values    : seg_array_type := (others => (others => '0'));
    signal current_digit : integer range 0 to 2 := 0;

    ----------------------------------------------------------------------------
    -- Slow down the multiplexing for visibility
    ----------------------------------------------------------------------------
    signal clk_divider : integer range 0 to 999999 := 0;
    constant MAX_COUNT : integer := 999999;

begin

    ----------------------------------------------------------------------------
    -- Instantiate three decoders
    ----------------------------------------------------------------------------
    BCD0: entity work.BCD_to_7Seg
        port map (
            bcd => bcd_digits(3 downto 0),
            seg => seg_values(0)
        );

    BCD1: entity work.BCD_to_7Seg
        port map (
            bcd => bcd_digits(7 downto 4),
            seg => seg_values(1)
        );

    BCD2: entity work.BCD_to_7Seg
        port map (
            bcd => bcd_digits(11 downto 8),
            seg => seg_values(2)
        );

    ----------------------------------------------------------------------------
    -- Clock Divider for multiplexing
    ----------------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            clk_divider   <= 0;
            current_digit <= 0;
        elsif rising_edge(clk) then
            if clk_divider < MAX_COUNT then
                clk_divider <= clk_divider + 1;
            else
                clk_divider <= 0;
                if current_digit < 2 then
                    current_digit <= current_digit + 1;
                else
                    current_digit <= 0;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Output Mux
    ----------------------------------------------------------------------------
    process(current_digit, seg_values)
    begin
        case current_digit is
            when 0 =>
                seg_out <= seg_values(0);
                an      <= "110";  -- digit 0 on, others off
            when 1 =>
                seg_out <= seg_values(1);
                an      <= "101";  -- digit 1 on
            when 2 =>
                seg_out <= seg_values(2);
                an      <= "011";  -- digit 2 on
            when others =>
                seg_out <= "1111111";
                an      <= "111";
        end case;
    end process;

end Behavioral;
