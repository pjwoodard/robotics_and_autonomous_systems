----------------------------------------------------------------------------------
-- 
-- Group 2 testbench for VGA controller
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.ALL;

ENTITY debouncer_tb IS
END debouncer_tb;

ARCHITECTURE rtl OF debouncer_tb IS
    SIGNAL reset : STD_LOGIC;
    SIGNAL clk : STD_LOGIC;
    SIGNAL button_in : STD_LOGIC;
    SIGNAL debounce_out : STD_LOGIC;
BEGIN

  -- stimulate reset
  reset <= '0', '1' AFTER 10ns, '0' AFTER 20ns;
  
    -- Generate our button press
    process
    begin
        button_in <= '1';
        wait for 15 ms;
        button_in <= '0';
        wait for 5 ms;
    end process;
    
  -- generate 100MHz clock (10ns cycle)
  PROCESS
  BEGIN
    clk <= '1';
    WAIT FOR 5 ns;
    clk <= '0';
    WAIT FOR 5 ns;
  END PROCESS;

  debouncer : ENTITY work.debouncer
    PORT MAP(
      CLK => clk,
      RST => reset,
      BTN => button_in,
      BTN_DB => debounce_out
    );
    
    verify_debounce : PROCESS
    BEGIN 
        -- wait to come out of reset
        wait for 10 us;
    END PROCESS;

END rtl;