--author: Henrik Schmidt
--date: 05.01.2025
--version: V0.1

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity Delay is
  Generic(width         : integer := 16
          );
    Port(clk        : in std_logic;
         audioIn    : in std_logic_vector((width - 1) downto 0);
         audioOut   : out std_logic_vector((width - 1) downto 0);
         delayTime  : in std_logic_vector(15 downto 0);
         Enable     : in std_logic
         );
end Delay;

architecture Behavioral of Delay is

component Mixer is
  Generic(width         : integer := 16
          );         
  Port (audio1In        : in std_logic_vector((width - 1) downto 0); 
        audio2In        : in std_logic_vector((width - 1) downto 0);
        audioOut        : out std_logic_vector((width - 1) downto 0);
        clk             : in std_logic;
        Enable          : in std_logic
        );
end component;

component DelayLine is
  Generic(width         : integer := 16;
          depth         : integer := 30000
          );
  Port (audioIn         : in std_logic_vector((width - 1) downto 0);
        audioOut        : out std_logic_vector((width - 1) downto 0);
        delayTime       : in std_logic_vector(15 downto 0);
        clk             : in std_logic;
        Enable          : in std_logic
        );
end component;

signal delayedSample    : std_logic_vector((width - 1) downto 0) := (others => '0');
signal audioOutBuff     : std_logic_vector((width - 1) downto 0) := (others => '0');

begin

audioOut <= audioOutBuff;

MIXER1 : Mixer port map( audio1In        => audioIn,
                         audio2In        => delayedSample,
                         audioOut        => audioOutBuff,
                         clk             => clk,
                         Enable          => Enable
                         );

DELAYLINE1 : DelayLine port map(audioIn     => audioOutBuff,
                                audioOut    => delayedSample,
                                delayTime   => delayTime,
                                clk         => clk,
                                Enable      => Enable
                                );                     
                       

end Behavioral;


