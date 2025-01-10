library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RMS_Calculator is
    Generic (
        N : integer := 256  -- Number of samples
    );
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        buffer_full : in  std_logic;
        data_in     : in  unsigned(11 downto 0);
        rms_out     : out unsigned(23 downto 0)
    );
end RMS_Calculator;

architecture Behavioral of RMS_Calculator is
    signal sum_squares : unsigned(23 downto 0) := (others => '0');
    signal count       : integer range 0 to N := 0;
    signal rms_out_sig : unsigned(23 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            sum_squares <= (others => '0');
            count       <= 0;
            rms_out_sig <= (others => '0');
        elsif rising_edge(clk) then
            if buffer_full = '1' then
                -- sum of squares
                sum_squares <= sum_squares + resize(data_in * data_in, 24);
                count       <= count + 1;

                if count = N then
                    -- "Real" RMS requires sqrt. Placeholder: just average of squares:
                    rms_out_sig <= sum_squares / to_unsigned(N, 24);

                    -- Reset for next block
                    sum_squares <= (others => '0');
                    count       <= 0;
                end if;
            end if;
        end if;
    end process;

    rms_out <= rms_out_sig;

end Behavioral;
