--------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: This module is responsible for debouncing the input value and outputting a debounced value
--------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY debouncer IS
    PORT (
        CLK : IN STD_LOGIC;
        RST        : IN STD_LOGIC;
        BTN       : IN STD_LOGIC;
        BTN_DB    : OUT STD_LOGIC
    );
END debouncer;

ARCHITECTURE Behavioral OF debouncer IS
    -- Needs to be large enough to count to 1 Million
    SIGNAL db_cntr : UNSIGNED(20 DOWNTO 0);
    SIGNAL debounced_value : STD_LOGIC;
    SIGNAL debounced_value_q : STD_LOGIC;
BEGIN
    debounce : PROCESS (CLK, RST)
    BEGIN
        if(RST = '1') THEN
             db_cntr <= (OTHERS => '0');
             debounced_value <= '0';
             debounced_value_q <= '0';
             BTN_DB <= '0';
        ELSIF (rising_edge(CLK)) THEN
            if(BTN = '1') then
                -- 10 ms until we consider it a clean signal
                if db_cntr < 1000000 then
                    db_cntr <= db_cntr + 1;
                else
                    debounced_value <= '1';
                end if;
            else
                debounced_value <= '0';
                db_cntr <= (OTHERS => '0');
            end if;

            debounced_value_q <= debounced_value;
            BTN_DB <= (debounced_value AND NOT debounced_value_q);
        END IF;
    END PROCESS;
END Behavioral;