
--- ==========================================
-- EXPERIMENT 1: ALU TESTBENCH
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_alu_4bit is
end tb_alu_4bit;

architecture test of tb_alu_4bit is
    signal A, B : STD_LOGIC_VECTOR(3 downto 0);
    signal Sel : STD_LOGIC_VECTOR(2 downto 0);
    signal Result : STD_LOGIC_VECTOR(3 downto 0);
    signal CarryOut : STD_LOGIC;
begin
    DUT: entity work.alu_4bit
        port map(A, B, Sel, Result, CarryOut);

    process
    begin
        A <= "0101"; B <= "0011"; Sel <= "000";
        wait for 10 ns;

        Sel <= "001";
        wait for 10 ns;

        Sel <= "100";
        wait for 10 ns;

        Sel <= "101";
        wait for 10 ns;

        Sel <= "110";
        wait for 10 ns;

        Sel <= "111";
        wait for 10 ns;

        wait;
    end process;
end test;


-- ==========================================
-- EXPERIMENT 2: SHIFT REGISTER TESTBENCH
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_shift_register is
end tb_shift_register;

architecture test of tb_shift_register is
    signal clk : STD_LOGIC := '0';
    signal Reset : STD_LOGIC := '0';
    signal Sel : STD_LOGIC_VECTOR(1 downto 0);
    signal Serial_In : STD_LOGIC;
    signal Parallel_In : STD_LOGIC_VECTOR(3 downto 0);
    signal Serial_Out : STD_LOGIC;
    signal Reg_Data : STD_LOGIC_VECTOR(3 downto 0);
begin
    clk <= not clk after 5 ns;

    DUT: entity work.Universal_Shift_Register
        port map(clk, Reset, Sel, Serial_In,
                 Parallel_In, Serial_Out, Reg_Data);

    process
    begin
        Reset <= '1';
        wait for 10 ns;
        Reset <= '0';

        Parallel_In <= "1010";
        Sel <= "10";
        wait for 10 ns;

        Sel <= "00";
        Serial_In <= '1';
        wait for 20 ns;

        Sel <= "01";
        wait for 20 ns;

        wait;
    end process;
end test;


-- ==========================================
-- EXPERIMENT 3: MOD-10 COUNTER TESTBENCH
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_mod_n_counter is
end tb_mod_n_counter;

architecture test of tb_mod_n_counter is
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal en : STD_LOGIC := '0';
    signal count : STD_LOGIC_VECTOR(3 downto 0);
    signal max_tick : STD_LOGIC;
begin
    clk <= not clk after 5 ns;

    DUT: entity work.mod_n_counter
        port map(clk, rst, en, count, max_tick);

    process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        en <= '1';
        wait for 120 ns;

        en <= '0';
        wait;
    end process;
end test;


-- ==========================================
-- EXPERIMENT 4: FIFO TESTBENCH
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_fifo_memory is
end tb_fifo_memory;

architecture test of tb_fifo_memory is
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal wr_en, rd_en : STD_LOGIC := '0';
    signal data_in, data_out : STD_LOGIC_VECTOR(7 downto 0);
    signal full, empty : STD_LOGIC;
begin
    clk <= not clk after 5 ns;

    DUT: entity work.fifo_memory
        generic map(DATA_WIDTH => 8, FIFO_DEPTH => 4)
        port map(clk, rst, wr_en, rd_en,
                 data_in, data_out, full, empty);

    process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        wr_en <= '1';
        data_in <= x"11";
        wait for 10 ns;

        data_in <= x"22";
        wait for 10 ns;

        data_in <= x"33";
        wait for 10 ns;

        wr_en <= '0';
        rd_en <= '1';
        wait for 30 ns;

        rd_en <= '0';
        wait;
    end process;
end test;


-- ==========================================
-- EXPERIMENT 5: LCD TESTBENCH
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_lcd_interface is
end tb_lcd_interface;

architecture test of tb_lcd_interface is
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal lcd_e, lcd_rs, lcd_rw : STD_LOGIC;
    signal lcd_data : STD_LOGIC_VECTOR(7 downto 0);
begin
    clk <= not clk after 10 ns;

    DUT: entity work.lcd_interface
        port map(clk, rst, lcd_e, lcd_rs,
                 lcd_rw, lcd_data);

    process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';

        wait for 60 ms;
        wait;
    end process;
end test;
