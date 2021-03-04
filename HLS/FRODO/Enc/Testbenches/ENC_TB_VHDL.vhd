library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity enc_tb is
end entity enc_tb;

architecture behave of enc_tb is

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

	component frodo_enc is
	port (
	    ap_clk : IN STD_LOGIC;
	    ap_rst : IN STD_LOGIC;
	    ap_start : IN STD_LOGIC;
	    ap_done : OUT STD_LOGIC;
	    ap_idle : OUT STD_LOGIC;
	    ap_ready : OUT STD_LOGIC;
	    ct_address0 : OUT STD_LOGIC_VECTOR (12 downto 0);
	    ct_ce0 : OUT STD_LOGIC;
	    ct_we0 : OUT STD_LOGIC;
	    ct_d0 : OUT STD_LOGIC_VECTOR (15 downto 0);
	    ss_address0 : OUT STD_LOGIC_VECTOR (2 downto 0);
	    ss_ce0 : OUT STD_LOGIC;
	    ss_we0 : OUT STD_LOGIC;
	    ss_d0 : OUT STD_LOGIC_VECTOR (15 downto 0);
	    mu_in_address0 : OUT STD_LOGIC_VECTOR (2 downto 0);
	    mu_in_ce0 : OUT STD_LOGIC;
	    mu_in_q0 : IN STD_LOGIC_VECTOR (15 downto 0);
	    pk_address0 : OUT STD_LOGIC_VECTOR (12 downto 0);
	    pk_ce0 : OUT STD_LOGIC;
	    pk_q0 : IN STD_LOGIC_VECTOR (15 downto 0) );
	end component;

	file values : text;

	signal clk : std_logic := '1';

	type states is (read_mu, read_pk, read_ct, read_ss, execute, compare);
	signal state : states := read_mu;

	signal counter, tests_passed, tests_failed, tests_completed, comparisons, cycles : integer := 0;
	signal input_done, outputs_compared, ct_done, ss_done : std_logic := '0';
	signal comparisons_ct, comparisons_ss : integer := 0;

	signal reset_enc, start_enc, done_enc, idle_enc, ready_enc : std_logic;
	signal ct_ce0, ct_we0, ss_ce0, ss_we0, mu_in_ce0, pk_ce0 : std_logic;
	signal ct_address0, pk_address0 : std_logic_vector(12 downto 0);
	signal mu_in_address0, ss_address0 : std_logic_vector(2 downto 0);
	signal ct_d0, ss_d0, mu_in_q0, pk_q0 : std_logic_vector(15 downto 0);

	signal we_mu, we_mu_tb : std_logic;
	signal addr_mu, addr_mu_tb : std_logic_vector(2 downto 0);
	signal din_mu, dout_mu, din_mu_tb, dout_mu_tb : std_logic_vector(15 downto 0);

	signal we_pk, we_pk_tb : std_logic;
	signal addr_pk, addr_pk_tb : std_logic_vector(12 downto 0);
	signal din_pk, dout_pk, din_pk_tb, dout_pk_tb : std_logic_vector(15 downto 0);

	signal we_a : std_logic;
	signal addr_a : std_logic_vector(12 downto 0);
	signal din_a, dout_a : std_logic_vector(15 downto 0);

	signal we_ct, we_ct_tb : std_logic;
	signal addr_ct, addr_ct_tb : std_logic_vector(12 downto 0);
	signal din_ct, dout_ct, din_ct_tb, dout_ct_tb : std_logic_vector(15 downto 0);

	signal we_b : std_logic;
	signal addr_b : std_logic_vector(2 downto 0);
	signal din_b, dout_b : std_logic_vector(15 downto 0);

	signal we_ss, we_ss_tb : std_logic;
	signal addr_ss, addr_ss_tb : std_logic_vector(2 downto 0);
	signal din_ss, dout_ss, din_ss_tb, dout_ss_tb : std_logic_vector(15 downto 0);

	constant clk_period : time := 10 ns;
	constant total_tests : integer := 1;

