LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_STD.ALL;

ENTITY timer IS
	PORT (
		clk       : IN STD_LOGIC;
		rst       : IN STD_LOGIC;
		en        : IN STD_LOGIC;
		max_count : IN UNSIGNED(31 DOWNTO 0);
		pulse     : OUT STD_LOGIC
	);
END timer;

ARCHITECTURE Behavioral OF timer IS
	SIGNAL cntr : unsigned(31 DOWNTO 0);
BEGIN
	PROCESS (rst, clk)
	BEGIN
		IF (rst = '1') THEN
			cntr <= (OTHERS => '0');
		ELSIF (rising_edge(clk)) THEN
			IF (en = '1') THEN
				IF (cntr < max_count) THEN
					cntr <= cntr + 1;
				ELSE
					cntr <= (OTHERS => '0');
				END IF;
			ELSE
				cntr <= (OTHERS => '0');
			END IF;
		END IF;
	END PROCESS;

	pulse <= '1' WHEN cntr = max_count ELSE '0';
END Behavioral;