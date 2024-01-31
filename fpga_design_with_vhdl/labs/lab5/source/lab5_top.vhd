---------------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Generates single clock pulses at varying frequencies using a generic max count
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.types.bus_8x4;

ENTITY lab5_top IS
    PORT (
        CLK_100MHZ : IN STD_LOGIC;
        RESET      : IN STD_LOGIC;
        BTNU       : IN STD_LOGIC;
        BTND       : IN STD_LOGIC;
        BTNL       : IN STD_LOGIC;
        BTNR       : IN STD_LOGIC;
        ACCEL_EN   : IN STD_LOGIC;
        SW         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        ACL_SCLK   : OUT STD_LOGIC;
        ACL_CSN    : OUT STD_LOGIC;
        ACL_MOSI   : OUT STD_LOGIC;
        ACL_MISO   : IN STD_LOGIC;
        VGA_HS     : OUT STD_LOGIC;
        VGA_VS     : OUT STD_LOGIC;
        VGA_R      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        VGA_G      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        VGA_B      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SEG7_CATH  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        AN         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END lab5_top;

ARCHITECTURE Behavioral OF lab5_top IS
    SIGNAL accel_id_ad           : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL accel_id_1d           : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL accel_x_data          : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL accel_y_data          : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL accel_z_data          : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL command_up            : STD_LOGIC;
    SIGNAL command_down          : STD_LOGIC;
    SIGNAL command_left          : STD_LOGIC;
    SIGNAL command_right         : STD_LOGIC;
    SIGNAL accel_up_input        : STD_LOGIC;
    SIGNAL accel_down_input      : STD_LOGIC;
    SIGNAL accel_right_input     : STD_LOGIC;
    SIGNAL accel_left_input      : STD_LOGIC;
    SIGNAL accel_data_to_display : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL display_array         : bus_8x4;
    SIGNAL red_square_x          : UNSIGNED(7 DOWNTO 0);
    SIGNAL red_square_y          : UNSIGNED(7 DOWNTO 0);
BEGIN
    
    -- Controls which input to choose from when driving the up/down/left/right controls for our VGA controller 
    -- Either the buttons or the accelerometer based on ACCEL_EN (SW[1])
    accel_up_input <= '1' WHEN (unsigned(accel_x_data) <= x"FA" AND unsigned(accel_x_data) >= x"E0") ELSE
        '0';
    command_up <= BTNU WHEN (ACCEL_EN = '0') ELSE
        accel_up_input;

    accel_down_input <= '1' WHEN (unsigned(accel_x_data) <= x"30" AND unsigned(accel_x_data) >= x"15") ELSE
        '0';
    command_down <= BTND WHEN (ACCEL_EN = '0') ELSE
        accel_down_input;

    accel_right_input <= '1' WHEN (unsigned(accel_y_data) <= x"FA" AND unsigned(accel_y_data) >= x"E0") ELSE
        '0';
    command_right <= BTNR WHEN (ACCEL_EN = '0') ELSE
        accel_right_input;

    accel_left_input <= '1' WHEN (unsigned(accel_y_data) <= x"30" AND unsigned(accel_y_data) >= x"15") ELSE
        '0';
    command_left <= BTNL WHEN (ACCEL_EN = '0') ELSE
        accel_left_input;

    -- Use our switch input to decide which accel data to display on our 7 segment display
    WITH SW SELECT
        accel_data_to_display <=
        accel_id_ad WHEN "00",
        accel_x_data WHEN "01",
        accel_y_data WHEN "10",
        accel_z_data WHEN "11",
        x"00" WHEN OTHERS;

    -- Displays red square coordinates on our 7 segment display as well as our accelerometer data
    display_red_square_coordinates : PROCESS (accel_id_ad, accel_id_1d, red_square_x, red_square_y, accel_data_to_display)
    BEGIN
        display_array <=
            (accel_id_1d(7 DOWNTO 4),
            accel_id_1d(3 DOWNTO 0),
            accel_data_to_display(7 DOWNTO 4),
            accel_data_to_display(3 DOWNTO 0),
            STD_LOGIC_VECTOR(red_square_x(7 DOWNTO 4)),
            STD_LOGIC_VECTOR(red_square_x(3 DOWNTO 0)),
            STD_LOGIC_VECTOR(red_square_y(7 DOWNTO 4)),
            STD_LOGIC_VECTOR(red_square_y(3 DOWNTO 0)));
    END PROCESS;

    seg7_controller : ENTITY work.seg7_controller
        PORT MAP(
            CLK_100MHZ => CLK_100MHZ,
            RST        => RESET,
            CHAR_BUS   => display_array,
            SEG7_CATH  => SEG7_CATH,
            AN         => AN
        );

    accel_spi_controller : ENTITY work.accel_spi_rw
        PORT MAP(
            CLK    => CLK_100MHZ,
            RESET  => RESET,
            ID_AD  => accel_id_ad,
            ID_1D  => accel_id_1d,
            DATA_X => accel_x_data,
            DATA_Y => accel_y_data,
            DATA_Z => accel_z_data,
            SCLK   => ACL_SCLK,
            CSb    => ACL_CSN,
            MISO   => ACL_MISO,
            MOSI   => ACL_MOSI
        );

    vga_controller : ENTITY work.vga_controller
        PORT MAP(
            CLK          => CLK_100MHZ,
            RESET        => RESET,
            BTNU         => command_up,
            BTND         => command_down,
            BTNL         => command_left,
            BTNR         => command_right,
            RED_SQUARE_X => red_square_x,
            RED_SQUARE_Y => red_square_y,
            VGA_HS       => VGA_HS,
            VGA_VS       => VGA_VS,
            VGA_R        => VGA_R,
            VGA_G        => VGA_G,
            VGA_B        => VGA_B
        );
END Behavioral;