----------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Q13 on midterm
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY midterm_q13_tb IS
END midterm_q13_tb;

ARCHITECTURE Behavioral OF midterm_q13_tb IS
    CONSTANT PERIOD : TIME := 20 ns;
    SIGNAL clk      : STD_LOGIC;
    SIGNAL reset    : STD_LOGIC;

    SIGNAL signal_change_cntr : UNSIGNED(15 DOWNTO 0);
    SIGNAL led                : STD_LOGIC;
    SIGNAL sync_pulse         : STD_LOGIC;
BEGIN
    --Main testbench process
    PROCESS
    BEGIN
        reset <= '1';
        WAIT FOR 100 ns;
        reset <= '0';
        sync_pulse <= '0';


        wait for PERIOD;

        wait until rising_edge(clk);
        sync_pulse <= '1';
        
        wait for PERIOD * 3;
        sync_pulse <= '0';
        wait for PERIOD * 2;
        sync_pulse <= '1';
        wait for PERIOD;
        sync_pulse <= '0';
        wait for PERIOD;
        sync_pulse <= '1';
        wait for PERIOD * 2;
        sync_pulse <= '0';
        wait for PERIOD * 2;
        sync_pulse <= '1';
        wait for PERIOD * 5;
        sync_pulse <= '0';
        WAIT;
    END PROCESS;

    -- Clock generation process
    clock_50MHz : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR PERIOD / 2;
        clk <= '1';
        WAIT FOR PERIOD / 2;
    END PROCESS;

    -- LED Toggle
    led_toggle : PROCESS (clk, reset, sync_pulse, led, signal_change_cntr)
    BEGIN
        IF (reset = '1') THEN
            led <= '0';
            signal_change_cntr <= (OTHERS => '0');
        ELSIF (rising_edge(clk)) THEN
            IF rising_edge(sync_pulse) THEN
                -- Turn LED on and increment our counter
                led <= NOT(led);
                signal_change_cntr <= signal_change_cntr + 1;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;