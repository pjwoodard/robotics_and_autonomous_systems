------------------------------------------------------------------------------------------------------------------------------
-- Author: Parker Woodard
--
-- Description: Drives all state machines necessary for initializing and operating the SPI bus and reading accelerometer data
------------------------------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY accel_spi_rw IS
    PORT (
        CLK    : IN STD_LOGIC;
        RESET  : IN STD_LOGIC;
        ID_AD  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        ID_1D  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        DATA_X : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        DATA_Y : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        DATA_Z : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SCLK   : OUT STD_LOGIC;
        CSb    : OUT STD_LOGIC;
        MOSI   : OUT STD_LOGIC;
        MISO   : IN STD_LOGIC
    );
END accel_spi_rw;

ARCHITECTURE Behavioral OF accel_spi_rw IS
    TYPE spi_state_t IS (idle, wait100ms, setCSlow, setCShi, sclkHi, sclkLo, incSclkCntr, checkSclkCntr);
    TYPE command_state_t IS (idle, writeAddr2D, doneStartup,
        readAddr00, captureID_AD, readAddr01, captureID_1D,
        readAddr08, captureX, readAddr09, captureY,
        readAddr0A, captureZ);
    SIGNAL cur_spi_state        : spi_state_t;
    SIGNAL next_spi_state       : spi_state_t;
    SIGNAL cur_command_state    : command_state_t;
    SIGNAL next_command_state   : command_state_t;
    SIGNAL spi_start            : STD_LOGIC;
    SIGNAL spi_done             : STD_LOGIC;
    SIGNAL timer_start          : STD_LOGIC;
    SIGNAL timer_done           : STD_LOGIC;
    SIGNAL timer_max            : unsigned(31 DOWNTO 0);
    SIGNAL sclk_cntr            : unsigned(31 DOWNTO 0);
    SIGNAL reset_sclk_cntr      : STD_LOGIC;
    SIGNAL inc_sclk_cntr        : STD_LOGIC;
    SIGNAL to_spi_bytes         : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL par_to_ser_shift_reg : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL ser_to_par_shift_reg : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL id_ad_reg            : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL id_1d_reg            : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL x_data_reg           : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL y_data_reg           : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL z_data_reg           : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sclk_reg             : STD_LOGIC;
    SIGNAL csb_reg              : STD_LOGIC;
