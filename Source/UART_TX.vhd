-- UART_TX asynchronous transmitter

-- clk_baudrate : clk / baudrate
-- Please refer to documentation for more details

-- Realised by Ayoub SABRI, Antoine SOMSAY, Adam VRIGNAUD
-- Polytech Sorbonne | EISE 3
-- Last modified : 06/05/2018

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UART_TX is
generic(
	clk_baudrate : integer := 5208 );					-- (5000000 / 9600 )
port(	clk : in std_logic;								-- clock
		rst : in std_logic;								-- reset
		TX_start : in std_logic;						-- when active start transmission
		TX_data_in : in std_logic_vector(7 downto 0);	-- 8 bit data to send
		TX_data_out : out std_logic;					-- data sent through TX line
		TX_busy : out std_logic;						-- active when transmitter is sending data
		TX_finish : out std_logic );					-- active when transmission is done
end UART_TX;



architecture diagram of UART_TX is

	type state_type is (idle_state,start_state,data_state,stop_state);		-- finite state machine configuration

	signal current_state : state_type := idle_state;
	signal count_8 : integer range 0 to 7 := 0;								-- used for counting the number of bits sent
	signal count_clk : integer range 0 to (clk_baudrate-1) := 0;
	signal TX_in : std_logic_vector(7 downto 0) := (others => '0');
	signal TX_out : std_logic := '1';
	signal TX_active : std_logic := '0';
	signal TX_end : std_logic := '0';

begin

TX_state_machine : process(clk, rst)

begin

if rst = '1' then

	count_8 <= 0;
	current_state <= idle_state;
	count_clk <= 0;
	TX_out <= '1';
	TX_active <= '0';
	TX_end <= '0';

elsif ( rising_edge(clk) ) then

	case current_state is

		when idle_state => 					-- idle state, wait for start = '1'

			TX_out <= '1';
			TX_active <= '0';
			TX_end <= '0';
			count_8 <= 0;
			count_clk <= 0;

			if(TX_start = '1') then
				TX_in <= TX_data_in;
				current_state <= start_state;
			elsif(TX_start = '0') then
				current_state <= idle_state;
			end if;

		when start_state =>					-- start bit is sent through the TX line

			TX_out <= '0';
			TX_active <= '1';

			if (count_clk < clk_baudrate - 1) then
				count_clk <= count_clk + 1;
				current_state <= start_state;
			else
				count_clk <= 0;
				current_state <= data_state;
			end if;


		when data_state =>

			TX_out <= TX_in(count_8);		-- send next bit

			if ( count_clk < clk_baudrate - 1 ) then
				count_clk <= count_clk + 1;
				current_state <= data_state;
			else
				count_clk <= 0;
				if count_8 < 7 then
					count_8 <= count_8 + 1;
					current_state <= data_state;
				else
					count_8 <= 0;
					current_state <= stop_state;
				end if;
			end if;

		when stop_state =>

			TX_out <= '1';

			if ( count_clk < clk_baudrate - 1 ) then
				count_clk <= count_clk + 1;
				current_state <= stop_state;
			else
				TX_active <= '0';
				TX_end <= '1';
				current_state <= idle_state;
			end if;

		when others =>
			current_state <= idle_state;

	end case;

end if;

end process TX_state_machine;

TX_data_out <= TX_out;
TX_busy <= TX_active;
TX_finish <= TX_end;

end diagram;
