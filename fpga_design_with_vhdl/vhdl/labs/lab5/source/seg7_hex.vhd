----------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: This module is responsible for displaying the correct hex value on
--              a seven segment display 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY seg7_hex IS
    PORT (
        DIGIT : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        SEG7 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
END seg7_hex;

ARCHITECTURE Behavioral OF seg7_hex IS
    SIGNAL display_digit : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
    -- Grab our display digit from the value of switches 0 - 3.
    display_digit <= DIGIT(3 DOWNTO 0);
    
    -- Output SEG7 based on our display digit
    WITH display_digit SELECT
        SEG7 <= 
        "11000000" WHEN x"0",
        "11111001" WHEN x"1",
        "10100100" WHEN x"2",
        "10110000" WHEN x"3",
        "10011001" WHEN x"4",
        "10010010" WHEN x"5",
        "10000010" WHEN x"6",
        "11111000" WHEN x"7",
        "10000000" WHEN x"8",
        "10010000" WHEN x"9",
        "10001000" WHEN x"A",
        "10000011" WHEN x"B",
        "11000110" WHEN x"C",
        "10100001" WHEN x"D",
        "10000110" WHEN x"E",
        "10001110" WHEN OTHERS;
END Behavioral;