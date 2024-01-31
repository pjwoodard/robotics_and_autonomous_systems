----------------------------------------------------------------------------------
-- 
-- Accelerometer Model for Simulation ONLY
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

--
--    Sample Addresses:
--      0x00    should be   0xAD
--      0x01    should be   0x1D
--      0x02    should be   0xF2
--      0x03    should be   0x01
--
--      0x08    should be X-Data (7:0)
--      0x09    should be Y-Data (7:0)
--      0x0A    should be Z-Data (7:0)
-- 
--      0x2D    contains Power Control Register
--              should write 0x02 to 'start' or power-up device readings

entity acl_model is
  port (
    rst       : in  std_logic;
    ACL_CSN   : in  std_logic;
    ACL_MOSI  : in  std_logic;
    ACL_SCLK  : in  std_logic;
    ACL_MISO  : out std_logic;
    --- ACCEL VALUES ---
    X_VAL     : in  std_logic_vector(7 downto 0);
    Y_VAL     : in  std_logic_vector(7 downto 0);
    Z_VAL     : in  std_logic_vector(7 downto 0);
    --- ACCEL STATE ---
    acl_enabled : out std_logic);
end acl_model;

architecture Behavioral of acl_model is

signal reg_read_Q : std_logic_vector(7 downto 0);
signal rd_D, rd_Q, ctr_clr : std_logic;
signal addr_D, addr_Q, reg_out_D, reg_out_Q, wr_data_D, wr_data_Q : std_logic_vector(7 downto 0);
signal ctr : unsigned(2 downto 0);
type T_STATE is (S_IDLE, S_GET_ADDR, S_RD_DATA, S_WR_DATA);
signal state_D, state_Q : T_STATE;
signal i_acl_enabled : std_logic;

begin

  process (ACL_SCLK, rst)
  begin
    if (rst='1') then
      reg_read_Q   <= (others=>'0');
      ctr          <= (others=>'0');
      rd_Q         <='0';
      addr_Q       <= (others=>'0');
      wr_data_Q    <= (others=>'0');
      reg_out_Q    <= (others=>'0');
      state_Q      <= S_IDLE;
      i_acl_enabled  <= '0';
      
    elsif (rising_edge(ACL_SCLK)) then
      if (ACL_CSN='0') then --enabled
        reg_read_Q   <= reg_read_Q(6 downto 0) & ACL_MOSI;
        if (ctr_clr='1') then
          ctr <= (others=>'0');
        else
          ctr <= ctr+1;
        end if;
        rd_Q      <= rd_D;
        addr_Q    <= addr_D;
        wr_data_Q <= wr_data_D;
        state_Q   <= state_D;
      end if;
      

    elsif falling_edge(ACL_SCLK) then
        reg_out_Q <= reg_out_D;
        
        if (wr_data_D = x"02" and addr_Q = x"2D") then
          i_acl_enabled <= '1';
        end if;
    end if;
  end process;
  
  FSM : process (state_Q, reg_read_Q, ctr,
                 rd_Q, addr_Q, reg_out_Q, wr_data_Q,
                 X_VAL, Y_VAL, Z_VAL)
  begin
    state_D   <= state_Q;
    ctr_clr   <= '0';
    rd_D      <= rd_Q;
    addr_D    <= addr_Q;
    reg_out_D <= reg_out_Q;
    wr_data_D <= wr_data_Q;
    
    case (state_Q) is
      
      when S_IDLE =>
        if (ACL_CSN='0') then
          ctr_clr <= '1';
          if (reg_read_Q = x"0B") then --READ
            rd_D    <= '1';
            state_D <= S_GET_ADDR;
          elsif (reg_read_Q = x"0A") then --WRITE
            rd_D    <= '0';
            state_D <= S_GET_ADDR;
          end if;
        end if;
        
      when S_GET_ADDR =>
        if (ACL_CSN='0' and ctr="111") then
          addr_D  <= reg_read_Q;
          ctr_clr <= '1';
          if (rd_Q='1') then
            state_D      <= S_RD_DATA;
            if (reg_read_Q = x"08" and i_acl_enabled = '1') then   --X
              reg_out_D  <= X_VAL;
            elsif (reg_read_Q = x"09" and i_acl_enabled = '1') then --Y
              reg_out_D  <= Y_VAL;
            elsif (reg_read_Q = x"0A" and i_acl_enabled = '1') then --Z
              reg_out_D  <= Z_VAL;
            elsif (reg_read_Q = x"00") then --Reg 0
                reg_out_D  <= x"AD";
            elsif (reg_read_Q = x"01") then --Reg 1
                reg_out_D  <= x"1D"; 
            elsif (reg_read_Q = x"02") then --Reg 2
                reg_out_D  <= x"F2";  
            elsif (reg_read_Q = x"03") then --Reg 3
                reg_out_D  <= x"01";                                                   
            else
              reg_out_D  <= x"FF";
            end if;
          else
            state_D <= S_WR_DATA;
          end if;
        end if;     
      
      when S_RD_DATA =>
        reg_out_D <= reg_out_Q(6 downto 0) & '0';
        if (ACL_CSN='0' and ctr="111") then
          state_D   <= S_IDLE;
        end if;  

      when S_WR_DATA =>
        if (ACL_CSN='0' and ctr="111") then
          wr_data_D <= reg_read_Q;
          state_D   <= S_IDLE;
        end if; 
      end case;  
  end process FSM;

  ACL_MISO <= reg_out_Q(7);
  acl_enabled <= i_acl_enabled;

end Behavioral;
