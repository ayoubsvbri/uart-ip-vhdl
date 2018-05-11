-- testbench_SENSOR

-- Realised by Ayoub SABRI, Antoine SOMSAY, Adam VRIGNAUD
-- Polytech Sorbonne | EISE 3
-- Last modified : 21/02/2018

Library ieee;
Use ieee.std_logic_1164.all;

entity test_SENSOR is
end entity test_SENSOR;

architecture input of test_SENSOR is

  signal clk, RX_data_in, TX_data_out  : std_logic := '1';
  signal rst, sensor_echo, start_measure, sensor_trig : std_logic := '0';
  signal display_unit, display_ten, display_hundred : std_logic_vector(6 downto 0) := "0000000";

  constant clk_frequency : integer := 50e6; -- 50 MHz
  constant clk_period    : time    := 1000 ms / clk_frequency;
  constant echo_length : time := 2 ms;

begin

  testbench_SENSOR : entity work.IP_UART_US(archi_IP_UART_US) port map (clk =>clk,
							rst => rst,
							sensor_echo => sensor_echo,
							start_measure => start_measure,
							RX_data_in => RX_data_in,
							sensor_trig => sensor_trig,
							display_unit => display_unit,
							display_ten => display_ten,
							display_hundred => display_hundred,
							TX_data_out => TX_data_out );

  clk <= not clk after clk_period / 2;

  process begin
      wait for 10 * clk_period;
      start_measure <= '1'; wait for clk_period;
      start_measure <= '0'; wait for (10 us + 10 * clk_period) ; -- make sure sensor_trig passes to 0
      sensor_echo <= '1'; wait for echo_length;
    sensor_echo <= '0'; wait for 104 us * 30;
    wait;
  end process;

end input;
