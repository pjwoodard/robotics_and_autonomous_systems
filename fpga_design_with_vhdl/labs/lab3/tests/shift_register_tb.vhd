--------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: 
--------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.types.bus_8x4;

ENTITY shift_register_tb IS
END shift_register_tb;

ARCHITECTURE Testbench OF shift_register_tb IS
    SIGNAL clock     : STD_LOGIC;
    SIGNAL reset     : STD_LOGIC;
    SIGNAL pulse_1hz : STD_LOGIC;
    SIGNAL char_bus  : bus_8x4;
    SIGNAL switches  : UNSIGNED(3 DOWNTO 0) := "0000";
BEGIN
    reset <= '0', '1' AFTER 20 ns, '0' AFTER 100 ns;

    clk : PROCESS
    BEGIN
        clock <= '1';
        WAIT FOR 5 ns;
        clock <= '0';
        WAIT FOR 5 ns;
    END PROCESS;

    pulse : PROCESS
    BEGIN
        pulse_1hz <= '1';
        WAIT FOR 10ns;
        pulse_1hz <= '0';
        switches  <= switches + 1;
        WAIT FOR 1 ms;
    END PROCESS;

    shift_register_8bit : ENTITY work.shift_register
        PORT MAP(
            CLK        => clock,
            RST        => reset,
            EN         => pulse_1hz,
            SW         => STD_LOGIC_VECTOR(switches),
            DISP_OUT   => char_bus
        );
END Testbench;