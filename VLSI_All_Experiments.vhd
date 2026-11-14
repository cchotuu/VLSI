
-- ==========================================
-- EXPERIMENT 1: 4-BIT ALU
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_4bit is
    Port (
        A       : in  STD_LOGIC_VECTOR(3 downto 0);
        B       : in  STD_LOGIC_VECTOR(3 downto 0);
        Sel     : in  STD_LOGIC_VECTOR(2 downto 0);
        Result  : out STD_LOGIC_VECTOR(3 downto 0);
        CarryOut: out STD_LOGIC
    );
end alu_4bit;

architecture Behavioral of alu_4bit is
begin
    process(A, B, Sel)
        variable temp : unsigned(4 downto 0);
    variable res   : unsigned(3 downto 0);
    begin
        temp := (others => '0');
        res  := (others => '0');

        case Sel is
            when "000" =>
                temp := ('0' & unsigned(A)) + ('0' & unsigned(B));
                res := temp(3 downto 0);

            when "001" =>
                res := unsigned(A) - unsigned(B);

            when "010" =>
                res := unsigned(A) + 1;

            when "011" =>
                res := unsigned(A) - 1;

            when "100" =>
                res := unsigned(A) and unsigned(B);

            when "101" =>
                res := unsigned(A) or unsigned(B);

            when "110" =>
                res := unsigned(A) xor unsigned(B);

            when "111" =>
                res := not unsigned(A);

            when others =>
                res := (others => '0');
        end case;

        Result <= std_logic_vector(res);

        if Sel = "000" then
            CarryOut <= temp(4);
        elsif Sel = "010" then
            if A = "1111" then
                CarryOut <= '1';
            else
                CarryOut <= '0';
            end if;
        else
            CarryOut <= '0';
        end if;
    end process;
end Behavioral;


-- ==========================================
-- EXPERIMENT 2: UNIVERSAL SHIFT REGISTER
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Universal_Shift_Register is
    Port (
        clk        : in  STD_LOGIC;
        Reset      : in  STD_LOGIC;
        Sel        : in  STD_LOGIC_VECTOR(1 downto 0);
        Serial_In  : in  STD_LOGIC;
        Parallel_In: in  STD_LOGIC_VECTOR(3 downto 0);
        Serial_Out : out STD_LOGIC;
        Reg_Data   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Universal_Shift_Register;

architecture Behavioral of Universal_Shift_Register is
    signal reg : STD_LOGIC_VECTOR(3 downto 0);
begin
    process(clk, Reset)
    begin
        if Reset = '1' then
            reg <= "0000";
        elsif rising_edge(clk) then
            case Sel is
                when "00" =>
                    reg <= Serial_In & reg(3 downto 1);

                when "01" =>
                    reg <= '0' & reg(3 downto 1);

                when "10" =>
                    reg <= Parallel_In;

                when "11" =>
                    reg <= reg;

                when others =>
                    reg <= reg;
            end case;
        end if;
    end process;

    Serial_Out <= reg(0);
    Reg_Data <= reg;
end Behavioral;


-- ==========================================
-- EXPERIMENT 3: MOD-N COUNTER (MOD-10)
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mod_n_counter is
    generic (
        N     : integer := 10;
        WIDTH : integer := 4
    );
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        en       : in  STD_LOGIC;
        count    : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        max_tick : out STD_LOGIC
    );
end mod_n_counter;

architecture Behavioral of mod_n_counter is
    signal counter : unsigned(WIDTH-1 downto 0)
                   := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                if counter = N-1 then
                    counter <= (others => '0');
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;

    count <= std_logic_vector(counter);

    max_tick <= '1' when (counter = N-1 and en = '1')
                else '0';
end Behavioral;


-- ==========================================
-- EXPERIMENT 4: FIFO MEMORY
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo_memory is
    generic (
        DATA_WIDTH : integer := 8;
        FIFO_DEPTH : integer := 16
    );
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        wr_en     : in  STD_LOGIC;
        rd_en     : in  STD_LOGIC;
        data_in   : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        data_out  : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        full      : out STD_LOGIC;
        empty     : out STD_LOGIC
    );
