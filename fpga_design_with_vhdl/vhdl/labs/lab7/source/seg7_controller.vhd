--------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: This module is responsible for driving the time multiplexing that 
--              to display on the seven segment display allows the correct characters.
--------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.types.bus_8x4;

ENTITY seg7_controller IS
    PORT (
        CLK_100MHZ : IN STD_LOGIC;
        RST        : IN STD_LOGIC;
        CHAR_BUS   : IN bus_8x4;
        SEG7_CATH  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        AN         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END seg7_controller;

ARCHITECTURE Behavioral OF seg7_controller IS
    SIGNAL pulse_1kHz       : STD_LOGIC;
    SIGNAL anode_counter    : UNSIGNED(2 DOWNTO 0);
    SIGNAL digit_to_display : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
    -- Instantiate our seven segment encoder module
    seg7_enc : ENTITY work.seg7_hex
        PORT MAP(
            DIGIT => digit_to_display,
            SEG7  => SEG7_CATH
        );

    --  Instantiate our pulse generator with a max count of 100,000 --  this ensures a 1kHz pulse. 
    --  100,000,000 Hz main clock / 100,000 max count == 1,000 Hz
    pulse_generator : ENTITY work.pulse_generator
        PORT MAP(
            CLK       => CLK_100MHZ,
            RST       => RST,
            MAX_COUNT => to_unsigned(100000, 32),
            PULSE_OUT => pulse_1kHz
        );

    -- Process that maintains a counter to let us know which anode to set
    count_anode : PROCESS (CLK_100MHZ, RST)
    BEGIN
        IF (RST = '1') THEN
            anode_counter <= (OTHERS => '0');
        ELSIF (rising_edge(CLK_100MHZ)) THEN
            IF (pulse_1kHz = '1') THEN
                -- Latching counter that rolls over
                anode_counter <= anode_counter + 1;
            END IF;
        END IF;
    END PROCESS;

    -- Mux that selects which digit to display
    digit_to_display <= CHAR_BUS(to_integer(anode_counter));

    -- Mux that selects which display to light up
    WITH anode_counter SELECT
        AN <=
        "11111110" WHEN "000",
        "11111101" WHEN "001",
        "11111011" WHEN "010",
        "11110111" WHEN "011",
        "11101111" WHEN "100",
        "11011111" WHEN "101",
        "10111111" WHEN "110",
        "01111111" WHEN "111",
        "11111111" WHEN OTHERS;

END Behavioral;