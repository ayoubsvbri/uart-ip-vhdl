-- IP_UART_US

-- This system allows the control of an ultra sound sensor which
-- permits to measure distance. Please read documentation and take
-- a look at the block diagram in order to understand how the system works

-- UART RX/TX features:
-- N81 protocol
-- Start bit , Stop bit , No Parity
-- Baud Rate : 9600 bps

-- Realised by Ayoub SABRI, Antoine SOMSAY, Adam VRIGNAUD
-- Polytech Sorbonne | EISE 3
-- Last modified : 14/03/2018


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity IP_UART_US is
port(	clk : in std_logic;						-- clock
		rst : in std_logic;						-- reset
		sensor_echo : in std_logic;				-- sensor's output
		start_measure : in std_logic;			-- start new measure (from board)
		RX_data_in : in std_logic;				-- start new measure (from PC)
		sensor_trig  : out std_logic;			-- trigger : send 10 us pulse when start_measure is active

		display_unit : out std_logic_vector(6 downto 0);		-- three seven segments displays
		display_ten : out std_logic_vector(6 downto 0);
		display_hundred : out std_logic_vector(6 downto 0);

		TX_data_out : out std_logic ) ;		-- data is sent through the RS-232 connection
end IP_UART_US;


architecture archi_IP_UART_US of IP_UART_US is

signal TX_finish_tmp : std_logic := '0';
signal TX_data_in_tmp : std_logic_vector(7 downto 0);
signal TX_start_tmp : std_logic := '0';
signal RX_finish_tmp : std_logic;

signal data_BCD_tmp : std_logic_vector(23 downto 0);
signal data_distance_tmp : std_logic_vector(8 downto 0);
signal send_data_tmp : std_logic;


component SENSOR_US_CTRL is
port( clk: in std_logic;
		rst: in std_logic;
		sensor_echo: in std_logic;
		start_measure: in std_logic;
		RX_finish : in std_logic;
		sensor_trig : out std_logic;
		distance_cm : out std_logic_vector(8 downto 0);
		send_data : out std_logic );
end component;


component BINARY_BCD
port(	clk : in  std_logic;
		rst : in std_logic;
		data_in : in  std_logic_vector(8 downto 0);
		data_out : out std_logic_vector(23 downto 0) );
end component;


component Decoder_BCD_7segment
port (	clk : in std_logic;
	rst : in std_logic;
	data_BCD : in std_logic_vector(23 downto 0);
	unit : out std_logic_vector(6 downto 0);
	ten : out std_logic_vector(6 downto 0);
	hundred : out std_logic_vector(6 downto 0) );
end component;


component MAE_CTRL_TX
port(	clk : in std_logic;
	rst : in std_logic;
	data_ready : in std_logic;
	count_in : in std_logic;
	data_BCD_in : in std_logic_vector(23 downto 0);
	data_ASCII_out : out std_logic_vector(7 downto 0);
	TX_start : out std_logic );
end component;


component UART
port(	clk : in std_logic;
	rst : in std_logic;
	TX_start : in std_logic;
	TX_data_in : in std_logic_vector(7 downto 0);
	TX_data_out : out std_logic;
	TX_busy : out std_logic;
	TX_finish : out std_logic;
	RX_data_in : in std_logic;
	RX_data_out : out std_logic_vector(7 downto 0 );
	RX_finish : out std_logic );
end component;


begin

c_SENSOR_US_CTRL : SENSOR_US_CTRL port map (clk => clk,
					    rst => rst,
					    sensor_echo => sensor_echo,
					    start_measure => start_measure,
					    RX_finish => RX_finish_tmp,
					    sensor_trig => sensor_trig,
					    distance_cm => data_distance_tmp,
					    send_data => send_data_tmp);

c_BINARY_BCD : BINARY_BCD port map (clk => clk,
				    rst => rst,
				    data_in => data_distance_tmp,
				    data_out => data_BCD_tmp);


c_decoder_BCD_7segment : Decoder_BCD_7segment port map (clk => clk,
							rst => rst,
							data_BCD => data_BCD_tmp,
							unit => display_unit,
							ten => display_ten,
							hundred => display_hundred);


c_MAE_CTRL_TX : MAE_CTRL_TX port map (clk => clk,
			      rst => rst,
			      data_ready => send_data_tmp,
			      count_in => TX_finish_tmp,
			      data_BCD_in => data_BCD_tmp,
			      data_ASCII_out => TX_data_in_tmp,
		         TX_start => TX_start_tmp);

c_UART : UART port map (clk => clk,
			rst => rst,
			TX_start => TX_start_tmp,
			TX_data_in => TX_data_in_tmp,
			TX_data_out => TX_data_out,
			TX_busy => open,
			TX_finish => TX_finish_tmp,
			RX_data_in => RX_data_in,
			RX_data_out => open,
			RX_finish => RX_finish_tmp);

end archi_IP_UART_US;
