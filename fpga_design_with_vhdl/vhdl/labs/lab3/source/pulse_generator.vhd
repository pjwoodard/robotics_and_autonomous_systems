---------------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Generates single clock pulses at varying frequencies using a generic max count
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pulse_generator IS
    GENERIC (
        MAX_COUNT : INTEGER RANGE 0 TO 100000000  
    );

    PORT (
        CLK       : IN STD_LOGIC;
        RST       : IN STD_LOGIC;
        PULSE_OUT : OUT STD_LOGIC
    );
END pulse_generator;

ARCHITECTURE Behavioral OF pulse_generator IS
    SIGNAL pulse_count : UNSIGNED(31 DOWNTO 0);
    SIGNAL clear       : STD_LOGIC;
BEGIN
    PROCESS (CLK, RST)
    BEGIN
        IF (RST = '1') THEN
            pulse_count <= (OTHERS => '0');
        ELSIF (rising_edge(CLK)) THEN
            IF (clear = '1') THEN
                pulse_count <= (OTHERS => '0');
            ELSE
                pulse_count <= pulse_count + 1;
            END IF;
        END IF;
    END PROCESS;

    clear <= '1' WHEN (pulse_count = to_unsigned(MAX_COUNT, 32)) ELSE
        '0';
    PULSE_OUT <= clear;
END Behavioral;