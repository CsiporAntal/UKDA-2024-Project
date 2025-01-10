library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BinToBCD is
    Port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        binary_in : in  unsigned(7 downto 0);
        bcd_out   : out unsigned(11 downto 0)
    );
end BinToBCD;

architecture Behavioral of BinToBCD is
    signal shift_reg : unsigned(19 downto 0) := (others => '0');
    signal bit_count : integer range 0 to 8 := 0;
    signal bcd_reg   : unsigned(11 downto 0) := (others => '0');
begin

    process(clk, reset)
    begin
        if reset = '1' then
            shift_reg <= (others => '0');
            bit_count <= 0;
            bcd_reg   <= (others => '0');
        elsif rising_edge(clk) then
            if bit_count < 8 then
                -- Insert next bit of binary_in at LSB
                shift_reg <= shift_reg(18 downto 0) & binary_in(bit_count);

                -- Add 3 to each BCD nibble >= 5
                if shift_reg(19 downto 16) >= "0101" then
                    shift_reg(19 downto 16) <= shift_reg(19 downto 16) + 3;
                end if;
                if shift_reg(15 downto 12) >= "0101" then
                    shift_reg(15 downto 12) <= shift_reg(15 downto 12) + 3;
                end if;
                if shift_reg(11 downto 8) >= "0101" then
                    shift_reg(11 downto 8) <= shift_reg(11 downto 8) + 3;
                end if;

                bit_count <= bit_count + 1;
            else
                bcd_reg   <= shift_reg(11 downto 0);
                shift_reg <= (others => '0');
                bit_count <= 0;
            end if;
        end if;
    end process;

    bcd_out <= bcd_reg;

end Behavioral;
