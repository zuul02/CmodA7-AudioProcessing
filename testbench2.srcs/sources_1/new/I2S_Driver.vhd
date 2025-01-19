----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.11.2024 13:29:20
-- Design Name: 
-- Module Name: I2S_Driver - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2S_Driver is
  Port (clock : in std_logic;
        aud_clock : out std_logic;
        lock : out std_logic);
end I2S_Driver;

architecture Behavioral of I2S_Driver is
signal audio_Clock : std_logic;
signal locked_status : std_logic;

component clk_wiz_0 is

    Port(clk_out1 : out std_logic;
         reset : in std_logic;
         locked : out std_logic;
         clk_in1 : in std_logic);
end component;


begin

CLOCK_CONV : clk_wiz_0 port map (clk_out1 => audio_Clock, reset => '0', locked => locked_status, clk_in1 => clock);
aud_clock <= audio_Clock;
lock <= locked_status; 
end Behavioral;
