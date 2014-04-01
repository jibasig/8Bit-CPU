-- ------------------------ --
--  THM CPU RA WS 2013/14   --
--                          --
--  Internal Clock Gen.     --
-- ------------------------ --
-- Authors: Matthias Roell, --
--          Fabian Stahl    --
-- Date:    10.02.2014      --
-- ------------------------ --

library ieee;
use ieee.std_logic_1164.all;

-- 10 MHz clock generator

entity internal_clock is
    port (
        clk : out std_logic
    );
end internal_clock;

architecture rtl of internal_clock is
begin
    CLK_PROCESS:
    process begin
        clk <= '0';
        wait for 50 ns;  --for 50 ns signal is '0'.
        clk <= '1';
        wait for 50 ns;  --for next 50 ns signal is '1'.
   end process;
end;
