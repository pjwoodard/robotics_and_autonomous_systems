library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity seg7_driver is
    Port(clk50: in STD_LOGIC;
			rst: in STD_LOGIC;
			char0: in STD_LOGIC_VECTOR (3 downto 0);
			char1: in STD_LOGIC_VECTOR (3 downto 0);
			char2: in STD_LOGIC_VECTOR (3 downto 0);
			char3: in STD_LOGIC_VECTOR (3 downto 0);
			anodes: out STD_LOGIC_VECTOR (3 downto 0);
			encodedChar: out STD_LOGIC_VECTOR (6 downto 0));
end seg7_driver;

architecture Behavioral of seg7_driver is	
begin
	process(clk50, rst)
		variable vCounter: unsigned(15 downto 0);		-- Counter to drop 50MHz/1kHz
		variable vAnodes: STD_LOGIC_VECTOR(3 downto 0);	-- Holds anode pattern
		variable vChar: STD_LOGIC_VECTOR(3 downto 0);	-- Holds digit to display

	begin
		if rst = '1' then				-- High enable: set all digits to zero
			vAnodes := "0000";			-- Enable all displays
			encodedChar <= "0000001";	-- Pattern for '0'
			vCounter := conv_unsigned(1, 16); -- Reset counter to 1

		elsif rising_edge(clk50) then	-- Drop in every rising edge
			if vCounter = 50_000 then	-- Drop in every 50k/50mil = 1kHz

				if vAnodes = "0000" then
					vAnodes := "1110";	-- If we were in reset, enable LSB digit
				else					-- otherwise rotate left
					vAnodes := vAnodes(2 downto 0) & vAnodes(3);
				end if;

				case vAnodes is			-- Set character to display
					when "1110" => vChar := char0;
					when "1101" => vChar := char1;
					when "1011" => vChar := char2;
					when others => vChar := char3;
				end case;

			-- Codes for digits from UG130.pdf, page 16
			-- pin a is MSB while pin g is LSB
				case vChar is
					when X"0" => encodedChar <= "1000000";
					when X"1" => encodedChar <= "1111001";
					when X"2" => encodedChar <= "0100100";
					when X"3" => encodedChar <= "0110000";
					when X"4" => encodedChar <= "0011001";
					when X"5" => encodedChar <= "0010010";
					when X"6" => encodedChar <= "0000010";
					when X"7" => encodedChar <= "1111000";
					when X"8" => encodedChar <= "0000000";
					when X"9" => encodedChar <= "0010000";
					when X"A" => encodedChar <= "0001000";
					when X"B" => encodedChar <= "0000011";
					when X"C" => encodedChar <= "1000110";
					when X"D" => encodedChar <= "0100001";
					when X"E" => encodedChar <= "0000110";
					when others => encodedChar <= "0001110";
				end case;
				vCounter := (others => '0');	-- Clear counter
			end if;
			vCounter := vCounter + 1;	-- Increment counter
		end if;
		anodes <= vAnodes;				-- Assign anode signal
	end process;
end Behavioral;