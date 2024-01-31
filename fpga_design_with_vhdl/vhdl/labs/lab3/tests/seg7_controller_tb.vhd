--------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Testbench for driving the seven segment encoder
--------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY seg7_controller_tb IS
END seg7_controller_tb;

ARCHITECTURE testbench OF seg7_controller_tb IS
    SIGNAL clock        : STD_LOGIC;
    SIGNAL reset        : STD_LOGIC;
    SIGNAL encoded_char : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL chosen_anode : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
    seg7_controller_uut : ENTITY work.seg7_controller
        PORT MAP(
            CLK_100MHZ => clock,
            RST        => reset,
            CHAR_BUS   => ("0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111"),
            SEG7_CATH  => encoded_char,
            AN         => chosen_anode
        );

    reset <= '0', '1' AFTER 20 ns, '0' AFTER 100 ns;

    clk : PROCESS
    BEGIN
        clock <= '1';
        WAIT FOR 5 ns;
        clock <= '0';
        WAIT FOR 5 ns;
    END PROCESS;
END testbench;