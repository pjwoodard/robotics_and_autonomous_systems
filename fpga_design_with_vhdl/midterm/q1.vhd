----------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Q1 on midterm
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY midterm_q1 IS
    PORT (
        D   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        E   : IN STD_LOGIC;
        R   : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        s1  : IN STD_LOGIC;
        F   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        C   : IN STD_LOGIC;
        B   : IN STD_LOGIC;
        Y   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        W   : OUT STD_LOGIC
    );
END midterm_q1;

ARCHITECTURE Behavioral OF midterm_q1 IS
    SIGNAL Q        : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL mux1_out : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL mux2_sel : STD_LOGIC;
BEGIN
    W <= mux2_sel;

    -- select line for our second mux
    mux2_sel <= C OR B;

    -- First mux in our diagram 
    WITH s1 SELECT
        mux1_out <=
        "1001" WHEN '1',
        Q WHEN OTHERS;

    -- Second mux in our diagram
    WITH mux2_sel SELECT
        Y <=
        mux1_out WHEN '0',
        F WHEN OTHERS;

    flop : PROCESS (clk, R)
    BEGIN
        IF (R = '1') THEN
            Q <= (OTHERS => '0');
        ELSIF (rising_edge(clk)) THEN
            IF (E = '1') THEN
                Q <= D;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;