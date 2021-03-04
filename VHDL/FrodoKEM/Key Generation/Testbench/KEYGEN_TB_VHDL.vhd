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

	component pk_bram is
		port(
			clk : in std_logic;
			we1 : in std_logic;
			addr1 : in std_logic_vector(12 downto 0);
			din1 : in std_logic_vector(15 downto 0);
			dout1 : out std_logic_vector(15 downto 0);
			we2 : in std_logic;
			addr2 : in std_logic_vector(12 downto 0);
			din2 : in std_logic_vector(15 downto 0);
			dout2 : out std_logic_vector(15 downto 0)
		);
	end component pk_bram;

	component sk_bram is
		port(
			clk : in std_logic;
			we1 : in std_logic;
			addr1 : in std_logic_vector(13 downto 0);
			din1 : in std_logic_vector(15 downto 0);
			dout1 : out std_logic_vector(15 downto 0);
			we2 : in std_logic;
			addr2 : in std_logic_vector(13 downto 0);
			din2 : in std_logic_vector(15 downto 0);
			dout2 : out std_logic_vector(15 downto 0)
		);
	end component sk_bram;

	component frodo_gen is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			addr_rand : out std_logic_vector(4 downto 0);
			dout_rand : in std_logic_vector(15 downto 0);

			we1_pk : out std_logic;
			addr1_pk : out std_logic_vector(12 downto 0);
			din1_pk : out std_logic_vector(15 downto 0);
			we2_pk : out std_logic;
			addr2_pk : out std_logic_vector(12 downto 0);
			din2_pk : out std_logic_vector(15 downto 0);

			we1_sk : out std_logic;
			addr1_sk : out std_logic_vector(13 downto 0);
			din1_sk : out std_logic_vector(15 downto 0);
			we2_sk : out std_logic;
			addr2_sk : out std_logic_vector(13 downto 0);
			din2_sk : out std_logic_vector(15 downto 0)
		);
	end component frodo_gen;

	file values : text;
	signal clk : std_logic := '1';

	type states is (read_rand, read_pk, read_sk, execute, compare);
	signal state : states := read_rand;

	signal counter, tests_passed, tests_failed, tests_completed, comparisons, cycles : integer := 0;
	signal input_done, outputs_compared, pk_done, sk_done : std_logic := '0';
	signal comparisons_pk, comparisons_sk : integer := 0;

	signal we_rand, we_rand_tb : std_logic;
	signal addr_rand, addr_rand_gen, addr_rand_tb : std_logic_vector(4 downto 0);
	signal din_rand, dout_rand, din_rand_tb, dout_rand_gen : std_logic_vector(15 downto 0);

	signal we1_pk, we2_pk, we1_pk_gen, we2_pk_gen: std_logic;
	signal addr1_pk, addr2_pk, addr1_pk_gen, addr2_pk_gen, addr1_pk_tb, addr2_pk_tb : std_logic_vector(12 downto 0);
	signal din1_pk, din2_pk, dout1_pk, dout2_pk, din1_pk_gen, din2_pk_gen, dout1_pk_tb, dout2_pk_tb : std_logic_vector(15 downto 0);

	signal we1_sk, we2_sk, we2_sk_gen, we1_sk_gen : std_logic;
	signal addr1_sk, addr2_sk, addr1_sk_gen, addr2_sk_gen, addr1_sk_tb, addr2_sk_tb : std_logic_vector(13 downto 0);
	signal din1_sk, din2_sk, dout1_sk, dout2_sk, din1_sk_gen, din2_sk_gen, dout1_sk_tb, dout2_sk_tb : std_logic_vector(15 downto 0);

	signal we1_a, we2_a : std_logic;
	signal addr1_a, addr2_a : std_logic_vector(12 downto 0);
	signal din1_a, din2_a, dout1_a, dout2_a : std_logic_vector(15 downto 0);

	signal we1_b, we2_b : std_logic;
	signal addr1_b, addr2_b : std_logic_vector(13 downto 0);
	signal din1_b, din2_b, dout1_b, dout2_b : std_logic_vector(15 downto 0);

	signal reset_gen, enable_gen : std_logic := '0';
	signal done_gen : std_logic;

	constant clk_period : time := 10 ns;
	constant total_tests : integer := 2;

