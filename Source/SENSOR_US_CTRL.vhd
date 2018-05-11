-- SENSOR_US_CTRL

-- Realised by Ayoub SABRI, Antoine SOMSAY, Adam VRIGNAUD
-- Polytech Sorbonne | EISE 3
-- Last modified : 21/02/2018

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SENSOR_US_CTRL is
port( 	clk: in std_logic;									-- clock (50 MHz)
		rst: in std_logic;									-- reset
		sensor_echo : in std_logic;							-- sensor's output
		start_measure: in std_logic;						-- start new measure (from board)
		RX_finish : in std_logic;							-- start new measure (from terminal)
		sensor_trig : out std_logic;						-- trigger (10 us) to activate the sensor
		distance_cm: out std_logic_vector(8 downto 0);		-- distance value expressed in cm
		send_data : out std_logic );						-- data is ready to be displayed
end SENSOR_US_CTRL;

architecture behav of SENSOR_US_CTRL is

	type state_type is (idle_state,start_state,count_state,stop_state,data_state);	-- FSM configuration
	signal current_state : state_type := idle_state;
	signal count_clk : integer := 0;		-- allows to calculate distance_cm
	signal count_start : integer := 0;		-- counter for 10 us sensor_trig signal
	signal distance_cm_tmp: integer:= 0;

begin

	process(clk,rst,sensor_echo,start_measure)

	begin

	if rst = '1' then

		current_state <= idle_state;
		distance_cm_tmp <= 0;
		send_data <= '0';
		count_clk <= 0;
		count_start <= 0;
		sensor_trig <= '0';

	elsif rising_edge(clk) then

		case current_state is

			when idle_state =>
				count_clk <= 0;
				count_start <= 0;
				sensor_trig <= '0';
				send_data <= '0';

				if(start_measure = '1' or RX_finish = '1') then		-- wait until a new acquisition is requested
					current_state <= start_state;
				else
					current_state <= idle_state;
				end if;

			when start_state =>										-- send a 10 us pulse to start a new measure

				if count_start < 510 then
					count_start <= count_start + 1;
					sensor_trig <= '1';
				else
					sensor_trig <= '0';
				end if;

				if sensor_echo = '1' then							-- output is available to be read, pass to next
					current_state <= count_state;					-- state to proceed with time measurement
				else
					current_state <= start_state;
				end if;

			when count_state =>										-- time measurement
				distance_cm_tmp <= 0;
				count_clk <= count_clk + 1;							-- increase count_clk as long as sensor_echo is high

				if sensor_echo = '0' then							-- once time measurement is done, pass to stop_state
					current_state <= stop_state;					-- state to proceed with distance calculation
				end if;

			when stop_state =>
				distance_cm_tmp <= 34 * count_clk / 100000;			-- please refer to annexe 1 for more details
				current_state <= data_state;

			when data_state =>										-- output distance value in cm
				distance_cm <= std_logic_vector(to_unsigned(distance_cm_tmp,distance_cm'length));
				send_data <= '1';									-- data is ready to be displayed
				current_state <= idle_state;

			when others =>
				current_state <= idle_state;						-- go back to idle state and wait for a new start

		end case;

	end if;

end process;

end behav;
