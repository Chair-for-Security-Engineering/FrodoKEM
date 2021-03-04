library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity ntt_tb is
end entity ntt_tb;

architecture behave of ntt_tb is

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

	component true_dual_port_bram is
		generic(
			awidth : integer := 10;
			dwidth : integer := 16
		);
		port(
			clk : in std_logic;
			we1 : in std_logic;
			addr1 : in std_logic_vector(awidth-1 downto 0);
			din1 : in std_logic_vector(dwidth-1 downto 0);
			dout1 : out std_logic_vector(dwidth-1 downto 0);
			we2 : in std_logic;
			addr2 : in std_logic_vector(awidth-1 downto 0);
			din2 : in std_logic_vector(dwidth-1 downto 0);
			dout2 : out std_logic_vector(dwidth-1 downto 0)
		);
	end component true_dual_port_bram;

	component ntt is
		port (
		    ap_clk : IN STD_LOGIC;
		    ap_rst : IN STD_LOGIC;
		    ap_start : IN STD_LOGIC;
		    ap_done : OUT STD_LOGIC;
		    ap_idle : OUT STD_LOGIC;
		    ap_ready : OUT STD_LOGIC;
		    a_coeffs_address0 : OUT STD_LOGIC_VECTOR (9 downto 0);
		    a_coeffs_ce0 : OUT STD_LOGIC;
		    a_coeffs_we0 : OUT STD_LOGIC;
		    a_coeffs_d0 : OUT STD_LOGIC_VECTOR (15 downto 0);
		    a_coeffs_q0 : IN STD_LOGIC_VECTOR (15 downto 0);
		    a_coeffs_address1 : OUT STD_LOGIC_VECTOR (9 downto 0);
		    a_coeffs_ce1 : OUT STD_LOGIC;
		    a_coeffs_we1 : OUT STD_LOGIC;
		    a_coeffs_d1 : OUT STD_LOGIC_VECTOR (15 downto 0);
		    a_coeffs_q1 : IN STD_LOGIC_VECTOR (15 downto 0);
		    omega_coeffs_address0 : OUT STD_LOGIC_VECTOR (9 downto 0);
		    omega_coeffs_ce0 : OUT STD_LOGIC;
		    omega_coeffs_q0 : IN STD_LOGIC_VECTOR (15 downto 0) );
	end component;

	file values : text;

	signal clk : std_logic := '1';

	type states is (read_a, read_omega, read_result, execute, compare);
	signal state : states := read_a;

	signal counter : integer := 0;
	signal input_done : std_logic := '0';
	signal tests_passed, tests_failed, tests_completed, comparisons : integer := 0;
	signal outputs_done : std_logic := '0';
	signal cycles : integer := 0;

	signal reset_ntt, start_ntt, done_ntt, idle_ntt, ready_ntt : std_logic;
	signal a_coeffs_address0, a_coeffs_address1, omega_coeffs_address0 : std_logic_vector(9 downto 0);
	signal a_coeffs_ce0, a_coeffs_we0, a_coeffs_ce1, a_coeffs_we1, omega_coeffs_ce0 : std_logic;
	signal a_coeffs_d0, a_coeffs_q0, a_coeffs_d1, a_coeffs_q1, omega_coeffs_q0 : std_logic_vector(15 downto 0);

	signal we1_a, we2_a, we1_a_tb, we2_a_tb : std_logic;
	signal addr1_a, addr2_a, addr1_a_tb, addr2_a_tb : std_logic_vector(9 downto 0);
	signal din1_a, din2_a, din1_a_tb, din2_a_tb, dout1_a, dout2_a, dout1_a_tb, dout2_a_tb : std_logic_vector(15 downto 0);

	signal we_omega, we_omega_tb : std_logic;
	signal addr_omega, addr_omega_tb : std_logic_vector(9 downto 0);
	signal din_omega, dout_omega, din_omega_tb, dout_omega_tb : std_logic_vector(15 downto 0);

	signal we_r, we_r_tb : std_logic;
	signal addr_r, addr_r_tb : std_logic_vector(9 downto 0);
	signal din_r, dout_r, din_r_tb, dout_r_tb : std_logic_vector(15 downto 0);

	constant clk_period : time := 10 ns;
	constant total_tests : integer := 10;

