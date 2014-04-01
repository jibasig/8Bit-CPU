-- ------------------------ --
--  THM CPU RA WS 2013/14   --
--                          --
--  Arithmetic Logic Unit   --
-- ------------------------ --
-- Authors: Matthias Roell, --
--          Fabian Stahl    --
-- Date:    06.02.2014      --
-- ------------------------ --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arithmetic_logic_unit is
	port(
		-- Control Input --
		alu_op  : in  std_logic_vector(1 downto 0);
		-- Data Input --
		mem_out : in  std_logic_vector(7 downto 0);
		acc_out : in  std_logic_vector(7 downto 0);
		-- Data Output  --
		alu_out : out std_logic_vector(7 downto 0)
	);
end arithmetic_logic_unit;

architecture rtl of arithmetic_logic_unit is
begin

	-- Set output based on alu_op
	with alu_op select alu_out <=
		std_logic_vector(signed(mem_out) + signed(acc_out)) when "00", -- ADD
		std_logic_vector(signed(mem_out) - signed(acc_out)) when "01", -- SUB
		not (mem_out and acc_out) when "10",	-- NAND
		"00000000" when others;         		-- Not used Operation

end;
