--author: Henrik Schmidt
--date: 11.01.2025
--version: V0.1


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity SCLK_Generator is
  Port (clk         : in std_logic;
        clk_out     : out std_logic
        );
end SCLK_Generator;

architecture Behavioral of SCLK_Generator is

signal output       : std_logic := '0';
signal nextOutput       : std_logic := '0';

begin

--constant mapping
clk_out <= output;

CLOCK : process(clk)
begin

    if clk'event and clk = '0' then
        output <= nextOutput;
    end if;
end process;

COUNTING : process(output)
begin
    nextOutput <= not output;
end process;
end Behavioral;
