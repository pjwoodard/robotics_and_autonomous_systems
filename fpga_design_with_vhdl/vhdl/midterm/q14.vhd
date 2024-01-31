----------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Q14 on midterm
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY fsm_top_level IS
    PORT (
        clk     : IN STD_LOGIC; -- 100MHz input clock
        reset   : IN STD_LOGIC; -- Active High Async Reset
        fsm_in  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        fsm_out : OUT STD_LOGIC
    );
END fsm_top_level;

ARCHITECTURE rtl OF fsm_top_level IS
    TYPE q14_state_t IS (s0, s1, s2, s3);

    SIGNAL cur_state : q14_state_t;
    SIGNAL next_state : q14_state_t;
BEGIN
    a14_state_machine : PROCESS (cur_state, next_state, fsm_in)
    BEGIN
        next_state <= cur_state;
        CASE cur_state IS
            WHEN s0 =>
                fsm_out <= '0';

                if (fsm_in = "01") then 
                    next_state <= s1;
                end if;
            WHEN s1 =>
                fsm_out <= '0';

                if (fsm_in = "10") then 
                    next_state <= s2;
                elsif (fsm_in /= "01") then
                    next_state <= s0;
                end if;
            WHEN s2 =>
                fsm_out <= '0';

                if(fsm_in = "01") then 
                    next_state <= s1;
                elsif(fsm_in = "11") then
                    next_state <= s3;
                else 
                    next_state <= s0;
                end if;
            WHEN s3 =>
                fsm_out <= '1';

                if(fsm_in = "01") then
                    next_state <= s1;
                else 
                    next_state <= s0;
                end if;
        END CASE;
    END PROCESS;

    -- Command state driver process
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            cur_state     <= s0;
        ELSIF (rising_edge(clk)) THEN
            cur_state     <= next_state;
        END IF;
    END PROCESS;

END rtl;