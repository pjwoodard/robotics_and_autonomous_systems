----------------------------------------------------------------------------------
-- 
-- Group 2 testbench for VGA controller
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.ALL;

ENTITY vga_controller_tb IS
END vga_controller_tb;

ARCHITECTURE rtl OF vga_controller_tb IS

  SIGNAL clk                                               : STD_LOGIC;
  SIGNAL reset                                             : STD_LOGIC;
  SIGNAL center_btn, up_btn, down_btn, left_btn, right_btn : STD_LOGIC;
  SIGNAL h_sync, v_sync                                    : STD_LOGIC;
  SIGNAL red, green, blue                                  : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL cathode, anode                                    : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL pulse_25MHz_s                                     : STD_LOGIC;
BEGIN

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

  verify_horizontal_sync : PROCESS
  BEGIN  
    -- wait for hsync to go high and then low to start waiting for our horizontal pulse period
    WAIT UNTIL rising_edge(h_sync);
    WAIT UNTIL falling_edge(h_sync);
    
    -- Check that h sync has gone high to verify T_pw (Pulse Width Time)
    WAIT FOR 3.84 us + 1 ps;
    ASSERT h_sync = '1' REPORT "HSync Pulse Width Time failure" SEVERITY failure;

    -- Check that h sync has gone low again to verify Ts (Sync Pulse Time)
    WAIT FOR 32 us - 1 ps;
    ASSERT h_sync = '0' REPORT "HSync Sync Pulse Time failure" SEVERITY failure;
  END PROCESS;

  verify_vertical_sync : PROCESS
  BEGIN
    -- wait for v_sync to go high and then low
    WAIT UNTIL rising_edge(v_sync);
    WAIT UNTIL falling_edge(v_sync);

    -- Check that v sync has gone low to verify Ts (Sync Pulse Time)
    wait for 16.7 ms;
    ASSERT v_sync = '0' REPORT "VSync Sync Pulse Time failure" SEVERITY failure;

    -- Check that v sync has gone high to verify T_pw (Pulse Width Time)
    WAIT FOR 64 us;
    ASSERT v_sync = '1' REPORT "VSync Sync Pulse Width Time failure" SEVERITY failure;
  END PROCESS;

  vga_controller : ENTITY work.vga_controller
    PORT MAP(
      CLK_100MHZ => clk,
      RST        => reset,
      VGA_HS => h_sync,
      VGA_VS => v_sync,
      VGA_R => red,
      VGA_G => green,
      VGA_B => blue
    );

END rtl;