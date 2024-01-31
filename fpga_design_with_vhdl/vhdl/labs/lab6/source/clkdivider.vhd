----------------------------------------------------------------------------------
-- Company: EchelonEmbedded.com
-- Engineer: Doug Wenstrand
-- 
-- Create Date:    11:33:56 04/23/2007 
-- Design Name: 
-- Module Name:    clkdivider - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Just a simple clock divider to save some typing.  Creates a 1 clock
-- wide pulse at the rate specified in the divideby generic.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clkdivider is
    generic (divideby : natural := 2);
    Port ( clk : in std_logic;
           reset : in std_logic;
           pulseout : out std_logic);
end clkdivider;


architecture Behavioral of clkdivider is
signal cnt : natural range 0 to divideby-1;
begin

process(clk,reset)
begin
	if reset='1' then
		cnt<=0;
	elsif rising_edgE(clk) then
		if (cnt = divideby-1)  then
			cnt <= 0;
		else
			cnt <= cnt+1;
		end if;
	end if;
end process;
pulseout <= '1' when cnt=divideby-1 else '0';
end Behavioral;


