library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataBuffer is
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
end DataBuffer;

architecture Behavioral of DataBuffer is

    -- Renamed 'buffer' to 'data_mem' to avoid conflict with reserved keywords
    type buffer_type is array (0 to N-1) of unsigned(11 downto 0);
    signal data_mem        : buffer_type := (others => (others => '0'));
    signal write_ptr       : integer range 0 to N-1 := 0;
    signal count           : integer range 0 to N := 0;
    signal buffer_full_sig : std_logic := '0';

begin

    process(clk, reset)
    begin
        if reset = '1' then
            write_ptr       <= 0;
            count           <= 0;
            buffer_full_sig <= '0';
        elsif rising_edge(clk) then
            -- Write data into the memory at the current write pointer
            data_mem(write_ptr) <= unsigned(data_in);

            -- Increment count until buffer is full
            if count < N then
                count <= count + 1;
                if count = N-1 then
                    buffer_full_sig <= '1';
                end if;
            else
                buffer_full_sig <= '1';
            end if;

            -- Update write pointer with wrap-around
            write_ptr <= (write_ptr + 1) mod N;
        end if;
    end process;

    -- Output the oldest data in the buffer
    -- If write_ptr points to the next write location, the oldest data is at write_ptr
    data_out <= std_logic_vector(data_mem(write_ptr));

    -- Assign buffer_full signal
    buffer_full <= buffer_full_sig;

end Behavioral;
