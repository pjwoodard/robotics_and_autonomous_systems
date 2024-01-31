----------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Q6 on midterm (verification of answer only)
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY midterm_q6_tb IS
END midterm_q6_tb;

ARCHITECTURE Behavioral OF midterm_q6_tb IS
    SIGNAL A, H1, H2, H3, H4, H5 : signed(7 DOWNTO 0);
BEGIN
    A <= "10100011";

    H1 <= A SLL 4;
    H2 <= A SRL 2;
    H3 <= A ROL 3;
    H4 <= A ROR 8;
    H5 <= A ROR 5;

END Behavioral;