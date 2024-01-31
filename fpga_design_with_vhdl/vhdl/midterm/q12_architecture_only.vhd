-- This design assumes that if we are stretching a pulse and we receive another pulse, we do not reset the timer
ARCHITECTURE Behavioral OF midterm_q12_tb IS
    SIGNAL clk             : STD_LOGIC;
    SIGNAL reset           : STD_LOGIC;
    SIGNAL stretched_pulse : STD_LOGIC;
    SIGNAL pulse_count : UNSIGNED(31 DOWNTO 0);
    SIGNAL clear       : STD_LOGIC;
BEGIN

    -- We want to stretch for 1ms
    clear <= '1' WHEN (pulse_count = to_unsigned(50000, 32)) ELSE
        '0';

    pulse_stretch : PROCESS (clk, reset, pulse_count, stretched_pulse, clear)
    BEGIN
        IF (reset = '1') THEN
            stretched_pulse <= '0';
            pulse_count     <= (OTHERS => '0');
        ELSIF (rising_edge(clk)) THEN
            IF (async_pulse = '1' AND stretched_pulse = '0') THEN
                -- Restart our counter and enabled our pulse if we aren't already stretching
                stretched_pulse <= '1';
                pulse_count <= (OTHERS => '0');
            ELSIF (stretched_pulse = '1') THEN
                -- We our pulse stretching and should start counting
                IF (clear = '1') THEN
                    stretched_pulse <= '0';
                    pulse_count <= (OTHERS => '0');
                ELSE
                    pulse_count <= pulse_count + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;