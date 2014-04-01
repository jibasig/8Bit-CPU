-- ------------------------ --
--  THM CPU RA WS 2013/14   --
--                          --
--  Accumulator             --
-- ------------------------ --
-- Authors: Matthias Roell, --
--          Fabian Stahl    --
-- Date:    06.02.2014      --
-- ------------------------ --

library ieee;
use ieee.std_logic_1164.all;

entity accumulator is
	port(
		-- Control Input --
		clk       : in  std_logic;
		acc_load  : in  std_logic;
		acc_sel   : in  std_logic_vector(1 downto 0);
		-- Data Input --
		key_in    : in  std_logic_vector(7 downto 0);
		mem_out   : in  std_logic_vector(7 downto 0);
		alu_out   : in  std_logic_vector(7 downto 0);
		-- Data Output  --
		acc_out   : out std_logic_vector(7 downto 0);
		pos_flag  : out std_logic;
		zero_flag : out std_logic
	);
end accumulator;

architecture rtl of accumulator is

	-- Register to hold the output
	signal hold_acc_out : std_logic_vector(7 downto 0);

begin
	CLK_PROCESS : process(clk)
	begin
		if rising_edge(clk) then
            -- Load new input
            if acc_load = '1' then
                if acc_sel = "00" then      -- Load ALU
                    hold_acc_out <= alu_out;
                elsif acc_sel = "01" then   -- Load Memory
                    hold_acc_out <= mem_out;
                elsif acc_sel = "10" then   -- Load Keyinput
                    hold_acc_out <= key_in;
                else                        -- Not used Value
                    hold_acc_out <= "00000000";
                end if;
            end if;

			-- Set Zero Flag
			if hold_acc_out = "00000000" then
				zero_flag <= '1';
			else
				zero_flag <= '0';
			end if;
			-- Set Positive Flag
			if hold_acc_out(7) = '0' then
				pos_flag <= '1';
			else
				pos_flag <= '0';
			end if;

			-- Set Output
			acc_out <= hold_acc_out;
		end if;
	end process;

end;
