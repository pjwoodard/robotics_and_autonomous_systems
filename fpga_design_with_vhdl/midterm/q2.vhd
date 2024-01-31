----------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Q2 on midterm
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY midterm_q2 IS
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        EN : IN STD_LOGIC
    );
END midterm_q2;

ARCHITECTURE Behavioral OF midterm_q2 IS
    SIGNAL counter : UNSIGNED(7 DOWNTO 0);
BEGIN
    PROCESS (CLK, RST)
    BEGIN
        IF (RST = '1') THEN
            counter <= (OTHERS => '0');
        ELSIF (rising_edge(CLK)) THEN
            IF (EN = '1') THEN
                counter <= counter + 1;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;