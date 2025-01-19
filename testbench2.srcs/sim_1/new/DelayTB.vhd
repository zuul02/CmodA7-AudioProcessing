----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.01.2025 08:56:09
-- Design Name: 
-- Module Name: DelayTB - Behavioral
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

entity DelayTB is
--  Port ( );
end DelayTB;

architecture Behavioral of DelayTB is

component Delay is
  Generic(width         : integer := 16
          );
    Port(clk        : in std_logic;
         audioIn    : in std_logic_vector((width - 1) downto 0);
         audioOut   : out std_logic_vector((width - 1) downto 0);
         Enable     : in std_logic
         );
end component;

component RAM16Bit is
Generic(width       : integer := 16;
        depth       : integer := 50000
        );
  Port (clk         : in std_logic;
        addr        : in std_logic_vector(15 downto 0);
        readEnable  : in std_logic;
        writeEnable : in std_logic;
        dataOut     : out std_logic_vector((width - 1) downto 0);
        dataIn      : in std_logic_vector((width - 1) downto 0)
        );
end component;

signal clk      :std_logic;
signal Enable   :std_logic;
signal audioIn  :std_logic_vector(15 downto 0);
signal audioOut :std_logic_vector(15 downto 0);
signal adress   :std_logic_vector(15 downto 0); 
signal dataIn, dataOut : std_logic_vector(15 downto 0);
signal readEnb, writeEnb : std_logic;

begin

process
begin
clk <= '1';
wait for 10ns;
clk <= '0';
wait for 10ns;

end process;

--DelayTest

process
begin
Enable <= '1';
wait for 20ns;
Enable <= '0';
wait for 80ns;
end process;

process
begin
audioIn <= "1111111111111111";
wait for 100ns;
audioIn <= (others => '0');
wait for 100ns;
end process;

TEST1 : Delay port map(clk => clk, audioIn => audioIn, audioOut => audioOut, Enable => Enable);


--RamTest

--process
--begin
--readEnb <= '0';
--writeEnb <= '0';
--adress <= "0000000000000000";
--dataIn <= (others => '0');
--wait for 20ns;
--dataIn <= "1111111111111111";
--writeEnb <= '1';
--wait for 50 ns;
--writeEnb <= '0';
--readEnb <= '1';
--wait for 50ns;
--end process;


--TEST2 : RAM16Bit port map(clk => clk, addr => adress, readEnable => readEnb, writeEnable => writeEnb, dataOut => dataOut, dataIn => dataIn);

end Behavioral;
