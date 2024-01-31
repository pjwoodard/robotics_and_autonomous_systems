----------------------------------------------------------------------------------
-- Group 2:    Erin McDonnell, Parker Woodard, Tommy Gao, Alexandria Banks, Reema Dhar, Hans Kreuk
--
-- Date: 11/28/2023
--
-- Description: Top Level VHDL for Team 2's BRAM and Music Player
--
--              A continuation of Lab7 using BRAM to store and play music
--              
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.ALL;

ENTITY lab8_top_group2 IS
    PORT (
        -- clock
        CLK100MHZ     : IN STD_LOGIC;

        --reset
        SW14          : IN STD_LOGIC; -- SW14 is used as the reset, constraints may need to be changed

        -- LEDs
        LED           : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        -- switches
        SW            : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- defines number of playback
        SW15          : IN STD_LOGIC;                    -- this turns on the audio output

        -- buttons
        BTNC          : IN STD_LOGIC; -- start playback
        BTNU          : IN STD_LOGIC; -- load new values into BRAM

        -- audio
        AUD_PWM       : OUT STD_LOGIC;
        AUD_SD        : OUT STD_LOGIC;

        -- UART
        UART_TXD_IN   : IN STD_LOGIC;
        UART_RXD_OUT  : OUT STD_LOGIC
    );
END lab8_top_group2;

ARCHITECTURE Behavioral OF lab8_top_group2 IS
    CONSTANT MAX_ADDR_COUNT   : INTEGER := 264600;
    SIGNAL bram_dout          : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL addr_cntr          : UNSIGNED(18 DOWNTO 0);
    SIGNAL en44_1             : STD_LOGIC;
    
    signal btnc_db, btnc_prior, btnc_det : std_logic;
    signal btnu_db, btnu_prior, btnu_det : std_logic;
    signal play_en            : std_logic;
    signal max_play_count     : std_logic_vector(1 downto 0);
    signal play_count         : unsigned (1 downto 0);
    signal play_count_clear   : std_logic;
    
    signal load_music_sample  : std_logic;
    signal new_music_data     : std_logic;
    signal music_data         : std_logic_vector(9 downto 0);
    signal bram_din           : std_logic_vector(9 downto 0);
    signal bram_ena           : std_logic;
    signal samples_loaded     : unsigned(18 DOWNTO 0);
    signal write_en           : STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal bram_addr          : UNSIGNED(18 DOWNTO 0);
    signal start_serial_load  : std_logic;

    type loader_states is (LOADER_IDLE, LOADER_WAIT_SERIAL, LOADER_LOAD_BRAM);
    signal loader_state : loader_states;

