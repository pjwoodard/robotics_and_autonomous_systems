---------------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Generates single clock pulses at varying frequencies using a generic max count
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pulse_generator IS
    PORT (
        CLK       : IN STD_LOGIC;
        RST       : IN STD_LOGIC;
        MAX_COUNT : IN UNSIGNED(31 DOWNTO 0);
        PULSE_OUT : OUT STD_LOGIC
    );
END pulse_generator;

ARCHITECTURE Behavioral OF pulse_generator IS
    SIGNAL pulse_count    : UNSIGNED(31 DOWNTO 0);
    SIGNAL clear          : STD_LOGIC;
    SIGNAL saved_value : UNSIGNED(31 DOWNTO 0);
    SIGNAL prev_value : UNSIGNED(31 DOWNTO 0);
BEGIN
    PROCESS (CLK, RST, MAX_COUNT, pulse_count, prev_value, saved_value, clear)
    BEGIN
        IF (RST = '1') THEN
            prev_value <= MAX_COUNT;
            saved_value <= MAX_COUNT;
            pulse_count <= (OTHERS => '0');
        ELSIF (rising_edge(CLK)) THEN
            IF (clear = '1' OR prev_value /= MAX_COUNT) THEN
                pulse_count <= (OTHERS => '0');
                prev_value <= MAX_COUNT;
            ELSE
                saved_value <= MAX_COUNT;
                prev_value <= saved_value;
                pulse_count <= pulse_count + 1;
            END IF;
        END IF;
    END PROCESS;

    clear <= '1' WHEN (pulse_count = MAX_COUNT - 1) ELSE
        '0';
    PULSE_OUT <= clear;
END Behavioral;