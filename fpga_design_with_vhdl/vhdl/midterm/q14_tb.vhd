----------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Q14 on midterm (testbench)
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY midterm_q14_tb IS
END midterm_q14_tb;

ARCHITECTURE Behavioral OF midterm_q14_tb IS
    CONSTANT PERIOD : TIME := 20 ns;
    SIGNAL clk      : STD_LOGIC;
    SIGNAL reset    : STD_LOGIC;
    SIGNAL fsm_in   : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL fsm_out  : STD_LOGIC;
BEGIN
	fsm : entity work.fsm_top_level port map (
        clk => clk,
        reset => reset,
        fsm_in => fsm_in,
        fsm_out => fsm_out
    );

    --Main testbench process
    PROCESS
    BEGIN
        reset <= '1';
        WAIT FOR 100 ns;
        reset <= '0';

        wait until rising_edge(clk);
        -- Go to state 1
        fsm_in <= "01";

        -- wait for a bit
        wait for PERIOD * 5; 

        fsm_in <= "11";
        WAIT FOR PERIOD * 2;

        -- Make sure we go back to s0
        fsm_in <= "01";
        WAIT FOR PERIOD;

        fsm_in <= "10";
        WAIT FOR PERIOD;

        fsm_in <= "11";
        WAIT FOR PERIOD;

        fsm_in <= "01";
        WAIT FOR PERIOD;

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
END Behavioral;