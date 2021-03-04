library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity keygen_tb is
end entity keygen_tb;

architecture behave of keygen_tb is

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

	component frodo_keygen is
	port (
	    ap_clk : IN STD_LOGIC;
	    ap_rst : IN STD_LOGIC;
	    ap_start : IN STD_LOGIC;
	    ap_done : OUT STD_LOGIC;
	    ap_idle : OUT STD_LOGIC;
	    ap_ready : OUT STD_LOGIC;
	    pk_address0 : OUT STD_LOGIC_VECTOR (12 downto 0);
	    pk_ce0 : OUT STD_LOGIC;
	    pk_we0 : OUT STD_LOGIC;
	    pk_d0 : OUT STD_LOGIC_VECTOR (15 downto 0);
	    sk_address0 : OUT STD_LOGIC_VECTOR (13 downto 0);
	    sk_ce0 : OUT STD_LOGIC;
	    sk_we0 : OUT STD_LOGIC;
	    sk_d0 : OUT STD_LOGIC_VECTOR (15 downto 0);
	    randomness_address0 : OUT STD_LOGIC_VECTOR (4 downto 0);
	    randomness_ce0 : OUT STD_LOGIC;
	    randomness_q0 : IN STD_LOGIC_VECTOR (15 downto 0);
	    randomness_address1 : OUT STD_LOGIC_VECTOR (4 downto 0);
	    randomness_ce1 : OUT STD_LOGIC;
	    randomness_q1 : IN STD_LOGIC_VECTOR (15 downto 0) );
	end component;

	file values : text;

	signal clk : std_logic := '1';

	type states is (read_rand, read_pk, read_sk, execute, compare);
	signal state : states := read_rand;

	signal counter, tests_passed, tests_failed, tests_completed, comparisons, cycles : integer := 0;
	signal input_done, outputs_compared, pk_done, sk_done : std_logic := '0';
	signal comparisons_pk, comparisons_sk : integer := 0;

	signal start_gen, reset_gen, done_gen, idle_gen, ready_gen : std_logic;
	signal pk_ce0, pk_we0, sk_ce0, sk_we0, randomness_ce0, randomness_ce1 : std_logic;
	signal pk_address0 : std_logic_vector(12 downto 0);
	signal sk_address0 : std_logic_vector(13 downto 0);
	signal randomness_address0, randomness_address1 : std_logic_vector(4 downto 0);
	signal pk_d0, sk_d0, randomness_q0, randomness_q1 : std_logic_vector(15 downto 0);

	signal we1_rand, we2_rand, we1_rand_tb, we2_rand_tb : std_logic;
	signal addr1_rand, addr2_rand, addr1_rand_tb, addr2_rand_tb : std_logic_vector(4 downto 0);
	signal din1_rand, din2_rand, dout1_rand, dout2_rand, din1_rand_tb, din2_rand_tb, dout1_rand_tb, dout2_rand_tb : std_logic_vector(15 downto 0);

	signal we_pk, we_pk_tb : std_logic;
	signal addr_pk, addr_pk_tb : std_logic_vector(12 downto 0);
	signal din_pk, dout_pk, din_pk_tb, dout_pk_tb : std_logic_vector(15 downto 0);

	signal we_sk, we_sk_tb : std_logic;
	signal addr_sk, addr_sk_tb : std_logic_vector(13 downto 0);
	signal din_sk, dout_sk, din_sk_tb, dout_sk_tb : std_logic_vector(15 downto 0);

	signal we_a, we_a_tb : std_logic;
	signal addr_a, addr_a_tb : std_logic_vector(12 downto 0);
	signal din_a, dout_a, din_a_tb, dout_a_tb : std_logic_vector(15 downto 0);

	signal we_b, we_b_tb : std_logic;
	signal addr_b, addr_b_tb : std_logic_vector(13 downto 0);
	signal din_b, dout_b, din_b_tb, dout_b_tb : std_logic_vector(15 downto 0);

	constant clk_period : time := 10 ns;
	constant total_tests : integer := 1;

