----------------------------------------------------------------------------------
-- Engineer:    K. Newlander
-- Course:      ECE 525.442 JHU Engineering
--
-- Description: Lab6 Base Picoblaze Project which demonstrates the instatiation
--              of a Picoblaze soft core processor on the Artix-7 FPGA
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
    Port (  --Clock
          CLK100MHZ : in STD_LOGIC;
   
          --Push Buttons
          --BTNC : in STD_LOGIC;
          BTND : in STD_LOGIC;
          BTNL : in STD_LOGIC;
          BTNR : in STD_LOGIC;
          BTNU : in STD_LOGIC;
          
          CPU_RESETN : in STD_LOGIC;
          
           --Switches (16 Switches)
          SW : in STD_LOGIC_VECTOR (15 downto 0);
          
           --LEDs (16 LEDs)
          LED : out STD_LOGIC_VECTOR (15 downto 0);
          
          --UART
          UART_RXD_OUT : out STD_LOGIC;
          UART_TXD_IN : in STD_LOGIC;
          
           --Seg7 Display Signals
          SEG7_CATH : out STD_LOGIC_VECTOR (7 downto 0);
          AN : out STD_LOGIC_VECTOR (7 downto 0));
end top_level;

architecture Behavioral of top_level is

    --TODO: Package these into seperate file for ease of readibility
    
    component kcpsm6 
        generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                        interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
                 scratch_pad_memory_size : integer := 64);
        port (                   address : out std_logic_vector(11 downto 0);
                             instruction : in std_logic_vector(17 downto 0);
                             bram_enable : out std_logic;
                                 in_port : in std_logic_vector(7 downto 0);
                                out_port : out std_logic_vector(7 downto 0);
                                 port_id : out std_logic_vector(7 downto 0);
                            write_strobe : out std_logic;
                          k_write_strobe : out std_logic;
                             read_strobe : out std_logic;
                               interrupt : in std_logic;
                           interrupt_ack : out std_logic;
                                   sleep : in std_logic;
                                   reset : in std_logic;
                                     clk : in std_logic);
    end component;
  
    component lab6_starter                             
      generic(             C_FAMILY : string := "S6"; 
                  C_RAM_SIZE_KWORDS : integer := 1;
               C_JTAG_LOADER_ENABLE : integer := 0);
      Port (      address : in std_logic_vector(11 downto 0);
              instruction : out std_logic_vector(17 downto 0);
                   enable : in std_logic;
                      rdl : out std_logic;                    
                      clk : in std_logic);
    end component;
    
    component uart_tx6
      Port (             data_in : in std_logic_vector(7 downto 0);
                    en_16_x_baud : in std_logic;
                      serial_out : out std_logic;
                    buffer_write : in std_logic;
             buffer_data_present : out std_logic;
                buffer_half_full : out std_logic;
                     buffer_full : out std_logic;
                    buffer_reset : in std_logic;
                             clk : in std_logic);
      end component;
      
    component uart_rx6
        Port (           serial_in : in std_logic;
                      en_16_x_baud : in std_logic;
                          data_out : out std_logic_vector(7 downto 0);
                       buffer_read : in std_logic;
               buffer_data_present : out std_logic;
                  buffer_half_full : out std_logic;
                       buffer_full : out std_logic;
                      buffer_reset : in std_logic;
                               clk : in std_logic);
        end component;
        
    component clkdivider
            generic (divideby : natural := 2);
            Port ( clk : in std_logic;
                   reset : in std_logic;
                   pulseout : out std_logic);
        end component;
        
    component seg7_driver
            Port(clk50: in STD_LOGIC;
                    rst: in STD_LOGIC;
                    char0: in STD_LOGIC_VECTOR (3 downto 0);
                    char1: in STD_LOGIC_VECTOR (3 downto 0);
                    char2: in STD_LOGIC_VECTOR (3 downto 0);
                    char3: in STD_LOGIC_VECTOR (3 downto 0);
                    anodes: out STD_LOGIC_VECTOR (3 downto 0);
                    encodedChar: out STD_LOGIC_VECTOR (6 downto 0));
        end component;
        
    --
    -- Clock Generation (50MHz Clock)
    --
    signal clk : std_logic;
    
    --
    -- Signals for connection of KCPSM6 and Program Memory.
    --
    signal         address : std_logic_vector(11 downto 0);
    signal     instruction : std_logic_vector(17 downto 0);
    signal     bram_enable : std_logic;
    signal         in_port : std_logic_vector(7 downto 0);
    signal        out_port : std_logic_vector(7 downto 0);
    signal         port_id : std_logic_vector(7 downto 0);
    signal    write_strobe : std_logic;
    signal  k_write_strobe : std_logic;
    signal     read_strobe : std_logic;
    signal       interrupt : std_logic;
    signal   interrupt_ack : std_logic;
    signal    kcpsm6_sleep : std_logic;
    signal    kcpsm6_reset : std_logic;
    
    --
    -- Some additional signals are required if your system also needs to reset KCPSM6. 
    --
    signal       cpu_reset : std_logic;
    signal             rdl : std_logic;
    
    --
    -- When interrupt is to be used then the recommended circuit included below requires 
    -- the following signal to represent the request made from your system.
    --
    signal     int_request : std_logic;
    
    
    --
    -- Extra Signals for IN/OUT ports
    --
    
    --
    -- Input Signals to Processor
    --
    signal sliders : std_logic_vector(7 downto 0);
    signal buttons : std_logic_vector(3 downto 0);
    
    --
    -- Output Singals to Processor
    --
    signal leds_reg : std_logic_vector(7 downto 0);
    signal seg7chars : std_logic_vector(15 downto 0);
    signal anodesHalf : std_logic_vector(3 downto 0);
    signal encodedChar : std_logic_vector(6 downto 0);


    --
    -- UART Signals and Register for in port
    --
    signal uart_tx, uart_rx : std_logic;
    signal status_register, data_from_uartrx, in_port_reg : std_logic_vector(7 downto 0);
    signal read_uart_word, write_uart_word : std_logic;
    signal uart_data_available, uart_rx_full, uart_rx_half, uart_tx_full, uart_tx_half : std_logic;
    signal baudclk, ms_ena : std_logic;
    signal mstimer : std_logic_vector(15 downto 0);

