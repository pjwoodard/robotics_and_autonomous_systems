----------------------------------------------------------------------------------
-- 
-- testbench for pwm generator
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity lab8_top_group2_tb is
end lab8_top_group2_tb;

architecture rtl of lab8_top_group2_tb is

  signal clk, reset, btnc     : std_logic;

begin
  
  -- stimulate signals
  reset <= '0', '1' after 10ns, '0' after 20ns;
  btnc <= '0', '1' after 30ns, '0' after 100001003ns;

  -- generate 100MHz clock (10ns cycle)
  process
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;

  lab8_top_group2_inst : entity work.lab8_top_group2
  Port map (
        CLK100MHZ       => clk, -- IN STD_LOGIC;
        SW14            => reset, -- IN STD_LOGIC; -- SW14 is used as the reset, constraints may need to be changed
        LED             => open, -- OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        SW              => "11",-- IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- defines number of playback
        SW15            => '0',-- IN STD_LOGIC;                    -- this turns on the audio output
        BTNC            => btnc, -- IN STD_LOGIC; -- start playback
        BTNU            => '0',-- IN STD_LOGIC; -- load new values into BRAM
        AUD_PWM         => open,-- OUT STD_LOGIC;
        AUD_SD          => open,-- OUT STD_LOGIC;
        UART_TXD_IN     => open,-- OUT STD_LOGIC;
        UART_RXD_OUT    => '0'-- IN STD_LOGIC
  );
end rtl;