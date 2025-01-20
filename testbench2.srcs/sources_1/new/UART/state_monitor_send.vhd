library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity state_monitor_send is
    Port (
        CLK100MHZ : in  std_logic;
        RST       : in  std_logic;
        sw        : in  std_logic_vector(10 downto 0);
        btnL      : in  std_logic;
        btnC      : in  std_logic;
        btnR      : in  std_logic;
        btnU      : in  std_logic;
        UART_TXD  : out std_logic;
        UART_RXD  : in  std_logic
    );
end state_monitor_send;

architecture Behavioral of state_monitor_send is

    ------------------------------------------------------------------------------
    -- Protokoll-Konstanten (5-Byte-Paket)
    ------------------------------------------------------------------------------
    constant START_BYTE  : std_logic_vector(7 downto 0) := x"AA";
    constant STOP_BYTE   : std_logic_vector(7 downto 0) := x"FF";
    constant DATA_LENGTH : std_logic_vector(7 downto 0) := x"01";

    -- Befehle für Schiebeschalter
    constant CMD_SW0  : std_logic_vector(7 downto 0) := x"10";
    constant CMD_SW1  : std_logic_vector(7 downto 0) := x"11";
    constant CMD_SW2  : std_logic_vector(7 downto 0) := x"12";
    constant CMD_SW3  : std_logic_vector(7 downto 0) := x"13";
    constant CMD_SW4  : std_logic_vector(7 downto 0) := x"14";
    constant CMD_SW5  : std_logic_vector(7 downto 0) := x"15";
    constant CMD_SW6  : std_logic_vector(7 downto 0) := x"16";
    constant CMD_SW7  : std_logic_vector(7 downto 0) := x"17";
    constant CMD_SW8  : std_logic_vector(7 downto 0) := x"18";
    constant CMD_SW9  : std_logic_vector(7 downto 0) := x"19";
    constant CMD_SW10 : std_logic_vector(7 downto 0) := x"1A";

    -- Befehle für Taster
    constant CMD_BTNL : std_logic_vector(7 downto 0) := x"20";
    constant CMD_BTNC : std_logic_vector(7 downto 0) := x"21";
    constant CMD_BTNR : std_logic_vector(7 downto 0) := x"22";
    constant CMD_BTNU : std_logic_vector(7 downto 0) := x"23";

    -- Paketgröße: 5 Byte
    constant PACKET_SIZE : integer := 5;

    ------------------------------------------------------------------------------
    -- Signale für die Zustandserkennung
    ------------------------------------------------------------------------------
    signal pending_cmd   : std_logic_vector(7 downto 0) := (others => '0');
    signal pending_data  : std_logic_vector(7 downto 0) := (others => '0');
    signal pending_valid : std_logic := '0';  -- wird auf '1' gesetzt, wenn eine Änderung detektiert wurde

    -- Register zur Speicherung der vorigen Werte
    signal prev_sw   : std_logic_vector(10 downto 0) := (others => '0');
    signal prev_btnL : std_logic := '0';
    signal prev_btnC : std_logic := '0';
    signal prev_btnR : std_logic := '0';
    signal prev_btnU : std_logic := '0';

    ------------------------------------------------------------------------------
    -- Zustandsmaschine für den Paketversand (UART-Sender)
    ------------------------------------------------------------------------------
    type tx_state_type is (idle, load_packet, send_byte, wait_uart);
    signal tx_state   : tx_state_type := idle;
    signal byte_index : integer range 0 to PACKET_SIZE-1 := 0;

    type packet_array is array (0 to PACKET_SIZE-1) of std_logic_vector(7 downto 0);
    signal packet_mem : packet_array;

    ------------------------------------------------------------------------------
    -- UART-Schnittstellen-Signale (wie im funktionierenden stateCheck_TOP)
    ------------------------------------------------------------------------------
    signal DIN       : std_logic_vector(7 downto 0);  -- Daten, die an die UART gesendet werden
    signal DIN_VLD   : std_logic;                     -- Data Valid: aktiviert, wenn DIN gültig ist
    signal DIN_RDY   : std_logic;                     -- 1 = UART ist bereit, ein neues Byte zu übernehmen
    signal DOUT      : std_logic_vector(7 downto 0);  -- wird als Vektor deklariert
    signal DOUT_VLD  : std_logic;
    signal FRAME_ERROR, PARITY_ERROR : std_logic;

    -- Wir nutzen DIN_RDY als Kennzeichen, dass der UART bereit ist:
    signal uart_ready : std_logic;