begin

	mu : single_port_bram
	generic map(
		awidth => 3,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_mu,
		addr => addr_mu,
		din => din_mu,
		dout => dout_mu
	);

	pk : single_port_bram
	generic map(
		awidth => 13,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_pk,
		addr => addr_pk,
		din => din_pk,
		dout => dout_pk
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

	ct : single_port_bram
	generic map(
		awidth => 13,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_ct,
		addr => addr_ct,
		din => din_ct,
		dout => dout_ct
	);

	b : single_port_bram
	generic map(
		awidth => 3,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_b,
		addr => addr_b,
		din => din_b,
		dout => dout_b
	);

	ss : single_port_bram
	generic map(
		awidth => 3,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_ss,
		addr => addr_ss,
		din => din_ss,
		dout => dout_ss
	);

	encryption : frodo_enc
	port map(
		ap_clk => clk,
		ap_rst => reset_enc,
		ap_start => start_enc,
		ap_done => done_enc,
		ap_idle => idle_enc,
		ap_ready => ready_enc,
		ct_address0 => ct_address0,
		ct_ce0 => ct_ce0,
		ct_we0 => ct_we0,
		ct_d0 => ct_d0,
		ss_address0 => ss_address0,
		ss_ce0 => ss_ce0,
		ss_we0 => ss_we0,
		ss_d0 => ss_d0,
		mu_in_address0 => mu_in_address0,
		mu_in_ce0 => mu_in_ce0,
		mu_in_q0 => mu_in_q0,
		pk_address0 => pk_address0,
		pk_ce0 => pk_ce0,
		pk_q0 => pk_q0
	);

	we_mu <= we_mu_tb;
	addr_mu <= addr_mu_tb when start_enc = '0' else mu_in_address0;
	din_mu <= din_mu_tb;
	mu_in_q0 <= dout_mu;

	we_pk <= we_pk_tb;
	addr_pk <= addr_pk_tb when start_enc = '0' else pk_address0;
	din_pk <= din_pk_tb;
	pk_q0 <= dout_pk;

	we_ct <= we_ct_tb when start_enc = '0' else ct_we0;
	addr_ct <= addr_ct_tb when start_enc = '0' else ct_address0;
	din_ct <= din_ct_tb when start_enc = '0' else ct_d0;
	dout_ct_tb <= dout_ct;

	we_ss <= we_ss_tb when start_enc = '0' else ss_we0;
	addr_ss <= addr_ss_tb when start_enc = '0' else ss_address0;
	din_ss <= din_ss_tb when start_enc = '0' else ss_d0;
	dout_ss_tb <= dout_ss;
	
	clk_process : process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	timing : process (clk)
	begin
		if (clk = '1' and start_enc = '1') then
			cycles <= cycles + 1;
		end if;
	end process;

	testing : process
		variable row, msg : line;
		variable mu_vector, pk_vector, ct_vector, ss_vector : std_logic_vector(15 downto 0);
	begin
		file_open(values, "C:/Users/fabusbo/Desktop/Masterarbeit/HLS/FrodoKEM-640/Enc/frodo_enc_values_vhdl.txt", read_mode);
	
		while (tests_completed < total_tests) loop
			while (input_done = '0') loop
				start_enc <= '0';
				if (state = read_mu) then
					readline(values, row);
					hread(row, mu_vector);
					we_mu_tb <= '1';
					addr_mu_tb <= std_logic_vector(to_unsigned(counter, 3));
					din_mu_tb <= mu_vector;
					counter <= counter + 1;
					if (counter = 7) then
						counter <= 0;
						state <= read_pk;
					end if;
				elsif (state = read_pk) then
					readline(values, row);
					hread(row, pk_vector);
					we_pk_tb <= '1';
					addr_pk_tb <= std_logic_vector(to_unsigned(counter, 13));
					din_pk_tb <= pk_vector;
					counter <= counter + 1;
					if (counter = 4807) then
						counter <= 0;
						state <= read_ct;
					end if;
				elsif (state = read_ct) then
					readline(values, row);
					hread(row, ct_vector);
					we_a <= '1';
					addr_a <= std_logic_vector(to_unsigned(counter, 13));
					din_a <= ct_vector;
					counter <= counter + 1;
					if (counter = 4859) then
						counter <= 0;
						state <= read_ss;
					end if;
				elsif (state = read_ss) then
					readline(values, row);
					hread(row, ss_vector);
					we_b <= '1';
					addr_b <= std_logic_vector(to_unsigned(counter, 3));
					din_b <= ss_vector;
					counter <= counter + 1;
					if (counter = 7) then
						counter <= 0;
						state <= execute;
						input_done <= '1';
					end if;
				end if;
				wait for clk_period;
			end loop;
			if (state = execute) then
				we_mu_tb <= '0';
				we_pk_tb <= '0';
				we_a <= '0';
				we_b <= '0';
				reset_enc <= '1';
				wait for clk_period;
				reset_enc <= '0';
				start_enc <= '1';
				wait until done_enc = '1';
				state <= compare;
				start_enc <= '0';
				wait for clk_period;
			elsif (state = compare) then
				while (ct_done = '0') loop
					addr_a <= std_logic_vector(to_unsigned(counter, 13));
					addr_ct_tb <= std_logic_vector(to_unsigned(counter, 13));
					counter <= counter + 1;
					wait for 2*clk_period;
					if (dout_a = dout_ct_tb) then
						comparisons_ct <= comparisons_ct + 1;
					end if;
					if (counter = 4859) then
						ct_done <= '1';
						counter <= 0;
					end if;
					wait for clk_period;
				end loop;
				while (ss_done = '0') loop
					addr_b <= std_logic_vector(to_unsigned(counter, 3));
					addr_ss_tb <= std_logic_vector(to_unsigned(counter, 3));
					counter <= counter + 1;
					wait for 2*clk_period;
					if (dout_b = dout_ss_tb) then
						comparisons_ss <= comparisons_ss + 1;
					end if;
					if (counter = 7) then
						ss_done <= '1';
						counter <= 0;
					end if;
					wait for clk_period;
				end loop;
				if (comparisons_ct = 4859 and comparisons_ss = 7) then
					tests_passed <= tests_passed + 1;
				else
					tests_failed <= tests_failed + 1;
				end if;
				tests_completed <= tests_completed + 1;
				ct_done <= '0';
				ss_done <= '0';
				comparisons_ct <= 0;
				comparisons_ss <= 0;
				state <= read_mu;
				input_done <= '0';
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