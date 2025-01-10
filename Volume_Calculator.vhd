library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Volume_Calculator is
    Port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        rms_in     : in  unsigned(23 downto 0);
        volume_out : out unsigned(7 downto 0)
    );
end Volume_Calculator;

architecture Behavioral of Volume_Calculator is
    constant REF_VALUE : unsigned(23 downto 0) := to_unsigned(4095, 24);

    -- A simple (very incomplete) LUT for demonstration:
    type log_table_type is array (0 to 4095) of unsigned(7 downto 0);
    signal log_table : log_table_type := (
        0 => x"00",
        1 => x"00",
        2 => x"02",  -- approximate
        3 => x"04",  
        4 => x"06",  
        5 => x"08",  
        10 => x"12",
        100 => x"22",
        1000 => x"42",
        others => x"00"
    );

    signal volume_out_sig : unsigned(7 downto 0) := (others => '0');

begin
    process(clk, reset)
        variable idx : integer := 0;
    begin
        if reset = '1' then
            volume_out_sig <= (others => '0');
        elsif rising_edge(clk) then

            if rms_in > REF_VALUE then
                volume_out_sig <= to_unsigned(255, 8);
            elsif rms_in = 0 then
                volume_out_sig <= (others => '0');
            else
                -- Scale to 0..4095 range (example, if you want direct indexing).
                idx := to_integer(rms_in(11 downto 0)); 
                if idx >= 0 and idx < 4096 then
                    volume_out_sig <= log_table(idx);
                else
                    volume_out_sig <= (others => '0');
                end if;
            end if;

        end if;
    end process;

    volume_out <= volume_out_sig;

end Behavioral;
