--author: Henrik Schmidt
--date: 05.01.2025
--version: V0.1

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity Top_Module is
generic(width       : integer := 16
        );
  Port (clk         : in std_logic;
        AnPos       : in std_logic;
        AnNeg       : in std_logic;
        PotiP       : in std_logic;
        PotiN       : in std_logic;
        switch      : in std_logic_vector(4 downto 0);
        muxA        : out std_logic;
        muxB        : out std_logic;
        sclk        : out std_logic;
        mClk        : out std_logic;
        lrclk       : out std_logic;
        sdata       : out std_logic;
        sda         : out std_logic;
        scl         : out std_logic
        );
end Top_Module;

architecture Behavioral of Top_Module is

component ADC_wrapper is
  Port (clk         : in std_logic;
        data_out    : out std_logic_vector(15 downto 0);
        potdata     : out std_logic_vector(15 downto 0);
        Pos         : in std_logic;
        Neg         : in std_logic;
        PotiP       : in std_logic;
        PotiN       : in std_logic;
        audio_clock : in std_logic
        );
end component;

component I2S_Transmit is
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
end component;

component clock_enable is
  Port (clk     : in std_logic;
        enable  : out std_logic;
        divider : in unsigned(23 downto 0)
       );
end component;


component SCLK_Generator is
  Port (clk         : in std_logic;
        clk_out     : out std_logic
        );
end component;

component EffectRouting is
Generic(width           : integer := 16
        );
  Port (clk             : in std_logic;
        audioEnable     : in std_logic;
        delayTimeIn       : in std_logic_vector(15 downto 0);
        selection       : in std_logic_vector(4 downto 0);
        audioIn         : in std_logic_vector((width - 1) downto 0);
        audioOut        : out std_logic_vector((width - 1) downto 0)
        );
end component;

signal audioRaw         : std_logic_vector((width - 1) downto 0);
signal audioProcessed   : std_logic_vector((width - 1) downto 0);
signal combinedChannel  : std_logic_vector(((2 * width) - 1) downto 0);
signal transmitReady    : std_logic;
signal transmitEnable   : std_logic;
signal muxAddr          : std_logic_vector(1 downto 0) := "01";

signal delayTime        : std_logic_vector(15 downto 0);

begin

--constant mapping DAC config
scl <= '0';
sda <= '0';

--MUX config
muxA <= muxAddr(0);
muxB <= muxAddr(1);

--component routing
SIGNAL_COMB     : process(audioProcessed)
                  begin
                  
                    combinedChannel <= audioProcessed & audioProcessed;
                  end process; 

AUDIOADC        : ADC_wrapper port map( clk         => clk,
                                        data_out    => audioRaw,
                                        potdata     => delayTime,
                                        Pos         => AnPos,
                                        Neg         => AnNeg,
                                        PotiP       => PotiP,
                                        PotiN       => PotiN,
                                        audio_clock => transmitReady
                                        );
                                        
TRANSMITTER     : I2S_Transmit port map( clk            => clk,
                                         nReset         => '1',
                                         Ready          => transmitReady,
                                         Tx             => combinedChannel,
                                         LRclk          => lrclk,
                                         sclk           => sclk,
                                         serial_data    => sdata,
                                         clock_enable   => transmitEnable
                                         );
                                         
TRANSMITTERCLK  : SCLK_Generator port map (clk          => clk,
                                           clk_out      => mClk
                                           );                                   
                                         
ENABLE_SIGNAL   : clock_enable port map( clk            => clk,
                                         enable         => transmitEnable,
                                         divider        => "000000000000000000000011" --100MHz setup
                                         );                                                                             

EFFECTS         : EffectRouting port map( clk           => clk,
                                          audioEnable   => transmitReady,
                                          delayTimeIn   => delayTime,
                                          selection     => switch,
                                          audioIn       => audioRaw,
                                          audioOut      => audioProcessed
                                          );

end Behavioral;
