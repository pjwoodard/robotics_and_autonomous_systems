--------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Test bench for testing a couple variations of the pulse generator module
--              at different frequencies. 
--------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;

ENTITY pulse_generator_tb IS
END pulse_generator_tb;


ARCHITECTURE testbench OF pulse_generator_tb IS
    SIGNAL clock    : STD_LOGIC;
    SIGNAL reset      : STD_LOGIC;
    SIGNAL pulse_1kHz : STD_LOGIC;
    SIGNAL pulse_1Hz  : STD_LOGIC;
BEGIN
    pulse_generator_1kHz_uut : ENTITY work.pulse_generator
        GENERIC MAP(
            MAX_COUNT => 100000
        )
        PORT MAP(
            CLK       => clock,
            RST       => reset,
            PULSE_OUT => pulse_1kHz
        );

    pulse_generator_1Hz_uut : ENTITY work.pulse_generator
        GENERIC MAP(
            MAX_COUNT => 100000000
        )
        PORT MAP(
            CLK       => clock,
            RST       => reset,
            PULSE_OUT => pulse_1Hz
        );

    reset <= '0', '1' AFTER 20 ns, '0' AFTER 100 ns;

    clk_proc : PROCESS
    BEGIN
        clock <= '1';
        WAIT FOR 5 ns;
        clock <= '0';
        WAIT FOR 5 ns;
    END PROCESS;

    verify_pulses : PROCESS
    BEGIN
        -- Wait until reset is deasserted
        WAIT FOR 100 ns;
    
        WAIT FOR 1 ms;

        ASSERT pulse_1kHz = '1' REPORT "1kHz Pulse has incorrect timing" SEVERITY failure;

        wait until rising_edge(clock);
        wait until rising_edge(clock);

        -- check that our pulse only lasted one clock cycle
        ASSERT pulse_1kHz = '0' REPORT "1kHz Pulse longer than one clock cycle" SEVERITY failure;
        
        -- We waited 1 ms + 20 ns (2 clock periods) already
        WAIT FOR 1000 ms - (1 ms + 10 ns);
        ASSERT pulse_1Hz = '1' REPORT "1Hz Pulse has incorrect timing" SEVERITY failure;

        wait until rising_edge(clock);
        wait until rising_edge(clock);

        -- check that our pulse only lasted one clock cycle
        ASSERT pulse_1Hz = '0' REPORT "1Hz Pulse longer than one clock cycle" SEVERITY failure;
        
        std.env.stop;
    END PROCESS;
END testbench;