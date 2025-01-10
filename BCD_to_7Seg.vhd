library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BCD_to_7Seg is
    Port (
        bcd   : in  unsigned(3 downto 0);
        seg   : out std_logic_vector(6 downto 0)  -- seg(6)=A, seg(5)=B, ..., seg(0)=G
    );
end BCD_to_7Seg;

architecture Behavioral of BCD_to_7Seg is
begin
    process(bcd)
    begin
        case bcd is
            when "0000" => seg <= "0000001"; -- 0
            when "0001" => seg <= "1001111"; -- 1
            when "0010" => seg <= "0010010"; -- 2
            when "0011" => seg <= "0000110"; -- 3
            when "0100" => seg <= "1001100"; -- 4
            when "0101" => seg <= "0100100"; -- 5
            when "0110" => seg <= "0100000"; -- 6
            when "0111" => seg <= "0001111"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0000100"; -- 9
            when others => seg <= "1111111"; -- Off
        end case;
    end process;
end Behavioral;
