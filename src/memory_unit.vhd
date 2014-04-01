-- ------------------------ --
--  THM CPU RA WS 2013/14   --
--                          --
--  Memory                  --
-- ------------------------ --
-- Authors: Matthias Roell, --
--          Fabian Stahl    --
-- Date:    06.02.2014      --
-- ------------------------ --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_unit is
	port(
		-- Control Input --
		clk       : in  std_logic;
		reset     : in  std_logic;
		mem_write : in  std_logic;
		-- Data Input --
		address   : in  std_logic_vector(4 downto 0);
		acc_out   : in  std_logic_vector(7 downto 0);
		-- Data Output  --
		mem_out   : out std_logic_vector(7 downto 0)
	);
end memory_unit;

architecture rtl of memory_unit is
	type ram_type is array (31 downto 0) of std_logic_vector(7 downto 0);
	signal ram          : ram_type;
	signal read_address : std_logic_vector(4 downto 0);

begin
	RAM_PROCESS : process(clk, reset)
	begin
		if reset = '1' then
			-- Default Code

			-- Some Values
			ram(31) <= "00000110";      -- Value: 0x06
			ram(30) <= "00000101";      -- Value: 0x05
			ram(29) <= "00000100";      -- Value: 0x04
			ram(28) <= "00000011";      -- Value: 0x03
			ram(27) <= "00000010";      -- Value: 0x02
			ram(26) <= "00000001";      -- Value: 0x01
			ram(25) <= "00000000";      -- Value: 0x00

			-- Default Program (Instruction Testing)
			--
			--          Ins  |  Addr
			ram(00) <= "000" & "11001"; -- ACC <- 0x00
            ram(01) <= "100" & "00000"; -- ACC <- IN
            ram(02) <= "001" & "11000"; -- MEM(24) <- ACC
            ram(03) <= "100" & "00000"; -- ACC <- IN
            ram(04) <= "001" & "10111"; -- MEM(23) <- ACC
            -- ADD
            ram(05) <= "010" & "11000"; -- ACC <- ACC + MEM(24)
            ram(06) <= "100" & "00001"; -- OUT <- ACC
            -- SUB
            ram(07) <= "000" & "11000"; -- ACC <- MEM(24)
            ram(08) <= "011" & "10111"; -- ACC <- ACC - MEM(23)
            ram(09) <= "100" & "00001"; -- OUT <- ACC
            -- NAND
            ram(10) <= "000" & "11000"; -- ACC <- MEM(24)
            ram(11) <= "100" & "10111"; -- ACC <- ACC nand MEM(23)
            ram(12) <= "100" & "00001"; -- OUT <- ACC
            -- JPos
            ram(13) <= "000" & "11111"; -- ACC <- MEM(31)
            ram(14) <= "110" & "10010"; -- PC <- 18
            -- JZ
            ram(18) <= "000" & "11001"; -- ACC <- MEM(25)
            ram(19) <= "101" & "10000"; -- PC <- 16
            -- Jump
            ram(15) <= "100" & "00001"; -- OUT <- ACC
            ram(16) <= "111" & "00000"; -- PC <- 00

		elsif rising_edge(clk) then
			-- Write data to memory
			if mem_write = '1' then
				ram(to_integer(unsigned(address))) <= acc_out;
			end if;
			-- Store output adress
			read_address <= address;
		end if;
	end process;

	-- Set output (updates with RAM_PROCESS)
	mem_out <= ram(to_integer(unsigned(read_address)));

end;
