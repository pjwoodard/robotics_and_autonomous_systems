----------------------------------------------------------------------------------
-- 
-- Author: Erin McDonnell
-- 
-- Description:
--    ECE 525.642 Lab 4
--    Outputs a debounced signal after the input bouncy signal is high for at least 100ms 
--    Assumes a 100MHz clock input
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.all;

entity debounce is
  Port ( 
    clk           : in std_logic;    -- assumed 100MHz clock
    reset         : in std_logic;    -- active high reset
    pb            : in std_logic;    -- pushbutton input to debounce
    debounce_pb   : out std_logic    -- debounced pushbutton output
  );
end debounce;

architecture rtl of debounce is
  
  -- count to 10,000,000 because there are 10,000,000 x 10ns counts in 100ms
  signal count    : unsigned (23 downto 0);
  signal maxCount : unsigned (23 downto 0) := "100110001001011010000000";
  
begin

  process (clk, reset)
  begin
    if (reset = '1') then
      count <= (others => '0');
      debounce_pb <= '0';
    elsif (rising_edge(clk)) then
      if (pb = '1') then
        if (count < maxCount) then  -- if button is pressed and less than 100ms have elapsed
          count <= count + 1;        --    then increment the counter
        else                        -- if button is pressed and >= 100ms have elapsed
          debounce_pb <= '1';       --    then set the debounced signal to high for 1 clk cycle
        end if;
      else                          -- if button is not pressed
        debounce_pb <= '0';         --    then the debounce signal and count are 0         
        count <= (others => '0');
      end if;
    end if;
  end process;

end rtl;