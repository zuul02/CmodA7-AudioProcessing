library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_TOP is
    Port (
        CLK12MHZ : in  std_logic;
        RST       : in  std_logic;
        sw        : in  std_logic_vector(10 downto 0);
        btnL      : in  std_logic;
        btnC      : in  std_logic;
        btnR      : in  std_logic;
        btnU      : in  std_logic;
        UART_TXD  : out std_logic;
        UART_RXD  : in  std_logic
    );
end main_TOP;

architecture Behavioral of main_TOP is
begin
    state_monitor_send_inst : entity work.state_monitor_send
        port map (
            CLK12MHZ => CLK12MHZ,
            RST       => RST,
            sw        => sw,
            btnL      => btnL,
            btnC      => btnC,
            btnR      => btnR,
            btnU      => btnU,
            UART_TXD  => UART_TXD,
            UART_RXD  => UART_RXD
        );
end Behavioral;