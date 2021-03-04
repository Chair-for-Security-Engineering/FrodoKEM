library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity poly_mul_tb is
end entity poly_mul_tb;

architecture behave of poly_mul_tb is

	component single_port_bram is
		generic(
			awidth : integer := 10;
			dwidth : integer := 16
		);
		port(
			clk : in std_logic;
			we : in std_logic;
			addr : in std_logic_vector(awidth-1 downto 0);
			din : in std_logic_vector(dwidth-1 downto 0);
			dout : out std_logic_vector(dwidth-1 downto 0)
		);
	end component single_port_bram;

	component poly_mul_test is
		port (
		    ap_clk : IN STD_LOGIC;
		    ap_rst : IN STD_LOGIC;
		    ap_start : IN STD_LOGIC;
		    ap_done : OUT STD_LOGIC;
		    ap_idle : OUT STD_LOGIC;
		    ap_ready : OUT STD_LOGIC;
		    R_coeffs_address0 : OUT STD_LOGIC_VECTOR (8 downto 0);
		    R_coeffs_ce0 : OUT STD_LOGIC;
		    R_coeffs_we0 : OUT STD_LOGIC;
		    R_coeffs_d0 : OUT STD_LOGIC_VECTOR (10 downto 0);
		    a_coeffs_address0 : OUT STD_LOGIC_VECTOR (8 downto 0);
		    a_coeffs_ce0 : OUT STD_LOGIC;
		    a_coeffs_q0 : IN STD_LOGIC_VECTOR (10 downto 0);
		    B_coeffs_address0 : OUT STD_LOGIC_VECTOR (8 downto 0);
		    B_coeffs_ce0 : OUT STD_LOGIC;
		    B_coeffs_q0 : IN STD_LOGIC_VECTOR (10 downto 0) );
	end component;

	file values : text;

	signal clk : std_logic := '1';

	type states is (read_a, read_b, read_r, execute, compare);
	signal state : states := read_a;

	signal counter : integer := 0;
	signal input_done, outputs_compared : std_logic := '0';
	signal tests_passed, tests_failed, tests_completed, comparisons : integer := 0;
	signal cycles : integer := 0;

	signal we_a, we_a_tb : std_logic;
	signal addr_a, addr_a_tb : std_logic_vector(8 downto 0);
	signal din_a, din_a_tb, dout_a, dout_a_tb : std_logic_vector(10 downto 0);

	signal we_b, we_b_tb : std_logic;
	signal addr_b, addr_b_tb : std_logic_vector(8 downto 0);
	signal din_b, din_b_tb, dout_b, dout_b_tb : std_logic_vector(10 downto 0);

	signal we_r, we_r_tb : std_logic;
	signal addr_r, addr_r_tb : std_logic_vector(8 downto 0);
	signal din_r, din_r_tb, dout_r, dout_r_tb : std_logic_vector(10 downto 0);

	signal we_s, we_s_tb : std_logic;
	signal addr_s, addr_s_tb : std_logic_vector(8 downto 0);
	signal din_s, din_s_tb, dout_s, dout_s_tb : std_logic_vector(10 downto 0);

	signal reset_mul, start_mul, done_mul, idle_mul, ready_mul : std_logic;
	signal R_coeffs_address0, a_coeffs_address0, B_coeffs_address0 : std_logic_vector(8 downto 0);
	signal R_coeffs_ce0, R_coeffs_we0, a_coeffs_ce0, B_coeffs_ce0 : std_logic;
	signal R_coeffs_d0, a_coeffs_q0, B_coeffs_q0 : std_logic_vector(10 downto 0);


	constant clk_period : time := 10 ns;
	constant total_tests : integer := 3;

