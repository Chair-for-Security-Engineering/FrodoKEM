library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity sample_tb is
end entity sample_tb;

architecture behave of sample_tb is

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
	end component;

	component frodo_sample_n is
		port (
		    ap_clk : IN STD_LOGIC;
		    ap_rst : IN STD_LOGIC;
		    ap_start : IN STD_LOGIC;
		    ap_done : OUT STD_LOGIC;
		    ap_idle : OUT STD_LOGIC;
		    ap_ready : OUT STD_LOGIC;
		    out_r_address0 : OUT STD_LOGIC_VECTOR (12 downto 0);
		    out_r_ce0 : OUT STD_LOGIC;
		    out_r_we0 : OUT STD_LOGIC;
		    out_r_d0 : OUT STD_LOGIC_VECTOR (15 downto 0);
		    s_address0 : OUT STD_LOGIC_VECTOR (12 downto 0);
		    s_ce0 : OUT STD_LOGIC;
		    s_q0 : IN STD_LOGIC_VECTOR (15 downto 0);
		    n : IN STD_LOGIC_VECTOR (12 downto 0) );
	end component;

	file values : text;

	signal clk : std_logic := '1';

	type states is (read_n, read_s, read_out, execute, compare);
	signal state : states := read_n;

	signal counter : integer := 0;
	signal input_done : std_logic := '0';
	signal tests_passed, tests_failed, comparisons, tessts_completed : integer := 0;
	signal outputs_compared : std_logic := '0';
	signal total_cycles : integer := 0;

	signal we_s, we_s_tb : std_logic;
	signal addr_s, addr_s_tb : std_logic_vector(12 downto 0);
	signal din_s, din_s_tb, dout_s, dout_s_tb : std_logic_vector(15 downto 0);

	signal we_r, we_r_tb : std_logic;
	signal addr_r, addr_r_tb : std_logic_vector(12 downto 0);
	signal din_r, din_r_tb, dout_r, dout_r_tb : std_logic_vector(15 downto 0);

	signal we_a, we_a_tb, we_a_sample : std_logic;
	signal addr_a, addr_a_tb, addr_a_sample : std_logic_vector(12 downto 0);
	signal din_a, din_a_tb, din_a_sample, dout_a, dout_a_tb, dout_a_sample : std_logic_vector(15 downto 0);

	signal reset_sample, start_sample, done_sample, idle_sample, ready_sample : std_logic;
	signal out_r_address0, s_address0 : std_logic_vector(12 downto 0);
	signal out_r_ce0, out_r_we0, s_ce0 : std_logic;
	signal out_r_d0, s_q0 : std_logic_vector(15 downto 0);
	signal n : std_logic_vector(12 downto 0);

	constant clk_prediod : time := 10 ns;
	constant total_tests : integer := 80;

begin

	s : single_port_bram
	generic map(
		awidth => 13,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_s,
		addr => addr_s,
		din => din_s,
		dout => dout_s
	);

	r : single_port_bram
	generic map(
		awidth => 13,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_r,
		addr => addr_r,
		din => din_r,
		dout => dout_r
	);

	a : single_port_bram
	generic map(
		awidth => 13,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_a,
		addr => addr_a,
		din => din_a,
		dout => dout_a
	);

	sampler : frodo_sample_n
	port map(
		ap_clk => clk,
		ap_rst => reset_sample,
		ap_start => start_sample,
		ap_done => done_sample,
		ap_idle => idle_sample,
		ap_ready => ready_sample,
		out_r_address0 => out_r_address0,
		out_r_ce0 => out_r_ce0,
		out_r_we0 => out_r_we0,
		out_r_d0 => out_r_d0,
		s_address0 => s_address0,
		s_ce0 => s_ce0,
		s_q0 => s_q0,
		n => n
	);

	we_s <= we_s_tb when start_sample = '0';
	addr_s <= addr_s_tb when start_sample = '0' else s_address0;
	din_s <= din_s_tb;
	s_q0 <= dout_s;
	we_r <= we_r_tb;
	addr_r <= addr_r_tb;
	din_r <= din_r_tb;
	dout_r_tb <= dout_r;
	we_a <= we_a_tb when start_sample = '0' else out_r_we0;
	addr_a <= addr_a_tb when start_sample = '0' else out_r_address0;
	din_a <= din_a_tb when start_sample = '0' else out_r_d0;
	dout_a_tb <= dout_a;


	clk_proc : process
	begin
		clk <= '1'; wait for clk_prediod/2;
		clk <= '0'; wait for clk_prediod/2;
	end process;

	timing : process (clk)
	begin
		if (clk = '1' and start_sample = '1') then
			total_cycles <= total_cycles + 1;
		end if;
	end process;

	testing : process
		variable row : line;
		variable s_vector, out_vector : std_logic_vector(15 downto 0);
		variable n_vector : integer;
		variable num : integer;
		variable msg : line;
	begin
		file_open(values, "C:/Users/fabusbo/Desktop/Masterarbeit/HLS/Sample_Gaussian/sample_values_vhdl.txt", read_mode);

		while (tessts_completed < total_tests) loop
			while (input_done = '0') loop
				if (state = read_n) then
					readline(values, row);
					read(row, n_vector);
					n <= std_logic_vector(to_unsigned(n_vector, 13));
					state <= read_s;
					start_sample <= '0';
				elsif (state = read_s) then
					readline(values, row);
					hread(row, s_vector);
					we_s_tb <= '1';
					addr_s_tb <= std_logic_vector(to_unsigned(counter, 13));
					din_s_tb <= s_vector;
					counter <= counter + 1;
					if (counter = to_integer(unsigned(n))-1) then
						counter <= 0;
						state <= read_out;
					end if;
				elsif (state = read_out) then
					readline(values, row);
					hread(row, out_vector);
					we_r_tb <= '1';
					addr_r_tb <= std_logic_vector(to_unsigned(counter, 13));
					din_r_tb <= out_vector;
					counter <= counter + 1;
					if (counter = to_integer(unsigned(n))-1) then
						counter <= 0;
						state <= execute;
						input_done <= '1';
					end if;
				end if;
				wait for clk_prediod;
			end loop;
			if (state = execute) then
				we_s_tb <= '0';
				we_r_tb <= '0';
				reset_sample <= '1';
				wait for clk_prediod;
				reset_sample <= '0';
				start_sample <= '1';
				wait until done_sample = '1';
				state <= compare;
				start_sample <= '0';
				wait for clk_prediod;
			elsif (state = compare) then
				while (outputs_compared = '0') loop
					addr_r_tb <= std_logic_vector(to_unsigned(counter, 13));
					addr_a_tb <= std_logic_vector(to_unsigned(counter, 13));
					counter <= counter + 1;
					wait for 2*clk_prediod;			
					if (dout_a_tb = dout_r_tb) then
						comparisons <= comparisons + 1;
					end if;
					if (counter = to_integer(unsigned(n))-1) then
						outputs_compared <= '1';
					end if;
					wait for clk_prediod;
				end loop;
				if (comparisons = to_integer(unsigned(n))-1) then
					tests_passed <= tests_passed + 1;
				else
					tests_failed <= tests_failed + 1;
				end if;
				outputs_compared <= '0';
				tessts_completed <= tessts_completed + 1;
				comparisons <= 0;
				input_done <= '0';
				state <= read_n;
				counter <= 0;
				wait for clk_prediod;
			end if;
		end loop;
		wait for clk_prediod;
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
		write(msg, total_cycles/total_tests);
		write(msg, string'(" clock cycles."));
		assert false report msg.all severity failure;
		wait for clk_prediod;
	end process;

end behave;