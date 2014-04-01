-- ------------------------ --
--  THM CPU RA WS 2013/14   --
--                          --
--  Control Unit            --
-- ------------------------ --
-- Authors: Matthias Roell, --
--          Fabian Stahl    --
-- Date:    06.02.2014      --
-- ------------------------ --

library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	port(
		-- Control Input --
		clk           : in  std_logic;
		reset         : in  std_logic;
		in_enter      : in  std_logic;
		pos_flag      : in  std_logic;
		zero_flag     : in  std_logic;

		-- Data Input --
		op_code       : in  std_logic_vector(2 downto 0);
		ir_out        : in  std_logic_vector(4 downto 0);

		-- Program Counter Output  --
		pc_sel        : out std_logic_vector(1 downto 0);
		pc_load       : out std_logic;
		adr_sel       : out std_logic;

		-- Instruction Register Output  --
		ir_load       : out std_logic;

		-- Accumulator Output  --
		acc_sel       : out std_logic_vector(1 downto 0);
		acc_load      : out std_logic;

		-- Arithmetic Logic Unit Output  --
		alu_op        : out std_logic_vector(1 downto 0);

		-- Memory Output  --
		mem_write     : out std_logic;

		-- Generic Output  --
		output_enable : out std_logic;
		led_wait	  : out std_logic
	);
end control_unit;

architecture rtl of control_unit is
	type state_type is (
		RESET_STATE,                    -- Reset CPU

		CTRL_LOAD_IR,                   -- New Instruction from IR

		MEM_STORE,                      -- Write Memory In
		ACC_MEM,                        -- Acc load Memory

		ACC_ALU_ADD,                    -- Acc load ALU with ALU-Add Operation
		ACC_ALU_SUB,                    -- Acc load ALU with ALU-Sub Operation
		ACC_ALU_NAND,                   -- Acc load ALU with ALU-Nand Operation

		ACC_IN_ENTER,                   -- Acc load key_in when in_enter

		JUMP_PC_MEM,                    -- PC Jump to Address

		NOP_PC,                         -- Update PC
		NOP_OUT,                        -- Enable Output while not in_enter
		NOP_MEM,                        -- Update MEM
		NOP_IR                          -- Update IR
);
	signal state      : state_type := RESET_STATE;
	signal next_state : state_type := RESET_STATE;

