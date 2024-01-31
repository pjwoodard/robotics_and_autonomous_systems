----------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: This module handles the top level logic of button pushes, LEDs, 
--              switches, and the display number for the sevent segment display.
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY lab1_top IS
    PORT (
        --Push Buttons
        BTNC : IN STD_LOGIC;
        BTND : IN STD_LOGIC;
        BTNU : IN STD_LOGIC;
        --Switches (16 Switches)
        SW : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        --LEDs (16 LEDs)
        LED : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        --Seg7 Display Signals
        SEG7_CATH : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        AN : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
END lab1_top;

ARCHITECTURE Behavioral OF lab1_top IS
    SIGNAL display_digit : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
    -- Grab our 4-bit digit to display from SW
    -- if BTNC is pressed we force the value to all 0s
    display_digit <= ("0000") WHEN BTNC = '1' ELSE SW(3 DOWNTO 0);

    -- Instantiate our seg7_hex component
    enc : ENTITY work.seg7_hex PORT MAP (
        DIGIT => display_digit,
        SEG7 => SEG7_CATH
        );

    -- Determine active display based on SW11 - SW4, and the push buttons
    AN <=
        ("00001111") WHEN BTNU = '1' ELSE
        ("11110000") WHEN BTND = '1' ELSE
        ("00000000") WHEN BTNC = '1' ELSE
        NOT(SW(11 DOWNTO 4));

    -- LEDs just get the switch signals forwarded on irrespective of the value of the buttons
    LED <= SW;

END Behavioral;