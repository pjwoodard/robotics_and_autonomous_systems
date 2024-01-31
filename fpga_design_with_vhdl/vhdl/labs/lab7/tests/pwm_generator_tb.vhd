----------------------------------------------------------------------------------
-- 
-- Testbench for Lab 7 - PWM Generator 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.ALL;

ENTITY pwm_generator_tb IS
END pwm_generator_tb;

ARCHITECTURE rtl OF pwm_generator_tb IS
    SIGNAL reset : STD_LOGIC;
    SIGNAL clk   : STD_LOGIC;
    SIGNAL sw    : STD_LOGIC_VECTOR(2 DOWNTO 0);

    type integer_array is array (0 to 3) of integer;
    constant duty_cycle_values: integer_array := (0, 256, 512, 1023);

    SIGNAL pwm_outputs : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN

    generate_pwms:
        for i in integer_array'range generate
            -- Instantiate our module
            pwm_gen : ENTITY work.pwm_generator
                GENERIC MAP(
                    PWM_RESOLUTION => 10
                )
                PORT MAP(
                    CLK => clk,
                    RST => reset,
                    DUTY_CYCLE => std_logic_vector(to_unsigned(duty_cycle_values(i), 10)),
                    PWM_OUT => pwm_outputs(i)
                );
    end generate;

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
        -- wait to come out of reset
        WAIT FOR 10 us;
    END PROCESS;

END rtl;