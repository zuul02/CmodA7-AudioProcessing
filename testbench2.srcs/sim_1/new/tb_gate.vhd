----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2024 19:17:36
-- Design Name: 
-- Module Name: tb_gate - Behavioral
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

entity tb_gate is
--  Port ( );
end tb_gate;

architecture Behavioral of tb_gate is

component gate is
Port(   pass_in : in bit_vector(3 downto 0);
        pass_out : out bit_vector(3 downto 0);
        clk : in bit);
end component;

signal in_bits, out_bits : bit_vector(3 downto 0);
signal clock : bit;
begin

TEST: gate port map( pass_in => in_bits, 
                pass_out => out_bits, 
                clk => clock);
                
                
TAKT: process
begin

    clock <= '0';
    wait for 10 ns;
    clock <= '1';
    wait for 10ns;
end process;


DATA: process
begin

    in_bits <= "0000";
    wait for 100ns;
    in_bits <= "0001";
    wait for 100ns;
    in_bits <= "0010";
    wait for 100ns;
    in_bits <= "0100";
    wait for 100ns;
    in_bits <= "1000";
    wait for 100ns;

end process;
end Behavioral;
