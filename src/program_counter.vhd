-- ------------------------ --
--  THM CPU RA WS 2013/14   --
--                          --
--  Program Counter         --
-- ------------------------ --
-- Authors: Matthias Roell, --
--          Fabian Stahl    --
-- Date:    06.02.2014      --
-- ------------------------ --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
	port(
		-- Control Input --
		clk     : in  std_logic;
		pc_load : in  std_logic;
		pc_sel  : in  std_logic_vector(1 downto 0);
		adr_sel : in  std_logic;
		-- Data Input --
		ir_out  : in  std_logic_vector(4 downto 0);
		-- Data Output  --
		address : out std_logic_vector(4 downto 0)
	);
end program_counter;

architecture rtl of program_counter is

	-- internal pc address
	signal hold_address : std_logic_vector(4 downto 0);

begin
	PC_PROCESS : process(clk)
	begin
		if rising_edge(clk) then
			if pc_load = '1' then
				if pc_sel = "00" then
					hold_address <= std_logic_vector(unsigned(hold_address) + 1);
				elsif pc_sel = "01" then
					hold_address <= ir_out;
				else
					hold_address <= "00000";
				end if;
			end if;
		end if;
	end process;

	-- Set output based on adr_sel
	with adr_sel select address <=
		hold_address when '0',          -- PC address
		ir_out when others;             -- IR address

end;
