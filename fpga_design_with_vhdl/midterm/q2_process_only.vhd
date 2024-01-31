PROCESS (CLK, RST)
BEGIN
    IF (RST = '1') THEN
        counter <= (OTHERS => '0');
    ELSIF (rising_edge(CLK)) THEN
        IF (EN = '1') THEN
            counter <= counter + 1;
        END IF;
    END IF;
END PROCESS;