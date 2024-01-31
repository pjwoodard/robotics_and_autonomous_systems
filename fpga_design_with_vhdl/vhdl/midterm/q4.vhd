----------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Q4 on midterm (verification of answer only)
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY midterm_q4 IS
END midterm_q4;

ARCHITECTURE Behavioral OF midterm_q4 IS
BEGIN
    -- Code A
    PROCESS (D, E)
    BEGIN
        IF (E = '1') THEN
            Q1 <= D;
        END IF;
    END PROCESS;

    -- Code B
    PROCESS (C)
    BEGIN
        IF (rising_edge(C)) THEN
            IF (E = '1') THEN
                Q2 <= D;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;