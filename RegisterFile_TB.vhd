library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity RegisterFile_TB is
end RegisterFile_TB;

architecture Behavioral of RegisterFile_TB is

    -- Component declarations
    component RegisterFile_DFF is
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
    end component;

    component RegisterFile_Memory is
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
    end component;

    -- Test signals
    signal clk          : STD_LOGIC := '0';
    signal reset        : STD_LOGIC := '0';
    signal write_enable : STD_LOGIC := '0';
    signal read_addr0   : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal read_addr1   : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal write_addr   : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal write_data   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    signal read_data0_dff : STD_LOGIC_VECTOR(7 downto 0);
    signal read_data1_dff : STD_LOGIC_VECTOR(7 downto 0);
    signal read_data0_mem : STD_LOGIC_VECTOR(7 downto 0);
    signal read_data1_mem : STD_LOGIC_VECTOR(7 downto 0);

    constant clk_period : time := 10 ns;
    file out_f : text open write_mode is "sim_output.txt";

begin

    -- Instantiate both versions
    uut_dff: RegisterFile_DFF
        port map (
            clk          => clk,
            reset        => reset,
            write_enable => write_enable,
            read_addr0   => read_addr0,
            read_addr1   => read_addr1,
            write_addr   => write_addr,
            write_data   => write_data,
            read_data0   => read_data0_dff,
            read_data1   => read_data1_dff
        );

    uut_mem: RegisterFile_Memory
        port map (
            clk          => clk,
            reset        => reset,
            write_enable => write_enable,
            read_addr0   => read_addr0,
            read_addr1   => read_addr1,
            write_addr   => write_addr,
            write_data   => write_data,
            read_data0   => read_data0_mem,
            read_data1   => read_data1_mem
        );

    --------------------------------------------------------------------------
    -- Clock generation
    --------------------------------------------------------------------------
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    --------------------------------------------------------------------------
    -- Monitor process: log values every clock
    --------------------------------------------------------------------------
    monitor_process: process
        variable l : line;
        variable cycle_num : integer := 0;
    begin
        while true loop
            wait until rising_edge(clk);
            wait for 1 ns;
            cycle_num := cycle_num + 1;

            write(l, string'("Cycle "));
            write(l, cycle_num);
            write(l, string'(" | "));

            if reset = '1' then
                write(l, string'("RESET"));
            elsif write_enable = '1' then
                write(l, string'("Write R["));
                write(l, to_integer(unsigned(write_addr)));
                write(l, string'("]="));
                hwrite(l, write_data);
            else
                write(l, string'("Read"));
            end if;

            write(l, string'(" | DFF: P0="));
            hwrite(l, read_data0_dff);
            write(l, string'(" P1="));
            hwrite(l, read_data1_dff);
            write(l, string'(" | MEM: P0="));
            hwrite(l, read_data0_mem);
            write(l, string'(" P1="));
            hwrite(l, read_data1_mem);

            writeline(out_f, l);
        end loop;
    end process;

    --------------------------------------------------------------------------
    -- Stimulus Process: Drives input sequence
    --------------------------------------------------------------------------
    stim_process: process
        variable l : line;
        variable v_read0_dff, v_read1_dff : STD_LOGIC_VECTOR(7 downto 0);
        variable v_read0_mem, v_read1_mem : STD_LOGIC_VECTOR(7 downto 0);
    begin
        write(l, string'("=== Register File Test ==="));
        writeline(out_f, l);

        wait for clk_period * 2;

        -- Reset
        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';
        wait until rising_edge(clk);

        -- Write some registers
        write_enable <= '1';
        write_addr <= "000"; write_data <= X"FF"; wait until rising_edge(clk);
        write_addr <= "001"; write_data <= X"11"; wait until rising_edge(clk);
        write_addr <= "111"; write_data <= X"90"; wait until rising_edge(clk);
        write_addr <= "011"; write_data <= X"08"; wait until rising_edge(clk);

        -- Read/Write mixed
        write_addr <= "100"; write_data <= X"03";
        read_addr0 <= "001"; read_addr1 <= "111"; wait until rising_edge(clk);

        -- Read-only
        write_enable <= '0';
        read_addr0 <= "010"; read_addr1 <= "011"; wait until rising_edge(clk);
        read_addr0 <= "100"; read_addr1 <= "101"; wait until rising_edge(clk);

        -- Final write and read
        write_enable <= '1';
        write_addr <= "000"; write_data <= X"01";
        read_addr0 <= "110"; read_addr1 <= "000"; wait until rising_edge(clk);

        write_enable <= '0';
        wait until rising_edge(clk);

        -- Capture comparison
        wait for 1 ns;
        v_read0_dff := read_data0_dff;
        v_read1_dff := read_data1_dff;
        v_read0_mem := read_data0_mem;
        v_read1_mem := read_data1_mem;

        write(l, string'("=================================================================="));
        writeline(out_f, l);

        if (v_read0_dff = v_read0_mem) and (v_read1_dff = v_read1_mem) then
            write(l, string'("SUCCESS: Both implementations produce identical results!"));
        else
            write(l, string'("ERROR: Implementations produce different results!"));
            writeline(out_f, l);
            write(l, string'("  DFF P0=")); hwrite(l, v_read0_dff);
            write(l, string'(" MEM P0=")); hwrite(l, v_read0_mem);
            writeline(out_f, l);
            write(l, string'("  DFF P1=")); hwrite(l, v_read1_dff);
            write(l, string'(" MEM P1=")); hwrite(l, v_read1_mem);
        end if;
        writeline(out_f, l);

        write(l, string'("=== Test Complete ==="));
        writeline(out_f, l);

        wait;
    end process;

end Behavioral;
