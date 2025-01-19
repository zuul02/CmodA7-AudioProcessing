--date: 08.12.2024
--version: V0.1
--author: Henrik Schmidt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity clock_enable is
  Port (clk     : in std_logic;
        enable  : out std_logic;
        divider : in unsigned(23 downto 0)
       );
end clock_enable;

architecture Behavioral of clock_enable is

signal count : unsigned(23 downto 0) := "000000000000000000000000";
signal next_count : unsigned(23 downto 0) := "000000000000000000000000";
begin

COUNT_UP: process(clk)
begin
if clk'event and clk = '1' then
    count <= next_count;
end if;
end process;


GENERATE_OUTPUT: process(count)
begin
    next_count <= count + 1;
    
    if count = divider then
        enable <= '1';
        next_count <= "000000000000000000000000";
    else
        enable <= '0';   
    end if;
      
end process;
end Behavioral;
