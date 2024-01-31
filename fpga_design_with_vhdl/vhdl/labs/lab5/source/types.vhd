LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package types is
    type bus_8x4 is ARRAY(7 DOWNTO 0) of STD_LOGIC_VECTOR(3 DOWNTO 0);
end package;