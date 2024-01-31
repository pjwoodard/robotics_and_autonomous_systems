--------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: This module is responsible for controlling the VGA output including 
--              management of the HSYNC/VSYNC signals, screen coloring, and input
--              button management for controlling our moving tile.
--------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.types.bus_8x4;

ENTITY vga_controller IS
    PORT (
        CLK_100MHZ : IN STD_LOGIC;
        RST        : IN STD_LOGIC;
        BTNU       : IN STD_LOGIC;
        BTND       : IN STD_LOGIC;
        BTNL       : IN STD_LOGIC;
        BTNR       : IN STD_LOGIC;
        VGA_HS     : OUT STD_LOGIC;
        VGA_VS     : OUT STD_LOGIC;
        VGA_R      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        VGA_G      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        VGA_B      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SEG7_CATH : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        AN        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END vga_controller;

ARCHITECTURE Behavioral OF vga_controller IS
    SIGNAL hsync_pulse_counter : UNSIGNED(9 DOWNTO 0);
    SIGNAL vsync_pulse_counter : UNSIGNED(9 DOWNTO 0);
    SIGNAL en25                : STD_LOGIC;
    SIGNAL vga_red_t           : STD_LOGIC;
    SIGNAL vga_blue_t          : STD_LOGIC;
    SIGNAL vga_green_t         : STD_LOGIC;
    SIGNAL red_square_x        : UNSIGNED(7 DOWNTO 0);
    SIGNAL red_square_y        : UNSIGNED(7 DOWNTO 0);
    SIGNAL debounced_up      : STD_LOGIC;
    SIGNAL debounced_down      : STD_LOGIC;
    SIGNAL debounced_right     : STD_LOGIC;
    SIGNAL debounced_left      : STD_LOGIC;
    SIGNAL display_array       : bus_8x4;
BEGIN
     seg7_controller : ENTITY work.seg7_controller
        PORT MAP(
            CLK_100MHZ => CLK_100MHZ,
            RST        => RST,
            CHAR_BUS  => display_array,
            SEG7_CATH  => SEG7_CATH,
            AN         => AN
        );

    pulse_generator : ENTITY work.pulse_generator
        GENERIC MAP(
            MAX_COUNT => 4
        )
        PORT MAP(
            CLK       => CLK_100MHZ,
            RST       => RST,
            PULSE_OUT => en25
        );

    -- Probably could have gotten fancy and had this debounce all the buttons, but this only does one at once.
    debounce_up : ENTITY work.debouncer
        PORT MAP(
            CLK    => CLK_100MHZ,
            RST    => RST,
            BTN    => BTNU,
            BTN_DB => debounced_up
        );
    
    debounce_down : ENTITY work.debouncer
        PORT MAP(
            CLK    => CLK_100MHZ,
            RST    => RST,
            BTN    => BTND,
            BTN_DB => debounced_down
        );
        
     debounce_right : ENTITY work.debouncer
        PORT MAP(
            CLK    => CLK_100MHZ,
            RST    => RST,
            BTN    => BTNR,
            BTN_DB => debounced_right
        );
        
     debounce_left : ENTITY work.debouncer
        PORT MAP(
            CLK    => CLK_100MHZ,
            RST    => RST,
            BTN    => BTNL,
            BTN_DB => debounced_left
        );
    
    VGA_R <= (OTHERS => vga_red_t);
    VGA_G <= (OTHERS => vga_green_t);
    VGA_B <= (OTHERS => vga_blue_t);

    VGA_HS <= '0' WHEN (hsync_pulse_counter < 752 AND hsync_pulse_counter >= 656) ELSE
        '1';
    VGA_VS <= '0' WHEN (vsync_pulse_counter < 492 AND vsync_pulse_counter >= 490) ELSE
        '1';

    display_red_square_coordinates : PROCESS(red_square_x, red_square_y)
    BEGIN   
        display_array <= ("0000", "0000", "0000", "0000",
                          std_logic_vector(red_square_x(7 DOWNTO 4)), 
                          std_logic_vector(red_square_x(3 DOWNTO 0)), 
                          std_logic_vector(red_square_y(7 DOWNTO 4)), 
                          std_logic_vector(red_square_y(3 DOWNTO 0)));
    END PROCESS;

    track_red_square : PROCESS (CLK_100MHZ, RST, debounced_down, debounced_right)
    BEGIN
        IF (RST = '1') THEN
            red_square_x <= (OTHERS => '0');
            red_square_y <= (OTHERS => '0');
        ELSIF (rising_edge(CLK_100MHZ)) THEN
            -- Detect if a button was pressed and either increment or roll over our x, y coordinates
            IF (debounced_right = '1') THEN
                IF (red_square_x < x"13") THEN
                    red_square_x <= red_square_x + 1;
                ELSE
                    red_square_x <= (OTHERS => '0');
                END IF;
            ELSIF (debounced_left = '1') THEN
                IF (red_square_x <= x"00") THEN
                    red_square_x <= x"13";
                ELSE
                    red_square_x <= red_square_x - 1;
                END IF;
            ELSIF (debounced_up = '1') THEN
                IF (red_square_y <= x"00") THEN
                    red_square_y <= x"0E";
                ELSE
                    red_square_y <= red_square_y - 1;
                END IF;
            ELSIF (debounced_down = '1') THEN 
                IF (red_square_y < x"0E") THEN
                    red_square_y <= red_square_y + 1;
                ELSE
                    red_square_y <= (OTHERS => '0');
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- These signals need to swap values whenever the square pixel counter rolls over (= '0')
    display_checker_board : PROCESS (hsync_pulse_counter, vsync_pulse_counter, red_square_x, red_square_y)
    BEGIN
        -- Check for displayable region [0, 640) and [0, 480)
        IF (hsync_pulse_counter < 640 AND vsync_pulse_counter < 480) THEN
            -- Our red square is 32x32 and anchored at the top left corner of the square, so we draw our red square out from there
            -- We multiply by 32 as that is the number of pixels we jump for each coordinate movement of our red square
            IF ((hsync_pulse_counter >= (red_square_x * 32) AND hsync_pulse_counter <= (red_square_x * 32) + 32) AND ((vsync_pulse_counter >= (red_square_y * 32) AND vsync_pulse_counter <= (red_square_y * 32)+ 32))) THEN
                -- Display our red square
                vga_red_t   <= '1';
                vga_green_t <= '0';
                vga_blue_t  <= '0';
            ELSIF ((hsync_pulse_counter(5) XOR vsync_pulse_counter(5)) = '1') THEN
                -- Display our blue square
                vga_red_t   <= '0';
                vga_green_t <= '0';
                vga_blue_t  <= '1';
            ELSIF ((hsync_pulse_counter(5) XOR vsync_pulse_counter(5)) = '0') THEN
                -- Display our green square
                vga_red_t   <= '0';
                vga_blue_t  <= '0';
                vga_green_t <= '1';
            END IF;
        ELSE
            -- We are outside of the displayable region, everything is driven low
            vga_red_t   <= '0';
            vga_green_t <= '0';
            vga_blue_t  <= '0';
        END IF;
    END PROCESS;

    horizontal_counter : PROCESS (CLK_100MHZ, RST, en25, hsync_pulse_counter)
    BEGIN
        IF (RST = '1') THEN
            hsync_pulse_counter <= (OTHERS => '0');
        ELSIF (rising_edge(CLK_100MHZ)) THEN
            IF (en25 = '1') THEN
                IF (to_integer(hsync_pulse_counter) = 799) THEN
                    hsync_pulse_counter <= (OTHERS => '0');
                ELSE
                    hsync_pulse_counter <= hsync_pulse_counter + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    vertical_counter : PROCESS (CLK_100MHZ, RST, en25, vsync_pulse_counter)
    BEGIN
        IF (RST = '1') THEN
            vsync_pulse_counter <= (OTHERS => '0');
        ELSIF (rising_edge(CLK_100MHZ)) THEN
            IF (en25 = '1' AND to_integer(hsync_pulse_counter) = 799) THEN
                IF (to_integer(vsync_pulse_counter) = 520) THEN
                    vsync_pulse_counter <= (OTHERS => '0');
                ELSE
                    vsync_pulse_counter <= vsync_pulse_counter + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;