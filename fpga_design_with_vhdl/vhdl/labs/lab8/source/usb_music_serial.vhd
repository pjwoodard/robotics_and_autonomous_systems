----------------------------------------------------------------------------------
-- Engineer:    K. Newlander
--
-- Revisions:   2018/08 - Fall 2018 Build
--
-- Description: Uses the USB-UART interface on the Nexy's 4 DDR to collect music segments from
--              a pre-configured music file provided for Lab 8.
--
--
--              Two 8-bit UART words are used for one 10-bit music data packet
--              Expect UART to send as [Upper Byte 1][Lower Byte 1][Upper Byte 2][Lower Byte 2] etc...
--              Music data is generated for each upper/lower byte as UpperByte(4:0) & LowerByte(4:0)
--              
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity usb_music_serial is
    Port (  clk : in std_logic;
            reset : in std_logic;
            UART_TXD_IN : in std_logic;
            UART_RXD_OUT : out std_logic;
            load_music_sample : in std_logic;
            new_music_data : out std_logic;
            music_data : out std_logic_vector(9 downto 0)
          );
end usb_music_serial;

architecture Behavioral of usb_music_serial is
    
    --USB FSM
    type usb_states is (USB_WAIT_LOAD, USB_START_UART_HIGH, USB_WAIT_UART_HIGH, USB_START_UART_LOW, USB_WAIT_UART_LOW, USB_DATA_RX);
    signal usb_state : usb_states;
    
    --USB signals
    signal usb_uart_high, usb_uart_low : std_logic_vector(7 downto 0);
    signal usb_music_data : std_logic_vector(9 downto 0);
    
    --UART FSM
    type uart_states is (UART_IDLE, UART_FIND_START, UART_WAIT_START, UART_WAIT_BIT, UART_SAMPLE_BIT);
    signal uart_state, next_uart_state : uart_states;
    
    signal uart_get_byte : std_logic;
    signal uart_byte : std_logic_vector(8 downto 0); --8 bits + stop bit
    signal uart_bit_cnt : unsigned(3 downto 0);
    constant uart_bit_max : unsigned(3 downto 0) := to_unsigned(8, 4);
    signal uart_start_found : std_logic;
    
    signal uart_shift_reg : std_logic_vector(7 downto 0); 

    --Bit Timer
    signal bittimer_cnt : unsigned(9 downto 0);
    signal bittimer_max : unsigned(9 downto 0);
    signal bittimer_done, bittimer_reset : std_logic;
    
