----------------------------------------------------------------------------------
-- 
-- Testbench for Lab 7 - Sine Wave Generator
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.ALL;

ENTITY lab7_tb IS
END lab7_tb;

ARCHITECTURE rtl OF lab7_tb IS
    SIGNAL reset : STD_LOGIC;
    SIGNAL clk   : STD_LOGIC;
    SIGNAL sw    : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN

    -- Instantiate our module
    lab7_top : ENTITY work.lab7_top
        PORT MAP(
            CLK_100MHZ => clk,
            RESET      => reset,
            SW         => sw
        );

    -- stimulate reset
    reset <= '0', '1' AFTER 10ns, '0' AFTER 20ns;

    -- generate 100MHz clock (10ns cycle)
    PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR 5 ns;
        clk <= '0';
        WAIT FOR 5 ns;
    END PROCESS;

    verify_sample_rate_gen : PROCESS
    BEGIN
        sw(15 DOWNTO 0) <= (OTHERS => '0');

        sw(2 DOWNTO 0) <= "010";
        sw(5 DOWNTO 3) <= "111";
    
        -- wait to come out of reset
        WAIT FOR 10 us;
        
        WAIT FOR 1 ms;
        
        sw(2 DOWNTO 0) <= "001";
        
        wait for 2 ms;
        
    END PROCESS;

END rtl;