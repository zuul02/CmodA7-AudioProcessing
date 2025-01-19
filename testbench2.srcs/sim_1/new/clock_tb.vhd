----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.11.2024 13:38:32
-- Design Name: 
-- Module Name: clock_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_tb is
--  Port ( );
end clock_tb;

architecture Behavioral of clock_tb is

component I2S_Driver is
  Port (clock : in std_logic;
        aud_clock : out std_logic;
        lock : out std_logic);
end component;

signal art_clock : std_logic;
signal div_clock : std_logic;
signal locked : std_logic;

begin

TEST : I2S_Driver port map(clock => art_clock, aud_clock => div_clock, lock => locked);

process
begin
art_clock <= '1';
wait for 10ns;
art_clock <= '0';
wait for 10 ns;
end process;

end Behavioral;
