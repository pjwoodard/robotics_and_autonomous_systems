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
        CLK       : IN STD_LOGIC;
        RST       : IN STD_LOGIC;
        DUTY_CYCLE : IN STD_LOGIC_VECTOR(PWM_RESOLUTION-1 DOWNTO 0);
        PWM_OUT : OUT STD_LOGIC
    );
END pwm_generator;

ARCHITECTURE Behavioral OF pwm_generator IS
    SIGNAL counter : UNSIGNED(PWM_RESOLUTION-1 DOWNTO 0);
BEGIN
    pwm_output : PROCESS(counter, DUTY_CYCLE)
    BEGIN
        if (counter < unsigned(DUTY_CYCLE)) then 
            PWM_OUT <= '1';
        elsif (counter >= unsigned(DUTY_CYCLE)) then
            PWM_OUT <= '0';
        elsif (counter = counter'high) then
            PWM_OUT <= '0';
        else
            PWM_OUT <= '0';
        end if;
    END PROCESS;

    generate_pwm : PROCESS(CLK, RST, DUTY_CYCLE)
    BEGIN
        if(RST = '1') THEN
            counter <= (OTHERS => '0');
        elsif(rising_edge(CLK)) then
            counter <= counter + 1; 
        end if;
    END PROCESS;
END Behavioral;