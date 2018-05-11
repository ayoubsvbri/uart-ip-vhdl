-- Decoder BCD to 7 segments
-- Please refer to annexe 2 for the BCD to 7 segment conversion table

-- Realised by Ayoub SABRI, Antoine SOMSAY, Adam VRIGNAUD
-- Polytech Sorbonne | EISE 3
-- Last modified : 06/05/2018

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity Decoder_BCD_7segment is
port (clk : in std_logic;
		rst : in std_logic;
		data_BCD : in std_logic_vector(23 downto 0);
		unit : out std_logic_vector(6 downto 0);
		ten : out std_logic_vector(6 downto 0);
		hundred : out std_logic_vector(6 downto 0));
end Decoder_BCD_7segment;

architecture behav of Decoder_BCD_7segment is

  signal unit_tmp: std_logic_vector(6 downto 0);
  signal ten_tmp: std_logic_vector(6 downto 0);
  signal hundred_tmp: std_logic_vector(6 downto 0);

begin

	process(clk)

	begin

		if rst = '1' then	-- set to default value (zero)

			unit_tmp <= "1000000";
			ten_tmp <= "1000000";
			hundred_tmp <= "1000000";

		elsif rising_edge(clk) then

			case data_BCD(23 downto 16) is
				when "00000000" =>
					unit_tmp <= "1000000";
	        	when "00000001" =>
					unit_tmp <= "1111001";
				when "00000010" =>
					unit_tmp <= "0100100";
				when "00000011" =>
					unit_tmp <= "0110000";
				when "00000100" =>
					unit_tmp <= "0011001";
				when "00000101" =>
					unit_tmp <= "0010010";
				when "00000110" =>
					unit_tmp <= "0000010";
				when "00000111" =>
					unit_tmp <= "1111000";
				when "00001000" =>
					unit_tmp <= "0000000";
				when "00001001" =>
					unit_tmp <= "0010000";
				when others =>
					unit_tmp <= "0000110";
			end case;

			case data_BCD(15 downto 8) is
				when "00000000" =>
					ten_tmp <= "1000000";
				when "00000001" =>
					ten_tmp <= "1111001";
				when "00000010" =>
					ten_tmp <= "0100100";
				when "00000011" =>
					ten_tmp <= "0110000";
				when "00000100" =>
					ten_tmp <= "0011001";
				when "00000101" =>
					ten_tmp <= "0010010";
				when "00000110" =>
					ten_tmp <= "0000010";
				when "00000111" =>
					ten_tmp <= "1111000";
				when "00001000" =>
					ten_tmp <= "0000000";
				when "00001001" =>
					ten_tmp <= "0010000";
				when others =>
					ten_tmp <= "0000110";
			end case;

			case data_BCD(7 downto 0) is
				when "00000000" =>
					hundred_tmp <= "1000000";
				when "00000001" =>
					hundred_tmp <= "1111001";
				when "00000010" =>
					hundred_tmp <= "0100100";
				when "00000011" =>
					hundred_tmp <= "0110000";
				when "00000100" =>
					hundred_tmp <= "0011001";
				when "00000101" =>
					hundred_tmp <= "0010010";
				when "00000110" =>
					hundred_tmp <= "0000010";
				when "00000111" =>
					hundred_tmp <= "1111000";
				when "00001000" =>
					hundred_tmp <= "0000000";
				when "00001001" =>
					hundred_tmp <= "0010000";
				when others =>
					hundred_tmp <= "0000110";
			end case;

		end if;

	end process;

    hundred <= hundred_tmp;
    ten <= ten_tmp;
    unit <= unit_tmp;

end behav;
