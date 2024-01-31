---------------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Top Level VHDL for Lab 7 - Sine Wave Generator 
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.types.bus_8x4;

ENTITY lab7_top IS
    PORT (
        CLK_100MHZ : IN STD_LOGIC;
        RESET      : IN STD_LOGIC;
        SW         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        AUD_SD     : OUT STD_LOGIC;
        AUD_PWM    : OUT STD_LOGIC;
        SEG7_CATH  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        AN         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END lab7_top;

ARCHITECTURE Behavioral OF lab7_top IS
    CONSTANT sample_rate_multiplier : INTEGER := 100000000 * 1/256;
    SIGNAL phase_acc_en             : STD_LOGIC;
    SIGNAL sample_freq              : UNSIGNED(11 DOWNTO 0);
    SIGNAL sample_rate_cnt          : UNSIGNED(31 DOWNTO 0);
    SIGNAL phase_counter            : UNSIGNED(7 DOWNTO 0);
    SIGNAL volume_level             : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL sine_data                : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL shifted_sine_data        : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL display_array            : bus_8x4;
BEGIN
    -- Audio Enable/Disable
    AUD_SD <= SW(15);

    -- Volume level is the inverse of the switch values 
    volume_level <= NOT(SW(5 DOWNTO 3));

    -- Invert top bit of sine data (level shift) and adjust volume by volume level
    shifted_sine_data <= STD_LOGIC_VECTOR(shift_right(unsigned(NOT sine_data(15) & sine_data(14 DOWNTO 0)), to_integer(unsigned(volume_level))));

    -- Displays the current volume percentage
    WITH SW(5 DOWNTO 3) SELECT
    display_array(7 DOWNTO 4) <=
    ("0000", "0001", "0000", "0000") WHEN "111",  -- 7, 100%
    ("0000", "0000", "1000", "0110") WHEN "110",  -- 6, 86%
    ("0000", "0000", "0111", "0001") WHEN "101",  -- 5, 71%
    ("0000", "0000", "0101", "0111") WHEN "100",  -- 4, 57%
    ("0000", "0000", "0100", "0011") WHEN "011",  -- 3, 43%
    ("0000", "0000", "0010", "1001") WHEN "010",  -- 2, 29%
    ("0000", "0000", "0001", "0100") WHEN "001",  -- 1, 14%
    ("0000", "0000", "0000", "0000") WHEN OTHERS; -- 0, 0%

    -- Displays the current frequency
    WITH SW(2 DOWNTO 0) SELECT
    display_array(3 DOWNTO 0) <=
    ("0000", "0101", "0000", "0000") WHEN "001", -- 500Hz
    ("0001", "0000", "0000", "0000") WHEN "010", -- 1000Hz
    ("0001", "0101", "0000", "0000") WHEN "011", -- 1500Hz
    ("0010", "0000", "0000", "0000") WHEN "100", -- 2000Hz
    ("0010", "0101", "0000", "0000") WHEN "101", -- 2500Hz
    ("0011", "0000", "0000", "0000") WHEN "110", -- 3000Hz
    ("0011", "0101", "0000", "0000") WHEN "111", -- 3500Hz
    ("0000", "0000", "0000", "0000") WHEN OTHERS;

    -- Selects our sample frequency based on our switch value
    WITH SW(2 DOWNTO 0) SELECT
    sample_freq <=
        to_unsigned(0, sample_freq'length) WHEN "000",
        to_unsigned(500, sample_freq'length) WHEN "001",
        to_unsigned(1000, sample_freq'length) WHEN "010",
        to_unsigned(1500, sample_freq'length) WHEN "011",
        to_unsigned(2000, sample_freq'length) WHEN "100",
        to_unsigned(2500, sample_freq'length) WHEN "101",
        to_unsigned(3000, sample_freq'length) WHEN "110",
        to_unsigned(3500, sample_freq'length) WHEN "111",
        to_unsigned(0, sample_freq'length) WHEN OTHERS;

    -- Calculates sample_rate_cnt 
    calc_sample_rate_cnt : PROCESS (sample_freq, sample_rate_cnt)
    BEGIN
        IF to_integer(sample_freq) /= 0 THEN
            sample_rate_cnt <= to_unsigned((1 * sample_rate_multiplier) / to_integer(sample_freq), sample_rate_cnt'length);
        ELSE
            sample_rate_cnt <= (OTHERS => '0');
        END IF;
    END PROCESS;

    -- 8-Bit Phase counter
    phase_accumulator : PROCESS (CLK_100MHZ, RESET, phase_acc_en)
    BEGIN
        IF (RESET = '1') THEN
            phase_counter <= (OTHERS => '0');
        ELSIF (rising_edge(CLK_100MHZ)) THEN
            IF (phase_acc_en = '1') THEN
                phase_counter <= phase_counter + 1;
            END IF;
        END IF;
    END PROCESS;

    -- Used to display our frequency and our volume percentage
    seg7_controller : ENTITY work.seg7_controller
        PORT MAP(
            CLK_100MHZ => CLK_100MHZ,
            RST        => RESET,
            CHAR_BUS   => display_array,
            SEG7_CATH  => SEG7_CATH,
            AN         => AN
        );

    -- Generate pulses at the max sample count, used as an enable for the phase accumulator
    -- (1/Fs) * 100MHz * (1/2^8)
    sample_gen : ENTITY work.pulse_generator
        PORT MAP(
            CLK       => CLK_100MHZ,
            RST       => RESET,
            MAX_COUNT => sample_rate_cnt,
            PULSE_OUT => phase_acc_en
        );

    sine_lut : ENTITY work.dds_compiler_0
        PORT MAP(
            aclk                => CLK_100MHZ,
            s_axis_phase_tvalid => '1',
            s_axis_phase_tdata  => STD_LOGIC_VECTOR(phase_counter),
            m_axis_data_tvalid  => OPEN,
            m_axis_data_tdata   => sine_data
        );

    -- PWM Duty Cycle is the top 10 bits of the transformed LUT output
    pwm_gen : ENTITY work.pwm_generator
        GENERIC MAP(
            PWM_RESOLUTION => 10
        )
        PORT MAP(
            CLK        => CLK_100MHZ,
            RST        => RESET,
            DUTY_CYCLE => shifted_sine_data(15 DOWNTO 6),
            PWM_OUT    => AUD_PWM
        );
END Behavioral;