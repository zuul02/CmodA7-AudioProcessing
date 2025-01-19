--author: Henrik Schmidt
--date: 11.01.2025
--version: V0.1

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EffectRouting is
Generic(width           : integer := 16
        );
  Port (clk             : in std_logic;
        audioEnable     : in std_logic;
        delayTimeIn       : in std_logic_vector(15 downto 0);
        selection       : in std_logic_vector(4 downto 0);
        audioIn         : in std_logic_vector((width - 1) downto 0);
        audioOut        : out std_logic_vector((width - 1) downto 0)
        );
end EffectRouting;

architecture Behavioral of EffectRouting is

component Delay is
  Generic(width         : integer := 16
          );
    Port(clk        : in std_logic;
         audioIn    : in std_logic_vector((width - 1) downto 0);
         audioOut   : out std_logic_vector((width - 1) downto 0);
         delayTime  : in std_logic_vector(15 downto 0);
         Enable     : in std_logic
         );
end component;

component FIR_LP is
Generic( width      : integer := 16;
         tabs       : integer := 100
         );
  Port (clk         : in std_logic;
        audioEnable : in std_logic;
        audioIn     : in std_logic_vector((width - 1) downto 0);
        audioOut    : out std_logic_vector((width - 1) downto 0)
        );
end component;

signal delayEnable      : std_logic := '0';
signal delayTime        : std_logic_vector(15 downto 0) := (others =>'0');
signal delayIn          : std_logic_vector((width - 1) downto 0) := (others => '0');
signal delayOut         : std_logic_vector((width - 1) downto 0) := (others => '0');

signal filterEnable     : std_logic := '0';
signal firIn            : std_logic_vector((width - 1) downto 0) := (others => '0');
signal firOut           : std_logic_vector((width - 1) downto 0) := (others => '0');

signal effect3Enb       : std_logic := '0';
signal processed        : std_logic_vector((width - 1) downto 0) := (others => '0');

begin
delayEnable <= selection(1) or selection(2) or selection(3) or selection(4);
filterEnable <= selection(0);

firIn <= audioIn;
audioOut <= processed;

ROUTING : process(clk)
begin

if clk'event and clk = '1' and audioEnable = '1' then
    if delayEnable = '1' then
        processed <= delayOut;
    else
        processed <= delayIn;
    end if;
    
    if filterEnable = '1' then
        delayIn <= firOut;
    else
        delayIn <= firIn;
    end if;
    
    if selection(4) = '1' then
           delayTime <= "1000000000000000";
    elsif selection(3) = '1' then
           delayTime <= "0000000100000000";
    elsif selection(2) = '1' then
           delayTime <= "0000000000010000";
    else 
           delayTime <= delayTimeIn;
    end if;
    
end if;

end process;

DELAY_EFFECT    : Delay port map(clk        => clk,
                                 audioIn    => delayIn,
                                 audioOut   => delayOut,
                                 delayTime  => delayTime,
                                 Enable     => audioEnable
                                 );
                                 
FILTER          : FIR_LP port map ( clk         => clk,
                                    audioEnable => audioEnable,
                                    audioIn     => firIn,
                                    audioOut    => firOut
                                    );

end Behavioral;
