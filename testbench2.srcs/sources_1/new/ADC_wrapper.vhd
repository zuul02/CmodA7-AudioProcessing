--date: 08.12.2024
--version: V0.1
--author: Henrik Schmidt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity ADC_wrapper is
  Port (clk         : in std_logic;
        data_out    : out std_logic_vector(15 downto 0);
        potdata     : out std_logic_vector(15 downto 0);
        Pos         : in std_logic;
        Neg         : in std_logic;
        PotiP       : in std_logic;
        PotiN       : in std_logic;
        audio_clock : in std_logic
        );
end ADC_wrapper;

architecture Behavioral of ADC_wrapper is
component xadc_wiz_1 is
 port
   (
    daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
    den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
    di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
    dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
    do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
    dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
    reset_in        : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
    vauxp4          : in  STD_LOGIC;                         -- Auxiliary Channel 5
    vauxn4          : in  STD_LOGIC;
    vauxn12         : in STD_LOGIC;
    vauxp12         : in STD_LOGIC;
    busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
    channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
    eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
    eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
    alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
    vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
    vn_in           : in  STD_LOGIC
);
end component;

type statetype  is (AUDIO, POTI);
signal state    : statetype := AUDIO;

signal channel_out : std_logic_vector(4 downto 0); --channel selection output
signal daddr_in  : std_logic_vector(6 downto 0) := "0010100"; --digital adress in 
signal eoc_out : std_logic; --end of conversation

signal do_out  : std_logic_vector(15 downto 0);  --digital output

signal anal_p, anal_n   : std_logic;      --positive, negative analog signal
signal potP          : std_logic;
signal potN          : std_logic;

signal enable : std_logic;
signal shifted_data : std_logic_vector( 11 downto 0);
signal bipolar_data : std_logic_vector( 12 downto 0);
signal channel20Buff : std_logic_vector(15 downto 0);
signal channel28Buff : std_logic_vector(15 downto 0);


begin
inst_xadc : xadc_wiz_1 
      port map
      (
        daddr_in        => daddr_in,
        den_in          => eoc_out,
        di_in           => "0000000000000000",
        dwe_in          => '0',
        do_out          => do_out,
        drdy_out        => open,
        dclk_in         => clk,
        reset_in        => '0',
        vauxp4          => anal_p,
        vauxn4          => anal_n,
        vauxn12         => PotiN,
        vauxp12         => PotiP,
        busy_out        => open, 
        channel_out     => channel_out,
        eoc_out         => eoc_out,
        eos_out         => open,
        alarm_out       => open,
        vp_in           => '0',
        vn_in           => '0');
        
        process(clk)
        begin
           if clk'event and clk = '1' then
            
            case state is
                when AUDIO => daddr_in <= "0010100";
                          channel20Buff <= do_out;
                          state <= POTI;
                when POTI => daddr_in <= "0011100";
                          channel28Buff <= do_out;
                          state <= AUDIO;
            end case;
            end if;
        end process;
        
        process(audio_clock, channel20Buff)
        begin
            if audio_clock = '1' then
                shifted_data <= channel20Buff(15 downto 4);
                bipolar_data <= std_logic_vector(signed("0" & shifted_data) - 2048);
            end if;
       end process;
       
      data_out <=  bipolar_data & "000";
      potdata <= "0000" & channel28Buff(15 downto 4);
      anal_p <= Pos;
      anal_n <= Neg;

end Behavioral;
