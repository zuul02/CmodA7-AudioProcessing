--date: 08.12.2024
--version: V0.1
--author: Henrik Schmidt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity I2S_Transmit is
    Generic ( width : integer := 16);
    Port ( clk :            in STD_LOGIC;                                   --input clock
           nReset :         in STD_LOGIC;                                   --reset for audio interface
           Ready :          out STD_LOGIC;                                  --ready for new data
           Tx :             in std_logic_vector(((2 * width)-1) downto 0);  --transmitting data
           LRclk :          out std_logic;                                  --leftright clock
           sclk :           out std_logic;                                  --serial clock
           serial_data :    out std_logic;                                  --serial data out
           clock_enable :  in std_logic                                     --clock enable for lower frequency
        ); --serial data
end I2S_Transmit;

architecture Behavioral of I2S_Transmit is
type STATETYPE is (RESET, LOADWORD, TRANSMITWORD);
signal state : STATETYPE;
signal Tx_Int : std_logic_vector(((2 * width)-1) downto 0) 
              := (others => '0');
signal Ready_Int : std_logic := '0';
signal LRclk_Int : std_logic := '1';
signal SD_Int : std_logic := '0';
signal Enable : std_logic := '0';
signal sclk_status : std_logic := '0';
signal edge_detect  : std_logic := '0';
signal clkReady     : std_logic := '0';

begin
CHANGESTATE: process(clk)
variable BitCounter : integer range 0 to (2*width):= 0;
begin
    if clk'event and clk = '0' and clock_enable = '1' and sclk_status = '1' then
    
    case state is
        when RESET => Ready_Int <= '0';
                      LRclk_Int <= '1';
                      Enable <= '1';
                      SD_Int <= '0';
                      Tx_Int <= (others => '0');
                      state <= LOADWORD;
                      Enable <= '0';
                      
       when LOADWORD => 
                        BitCounter := 0;
                        Tx_Int <= Tx;
                        LRclk_Int <= '0';
                        state <= TRANSMITWORD;
                     
      when TRANSMITWORD => 
                           BitCounter := BitCounter + 1;
                           if BitCounter > (width - 1) then
                                LRclk_Int <= '1';
                           end if;
                           if BitCounter < ((2 * width)-1) then
                                Ready_Int <= '0';
                                state <= TRANSMITWORD;
                           else 
                               Ready_Int <= '1';
                               state <= LOADWORD;
                           end if;
                           
                           Enable <= '1';
                           Tx_Int <=  Tx_Int(((2*width)-2) downto 0) & "0";
                           SD_Int <= Tx_Int((2 * width)-1);                            
    end case;
    
    if nReset = '0' then
    state <= RESET;
    end if;
    end if;
end process;

CLOCKING: process(clk)
begin 
    if clk'event and clk = '0' and clock_enable = '1' then
        sclk_status <= not sclk_status;
    end if;
end process;

READYSIGNAL : process(clk)
begin
if clk'event and clk = '1' then
    if Ready_Int = '1' and edge_detect = '0' then
        clkReady <= '1';
        edge_detect <= '1';
    elsif edge_detect = '1' then
         clkReady <= '0';
    end if;
    
    if Ready_Int <= '0' then
        edge_detect <= '0';
    end if;
    
end if;
end process;    

Ready <= clkReady;
LRclk <= LRclk_Int;
serial_data <= SD_Int;
sclk <= sclk_status and Enable;

end Behavioral;
