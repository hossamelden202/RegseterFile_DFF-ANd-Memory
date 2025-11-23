-- Register File using D Flip-Flops
-- 8 registers, 8-bit width each
-- 2 read ports, 1 write port
-- Address bus size: 3 bits (to address 8 registers)
-- Data bus size: 8 bits (register width)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile_DFF is
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        write_enable : in  STD_LOGIC;
        read_addr0   : in  STD_LOGIC_VECTOR(2 downto 0);  -- 3-bit address
        read_addr1   : in  STD_LOGIC_VECTOR(2 downto 0);
        write_addr   : in  STD_LOGIC_VECTOR(2 downto 0);
        write_data   : in  STD_LOGIC_VECTOR(7 downto 0);  -- 8-bit data
        read_data0   : out STD_LOGIC_VECTOR(7 downto 0);
        read_data1   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end RegisterFile_DFF;

architecture Structural of RegisterFile_DFF is
    
    -- Component declaration for DFF
    component DFF is
        Port (
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            d     : in  STD_LOGIC;
            q     : out STD_LOGIC
        );
    end component;
    
    -- Internal signals
    type reg_array is array (0 to 7) of STD_LOGIC_VECTOR(7 downto 0);
    signal reg_out : reg_array;
    signal reg_in  : reg_array;
    signal write_enable_decoded : STD_LOGIC_VECTOR(7 downto 0);
    
begin
    
    -- Decode write address to enable signals
    write_enable_decoded(0) <= '1' when (write_enable = '1' and write_addr = "000") else '0';
    write_enable_decoded(1) <= '1' when (write_enable = '1' and write_addr = "001") else '0';
    write_enable_decoded(2) <= '1' when (write_enable = '1' and write_addr = "010") else '0';
    write_enable_decoded(3) <= '1' when (write_enable = '1' and write_addr = "011") else '0';
    write_enable_decoded(4) <= '1' when (write_enable = '1' and write_addr = "100") else '0';
    write_enable_decoded(5) <= '1' when (write_enable = '1' and write_addr = "101") else '0';
    write_enable_decoded(6) <= '1' when (write_enable = '1' and write_addr = "110") else '0';
    write_enable_decoded(7) <= '1' when (write_enable = '1' and write_addr = "111") else '0';
    
    -- Input data selection for each register
    gen_reg_input: for i in 0 to 7 generate
        reg_in(i) <= write_data when write_enable_decoded(i) = '1' else reg_out(i);
    end generate;
    
    -- Instantiate 64 DFFs (8 registers × 8 bits each)
    gen_registers: for i in 0 to 7 generate
        gen_bits: for j in 0 to 7 generate
            dff_inst: DFF
                port map (
                    clk   => clk,
                    reset => reset,
                    d     => reg_in(i)(j),
                    q     => reg_out(i)(j)
                );
        end generate;
    end generate;
    
    -- Read port multiplexers
    read_data0 <= reg_out(to_integer(unsigned(read_addr0)));
    read_data1 <= reg_out(to_integer(unsigned(read_addr1)));
    
end Structural;