-- ------------------------ --
--  THM CPU RA WS 2013/14   --
--                          --
--  Central Processing Unit --
-- ------------------------ --
-- Authors: Matthias Roell, --
--          Fabian Stahl    --
-- Date:    06.02.2014      --
-- ------------------------ --

library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity cpu is
	port(
		clk      	: in  std_logic;

		reset    	: in  std_logic;

		in_enter	: in  std_logic;
		key_in  	: in  std_logic_vector(7 downto 0);

		led_wait	: out std_logic;
		led_out		: out std_logic_vector(7 downto 0)
	);
end cpu;

architecture rtl of cpu is

	-- Data Wires
	signal address : std_logic_vector(4 downto 0); -- PC to MEM
	signal mem_out : std_logic_vector(7 downto 0); -- MEM to IR, ALU & ACC
	signal acc_out : std_logic_vector(7 downto 0); -- ACC to MEM, ALU & OUT_LEDS
	signal op_code : std_logic_vector(2 downto 0); -- IR to CTRL
	signal ir_out  : std_logic_vector(4 downto 0); -- IR to CTRL & PC
	signal alu_out : std_logic_vector(7 downto 0); -- ALU to ACC

	-- Control Wires
	signal pc_sel  : std_logic_vector(1 downto 0);     -- PC input address selection
	signal pc_load : std_logic;                        -- PC enable
	signal adr_sel : std_logic;                        -- PC output address selection

	signal ir_load : std_logic;                        -- IR enable

	signal acc_sel   : std_logic_vector(1 downto 0);   -- ACC input data selection
	signal acc_load  : std_logic;                      -- ACC enable
	signal pos_flag  : std_logic;                      -- ACC data is positive flag
	signal zero_flag : std_logic;                      -- ACC data is zero flag

	signal alu_op : std_logic_vector(1 downto 0);      -- ALU operation selection

	signal mem_write : std_logic;                      -- MEM write enable

	signal output_enable : std_logic;                  -- LED output enable

begin

	CTRL	: control_unit port map(clk, reset, in_enter, pos_flag, zero_flag, op_code, ir_out, pc_sel, pc_load, adr_sel, ir_load, acc_sel, acc_load, alu_op, mem_write, output_enable, led_wait);
	MEM 	: memory_unit port map(clk, reset, mem_write, address, acc_out, mem_out);
	ALU 	: arithmetic_logic_unit port map(alu_op, mem_out, acc_out, alu_out);
	ACC 	: accumulator port map(clk, acc_load, acc_sel, key_in, mem_out, alu_out, acc_out, pos_flag, zero_flag);
	IR  	: instruction_register port map(clk, ir_load, mem_out, op_code, ir_out);
	PC		: program_counter port map(clk, pc_load, pc_sel, adr_sel, ir_out, address);

	led_out(0) <= acc_out(0) and output_enable;
	led_out(1) <= acc_out(1) and output_enable;
	led_out(2) <= acc_out(2) and output_enable;
	led_out(3) <= acc_out(3) and output_enable;

	led_out(4) <= acc_out(4) and output_enable;
	led_out(5) <= acc_out(5) and output_enable;
	led_out(6) <= acc_out(6) and output_enable;
	led_out(7) <= acc_out(7) and output_enable;

end;