begin

	a : true_dual_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we1 => we1_a,
		addr1 => addr1_a,
		din1 => din1_a,
		dout1 => dout1_a,
		we2 => we2_a,
		addr2 => addr2_a,
		din2 => din2_a,
		dout2 => dout2_a
	);

	omega : single_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_omega,
		addr => addr_omega,
		din => din_omega,
		dout => dout_omega
	);

	r : single_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_r,
		addr => addr_r,
		din => din_r,
		dout => dout_r
	);

	ntt_module : ntt
	port map(
		ap_clk => clk,
		ap_rst => reset_ntt,
		ap_start => start_ntt,
		ap_done => done_ntt,
		ap_idle => idle_ntt,
		ap_ready => ready_ntt,
		a_coeffs_address0 => a_coeffs_address0,
		a_coeffs_ce0 => a_coeffs_ce0,
		a_coeffs_we0 => a_coeffs_we0,
		a_coeffs_d0 => a_coeffs_d0,
		a_coeffs_q0 => a_coeffs_q0,
		a_coeffs_address1 => a_coeffs_address1,
		a_coeffs_ce1 => a_coeffs_ce1,
		a_coeffs_we1 => a_coeffs_we1,
		a_coeffs_d1 => a_coeffs_d1,
		a_coeffs_q1 => a_coeffs_q1,
		omega_coeffs_address0 => omega_coeffs_address0,
		omega_coeffs_ce0 => omega_coeffs_ce0,
		omega_coeffs_q0 => omega_coeffs_q0
	);

	we1_a <= we1_a_tb when start_ntt = '0' else a_coeffs_we0;
	addr1_a <= addr1_a_tb when start_ntt = '0' else a_coeffs_address0;
	din1_a <= din1_a_tb when start_ntt = '0' else a_coeffs_d0;
	we2_a <= we2_a_tb when start_ntt = '0' else a_coeffs_we1;
	addr2_a <= addr2_a_tb when start_ntt = '0' else a_coeffs_address1;
	din2_a <= din2_a_tb when start_ntt = '0' else a_coeffs_d1;
	a_coeffs_q0 <= dout1_a;
	a_coeffs_q1 <= dout2_a;
	dout1_a_tb <= dout1_a;
	dout2_a_tb <= dout2_a;

	we_omega <= we_omega_tb;
	addr_omega <= addr_omega_tb when start_ntt = '0' else omega_coeffs_address0;
	din_omega <= din_omega_tb;
	omega_coeffs_q0 <= dout_omega;

	we_r <= we_r_tb;
	addr_r <= addr_r_tb;
	din_r <= din_r_tb;
	dout_r_tb <= dout_r;


	clk_proc : process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	timing : process (clk)
	begin
		if (clk = '1' and start_ntt = '1') then
			cycles <= cycles + 1;
		end if;
	end process;

	testing : process
		variable row, msg : line;
		variable a_vector, omega_vector, r_vector : std_logic_vector(15 downto 0);
	begin
		file_open(values, "C:/Users/fabusbo/Desktop/Masterarbeit/HLS/NTT/ntt_values_vhdl.txt", read_mode);

		while (tests_completed < total_tests) loop
			while (input_done = '0') loop
				start_ntt <= '0';
				if (state = read_a) then
					readline(values, row);
					hread(row, a_vector);
					we1_a_tb <= '1';
					we2_a_tb <= '0';
					addr1_a_tb <= std_logic_vector(to_unsigned(counter, 10));
					din1_a_tb <= a_vector;
					counter <= counter + 1;
					if (counter = 1023) then
						state <= read_omega;
						counter <= 0;
					end if;
				elsif (state = read_omega) then
					readline(values, row);
					hread(row, omega_vector);
					we_omega_tb <= '1';
					addr_omega_tb <= std_logic_vector(to_unsigned(counter, 10));
					din_omega_tb <= omega_vector;
					counter <= counter + 1;
					if (counter = 1023) then
						state <= read_result;
						counter <= 0;
					end if;
				elsif (state = read_result) then
					readline(values, row);
					hread(row, r_vector);
					we_r_tb <= '1';
					addr_r_tb <= std_logic_vector(to_unsigned(counter, 10));
					din_r_tb <= r_vector;
					counter <= counter + 1;
					if (counter = 1023) then
						state <= execute;
						counter <= 0;
						input_done <= '1';
					end if;
				end if;
				wait for clk_period;
			end loop;
			if (state = execute) then
				we1_a_tb <= '0';
				we_omega_tb <= '0';
				we_r_tb <= '0';
				reset_ntt <= '1';
				wait for clk_period;
				reset_ntt <= '0';
				start_ntt <= '1';
				wait for clk_period;
				while (done_ntt = '0') loop
					wait for clk_period;
				end loop;
				start_ntt <= '0';
				state <= compare;
				wait for clk_period;
			elsif (state = compare) then
				while (outputs_done = '0') loop
					addr1_a_tb <=  std_logic_vector(to_unsigned(counter, 10));
					addr_r_tb <=  std_logic_vector(to_unsigned(counter, 10));
					counter <= counter + 1;
					wait for 2*clk_period;
					if (dout1_a_tb = dout_r_tb) then
						comparisons <= comparisons + 1;
					end if;
					if (counter = 1023) then
						outputs_done <= '1';
					end if;
					wait for clk_period;
				end loop;
				if (comparisons = 1023) then
					tests_passed <= tests_passed + 1;
				else
					tests_failed <= tests_failed + 1;
				end if;
				outputs_done <= '0';
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