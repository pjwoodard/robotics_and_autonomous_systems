------------------------------------------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Top level driver for lab 3
--              - Instantiates a seven segment controller
--              - Instantiates a 1Hz pulse generator to act as the enable for our shift register
--              - Instantiates a 4-bit wide, 8 depth shift register for scrolling characters across the display
--              - Drives the LEDs with the SW input
--              - Hooks all the components up to common reset (BTNC) and clock, drives seven segment display outputs with module outputs
------------------------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.types.bus_8x4;

ENTITY lab3_top IS
    PORT (
        CLK100MHZ : IN STD_LOGIC;
        BTNC      : IN STD_LOGIC;
        SW        : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        LED       : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        SEG7_CATH : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        AN        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END lab3_top;

ARCHITECTURE behavioral OF lab3_top IS
    SIGNAL pulse_1hz : STD_LOGIC;
    SIGNAL char_bus  : bus_8x4;
BEGIN
    seg7_controller : ENTITY work.seg7_controller
        PORT MAP(
            CLK_100MHZ => CLK100MHZ,
            RST        => BTNC,
            CHAR_BUS   => char_bus,
            SEG7_CATH  => SEG7_CATH,
            AN         => AN
        );

    pulse_generator_1hz : ENTITY work.pulse_generator
        GENERIC MAP(
            MAX_COUNT => 100000000 
        )
        PORT MAP(
            CLK       => CLK100MHZ,
            RST       => BTNC,
            PULSE_OUT => pulse_1hz
        );

    shift_register_8x4bit : ENTITY work.shift_register
        PORT MAP(
            CLK        => CLK100MHZ,
            RST        => BTNC,
            EN         => pulse_1hz,
            SW         => SW(3 DOWNTO 0),
            DISP_OUT   => char_bus
        );

    -- LEDs are driven directly by the switches
    LED <= SW;
END behavioral;