BEGIN
    -- TODO: Replace this with pulse generator with enable bit
    state_machine_timer : ENTITY work.timer
        PORT MAP(
            clk       => CLK,
            rst       => reset,
            en        => timer_start,
            max_count => timer_max,
            pulse     => timer_done
        );

    spi_done <= '1' WHEN (timer_done = '1' AND cur_spi_state = wait100ms) ELSE
        '0';
    reset_sclk_cntr <= '1' WHEN (cur_spi_state = wait100ms) ELSE
        '0';
    inc_sclk_cntr <= '1' WHEN (cur_spi_state = incSclkCntr) ELSE
        '0';

    MOSI   <= par_to_ser_shift_reg(par_to_ser_shift_reg'high);
    SCLK   <= sclk_reg;
    ID_AD  <= id_ad_reg;
    ID_1D  <= id_1d_reg;
    DATA_X <= x_data_reg;
    DATA_Y <= y_data_reg;
    DATA_Z <= z_data_reg;
    CSb    <= csb_reg;

    -- Make sure we start our timer for all of all our timed states
    timer_start <= '1' WHEN (
        cur_spi_state = setCSlow OR
        cur_spi_state = sclkHi OR
        cur_spi_state = sclkLo OR
        cur_spi_state = wait100ms) ELSE
        '0';

    timer_max_proc : PROCESS (timer_max, cur_spi_state)
    BEGIN
        IF (cur_spi_state = setCSlow) THEN
            timer_max <= to_unsigned(19, 32);
        ELSIF (cur_spi_state = sclkHi) THEN
            timer_max <= to_unsigned(49, 32);
        ELSIF (cur_spi_state = sclkLo) THEN
            timer_max <= to_unsigned(47, 32);
        ELSIF (cur_spi_state = wait100ms) THEN
            timer_max <= to_unsigned(10000000, 32);
        ELSE
            timer_max <= to_unsigned(0, 32);
        END IF;
    END PROCESS;

    chip_select : PROCESS (cur_spi_state, csb_reg)
    BEGIN
        IF (cur_spi_state = idle OR cur_spi_state = setCShi OR cur_spi_state = wait100ms) THEN
            csb_reg <= '1';
        ELSE
            csb_reg <= '0';
        END IF;
    END PROCESS;

    drive_sclk : PROCESS (sclk_reg, cur_spi_state)
    BEGIN
        IF (cur_spi_state = sclkHi) THEN
            sclk_reg <= '1';
        ELSE
            sclk_reg <= '0';
        END IF;
    END PROCESS;

    spi_state_machine : PROCESS (next_spi_state, spi_start, timer_done, cur_spi_state, sclk_cntr)
    BEGIN
        next_spi_state <= cur_spi_state;
        CASE cur_spi_state IS
            WHEN idle =>
                IF (spi_start = '1') THEN
                    next_spi_state <= setCSlow;
                END IF;
            WHEN setCSlow =>
                IF (timer_done = '1') THEN
                    next_spi_state <= sclkHi;
                END IF;
            WHEN setCShi =>
                next_spi_state <= wait100ms;
            WHEN sclkHi =>
                IF (timer_done = '1') THEN
                    next_spi_state <= sclkLo;
                END IF;
            WHEN sclkLo =>
                IF (timer_done = '1') THEN
                    next_spi_state <= incSclkCntr;
                END IF;
            WHEN incSclkCntr =>
                next_spi_state <= checkSclkCntr;
            WHEN checkSclkCntr =>
                IF (sclk_cntr = 24) THEN
                    next_spi_state <= setCShi;
                ELSE
                    next_spi_state <= sclkHi;
                END IF;
            WHEN wait100ms =>
                IF (timer_done = '1') THEN
                    next_spi_state <= idle;
                END IF;
        END CASE;
    END PROCESS;

    -- Increments the sclk_cntr
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            sclk_cntr <= (OTHERS => '0');
        ELSIF (rising_edge(clk)) THEN
            IF (reset_sclk_cntr = '1') THEN
                sclk_cntr <= (OTHERS => '0');
            ELSIF (inc_sclk_cntr = '1') THEN
                sclk_cntr <= sclk_cntr + 1;
            END IF;
        END IF;
    END PROCESS;

    -- Command state driver process
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            cur_spi_state     <= idle;
            cur_command_state <= idle;
        ELSIF (rising_edge(clk)) THEN
            cur_spi_state     <= next_spi_state;
            cur_command_state <= next_command_state;
        END IF;
    END PROCESS;

    spi_start <= '1' WHEN (cur_command_state = idle OR
        cur_command_state = doneStartup OR
        cur_command_state = captureID_AD OR
        cur_command_state = captureID_1D OR
        cur_command_state = captureX OR
        cur_command_state = captureY OR
        cur_command_state = captureZ) ELSE
        '0';

    command_state_machine : PROCESS (reset, next_command_state, spi_start, cur_command_state, to_spi_bytes, spi_done)
    BEGIN
        next_command_state <= cur_command_state;
        CASE cur_command_state IS
            WHEN idle =>
                to_spi_bytes       <= x"0A2D02";
                next_command_state <= writeAddr2D;
            WHEN writeAddr2D =>
                to_spi_bytes <= x"000000";
                IF (spi_done = '1') THEN
                    next_command_state <= doneStartup;
                END IF;
            WHEN doneStartup =>
                to_spi_bytes       <= x"0B0000";
                next_command_state <= readAddr00;
            WHEN readAddr00 =>
                to_spi_bytes <= x"000000";
                IF (spi_done = '1') THEN
                    next_command_state <= captureID_AD;
                END IF;
            WHEN captureID_AD =>
                to_spi_bytes       <= x"0B0100";
                next_command_state <= readAddr01;
            WHEN readAddr01 =>
                to_spi_bytes <= x"000000";
                IF (spi_done = '1') THEN
                    next_command_state <= captureID_1D;
                END IF;
            WHEN captureID_1D =>
                to_spi_bytes       <= x"0B0800";
                next_command_state <= readAddr08;
            WHEN readAddr08 =>
                to_spi_bytes <= x"000000";
                IF (spi_done = '1') THEN
                    next_command_state <= captureX;
                END IF;
            WHEN captureX =>
                to_spi_bytes       <= x"0B0900";
                next_command_state <= readAddr09;
            WHEN readAddr09 =>
                to_spi_bytes <= x"000000";
                IF (spi_done = '1') THEN
                    next_command_state <= captureY;
                END IF;
            WHEN captureY =>
                to_spi_bytes       <= x"0B0A00";
                next_command_state <= readAddr0A;
            WHEN readAddr0A =>
                to_spi_bytes <= x"000000";
                IF (spi_done = '1') THEN
                    next_command_state <= captureZ;
                END IF;
            WHEN captureZ =>
                to_spi_bytes       <= x"0B0000";
                next_command_state <= readAddr00;
        END CASE;
    END PROCESS;

    capture_data : PROCESS (reset, clk)
    BEGIN
        IF (reset = '1') THEN
            id_ad_reg  <= (OTHERS => '0');
            id_1d_reg  <= (OTHERS => '0');
            x_data_reg <= (OTHERS => '0');
            y_data_reg <= (OTHERS => '0');
            z_data_reg <= (OTHERS => '0');
        ELSIF (rising_edge(clk)) THEN
            IF (cur_command_state = captureID_AD) THEN
                id_ad_reg <= ser_to_par_shift_reg(7 DOWNTO 0);
            ELSIF (cur_command_state = captureID_1D) THEN
                id_1d_reg <= ser_to_par_shift_reg(7 DOWNTO 0);
            ELSIF (cur_command_state = captureX) THEN
                x_data_reg <= ser_to_par_shift_reg(7 DOWNTO 0);
            ELSIF (cur_command_state = captureY) THEN
                y_data_reg <= ser_to_par_shift_reg(7 DOWNTO 0);
            ELSIF (cur_command_state = captureZ) THEN
                z_data_reg <= ser_to_par_shift_reg(7 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;

    -- Converts outgoing parallel data into serial data using a 24-bit shift register (our SPI transactions are 24 SCLK cycles)
    parallel_to_serial : PROCESS (reset, clk, spi_start, timer_done, cur_spi_state, par_to_ser_shift_reg)
    BEGIN
        IF (reset = '1') THEN
            par_to_ser_shift_reg <= (OTHERS => '0');
        ELSIF (rising_edge(clk)) THEN
            IF (spi_start = '1') THEN
                par_to_ser_shift_reg <= to_spi_bytes;
            ELSIF (cur_spi_state = sclkHi AND timer_done = '1') THEN
                par_to_ser_shift_reg <= par_to_ser_shift_reg(par_to_ser_shift_reg'high - 1 DOWNTO par_to_ser_shift_reg'low) & '0';
            END IF;
        END IF;
    END PROCESS;

    -- Converts incoming serial data into parallel data using a 24-bit shift register, values are saved in registers using CSAs
    serial_to_parallel : PROCESS (reset, clk, spi_start, timer_done, cur_spi_state, ser_to_par_shift_reg, cur_command_state)
    BEGIN
        IF (reset = '1') THEN
            ser_to_par_shift_reg <= (OTHERS => '0');
        ELSIF (rising_edge(clk)) THEN
            IF (cur_spi_state = checkSclkCntr AND sclk_cntr < 24) THEN
                ser_to_par_shift_reg <= ser_to_par_shift_reg(ser_to_par_shift_reg'high - 1 DOWNTO ser_to_par_shift_reg'low) & MISO;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;