begin

    uart_ready <= DIN_RDY;

    ------------------------------------------------------------------------------
    -- Instanziierung der externen UART-Komponente
    ------------------------------------------------------------------------------
    uart_inst : entity work.UART
        generic map(
            CLK_FREQ      => 12_000_000,  -- 100 MHz
            BAUD_RATE     => 115200,       -- gewünschte Baudrate
            PARITY_BIT    => "none",
            USE_DEBOUNCER => False
        )
        port map(
            CLK          => CLK100MHZ,
            RST          => RST,
            UART_TXD     => UART_TXD,
            UART_RXD     => UART_RXD,
            DIN          => DIN,
            DIN_VLD      => DIN_VLD,
            DIN_RDY      => DIN_RDY,
            DOUT         => DOUT,
            DOUT_VLD     => DOUT_VLD,
            FRAME_ERROR  => FRAME_ERROR,
            PARITY_ERROR => PARITY_ERROR
        );

    ------------------------------------------------------------------------------
    -- Prozess: Zustandserkennung (State Detector)
    -- Vergleicht aktuelle Eingangswerte mit gespeicherten Vorwerten
    ------------------------------------------------------------------------------
    process(CLK100MHZ, RST)
    begin
        if RST = '1' then
            pending_valid <= '0';
            prev_sw       <= (others => '0');
            prev_btnL     <= '0';
            prev_btnC     <= '0';
            prev_btnR     <= '0';
            prev_btnU     <= '0';
        elsif rising_edge(CLK100MHZ) then
            if sw(0) /= prev_sw(0) then
                pending_cmd  <= CMD_SW0;
                pending_data <= (others => '0'); pending_data(0) <= sw(0);
                prev_sw(0)   <= sw(0);
                pending_valid <= '1';
            elsif sw(1) /= prev_sw(1) then
                pending_cmd  <= CMD_SW1;
                pending_data <= (others => '0'); pending_data(0) <= sw(1);
                prev_sw(1)   <= sw(1);
                pending_valid <= '1';
            elsif sw(2) /= prev_sw(2) then
                pending_cmd  <= CMD_SW2;
                pending_data <= (others => '0'); pending_data(0) <= sw(2);
                prev_sw(2)   <= sw(2);
                pending_valid <= '1';
            elsif sw(3) /= prev_sw(3) then
                pending_cmd  <= CMD_SW3;
                pending_data <= (others => '0'); pending_data(0) <= sw(3);
                prev_sw(3)   <= sw(3);
                pending_valid <= '1';
            elsif sw(4) /= prev_sw(4) then
                pending_cmd  <= CMD_SW4;
                pending_data <= (others => '0'); pending_data(0) <= sw(4);
                prev_sw(4)   <= sw(4);
                pending_valid <= '1';
            elsif sw(5) /= prev_sw(5) then
                pending_cmd  <= CMD_SW5;
                pending_data <= (others => '0'); pending_data(0) <= sw(5);
                prev_sw(5)   <= sw(5);
                pending_valid <= '1';
            elsif sw(6) /= prev_sw(6) then
                pending_cmd  <= CMD_SW6;
                pending_data <= (others => '0'); pending_data(0) <= sw(6);
                prev_sw(6)   <= sw(6);
                pending_valid <= '1';
            elsif sw(7) /= prev_sw(7) then
                pending_cmd  <= CMD_SW7;
                pending_data <= (others => '0'); pending_data(0) <= sw(7);
                prev_sw(7)   <= sw(7);
                pending_valid <= '1';
            elsif sw(8) /= prev_sw(8) then
                pending_cmd  <= CMD_SW8;
                pending_data <= (others => '0'); pending_data(0) <= sw(8);
                prev_sw(8)   <= sw(8);
                pending_valid <= '1';
            elsif sw(9) /= prev_sw(9) then
                pending_cmd  <= CMD_SW9;
                pending_data <= (others => '0'); pending_data(0) <= sw(9);
                prev_sw(9)   <= sw(9);
                pending_valid <= '1';
            elsif sw(10) /= prev_sw(10) then
                pending_cmd  <= CMD_SW10;
                pending_data <= (others => '0'); pending_data(0) <= sw(10);
                prev_sw(10)  <= sw(10);
                pending_valid <= '1';
            elsif btnL /= prev_btnL then
                pending_cmd  <= CMD_BTNL;
                pending_data <= (others => '0'); pending_data(0) <= btnL;
                prev_btnL    <= btnL;
                pending_valid <= '1';
            elsif btnC /= prev_btnC then
                pending_cmd  <= CMD_BTNC;
                pending_data <= (others => '0'); pending_data(0) <= btnC;
                prev_btnC    <= btnC;
                pending_valid <= '1';
            elsif btnR /= prev_btnR then
                pending_cmd  <= CMD_BTNR;
                pending_data <= (others => '0'); pending_data(0) <= btnR;
                prev_btnR    <= btnR;
                pending_valid <= '1';
            elsif btnU /= prev_btnU then
                pending_cmd  <= CMD_BTNU;
                pending_data <= (others => '0'); pending_data(0) <= btnU;
                prev_btnU    <= btnU;
                pending_valid <= '1';
            else
                pending_valid <= '0';
            end if;
        end if;
    end process;
    
    ------------------------------------------------------------------------------
    -- Paket-Sendeprozess (UART-Sender)
    -- Baut das Paket in ein Array und verschickt es byteweise über DIN
    ------------------------------------------------------------------------------
    process(CLK100MHZ, RST)
    begin
        if RST = '1' then
            tx_state   <= idle;
            byte_index <= 0;
            DIN_VLD    <= '0';
            DIN        <= (others => '0');
        elsif rising_edge(CLK100MHZ) then
            case tx_state is
                when idle =>
                    if pending_valid = '1' then
                        tx_state <= load_packet;
                    else
                        tx_state <= idle;
                    end if;
                when load_packet =>
                    packet_mem(0) <= START_BYTE;
                    packet_mem(1) <= pending_cmd;
                    packet_mem(2) <= DATA_LENGTH;
                    packet_mem(3) <= pending_data;
                    packet_mem(4) <= STOP_BYTE;
                    byte_index   <= 0;
                    tx_state     <= send_byte;
                when send_byte =>
                    if (DIN_VLD = '0') and (uart_ready = '1') then
                        DIN <= packet_mem(byte_index);
                        DIN_VLD <= '1';
                        tx_state <= wait_uart;
                    end if;
                when wait_uart =>
                    if DIN_VLD = '1' then
                        DIN_VLD <= '0';  -- DIN_VLD wird nach einer Taktperiode zurückgesetzt
                    elsif uart_ready = '1' then
                        if byte_index < PACKET_SIZE - 1 then
                            byte_index <= byte_index + 1;
                            tx_state   <= send_byte;
                        else
                            tx_state     <= idle;
                        end if;
                    end if;
                when others =>
                    tx_state <= idle;
            end case;
        end if;
    end process;

end Behavioral;