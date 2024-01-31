---------------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Pulse Width Modulation Generator
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pwm_generator IS
    GENERIC (
        PWM_RESOLUTION : INTEGER
    );
    PORT (
        CLK        : IN STD_LOGIC;
        RST        : IN STD_LOGIC;
        DUTY_CYCLE : IN STD_LOGIC_VECTOR(PWM_RESOLUTION - 1 DOWNTO 0);
        PWM_OUT    : OUT STD_LOGIC
    );
END pwm_generator;

ARCHITECTURE Behavioral OF pwm_generator IS
    SIGNAL counter : UNSIGNED(PWM_RESOLUTION - 1 DOWNTO 0);
BEGIN
    pwm_output : PROCESS (counter, DUTY_CYCLE)
    BEGIN
        IF (counter < unsigned(DUTY_CYCLE)) THEN
            PWM_OUT <= '1';
        ELSIF (counter >= unsigned(DUTY_CYCLE)) THEN
            PWM_OUT <= '0';
        ELSIF (counter = counter'high) THEN
            PWM_OUT <= '0';
        ELSE
            PWM_OUT <= '0';
        END IF;
    END PROCESS;

    generate_pwm : PROCESS (CLK, RST, DUTY_CYCLE)
    BEGIN
        IF (RST = '1') THEN
            counter <= (OTHERS => '0');
        ELSIF (rising_edge(CLK)) THEN
            counter <= counter + 1;
        END IF;
    END PROCESS;
END Behavioral;