-- UART RX/TX

-- Please refer to documentation for more details

-- Input Clock = 50 MHz
-- Baud Rate : 9600 bps
-- Start bit , Stop bit , No Parity
-- Realised by Ayoub SABRI, Antoine SOMSAY, Adam VRIGNAUD
-- Polytech Sorbonne | EISE 3
-- Last modified : 06/05/2018

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART is
port(	clk : in std_logic;									-- clock (50 MHz)
		rst : in std_logic;									-- reset

		TX_start : in std_logic;							-- TX start transmission
		TX_data_in : in std_logic_vector(7 downto 0);		-- 8 bit data to send
		TX_data_out : out std_logic;						-- data sent
		TX_busy : out std_logic;
		TX_finish : out std_logic;

		RX_data_in : in std_logic;
		RX_data_out : out std_logic_vector(7 downto 0 );	-- data received
		RX_finish : out std_logic );
end UART;

architecture archi_UART of UART is


	signal TX_out : std_logic;
	signal RX_out : std_logic_vector(7 downto 0) := (others => '0');

	component UART_TX
	port(	clk : in std_logic;
			rst : in std_logic;
			TX_start : in std_logic;
			TX_data_in : in std_logic_vector(7 downto 0);
			TX_data_out : out std_logic;
			TX_busy : out std_logic;
			TX_finish : out std_logic );
	end component;


	component UART_RX
	port(   clk : in std_logic;
			rst : in std_logic;
	        RX_data_in : in std_logic;
	        RX_data_out : out std_logic_vector(7 downto 0);
			RX_finish : out std_logic );
	end component;

begin

	c_TX : UART_TX port map (clk => clk,
				 rst => rst,
				 TX_start => TX_start,
				 TX_data_in => TX_data_in,
				 TX_data_out => TX_out,
				 TX_busy => TX_busy,
				 TX_finish => TX_finish);

	c_RX : UART_RX port map (clk => clk,
					rst => rst,
					RX_data_in => RX_data_in,		-- replace last RX_data_in with TX_out for testbench_UART
					RX_data_out => RX_out,
					RX_finish => RX_finish);

	TX_data_out <= TX_out;
	RX_data_out <= RX_out;

end archi_UART;
