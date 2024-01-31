----------------------------------------------------------------------------------
-- 
-- Testbench for Lab 7 - Sine Wave Generator
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.ALL;
use std.textio.all;

ENTITY lab8_tb IS
END lab8_tb;

ARCHITECTURE rtl OF lab8_tb IS
    SIGNAL reset   : STD_LOGIC;
    SIGNAL clk     : STD_LOGIC;
    SIGNAL sw      : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL btnc    : STD_LOGIC;
    SIGNAL btnu    : STD_LOGIC;
    SIGNAL pwm_out : STD_LOGIC;
    SIGNAL data_in : STD_LOGIC;

    -- File Stuff
    CONSTANT FILE_PATH : STRING := "../initial_music.coe";
    FILE coe_file      : text IS IN FILE_PATH;
BEGIN

    -- Instantiate our module
    lab8_top_group2 : ENTITY work.lab8_top_group2
        PORT MAP(
            CLK100MHZ    => clk,
            SW14         => reset,
            SW15         => '1',
            SW           => sw,
            LED          => OPEN,
            BTNC         => btnc,
            BTNU         => btnu,
            AUD_PWM      => pwm_out,
            AUD_SD       => OPEN,
            UART_TXD_IN  => data_in,
            UART_RXD_OUT => OPEN
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
    
    PROCESS
    BEGIN
        data_in <= '1';
        wait for 20 ns;
        data_in <= '0';
        wait for 20 ns;
    END PROCESS;

    verify_sample_rate_gen : PROCESS
    BEGIN
        sw(1 DOWNTO 0) <= "11";
        -- wait to come out of reset
         WAIT FOR 10 us;

         -- Bring BTNU high
         btnu <= '1';
         WAIT FOR 105 ms;
         btnu <= '0';

         -- Bring BTNC high
        --  btnc <= '1';
        --  WAIT FOR 105 ms;
        --  btnc <= '0';
        WAIT;
    END PROCESS;

END rtl;