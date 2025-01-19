--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
--Date        : Sun Dec  8 15:19:51 2024
--Host        : DESKTOP-SSD97QA running 64-bit major release  (build 9200)
--Command     : generate_target Audio_clock_wrapper.bd
--Design      : Audio_clock_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity Audio_clock_wrapper is
  port (
    clk_100MHz : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    locked : out STD_LOGIC;
    reset_rtl_0 : in STD_LOGIC
  );
end Audio_clock_wrapper;

architecture STRUCTURE of Audio_clock_wrapper is
  component Audio_clock is
  port (
    clk_100MHz : in STD_LOGIC;
    reset_rtl_0 : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    locked : out STD_LOGIC
  );
  end component Audio_clock;
begin
Audio_clock_i: component Audio_clock
     port map (
      clk_100MHz => clk_100MHz,
      clk_out1 => clk_out1,
      locked => locked,
      reset_rtl_0 => reset_rtl_0
    );
end STRUCTURE;
