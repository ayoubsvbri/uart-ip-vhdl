-- MAE_CTRL_TX

-- This IP employs a finite state machine in order to do three tasks :
-- 1. select the data to be sent
-- 2. convert the BCD data into ASCII
-- 3. send start signal to UART TX transmission

-- Made by Ayoub SABRI, Antoine SOMSAY, Adam VRIGNAUD
-- Polytech Sorbonne | EISE 3
-- Last modified : 14/03/2018

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity MAE_CTRL_TX is
port(	clk : in std_logic;									-- clock
		rst : in std_logic;									-- reset
		data_ready : in std_logic;							-- passes high when data_BCD_in is available
		count_in : in std_logic;							-- passes high when a byte is sent successfully by UART
		data_BCD_in : in std_logic_vector(23 downto 0); 	-- contain units, tens and hundreds of measured distance
		data_ASCII_out : out std_logic_vector(7 downto 0);	-- ASCII digit sent to through TX line
		TX_start : out std_logic );							-- make UART start new transmission
end MAE_CTRL_TX;


architecture behav of MAE_CTRL_TX is

	type state_type is (idle_state, hundred_state, ten_state, unit_state, space_state);		-- FSM configuration
	signal current_state : state_type := idle_state;
	signal data_BCD_prev : std_logic_vector(23 downto 0);	-- last data sent
	signal count : integer := 0;

begin

	process(clk, data_ready, count_in)
	begin

		if rst = '1' then

			current_state <= idle_state;
			count <= 0;
			data_BCD_prev <= (others => '0');
			data_ASCII_out <= (others => '0');
			TX_start <= '0';

		elsif rising_edge(clk) then

			case current_state is

				when idle_state =>
					data_ASCII_out <= (others => '0');
					TX_start <= '0';
					count <= 0;
					if data_ready = '1' then
						current_state <= hundred_state;
					else
						current_state <= idle_state;
					end if;

				when hundred_state =>
					data_BCD_prev <= data_BCD_in;	-- update last data sent with actual one
					data_ASCII_out <= conv_std_logic_vector(conv_integer(data_BCD_in(7 downto 0)) + 48, 8);		-- convert hundreds from BCD to ASCII
					count <= 0;

					if count_in = '1' then
						current_state <= ten_state;
					else
						current_state <= hundred_state;
						if count /= 1 then
							count <= count + 1;
							TX_start <= '0';
						else
							count <= count + 1;
							TX_start <= '1';	-- send hundreds through TX line
						end if;
					end if;

				when ten_state =>
					data_ASCII_out <= conv_std_logic_vector(conv_integer(data_BCD_in(15 downto 8)) + 48, 8);	-- convert tens from BCD to ASCII
					count <= 0;
					if count_in = '1' then
						current_state <= unit_state;
						TX_start <= '0';
					else
						current_state <= ten_state;
						if count /= 1 then
							count <= count + 1;
							TX_start <= '0';
						else
							count <= count + 1;
							TX_start <= '1';	-- send tens through TX line
						end if;
					end if;

				when unit_state =>
					data_ASCII_out <= conv_std_logic_vector(conv_integer(data_BCD_in(23 downto 16)) + 48, 8);	-- convert units from BCD to ASCII
					count <= 0;
					if count_in = '1' then
						current_state <= space_state;
						TX_start <= '0';
					else
						current_state <= unit_state;
						if count /= 1 then
							count <= count + 1;
							TX_start <= '0';
						else
							count <= count + 1;
							TX_start <= '1';	-- send units through TX line
						end if;
					end if;

				when space_state =>
					data_ASCII_out <= conv_std_logic_vector(32, 8);		-- space between two measures : 32 is the ASCII code of space character

					if count_in = '1' then
						current_state <= idle_state;
						TX_start <= '0';
					else
						current_state <= space_state;
						if count /= 1 then
							count <= count + 1;
							TX_start <= '0';
						else
							count <= count + 1;
							TX_start <= '1';
						end if;
					end if;

				when others =>
					current_state <= idle_state;	-- once all digits are sent go back to idle state

			end case;

		end if;

	end process;

end behav;