begin
    --Output Assignments
    music_data <= usb_music_data;
    
    --USB Music FSM
    --Captures two UART data packets and combines to single music data capture
    process(clk, reset)
    begin
        if(reset = '1') then
            usb_state <= USB_WAIT_LOAD;
            uart_get_byte <= '0';
            new_music_data <= '0';
            usb_uart_low <= (others=>'0');
            usb_uart_high <= (others=>'0');
            
        elsif(rising_edge(clk)) then
            --defaults
            uart_get_byte <= '0';
            new_music_data <= '0';
        
            case usb_state is
                when USB_WAIT_LOAD =>
                    --Wait here until ready to load next sample
                    if(load_music_sample = '1') then
                        uart_get_byte <= '1';
                        usb_state <= USB_START_UART_HIGH;
                    end if;
                    
                when USB_START_UART_HIGH =>
                    usb_state <= USB_WAIT_UART_HIGH;
                    
                when USB_WAIT_UART_HIGH =>
                    if(uart_state = UART_IDLE) then
                        uart_get_byte <= '1';
                        usb_uart_high <= uart_byte(7 downto 0);
                        usb_state <= USB_START_UART_LOW;
                    end if;
                    
                when USB_START_UART_LOW =>
                    usb_state <= USB_WAIT_UART_LOW;
                
                when USB_WAIT_UART_LOW =>
                    if(uart_state = UART_IDLE) then
                        usb_uart_low <= uart_byte(7 downto 0);
                        usb_state <= USB_DATA_RX;
                    end if;
                    
                when USB_DATA_RX =>
                    usb_music_data <= usb_uart_high(4 downto 0) & usb_uart_low(4 downto 0);
                    new_music_data <= '1';
                    usb_state <= USB_WAIT_LOAD;
                    
                when others =>
                    usb_state <= USB_WAIT_LOAD;
            end case;
        end if;
    end process;
    
    --Captures a single 8-bit UART data packet
    process(clk, reset)
    begin
        if(reset = '1') then
            uart_state <= UART_IDLE;
            uart_bit_cnt <= (others=>'0');
            uart_byte <= (others=>'0');
            
        elsif(rising_edge(clk)) then 
            uart_state <= next_uart_state;
            
            if(uart_state = UART_WAIT_START) then
                uart_bit_cnt <= (others=>'0');
                uart_byte <= (others=>'0');
            elsif(uart_state = UART_SAMPLE_BIT) then
                uart_bit_cnt <= uart_bit_cnt + 1;
                uart_byte <= uart_shift_reg(4) & uart_byte(8 downto 1);
            end if;
        end if;
    end process;
    
    --UART Next State Logic
    process(uart_state, uart_get_byte, uart_start_found, bittimer_done, uart_bit_cnt)
    begin
        --Defaults
        next_uart_state <= uart_state;
        bittimer_reset <= '0';
        
        case uart_state is
            when UART_IDLE =>
                if(uart_get_byte = '1') then
                    bittimer_reset <= '1';
                    next_uart_state <= UART_FIND_START;
                end if;
                
            when UART_FIND_START =>
                if(uart_start_found = '1') then
                    bittimer_reset <= '1';
                    next_uart_state <= UART_WAIT_START;
                end if;
                
            when UART_WAIT_START =>
                if(bittimer_done = '1') then
                    next_uart_state <= UART_WAIT_BIT;
                end if;

            when UART_WAIT_BIT =>
                if(bittimer_done = '1') then
                    next_uart_state <= UART_SAMPLE_BIT;
                end if;
            
            when UART_SAMPLE_BIT =>
                if(uart_bit_cnt = uart_bit_max) then
                    next_uart_state <= UART_IDLE;
                else
                    bittimer_reset <= '1';
                    next_uart_state <= UART_WAIT_BIT;
                end if;
            
            when others =>
                next_uart_state <= UART_IDLE;
        end case;
    end process;
    
    --start found logic and input shift register
    process(clk, reset)
    begin
        if(reset = '1') then
            uart_shift_reg <= (others=>'0');
        elsif(rising_edge(clk)) then
            if(uart_state = UART_IDLE) then
                uart_shift_reg <= (others=>'0');
            else
                uart_shift_reg <= uart_shift_reg(6 downto 0) & UART_TXD_IN;
            end if;
        end if;
    end process;
    
    uart_start_found <= '1' when uart_shift_reg(7 downto 6) = "11" and uart_shift_reg(5 downto 4) = "00" else '0'; --lower 4-bits are for syncrhonizer, upper 4-bits act as start filter

    bittimer_max <= to_unsigned(54, 10) when uart_state = UART_WAIT_START else --delay a half 921600 period
                    to_unsigned(109, 10) when uart_state = UART_WAIT_BIT else --delay 921600 period
                    to_unsigned(0, 10);
    
    --bittimer process
    process(clk, reset)
    begin
        if(reset = '1') then
            bittimer_cnt <= (others=>'0');
        elsif(rising_edge(clk)) then
            if(bittimer_reset = '1') then
                bittimer_cnt <= (others=>'0');
            elsif(bittimer_cnt = bittimer_max) then
                bittimer_cnt <= (others=>'0');
            else
                bittimer_cnt <= bittimer_cnt + 1;
            end if;
        end if;
    end process;
    
    bittimer_done <= '1' when bittimer_cnt = bittimer_max else '0';
    
end Behavioral;
