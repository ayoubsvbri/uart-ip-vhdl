-- testbench_UART

-- Realised by Ayoub SABRI, Antoine SOMSAY, Adam VRIGNAUD
-- Polytech Sorbonne | EISE 3
-- Last modified : 06/05/2018

Library ieee;
Use ieee.std_logic_1164.all;

entity test_UART is
end entity test_UART;

architecture input of test_UART is

    signal clk, start, TX_data_out, RX_data_in : std_logic := '1';
    signal rst, TX_busy, TX_finish, RX_finish : std_logic := '0';
    signal TX_data_in : std_logic_vector(7 downto 0) := "01101001" ;
    signal RX_data_out : std_logic_vector(7 downto 0) := (others => '0');

    constant clk_frequency : integer := 50e6; -- 50 MHz
    constant clk_period    : time    := 1000 ms / clk_frequency;

begin

    testbench_UART : entity work.UART(archi_uart) port map (clk =>clk,
                            rst => rst,
							TX_start => start,
							TX_data_in => TX_data_in,
							TX_data_out => TX_data_out,
							TX_busy => TX_busy,
							TX_finish => TX_finish,
							RX_data_in => RX_data_in,
							RX_data_out => RX_data_out,
							RX_finish => RX_finish );

    clk <= not clk after clk_period / 2;

end input;
