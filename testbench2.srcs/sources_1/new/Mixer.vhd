--author: Henrik Schmidt
--date: 05.01.2025
--version: V0.1

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity Mixer is
  Generic(width         : integer := 16
          );
  Port (audio1In        : in std_logic_vector((width - 1) downto 0); 
        audio2In        : in std_logic_vector((width - 1) downto 0);
        audioOut        : out std_logic_vector((width - 1) downto 0);
        clk             : in std_logic;
        Enable          : in std_logic
        );
end Mixer;

architecture Behavioral of Mixer is

signal LSB          : std_logic_vector(1 downto 0);
signal audio1Buff   : std_logic_vector((width - 1) downto 0) := (others => '0');
signal audio2Buff   : std_logic_vector((width - 1) downto 0) := (others => '0');
signal audio1Buff2  : std_logic_vector((width - 1) downto 0) := (others => '0');
signal audio2Buff2  : std_logic_vector((width - 1) downto 0) := (others => '0');
signal nextOut      : std_logic_vector((width - 1) downto 0) := (others => '0');   

begin

LSB(0) <= audio1In(0);
LSB(1) <= audio2In(0);
audioOut <= std_logic_vector(unsigned(audio1Buff) + unsigned(audio2Buff));
audio1Buff <= audio1In((width-1)) & audio1In((width - 1) downto 1);
audio2Buff <= audio2In((width-1)) & audio2In((width - 1) downto 1);


end Behavioral;
