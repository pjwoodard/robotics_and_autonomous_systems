----------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: This module handles the top level logic of button pushes, LEDs, 
--              switches, and the display number for the sevent segment display.
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY lab2_top IS
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
END lab2_top;

ARCHITECTURE Behavioral OF lab2_top IS
    SIGNAL display_digit : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
    -- LEDs just get the switch signals forwarded on irrespective of the value of the buttons
    LED <= SW;

    process_disp_digit : process(SW, BTNC)
    -- declarative part: empty
    begin
        -- Grab our 4-bit digit to display from SW
        -- if BTNC is pressed we force the value to all 0s
        if BTNC = '1' then
            display_digit <= ("0000");
        else
            display_digit <= SW(3 DOWNTO 0);
        end if;
    end process process_disp_digit;

    -- Instantiate our seg7_hex component
    enc : ENTITY work.seg7_hex PORT MAP (
        DIGIT => display_digit,
        SEG7 => SEG7_CATH
        );

    process_active_disp : process(SW, BTNC, BTNU, BTND)
    -- declarative part: empty
    begin
        if BTNU = '1' then
            AN <= ("00001111");
        elsif BTND = '1' then
            AN <= ("11110000");
        elsif BTNC = '1' then
            AN <= ("00000000");
        else
            AN <= NOT(SW(11 DOWNTO 4));
        end if;
    end process process_active_disp;

END Behavioral;