begin

	a : single_port_bram
	generic map(
		awidth => 9,
		dwidth => 11
	)
	port map(
		clk => clk,
		we => we_a,
		addr => addr_a,
		din => din_a,
		dout => dout_a
	);

	b : single_port_bram
	generic map(
		awidth => 9,
		dwidth => 11
	)
	port map(
		clk => clk,
		we => we_b,
		addr => addr_b,
		din => din_b,
		dout => dout_b
	);

	r : single_port_bram
	generic map(
		awidth => 9,
		dwidth => 11
	)
	port map(
		clk => clk,
		we => we_r,
		addr => addr_r,
		din => din_r,
		dout => dout_r
	);

	s : single_port_bram
	generic map(
		awidth => 9,
		dwidth => 11
	)
	port map(
		clk => clk,
		we => we_s,
		addr => addr_s,
		din => din_s,
		dout => dout_s
	);

	multiplier : poly_mul_test
	port map(
		ap_clk => clk,
		ap_rst => reset_mul,
		ap_start => start_mul,
		ap_done => done_mul,
		ap_idle => idle_mul,
		ap_ready => ready_mul,
		R_coeffs_address0 => R_coeffs_address0,
		R_coeffs_ce0 => R_coeffs_ce0,
		R_coeffs_we0 => R_coeffs_we0,
		R_coeffs_d0 => R_coeffs_d0,
		a_coeffs_address0 => a_coeffs_address0,
		a_coeffs_ce0 => a_coeffs_ce0,
		a_coeffs_q0 => a_coeffs_q0,
		B_coeffs_address0 => B_coeffs_address0,
		B_coeffs_ce0 => B_coeffs_ce0,
		B_coeffs_q0 => B_coeffs_q0
	);

	we_a <= we_a_tb;
	addr_a <= addr_a_tb when start_mul = '0' else a_coeffs_address0;
	din_a <= din_a_tb;
	dout_a_tb <= dout_a;
	a_coeffs_q0 <= dout_a;

	we_b <= we_b_tb;
	addr_b <= addr_b_tb when start_mul = '0' else B_coeffs_address0;
	din_b <= din_b_tb;
	dout_b_tb <= dout_b;
	B_coeffs_q0 <= dout_b;

	we_r <= we_r_tb when start_mul = '0' else R_coeffs_we0;
	addr_r <= addr_r_tb when start_mul = '0' else R_coeffs_address0;
	din_r <= din_r_tb when start_mul = '0' else R_coeffs_d0;
	dout_r_tb <= dout_r;

	we_s <= we_s_tb;
	addr_s <= addr_s_tb;
	din_s <= din_s_tb;
	dout_s_tb <= dout_s;

	clk_proc : process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	timing : process (clk) is
	begin
		if (clk = '1' and start_mul = '1') then
			cycles <= cycles + 1;
		end if;
	end process;

	testing : process
		variable row, msg : line;
		variable a_vector, b_vector, r_vector : std_logic_vector(15 downto 0);
	begin
		file_open(values, "C:/Users/fabusbo/Desktop/Masterarbeit/HLS/ntru-hps2048509/poly_mul_values_vhdl.txt", read_mode);

		while (tests_completed < total_tests) loop
			while (input_done = '0') loop
				start_mul <= '0';
				if (state = read_a) then
					readline(values, row);
					hread(row, a_vector);
					we_a_tb <= '1';
					addr_a_tb <= std_logic_vector(to_unsigned(counter, 9));
					din_a_tb <= a_vector(10 downto 0);
					counter <= counter + 1;
					if (counter = 508) then
						state <= read_b;
						counter <= 0;
					end if;
				elsif (state = read_b) then
					readline(values, row);
					hread(row, b_vector);
					we_b_tb <= '1';
					addr_b_tb <= std_logic_vector(to_unsigned(counter, 9));
					din_b_tb <= b_vector(10 downto 0);
					counter <= counter + 1;
					if (counter = 508) then
						state <= read_r;
						counter <= 0;
					end if;
				elsif (state = read_r) then
					readline(values, row);
					hread(row, r_vector);
					we_s_tb <= '1';
					addr_s_tb <= std_logic_vector(to_unsigned(counter, 9));
					din_s_tb <= r_vector(10 downto 0);
					counter <= counter + 1;
					if (counter = 508) then
						state <= execute;
						counter <= 0;
						input_done <= '1';
					end if;
				end if;
				wait for clk_period;
			end loop;
			if (state = execute) then
				we_a_tb <= '0';
				we_b_tb <= '0';
				we_s_tb <= '0';
				reset_mul <= '1';
				wait for clk_period;
				reset_mul <= '0';
				start_mul <= '1';
				wait until done_mul = '1';
				start_mul <= '0';
				state <= compare;
				wait for clk_period;
			elsif (state = compare) then
				while (outputs_compared = '0') loop
					addr_r_tb <= std_logic_vector(to_unsigned(counter, 9));
					addr_s_tb <= std_logic_vector(to_unsigned(counter, 9));
					counter <= counter + 1;
					wait for 2*clk_period;
					if (dout_r_tb = dout_s_tb) then
						comparisons <= comparisons + 1;
					end if;
					if (counter = 508) then
						outputs_compared <= '1';
					end if;
					wait for clk_period;
				end loop;
				if (comparisons = 508) then
					tests_passed <= tests_passed + 1;
				else
					tests_failed <= tests_failed + 1;
				end if;
				outputs_compared <= '0';
				tests_completed <= tests_completed + 1;
				comparisons <= 0;
				input_done <= '0';
				state <= read_a;
				counter <= 0;
				wait for clk_period;
			end if;
		end loop;
		wait for clk_period;
		if (tests_passed = total_tests) then
			write(msg, tests_passed);
			write(msg, string'(" of "));
			write(msg, total_tests);
			write(msg, string'(" Tests successful."));
			write(msg, string'(" Testbench passed :)"));
		else 
			write(msg, tests_failed);
			write(msg, string'(" of "));
			write(msg, total_tests);
			write(msg, string'(" Tests failed."));
			write(msg, string'(" Testbench failed :("));
		end if;
		write(msg, string'(" Average Latency: "));
		write(msg, cycles/total_tests);
		write(msg, string'(" clock cycles."));
		assert false report msg.all severity failure;
		wait for clk_period;
	end process;

end behave;