begin
	CLOCK_PROCESS : process(clk, reset)
	begin
		if reset = '1' then
			state <= RESET_STATE;
		elsif rising_edge(clk) then
			state <= next_state;
		end if;
	end process;

	INPUT_STATE_PROCESS : process(state, in_enter, op_code, ir_out, zero_flag, pos_flag)
	begin
		next_state <= state;	-- prevents inferred latches

		case (state) is

			-- On reset pc is set address 0x00 so no nop_pc is needed
			when RESET_STATE =>
				next_state <= NOP_MEM;

			-- Next State depends on inputs
			when CTRL_LOAD_IR =>
				-- Going through op_codes
				case (op_code) is
					when "000" =>       -- LOAD
						next_state <= ACC_MEM;
					when "001" =>
						next_state <= MEM_STORE;
					when "010" =>       -- ADD
						next_state <= ACC_ALU_ADD;
					when "011" =>       -- SUB
						next_state <= ACC_ALU_SUB;

					when "100" =>       				-- NAND, IN, OUT
						-- Depends on ir_out data
						if ir_out = "00000" then 		-- IN
							next_state <= ACC_IN_ENTER;
						elsif ir_out = "00001" then 	-- OUT
							next_state <= NOP_OUT;
						else            				-- NAND
							next_state <= ACC_ALU_NAND;
						end if;

					when "101" =>       -- JUMP ZERO
						if zero_flag = '1' then
							next_state <= JUMP_PC_MEM;
						else
							next_state <= NOP_PC;
						end if;
					when "110" =>       -- JUMP POSITIVE
						if pos_flag = '1' then
							next_state <= JUMP_PC_MEM;
						else
							next_state <= NOP_PC;
						end if;
					when others =>      -- JUMP ALWAYS
						next_state <= JUMP_PC_MEM;
				end case;

			when ACC_IN_ENTER | NOP_OUT =>
				 if in_enter = '1' then
                    next_state <= NOP_PC;
                 else
                    next_state <= state;
                 end if;

			when NOP_PC =>
				next_state <= NOP_MEM;
			-- JUMP_PC_MEM skips NOP_PC and NOP_MEM
			when JUMP_PC_MEM | NOP_MEM =>
				next_state <= NOP_IR;
			when NOP_IR =>
				next_state <= CTRL_LOAD_IR;

			-- Next State is always NOP_PC
			when others =>
				next_state <= NOP_PC;

		end case;
	end process;

	STATE_OUTPUT_PROCESS : process(state)
	begin
		case (state) is
			when RESET_STATE =>         -- Reset CPU
				-- PC
				pc_sel        <= "10";
				pc_load       <= '1';
				adr_sel       <= '0';
				-- IR
				ir_load       <= '0';
				-- ACC
				acc_sel       <= "00";
				acc_load      <= '0';
				-- ALU
				alu_op        <= "00";
				-- MEM
				mem_write     <= '0';
				-- GEN
				output_enable <= '0';
				led_wait 	  <= '0';

			when CTRL_LOAD_IR =>        -- New Instruction from IR
				-- PC
				pc_sel        <= "00";
				pc_load       <= '0';
				adr_sel       <= '1';
				-- IR
				ir_load       <= '0';
				-- ACC
				acc_sel       <= "00";
				acc_load      <= '0';
				-- ALU
				alu_op        <= "00";
				-- MEM
				mem_write     <= '0';
				-- GEN
				output_enable <= '0';
				led_wait 	  <= '0';

			when MEM_STORE =>           -- Write Memory In
				-- PC
				pc_sel        <= "00";
				pc_load       <= '0';
				adr_sel       <= '1';
				-- IR
				ir_load       <= '0';
				-- ACC
				acc_sel       <= "ZZ";
				acc_load      <= '0';
				-- ALU
				alu_op        <= "00";
				-- MEM
				mem_write     <= '1';
				-- GEN
				output_enable <= '0';
				led_wait 	  <= '0';

			when ACC_MEM =>             -- Acc load Memory
				-- PC
				pc_sel        <= "00";
				pc_load       <= '0';
				adr_sel       <= '0';
				-- IR
				ir_load       <= '0';
				-- ACC
				acc_sel       <= "01";
				acc_load      <= '1';
				-- ALU
				alu_op        <= "00";
				-- MEM
				mem_write     <= '0';
				-- GEN
				output_enable <= '0';
				led_wait 	  <= '0';

			when ACC_ALU_ADD =>         -- Acc load ALU with ALU-Add Operation
				-- PC
				pc_sel        <= "00";
				pc_load       <= '0';
				adr_sel       <= '0';
				-- IR
				ir_load       <= '0';
				-- ACC
				acc_sel       <= "00";
				acc_load      <= '1';
				-- ALU
				alu_op        <= "00";
				-- MEM
				mem_write     <= '0';
				-- GEN
				output_enable <= '0';
				led_wait 	  <= '0';

			when ACC_ALU_SUB =>         -- Acc load ALU with ALU-Sub Operation
				-- PC
				pc_sel        <= "00";
				pc_load       <= '0';
				adr_sel       <= '0';
				-- IR
				ir_load       <= '0';
				-- ACC
				acc_sel       <= "00";
				acc_load      <= '1';
				-- ALU
				alu_op        <= "01";
				-- MEM
				mem_write     <= '0';
				-- GEN
				output_enable <= '0';
				led_wait 	  <= '0';

			when ACC_ALU_NAND =>        -- Acc load ALU with ALU-Nand Operation
				-- PC
				pc_sel        <= "00";
				pc_load       <= '0';
				adr_sel       <= '0';
				-- IR
				ir_load       <= '0';
				-- ACC
				acc_sel       <= "00";
				acc_load      <= '1';
				-- ALU
				alu_op        <= "10";
				-- MEM
				mem_write     <= '0';
				-- GEN
				output_enable <= '0';
				led_wait 	  <= '0';

			when ACC_IN_ENTER =>        -- Acc load key_in when in_enter
				-- PC
				pc_sel        <= "00";
				pc_load       <= '0';
				adr_sel       <= '0';
				-- IR
				ir_load       <= '0';
				-- ACC
				acc_sel       <= "10";
				acc_load      <= '1';
				-- ALU
				alu_op        <= "00";
				-- MEM
				mem_write     <= '0';
				-- GEN
				output_enable <= '0';
				led_wait 	  <= '1';

			when JUMP_PC_MEM =>         -- PC Jump to Address
				-- PC
				pc_sel        <= "01";
				pc_load       <= '1';
				adr_sel       <= '1';
				-- IR
				ir_load       <= '0';
				-- ACC
				acc_sel       <= "00";
				acc_load      <= '0';
				-- ALU
				alu_op        <= "00";
				-- MEM
				mem_write     <= '0';
				-- GEN
				output_enable <= '0';
				led_wait 	  <= '0';

			when NOP_PC =>              -- Update PC
				-- PC
				pc_sel        <= "00";
				pc_load       <= '1';
				adr_sel       <= '0';
				-- IR
				ir_load       <= '0';
				-- ACC
				acc_sel       <= "00";
				acc_load      <= '0';
				-- ALU
				alu_op        <= "00";
				-- MEM
				mem_write     <= '0';
				-- GEN
				output_enable <= '0';
				led_wait 	  <= '0';

			when NOP_OUT =>             -- Enable Output
				-- PC
				pc_sel        <= "00";
				pc_load       <= '0';
				adr_sel       <= '0';
				-- IR
				ir_load       <= '0';
				-- ACC
				acc_sel       <= "00";
				acc_load      <= '0';
				-- ALU
				alu_op        <= "00";
				-- MEM
				mem_write     <= '0';
				-- GEN
				-- GEN
				output_enable <= '1';
				led_wait 	  <= '0';

			when NOP_MEM =>             -- Update MEM
				-- PC
				pc_sel        <= "00";
				pc_load       <= '0';
				adr_sel       <= '0';
				-- IR
				ir_load       <= '0';
				-- ACC
				acc_sel       <= "00";
				acc_load      <= '0';
				-- ALU
				alu_op        <= "00";
				-- MEM
				mem_write     <= '0';
				-- GEN
				output_enable <= '0';
				led_wait 	  <= '0';

			when others =>              -- Update IR (NOP_IR)
				-- PC
				pc_sel        <= "00";
				pc_load       <= '0';
				adr_sel       <= '0';
				-- IR
				ir_load       <= '1';
				-- ACC
				acc_sel       <= "00";
				acc_load      <= '0';
				-- ALU
				alu_op        <= "00";
				-- MEM
				mem_write     <= '0';
				-- GEN
				output_enable <= '0';
				led_wait 	  <= '0';
		end case;
	end process;

end;