begin
    --connections to USB UART (from computer perspective)
    uart_rx <= UART_TXD_IN;
    UART_RXD_OUT <= uart_tx;
    
    --LED connection (uses 8 bits)
    LED(7 downto 0) <= leds_reg;
    LED(15 downto 8) <= (others=>'1'); --tie to 0
    
    AN(3 downto 0) <= anodesHalf;
    AN(7 downto 4) <= (others=>'1'); --do not display
    
    SEG7_CATH(6 downto 0) <= encodedChar;
    SEG7_CATH(7) <= '1';
    
    --Slider Switches
    sliders <= SW(7 downto 0);
    buttons <= (3=>BTND, 2=>BTNU, 1=>BTNL, 0=>BTNR);

    --cpu_reset is tied to button on Nexys4 DDR development Board
    cpu_reset <= not CPU_RESETN;
    
    --Generate 50MHz master clock
    process(CLK100MHZ,cpu_reset)
    begin
        if(cpu_reset = '1') then
            clk <= '0';
        elsif(rising_edge(CLK100MHZ)) then
            clk <= not clk;
        end if;
    end process;
    
    --instaniate Picoblaze
    processor:  kcpsm6
                generic map (                 hwbuild => X"00", 
                                     interrupt_vector => X"3FF",
                              scratch_pad_memory_size => 64)
                port map(      address => address,
                           instruction => instruction,
                           bram_enable => bram_enable,
                               port_id => port_id,
                          write_strobe => write_strobe,
                        k_write_strobe => k_write_strobe,
                              out_port => out_port,
                           read_strobe => read_strobe,
                               in_port => in_port,
                             interrupt => interrupt,
                         interrupt_ack => interrupt_ack,
                                 sleep => kcpsm6_sleep,
                                 reset => kcpsm6_reset,
                                   clk => clk);
                                   
    --For Future Use for interrupts
    kcpsm6_sleep <= '0';
    interrupt <= interrupt_ack;

    
    --instaniate the testprogram ROM
    program_rom:    lab6_starter                    
                    generic map(             C_FAMILY => "7S",   --Artix-7 FPGA
                                    C_RAM_SIZE_KWORDS => 2,      
                                 C_JTAG_LOADER_ENABLE => 1)      --Include JTAG Loader when set to '1' 
                    port map(      address => address,      
                               instruction => instruction,
                                    enable => bram_enable,
                                       rdl => rdl,
                                       clk => clk);

   kcpsm6_reset <= cpu_reset or rdl;
   
   --
   -- Process for picoblaze reading
   --
   readmux: process(port_id, status_register, data_from_uartrx, sliders, buttons, seg7chars, leds_reg, mstimer)
   begin
       case port_id is
           when x"00" => in_port <= status_register;
           when x"01" => in_port <= data_from_uartrx;
           when x"02" => in_port <= sliders;
           when x"03" => in_port <= x"0" & buttons;
           when x"04" => in_port <= seg7chars(7 downto 0); -- even though 4,5,6 are write registers
           when x"05" => in_port <= seg7chars(15 downto 8); -- we map them to read so that we can 
           when x"06" => in_port <= leds_reg;    -- see what we wrote
           when x"07" => in_port <= mstimer(7 downto 0);
           when x"08" => in_port <= mstimer(15 downto 8);
          when others => in_port <= x"5a";
       end case;
   end process readmux;
   
   -- register the in_port to increase speed, which we certainly don't need for 50MHz clock
   -- but good practice, since PORT_ID is valid for 2 clocks
   -- also serves the purpose of synchronizing the inputs, which is a good idea since the picoblaze will
   -- be reading them.  Note of course that the inputs from switches...etc are not debounced, that is done in SW
   in_port_reg <= in_port when rising_edge(clk);
   
   -- 
   -- UART Blocks (115.2kbps)
   --
   rcvr : uart_rx6 port map
            (
            serial_in => uart_rx,
            en_16_x_baud => baudclk,
            data_out => data_from_uartrx,
            buffer_read => read_uart_word,
            buffer_data_present => uart_data_available,
            buffer_half_full => uart_rx_half,
            buffer_full => uart_rx_full,
            buffer_reset => kcpsm6_reset,
            clk => clk
            );
                 
   xmitter : uart_tx6 port map
            (
            data_in => out_port,
            en_16_x_baud => baudclk,
            serial_out => uart_tx,
            buffer_write => write_uart_word,
            buffer_data_present => open,
            buffer_half_full => uart_tx_half,
            buffer_full => uart_tx_full,
            buffer_reset => kcpsm6_reset,
            clk => clk
            );
   
   --
   -- Handling writes and control signals
   --
   read_uart_word <= '1' when port_id = x"01" and read_strobe='1' else '0';
   write_uart_word <= '1' when port_id = x"01" and write_strobe='1' else '0';
   
   process(clk, cpu_reset)
   begin
    if(cpu_reset = '1') then
        seg7chars <= (others=>'0');
        leds_reg <= (others=>'0');
    elsif(rising_edge(clk)) then
        if(write_strobe = '1') then
            if(port_id = x"04") then
                seg7chars(7 downto 0) <= out_port;
            elsif(port_id = x"05") then
                seg7chars(15 downto 8) <= out_port;
            elsif(port_id = x"06") then
                leds_reg <= out_port;
            end if;
        end if;
    end if;
   end process;
   
   -- misc
   status_register <= "000" & uart_rx_full & uart_rx_half & uart_tx_full & uart_tx_half & uart_data_available;
   
   makebaudclk : clkdivider generic map (divideby => 27)
       port map (clk=>clk, reset=>kcpsm6_reset, pulseout=>baudclk);
   
   -- makes a 1kHz pulse
   makemsclk : clkdivider generic map (divideby => 50000)
     port map (clk=>clk, reset=>kcpsm6_reset, pulseout=>ms_ena);
   
   mstimer <= std_logic_vector(unsigned(mstimer)+1) when rising_edge(clk) and ms_ena = '1';
   
   -- the 7 segment driver
   displaydrv : seg7_driver port map
       (
        clk50 => clk, 
        rst => kcpsm6_reset,
        char0 => seg7chars(3 downto 0),
        char1 => seg7chars(7 downto 4),
        char2 => seg7chars(11 downto 8),
        char3 => seg7chars(15 downto 12),
        anodes => anodesHalf,
        encodedChar => encodedChar
        );


end Behavioral;