begin
	
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

	b : single_port_bram
	generic map(
		awidth => 14,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_b,
		addr => addr_b,
		din => din_b,
		dout => dout_b
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

	sk : single_port_bram
	generic map(
		awidth => 14,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_sk,
		addr => addr_sk,
		din => din_sk,
		dout => dout_sk
	);

	randomness : true_dual_port_bram
	generic map(
		awidth => 5,
		dwidth => 16
	)
	port map(
		clk => clk,
		we1 => we1_rand,
		addr1 => addr1_rand,
		din1 => din1_rand,
		dout1 => dout1_rand,
		we2 => we2_rand,
		addr2 => addr2_rand,
		din2 => din2_rand,
		dout2 => dout2_rand
	);

	keygen : frodo_keygen
	port map(
		ap_clk => clk,
		ap_rst => reset_gen,
		ap_start => start_gen,
		ap_done => done_gen,
		ap_idle => idle_gen,
		ap_ready => ready_gen,
		pk_address0 => pk_address0,
		pk_ce0 => pk_ce0,
		pk_we0 => pk_we0,
		pk_d0 => pk_d0,
		sk_address0 => sk_address0,
		sk_ce0 => sk_ce0,
		sk_we0 => sk_we0,
		sk_d0 => sk_d0,
		randomness_address0 => randomness_address0,
		randomness_ce0 => randomness_ce0,
		randomness_q0 => randomness_q0,
		randomness_address1 => randomness_address1,
		randomness_ce1 => randomness_ce1,
		randomness_q1 => randomness_q1
	);

	we1_rand <= we1_rand_tb;
	we2_rand <= we2_rand_tb;
	addr1_rand <= addr1_rand_tb when start_gen = '0' else randomness_address0;
	addr2_rand <= addr2_rand_tb when start_gen = '0' else randomness_address1;
	din1_rand <= din1_rand_tb;
	din2_rand <= din2_rand_tb;
	randomness_q0 <= dout1_rand;
	randomness_q1 <= dout2_rand;
	
	we_a <= we_a_tb;
	addr_a <= addr_a_tb;
	din_a <= din_a_tb;
	dout_a_tb <= dout_a;
	we_b <= we_b_tb;
	addr_b <= addr_b_tb;
	din_b <= din_b_tb;
	dout_b_tb <= dout_b;

	we_pk <= we_pk_tb when start_gen = '0' else pk_we0;
	addr_pk <= addr_pk_tb when start_gen = '0' else pk_address0;
	din_pk <= din_pk when start_gen = '0' else pk_d0;
	dout_pk_tb <= dout_pk;
	we_sk <= we_sk_tb when start_gen = '0' else sk_we0;
	addr_sk <= addr_sk_tb when start_gen = '0' else sk_address0;
	din_sk <= din_sk when start_gen = '0' else sk_d0;
	dout_sk_tb <= dout_sk;

	clk_process : process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	timing : process (clk)
	begin
		if (clk = '1' and start_gen = '1') then
			cycles <= cycles + 1;
		end if;
	end process;

	testing : process
		variable row, msg : line;
		variable rand_vector, pk_vector, sk_vector : std_logic_vector(15 downto 0);
	begin
		file_open(values, "C:/Users/fabusbo/Desktop/Masterarbeit/HLS/FrodoKEM-640/KeyGen/frodo_keygen_values_vhdl.txt", read_mode);

		while (tests_completed < total_tests) loop
			while (input_done = '0') loop
				start_gen <= '0';
				if (state = read_rand) then
					readline(values, row);
					hread(row, rand_vector);
					we1_rand_tb <= '1';
					addr1_rand_tb <= std_logic_vector(to_unsigned(counter, 5));
					din1_rand_tb <= rand_vector;
					counter <= counter + 1;
					if (counter = 23) then
						counter <= 0;
						state <= read_pk;
					end if;
				elsif (state = read_pk) then
					readline(values, row);
					hread(row, pk_vector);
					we_a_tb <= '1';
					addr_a_tb <= std_logic_vector(to_unsigned(counter, 13));
					din_a_tb <= pk_vector;
					counter <= counter + 1;
					if (counter = 4807) then
						counter <= 0;
						state <= read_sk;
					end if;
				elsif (state = read_sk) then
					readline(values, row);
					hread(row, sk_vector);
					we_b_tb <= '1';
					addr_b_tb <= std_logic_vector(to_unsigned(counter, 14));
					din_b_tb <= sk_vector;
					counter <= counter + 1;
					if (counter = 9943) then
						counter <= 0;
						state <= execute;
						input_done <= '1';
					end if;
				end if;
				wait for clk_period;
			end loop;
			if (state = execute) then
				we1_rand_tb <= '0';
				we2_rand_tb <= '0';
				we_a_tb <= '0';
				we_b_tb <= '0';
				reset_gen <= '1';
				wait for clk_period;
				reset_gen <= '0';
				start_gen <= '1';
				wait until done_gen = '1';
				state <= compare;
				start_gen <= '0';
				wait for clk_period;
			elsif (state = compare) then
				while (pk_done = '0') loop
					addr_a_tb <= std_logic_vector(to_unsigned(counter, 13));
					addr_pk_tb <= std_logic_vector(to_unsigned(counter, 13));
					counter <= counter + 1;
					wait for 2*clk_period;
					if (dout_a_tb = dout_pk_tb) then
						comparisons_pk <= comparisons_pk + 1;
					end if;
					if (counter = 4807) then
						pk_done <= '1';
						counter <= 0;
					end if;
					wait for clk_period;
				end loop;
				while (sk_done = '0') loop
					addr_b_tb <= std_logic_vector(to_unsigned(counter, 14));
					addr_sk_tb <= std_logic_vector(to_unsigned(counter, 14));
					counter <= counter + 1;
					wait for 2*clk_period;
					if (dout_b_tb = dout_sk_tb) then
						comparisons_sk <= comparisons_sk + 1;
					end if;
					if (counter = 9943) then
						sk_done <= '1';
						counter <= 0;
					end if;
					wait for clk_period;
				end loop;
				if (comparisons_pk = 4807 and comparisons_sk = 9943) then
					tests_passed <= tests_passed + 1;
				else
					tests_failed <= tests_failed + 1;
				end if;
				tests_completed <= tests_completed + 1;
				pk_done <= '0';
				sk_done <= '0';
				comparisons_pk <= 0;
				comparisons_sk <= 0;
				state <= read_rand;
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
