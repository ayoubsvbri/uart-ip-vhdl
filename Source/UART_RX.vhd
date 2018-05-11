-- UART_RX asynchronous receiver

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


entity UART_RX is
generic(
	clk_baudrate : integer := 5208 );						-- (50000000) / (9600)
port(	clk : in std_logic;									-- clock
		rst : in std_logic;									-- reset
		RX_data_in : in std_logic;							-- RX line input
		RX_data_out : out std_logic_vector(7 downto 0);		-- 8 bit data received
		RX_finish : out std_logic );						-- active when data is received
end UART_RX;


architecture diagram of UART_RX is
	type state_type is (idle_state,start_state,data_state,stop_state);		-- finite state machine configuration

	signal current_state : state_type := idle_state;
	signal count_8 : integer range 0 to 7 := 0;								-- used for counting the number of bits sent
	signal count_clk : integer range 0 to (clk_baudrate - 1) := 0;
	signal RX_out : std_logic_vector (7 downto 0) := (others => '0');
	signal RX_end : std_logic := '0';

begin

RX_state_machine : process(clk, rst)

begin

if rst = '1' then

	current_state <= idle_state;
	count_8 <= 0;
	count_clk <= 0;
	RX_out <= (others => '0');
	RX_end <= '0';

elsif ( rising_edge(clk) ) then

	case current_state is

		when idle_state => 		-- idle state, wait for start bit
			count_8 <= 0;
			count_clk <= 0;
			RX_end <= '0';

		if(RX_data_in = '0') then
			current_state <= start_state;
		else
			current_state <= idle_state;
		end if;

		when start_state =>

			if count_clk = (clk_baudrate - 1)/2 then

				if (RX_data_in = '0') then		-- check if start bit is received
					count_clk <= 0;				-- synchronisation on the middle of the start bit
					current_state <= data_state;
				else
					current_state <= idle_state;	-- it was not a start bit but a glitch, back to idle state
				end if;
			else
				count_clk <= count_clk + 1;
				current_state <= start_state;
			end if;

		when data_state =>

			if count_clk < (clk_baudrate - 1) then
				count_clk <= count_clk + 1;
				current_state <= data_state;
			else
				count_clk <= 0;
				RX_out(count_8) <= RX_data_in;

				if count_8 < 7 then
					count_8 <= count_8 + 1;
					current_state <= data_state;
				else								-- if we received all data then go to stop_state
					count_8 <= 0;
					current_state <= stop_state;
				end if;
			end if;

		when stop_state =>

			if count_clk < (clk_baudrate - 1) then
				count_clk <= count_clk + 1;
				current_state <= stop_state;
			else
				if ( RX_data_in = '1' ) then		-- check is stop bit is received correctly
					count_clk <= 0;
					RX_end <= '1';
					current_state <= idle_state;	-- go back to idle state
				end if;
			end if;

		when others =>

			current_state <= idle_state;			-- go back to idle state
	end case;
end if;

end process RX_state_machine;

RX_data_out <= RX_out;
RX_finish <= RX_end;

end diagram;
