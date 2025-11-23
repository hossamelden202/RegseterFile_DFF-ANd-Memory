-- Register File using Memory Array
-- 8 registers, 8-bit width each
-- 2 read ports, 1 write port
-- Address bus size: 3 bits (to address 8 registers)
-- Data bus size: 8 bits (register width)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile_Memory is
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        write_enable : in  STD_LOGIC;
        read_addr0   : in  STD_LOGIC_VECTOR(2 downto 0);
        read_addr1   : in  STD_LOGIC_VECTOR(2 downto 0);
        write_addr   : in  STD_LOGIC_VECTOR(2 downto 0);
        write_data   : in  STD_LOGIC_VECTOR(7 downto 0);
        read_data0   : out STD_LOGIC_VECTOR(7 downto 0);
        read_data1   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end RegisterFile_Memory;

architecture Behavioral of RegisterFile_Memory is
    
    -- Memory array: 8 registers, each 8-bit wide
    type reg_array is array (0 to 7) of STD_LOGIC_VECTOR(7 downto 0);
    signal registers : reg_array;
    
begin
    
    -- Write operation (synchronous)
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset all registers to 0
            for i in 0 to 7 loop
                registers(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            if write_enable = '1' then
                registers(to_integer(unsigned(write_addr))) <= write_data;
            end if;
        end if;
    end process;
    
    -- Read operations (asynchronous/combinational)
    read_data0 <= registers(to_integer(unsigned(read_addr0)));
    read_data1 <= registers(to_integer(unsigned(read_addr1)));
    
end Behavioral;