BEGIN
    -- Switch 15 controls audio enable
    AUD_SD <= SW15;

    -- Loader State machine
    process(CLK100MHZ, SW14)
    begin
        if(SW14 = '1') then
            loader_state <= LOADER_IDLE;
            bram_din <= (OTHERS => '0');
            samples_loaded <= (OTHERS => '0');
            load_music_sample <= '0';
            write_en <= "0";
        elsif(rising_edge(CLK100MHZ)) then
            case loader_state is
                when LOADER_IDLE =>
                    bram_din <= (OTHERS => '0');
                    samples_loaded <= (OTHERS => '0');
                    write_en <= "0";
                    if(btnu_det = '1') then       -- if btnu pressed, indicate ready to load new music from serial interface
                        --write_en <= "1";
                        loader_state <= LOADER_WAIT_SERIAL; 
                        load_music_sample <= '1';
                        LED(0) <= '1';
                        LED(1) <= '0';
                    else
                        load_music_sample <= '0';
                    end if;
                when LOADER_WAIT_SERIAL =>
                    --bram_din <= music_data;
                    load_music_sample <= '0';
                    --write_en <= "1";
                    if(new_music_data = '1') then -- if there is new music data, start loading data into BRAM
                        loader_state <= LOADER_LOAD_BRAM;
                    end if;
                when LOADER_LOAD_BRAM =>          -- load 529200 bytes (264600 samples) of music data into BRAM
                    if(to_integer(samples_loaded) = MAX_ADDR_COUNT - 1) then
                        -- All done!
                        loader_state <= LOADER_IDLE;
                        LED(0) <= '0';
                        LED(1) <= '1';
                        write_en <= "0";
                    else
                        write_en <= "1";
                        bram_din <= music_data;
                        load_music_sample <= '1';
                        samples_loaded <= samples_loaded + 1;
                        loader_state <= LOADER_WAIT_SERIAL;
                    end if;
                when others =>
                    write_en <= "0";
                    samples_loaded <= (OTHERS => '0');
                    bram_din <= (OTHERS => '0');
                    load_music_sample <= '0';
                    loader_state <= LOADER_IDLE;
            end case;
        end if;
    end process;

    -- UART
    --instantiate usb_music_serial
    USB_instance: entity work.usb_music_serial
    port map (
        clk               => CLK100MHZ,
        reset             => SW14,
        UART_TXD_IN       => UART_TXD_IN,
        UART_RXD_OUT      => UART_RXD_OUT,
        load_music_sample => load_music_sample,
        new_music_data    => new_music_data,
        music_data        => music_data     
    );

    -- debounce btnu
    btnu_debounce : entity work.debounce
    port map (
        clk         => CLK100MHZ,
        reset       => SW14,
        pb          => BTNU,
        debounce_pb => btnu_db
    );
    
    -- detect when btnu is pressed 
    btnu_detect : process (CLK100MHZ, SW14)
    begin
        if (SW14 = '1') then
            btnu_det <= '0';
            btnu_prior   <= '0';
        elsif (rising_edge(CLK100MHZ)) then
            btnu_prior   <= btnu_db;                     -- register the debounce button once (db is current, 1 is prior)
            btnu_det <= btnu_db and (not btnu_prior);    -- detect when button is pressed (current = 1, prior = 0)
        end if;
    end process;
    
    -- debounce btnc 
    btnc_debounce : entity work.debounce
    port map (
        clk         => CLK100MHZ,
        reset       => SW14,
        pb          => BTNC,
        debounce_pb => btnc_db
    );
  
    -- detect when btnc is pressed 
    btnc_detect : process (CLK100MHZ, SW14)
    begin
        if (SW14 = '1') then
            btnc_det <= '0';
            btnc_prior   <= '0';
        elsif (rising_edge(CLK100MHZ)) then
            btnc_prior   <= btnc_db;                     -- register the debounce button once (db is current, 1 is prior)
            btnc_det <= btnc_db and (not btnc_prior);    -- detect when button is pressed (current = 1, prior = 0)
        end if;
    end process;
    
    -- enable playback when btnc is pressed; disable play back when reach max number of play throughs
    playback_controller : process (CLK100MHZ, SW14)
    begin 
        if (SW14 = '1') then 
            play_en <= '0';
            max_play_count <= (others => '0');
        elsif (rising_edge(CLK100MHZ)) then 
            if (btnc_det = '1') then 
                play_en <= '1';
                max_play_count <= SW(1 downto 0);
            elsif (play_count_clear = '1') then 
                play_en <= '0';
            end if;
        end if;
    end process;

    -- Counter used as address for reading BRAM data; also includes counter for number of playthroughs
    addr_gen : PROCESS (CLK100MHZ, SW14)
    BEGIN
        IF (SW14 = '1') THEN
            play_count <= (others => '0');
            addr_cntr <= to_unsigned(0, addr_cntr'length);
        ELSIF (rising_edge(CLK100MHZ)) THEN
            IF (en44_1 = '1') THEN
                IF (to_integer(addr_cntr) < MAX_ADDR_COUNT) THEN
                    addr_cntr <= addr_cntr + 1;
                ELSE                                   -- count one playthrough when reach max addr
                    addr_cntr <= (OTHERS => '0');
                    play_count <= play_count + 1;
                END IF;
            END IF;
            if (play_count_clear = '1') then 
                play_count <= (others => '0');
            end if;
        END IF;
    END PROCESS;
    play_count_clear <= '1' when (std_logic_vector(play_count) = max_play_count) else '0';

    -- 44.1kHz pulse (BLK MEM Enable)
    pulse_generator : ENTITY work.pulse_generator
        GENERIC MAP(
            MAX_COUNT => 2269
        )
        PORT MAP(
            CLK       => CLK100MHZ,
            RST       => SW14,
            enable    => play_en,
            PULSE_OUT => en44_1
        );

    -- PWM Duty Cycle is the BRAM output
    pwm_gen : ENTITY work.pwm_generator
        GENERIC MAP(
            PWM_RESOLUTION => 10
        )
        PORT MAP(
            CLK        => CLK100MHZ,
            RST        => SW14,
            DUTY_CYCLE => bram_dout,
            PWM_OUT    => AUD_PWM
        );

    -- BRAM IP setup as single port 10bit x 264603 RAM operating in write-first mode
    bram_addr <= samples_loaded when write_en = "1" else addr_cntr;
    bram_ena <= play_en OR write_en(0);
    bram : ENTITY work.blk_mem_gen_0
       PORT MAP(
           clka   => CLK100MHZ,
           ena    => bram_ena,
           wea    => write_en,
           addra  => std_logic_vector(bram_addr),
           dina   => bram_din,
           douta  => bram_dout
       );
        
END Behavioral;