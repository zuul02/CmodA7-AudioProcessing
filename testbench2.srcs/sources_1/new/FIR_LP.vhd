--author: Henrik Schmidt
--date: 05.01.2025
--version: V0.1


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity FIR_LP is
Generic( width      : integer := 16;
         input_width : integer := 16;
         FIR_TAPS    : integer range 0 to 101 := 70
         );
  Port (clk         : in std_logic;
        audioEnable : in std_logic;
        audioIn     : in std_logic_vector((width - 1) downto 0);
        audioOut    : out std_logic_vector((width - 1) downto 0)
        );
end FIR_LP;

architecture Behavioral of FIR_LP is

attribute use_dsp : string;
attribute use_dsp of Behavioral : architecture is "yes";

constant MAC_Width : integer := input_width + width;

type input_reg is array (0 to FIR_TAPS-1) of signed(input_width - 1 downto 0);
signal areg_s     :  input_reg := (others => (others =>'0'));

type multiplicationRegister is array (0 to FIR_TAPS-1) of signed((MAC_Width - 1) downto 0);
signal multReg          : multiplicationRegister := (others => (others=> '0'));

type dsp_register is array (0 to FIR_TAPS-1) of signed((MAC_Width - 1) downto 0);
signal dsp              : dsp_register := (others => (others =>'0'));

type coeffs is array (0 to FIR_TAPS-1) of signed((width - 1) downto 0);
signal coefficients     : coeffs := (x"0000",x"0000",x"FFFF",x"FFFF",x"FFFE",x"FFFD",x"FFFB",x"FFF9",x"FFF8",x"FFF7",x"FFF8",x"FFFB",x"0003",x"0011",x"0027",x"0047",x"0074",x"00B1",x"00FF",x"0160",x"01D7",x"0262",x"0302",x"03B5",x"0479",x"0549",x"0620",x"06F9",x"07CD",x"0896",x"094B",x"09E7",x"0A64",x"0ABD",x"0AEE",x"0AF5",x"0AD3",x"0A88",x"0A18",x"0987",x"08DA",x"0819",x"0749",x"0672",x"059A",x"04C8",x"0400",x"0348",x"02A1",x"020F",x"0191",x"0129",x"00D3",x"0091",x"005E",x"0038",x"001E",x"000D",x"0002",x"FFFD",x"FFFA",x"FFFA",x"FFFB",x"FFFC",x"FFFD",x"FFFE",x"FFFF",x"0000",x"0000",x"0000");

signal currentAudio     : signed((width - 1) downto 0) := (others => '0');
signal nextAudio         : signed((width - 1) downto 0) := (others => '0');

signal nextOut          : std_logic_vector((width - 1) downto 0) := (others=>'0');

begin
 
process(clk)
begin
if clk'event and clk= '1' and audioEnable = '1' then

    currentAudio <= nextAudio;
    nextAudio <= signed(audioIn(width-1) & audioIn((width - 1) downto 1));
    
    audioOut <= nextOut;
    nextOut <= std_logic_vector(dsp(0)((MAC_Width - 1) downto (width)));
    
    for count in 0 to FIR_TAPS - 1 loop    
        areg_s(count) <= signed(audioIn);
        
        if ( count < FIR_TAPS - 1) then
            multReg(count) <= areg_s(count) * coefficients(count);
            dsp(count) <= dsp(count + 1) + multReg(count);
        elsif (count = FIR_TAPS-1) then
            dsp(count) <= areg_s(count) * coefficients(count);
        end if;
    end loop;
end if;
end process;

end Behavioral;
