--------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Acts as a 8 depth, 4-bit width shift register with an aynchronous reset 
--              and an enable bit.          
--------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

use work.types.bus_8x4;

ENTITY shift_register IS
    PORT (
        CLK        : IN STD_LOGIC;
        RST        : IN STD_LOGIC;
        EN         : IN STD_LOGIC;
        SW         : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        DISP_OUT   : OUT bus_8x4
    );
END shift_register;

ARCHITECTURE Behavioral OF shift_register IS
    -- Our shift register is an 8 depth, 4-bit width shift register 
    SIGNAL shift_reg : bus_8x4;
BEGIN
    -- Drive our display "bus" output with our shift register
    DISP_OUT <= shift_reg;

    PROCESS (CLK, RST)
    BEGIN
        IF (RST = '1') THEN
            shift_reg <= (OTHERS => (OTHERS => '0'));
        ELSIF (rising_edge(CLK)) THEN
            IF (EN = '1') THEN
                 -- Do the actual left shifting of our signals
                 FOR i IN shift_reg'high DOWNTO shift_reg'low + 1 LOOP
                     shift_reg(i) <= shift_reg(i - 1);
                 END LOOP;

                 -- Shift new value in at the bottom, increment our counter
                 shift_reg(shift_reg'low) <= SW;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;