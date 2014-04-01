-- ------------------------ --
--  THM CPU RA WS 2013/14   --
--                          --
--  Instruction Register    --
-- ------------------------ --
-- Authors: Matthias Roell, --
--          Fabian Stahl    --
-- Date:    07.02.2014      --
-- ------------------------ --

library ieee;
use ieee.std_logic_1164.all;

entity instruction_register is
	port(
		clk     : in  std_logic;
		ir_load : in  std_logic;
		mem_out : in  std_logic_vector(7 downto 0);
		op_code : out std_logic_vector(2 downto 0);
		ir_out  : out std_logic_vector(4 downto 0)
	);
end instruction_register;

architecture rtl of instruction_register is
begin
	CLK_PROCESS : process(clk)
	begin
		if rising_edge(clk) then
			if ir_load = '1' then
				op_code <= mem_out(7 downto 5);
				ir_out  <= mem_out(4 downto 0);
			end if;
		end if;
	end process;

end;