end fifo_memory;

architecture Behavioral of fifo_memory is
    type memory_type is array (0 to FIFO_DEPTH-1)
        of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

    signal memory : memory_type;
    signal wr_ptr : integer range 0 to FIFO_DEPTH-1 := 0;
    signal rd_ptr : integer range 0 to FIFO_DEPTH-1 := 0;
    signal count  : integer range 0 to FIFO_DEPTH := 0;
    signal dout   : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
                    := (others => '0');
begin
    process(clk, rst)
        variable write_ok : boolean;
        variable read_ok  : boolean;
    begin
        if rst = '1' then
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            dout   <= (others => '0');

        elsif rising_edge(clk) then
            write_ok := (wr_en = '1' and count < FIFO_DEPTH);
            read_ok  := (rd_en = '1' and count > 0);

            if write_ok then
                memory(wr_ptr) <= data_in;

                if wr_ptr = FIFO_DEPTH-1 then
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1;
                end if;
            end if;

            if read_ok then
                dout <= memory(rd_ptr);

                if rd_ptr = FIFO_DEPTH-1 then
                    rd_ptr <= 0;
                else
                    rd_ptr <= rd_ptr + 1;
                end if;
            end if;

            if write_ok and not read_ok then
                count <= count + 1;
            elsif read_ok and not write_ok then
                count <= count - 1;
            end if;
        end if;
    end process;

    data_out <= dout;
    full  <= '1' when count = FIFO_DEPTH else '0';
    empty <= '1' when count = 0 else '0';
end Behavioral;


-- ==========================================
-- EXPERIMENT 5: LCD INTERFACE
-- HELLO WORLD
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd_interface is
    Port (
        clk   : in  STD_LOGIC;
        rst   : in  STD_LOGIC;
        lcd_e : out STD_LOGIC;
        lcd_rs: out STD_LOGIC;
        lcd_rw: out STD_LOGIC;
        lcd_data : out STD_LOGIC_VECTOR(7 downto 0)
    );
end lcd_interface;

architecture Behavioral of lcd_interface is

    type state_type is (WAIT_STATE, SEND_STATE, DONE_STATE);
    signal state : state_type := WAIT_STATE;

    type lcd_array is array (0 to 17)
        of STD_LOGIC_VECTOR(7 downto 0);

    constant lcd_rom : lcd_array := (
        x"38", x"0C", x"01", x"06", x"80",
        x"48", x"45", x"4C", x"4C", x"4F",
        x"20", x"57", x"4F", x"52", x"4C",
        x"44", x"21", x"00"
    );

    signal index : integer range 0 to 17 := 0;
    signal timer : integer range 0 to 2500000 := 0;
    signal e_reg : STD_LOGIC := '0';
    signal rs_reg: STD_LOGIC := '0';
    signal data_reg : STD_LOGIC_VECTOR(7 downto 0)
                     := (others => '0');

begin
    process(clk, rst)
    begin
        if rst = '1' then
            state <= WAIT_STATE;
            index <= 0;
            timer <= 0;
            e_reg <= '0';
            rs_reg <= '0';
            data_reg <= (others => '0');

        elsif rising_edge(clk) then
            case state is

                when WAIT_STATE =>
                    e_reg <= '0';

                    if timer < 2500000 then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        state <= SEND_STATE;
                    end if;

                when SEND_STATE =>
                    data_reg <= lcd_rom(index);

                    if index <= 4 then
                        rs_reg <= '0';
                    else
                        rs_reg <= '1';
                    end if;

                    e_reg <= not e_reg;

                    if timer < 50000 then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        e_reg <= '0';

                        if index = 17 then
                            state <= DONE_STATE;
                        else
                            index <= index + 1;
                            state <= WAIT_STATE;
                        end if;
                    end if;

                when DONE_STATE =>
                    e_reg <= '0';

                when others =>
                    state <= WAIT_STATE;

            end case;
        end if;
    end process;

    lcd_e <= e_reg;
    lcd_rs <= rs_reg;
    lcd_rw <= '0';
    lcd_data <= data_reg;

end Behavioral;
