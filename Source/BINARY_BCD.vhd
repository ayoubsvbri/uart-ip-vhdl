-- Binary to BCD converter
-- This module allow to convert a 9 bits binary vector to a 24 bits BCD vector
-- The input signal is decomposed in three parts : units, tens and hundred

-- Realised by Ayoub SABRI, Antoine SOMSAY, Adam VRIGNAUD
-- Polytech Sorbonne | EISE 3
-- Last modified : 06/05/2018

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BINARY_BCD is
port (clk : in  std_logic;
	rst : in std_logic;
	data_in : in  std_logic_vector(8 downto 0);
	data_out : out std_logic_vector(23 downto 0));
end BINARY_BCD;

architecture behav of BINARY_BCD is
begin

process (clk)
begin

	if rst = '1' then
		data_out <= (others => '0');
	elsif rising_edge(clk) then
		data_out(7 downto 0) <= conv_std_logic_vector((conv_integer(data_in) / 100) MOD 10,8);	-- hundreds
		data_out(15 downto 8) <= conv_std_logic_vector((conv_integer(data_in) / 10) MOD 10,8);	-- tens
		data_out(23 downto 16) <= conv_std_logic_vector((conv_integer(data_in)) MOD 10,8);	-- units
	end if;

end process;
end behav;
