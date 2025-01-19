--author: Henrik Schmidt
--date: 05.01.2025
--version: V0.1


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity DelayLine is
  Generic(width         : integer := 16;
          depth         : integer := 30000
          );
  Port (audioIn         : in std_logic_vector((width - 1) downto 0);
        audioOut        : out std_logic_vector((width - 1) downto 0);
        delayTime       : in std_logic_vector(15 downto 0);
        clk             : in std_logic;
        Enable          : in std_logic
        );
end DelayLine;

architecture Behavioral of DelayLine is

type memory is array (0 to (depth - 1)) of std_logic_vector((width - 1) downto 0);
signal ram    : memory := (others => (others => '0'));

signal nextOutput   : std_logic_vector((width-1) downto 0) := (others => '0');
signal nextInput    : std_logic_vector((width-1) downto 0) := (others => '0');

signal RamOutData   : std_logic_vector((width-1) downto 0) := (others => '0');
signal RamInData    : std_logic_vector((width-1) downto 0) := (others => '0');
signal delayTimeBuff: integer := 0;

begin

process(clk)
variable head : integer range 0 to (depth + 1) := 0;
variable tail : integer range 0 to ((2 * depth) + 1) := 0;
begin
    if clk'event and clk = '1' then
    delayTimeBuff <= to_integer(unsigned(delayTime));
    if delayTimeBuff > depth then
        delayTimeBuff <= depth;
    end if;
    audioOut <= RamOutData;
    RamInData <= audioIn;
    if Enable = '1' then
      
        if head < (depth - 1) then
            head := head + 1;
            tail := head + delayTimeBuff;
        else
            head := 0;
        end if;
        
        if tail > (depth - 1) then
            tail := tail - depth;
        end if;
       
        RamOutData <= ram(tail);
        ram(head) <= RamInData;
    end if;    
    end if;    
end process;

end Behavioral;