begin

	rand : single_port_bram
	generic map(
		awidth => 5,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_rand,
		addr => addr_rand,
		din => din_rand,
		dout => dout_rand
	);

	pk : pk_bram
	port map(
		clk => clk,
		we1 => we1_pk,
		addr1 => addr1_pk,
		din1 => din1_pk,
		dout1 => dout1_pk,
		we2 => we2_pk,
		addr2 => addr2_pk,
		din2 => din2_pk,
		dout2 => dout2_pk
	);

	sk : sk_bram
	port map(
		clk => clk,
		we1 => we1_sk,
		addr1 => addr1_sk,
		din1 => din1_sk,
		dout1 => dout1_sk,
		we2 => we2_sk,
		addr2 => addr2_sk,
		din2 => din2_sk,
		dout2 => dout2_sk
	);

	a : single_port_bram
	generic map(
		awidth => 13,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we1_a,
		addr => addr1_a,
		din => din1_a,
		dout => dout1_a
	);

	b : single_port_bram
	generic map(
		awidth => 14,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we1_b,
		addr => addr1_b,
		din => din1_b,
		dout => dout1_b
	);

	keygen : frodo_gen
	port map(
		clk => clk,
		reset => reset_gen,
		enable => enable_gen,
		done => done_gen,

		addr_rand => addr_rand_gen,
		dout_rand => dout_rand_gen,

		we1_pk => we1_pk_gen,
		addr1_pk => addr1_pk_gen,
		din1_pk => din1_pk_gen,
		we2_pk => we2_pk_gen,
		addr2_pk => addr2_pk_gen,
		din2_pk => din2_pk_gen,

		we1_sk => we1_sk_gen,
		addr1_sk => addr1_sk_gen,
		din1_sk => din1_sk_gen,
		we2_sk => we2_sk_gen,
		addr2_sk => addr2_sk_gen,
		din2_sk => din2_sk_gen
	);

	we_rand <= we_rand_tb;
	addr_rand <= addr_rand_tb when enable_gen = '0' else addr_rand_gen;
	din_rand <= din_rand_tb;
	dout_rand_gen <= dout_rand;

	we1_pk <= we1_pk_gen;
	we2_pk <= we2_pk_gen;
	addr1_pk <= addr1_pk_tb when enable_gen = '0' else addr1_pk_gen;
	addr2_pk <= addr2_pk_tb when enable_gen = '0' else addr2_pk_gen;
	din1_pk <= din1_pk_gen;
	din2_pk <= din2_pk_gen;
	dout1_pk_tb <= dout1_pk;
	dout2_pk_tb <= dout2_pk;

	we1_sk <= we1_sk_gen;
	we2_sk <= we2_sk_gen;
	addr1_sk <= addr1_sk_tb when enable_gen = '0' else addr1_sk_gen;
	addr2_sk <= addr2_sk_tb when enable_gen = '0' else addr2_sk_gen;
	din1_sk <= din1_sk_gen;
	din2_sk <= din2_sk_gen;
	dout1_sk_tb <= dout1_sk;
	dout2_sk_tb <= dout2_sk;

	clk_process : process is
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	timing : process (clk) is
	begin
		if (clk = '1' and enable_gen = '1') then
			cycles <= cycles + 1;
		end if;
	end process;

	testing : process is
		variable row, msg : line;
		variable rand_vector, pk_vector, sk_vector : std_logic_vector(15 downto 0);
	begin
		file_open(values, "C:/Users/fabusbo/Desktop/Masterarbeit/VHDL/GEN/frodo_gen_values_vhdl.txt", read_mode);

		while (tests_completed < total_tests) loop
			while (input_done = '0') loop
				enable_gen <= '0';
				if (state = read_rand) then
					readline(values, row);
					hread(row, rand_vector);
					we_rand_tb <= '1';
					addr_rand_tb <= std_logic_vector(to_unsigned(counter, 5));
					din_rand_tb <= rand_vector;
					counter <= counter + 1;
					if (counter = 23) then
						counter <= 0;
						state <= read_pk;
					end if;
				elsif (state = read_pk) then
					readline(values, row);
					hread(row, pk_vector);
					we1_a <= '1';
					addr1_a <= std_logic_vector(to_unsigned(counter, 13));
					din1_a <= pk_vector;
					counter <= counter + 1;
					if (counter = 4807) then
						counter <= 0;
						state <= read_sk;
					end if;
				elsif (state = read_sk) then
					readline(values, row);
					hread(row, sk_vector);
					we1_b <= '1';
					addr1_b <= std_logic_vector(to_unsigned(counter, 14));
					din1_b <= sk_vector;
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
				we_rand_tb <= '0';
				we1_a <= '0';
				we1_b <= '0';
				reset_gen <= '1';
				wait for clk_period;
				reset_gen <= '0';
				enable_gen <= '1';
				wait until done_gen = '1';
				enable_gen <= '0';
				state <= compare;
				wait for clk_period;
			elsif (state = compare) then
				while (pk_done = '0') loop
					addr1_a <= std_logic_vector(to_unsigned(counter, 13));
					addr1_pk_tb <= std_logic_vector(to_unsigned(counter, 13));
					counter <= counter + 1;
					wait for 2*clk_period;
					if (dout1_a = dout1_pk_tb) then
						comparisons_pk <= comparisons_pk + 1;
					end if;
					if (counter = 4807) then
						pk_done <= '1';
						counter <= 0;
					end if;
					wait for clk_period;
				end loop;
				while (sk_done = '0') loop
					addr1_b <= std_logic_vector(to_unsigned(counter, 14));
					addr1_sk_tb <= std_logic_vector(to_unsigned(counter, 14));
					counter <= counter + 1;
					wait for 2*clk_period;
					if (dout1_b = dout1_sk_tb) then
						comparisons_sk <= comparisons_sk + 1;
					end if;
					if (counter = 9943) then
						counter <= 0;
						sk_done <= '1';
					end if;
				end loop;
				if (comparisons_pk = 4807 and comparisons_sk = 9943) then
					tests_passed <= tests_passed + 1;
				else
					tests_failed <= tests_failed + 1;
				end if;
				tests_completed <= tests_completed + 1;
				pk_done <=  '0';
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