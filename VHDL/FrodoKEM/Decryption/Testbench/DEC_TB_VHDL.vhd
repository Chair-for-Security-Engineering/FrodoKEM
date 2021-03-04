library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity dec_tb is
end entity dec_tb;

architecture behave of dec_tb is

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

	component ct_bram is
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
	end component ct_bram;

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

	component frodo_dec is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			addr1_ct : out std_logic_vector(12 downto 0);
			dout1_ct : in std_logic_vector(15 downto 0);
			addr2_ct : out std_logic_vector(12 downto 0);
			dout2_ct : in std_logic_vector(15 downto 0);

			addr1_sk : out std_logic_vector(13 downto 0);
			dout1_sk : in std_logic_vector(15 downto 0);
			addr2_sk : out std_logic_vector(13 downto 0);
			dout2_sk : in std_logic_vector(15 downto 0);

			we_ss : out std_logic;
			addr_ss : out std_logic_vector(2 downto 0);
			din_ss : out std_logic_vector(15 downto 0)
		);
	end component frodo_dec;

	file values : text;

	signal clk : std_logic := '1';

	type states is (read_ct, read_sk, read_ss, execute, compare);
	signal state : states := read_ct;

	signal enable_dec, reset_dec, done_dec : std_logic;
	signal addr1_ct_dec, addr2_ct_dec : std_logic_vector(12 downto 0);
	signal addr1_sk_dec, addr2_sk_dec : std_logic_vector(13 downto 0);
	signal addr_ss_dec : std_logic_vector(2 downto 0);
	signal we_ss_dec : std_logic;
	signal dout1_ct_dec, dout2_ct_dec, dout1_sk_dec, dout2_sk_dec, din_ss_dec : std_logic_vector(15 downto 0);

	signal we1_ct, we2_ct, we1_ct_tb, we2_ct_tb : std_logic;
	signal addr1_ct, addr2_ct, addr1_ct_tb, addr2_ct_tb : std_logic_vector(12 downto 0);
	signal din1_ct, din2_ct, dout1_ct, dout2_ct, din1_ct_tb, din2_ct_tb, dout1_ct_tb, dout2_ct_tb : std_logic_vector(15 downto 0);

	signal we1_sk, we2_sk, we1_sk_tb, we2_sk_tb : std_logic;
	signal addr1_sk, addr2_sk, addr1_sk_tb, addr2_sk_tb : std_logic_vector(13 downto 0);
	signal din1_sk, din2_sk, dout1_sk, dout2_sk, din1_sk_tb, din2_sk_tb, dout1_sk_tb, dout2_sk_tb : std_logic_vector(15 downto 0);

	signal we_ss, we_ss_tb : std_logic;
	signal addr_ss, addr_ss_tb : std_logic_vector(2 downto 0);
	signal din_ss, dout_ss, din_ss_tb, dout_ss_tb : std_logic_vector(15 downto 0);

	signal we_a : std_logic;
	signal addr_a : std_logic_vector(2 downto 0);
	signal din_a, dout_a : std_logic_vector(15 downto 0);

	signal counter, tests_passed, tests_failed, tests_completed, comparisons, cycles : integer := 0;
	signal input_done, outputs_compared : std_logic := '0';

	constant clk_period : time := 10 ns;
	constant total_tests : integer := 2;

begin

	ct : ct_bram
	port map(
		clk => clk,
		we1 => we1_ct,
		addr1 => addr1_ct,
		din1 => din1_ct,
		dout1 => dout1_ct,
		we2 => we2_ct, 
		addr2 => addr2_ct,
		din2 => din2_ct,
		dout2 => dout2_ct
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

	a : single_port_bram
	generic map(
		awidth => 3,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_a,
		addr => addr_a,
		din => din_a,
		dout => dout_a
	);

	decryption : frodo_dec
	port map(
		clk => clk,
		reset => reset_dec,
		enable => enable_dec,
		done => done_dec,

		addr1_ct => addr1_ct_dec,
		dout1_ct => dout1_ct_dec,
		addr2_ct => addr2_ct_dec,
		dout2_ct => dout2_ct_dec,

		addr1_sk => addr1_sk_dec,
		dout1_sk => dout1_sk_dec,
		addr2_sk => addr2_sk_dec,
		dout2_sk => dout2_sk_dec,

		we_ss => we_ss_dec,
		addr_ss => addr_ss_dec,
		din_ss => din_ss_dec
	);

	we1_ct <= we1_ct_tb;
	we2_ct <= we2_ct_tb;
	addr1_ct <= addr1_ct_tb when enable_dec = '0' else addr1_ct_dec;
	addr2_ct <= addr2_ct_tb when enable_dec = '0' else addr2_ct_dec;
	din1_ct <= din1_ct_tb;
	din2_ct <= din2_ct_tb;
	dout1_ct_dec <= dout1_ct;
	dout2_ct_dec <= dout2_ct;

	we1_sk <= we1_sk_tb;
	we2_sk <= we2_sk_tb;
	addr1_sk <= addr1_sk_tb when enable_dec = '0' else addr1_sk_dec;
	addr2_sk <= addr2_sk_tb when enable_dec = '0' else addr2_sk_dec;
	din1_sk <= din1_sk_tb;
	din2_sk <= din2_sk_tb;
	dout1_sk_dec <= dout1_sk;
	dout2_sk_dec <= dout2_sk;

	we_ss <= we_ss_dec;
	addr_ss <= addr_ss_dec when enable_dec = '1' else addr_ss_tb;
	din_ss <= din_ss_dec;
	dout_ss_tb <= dout_ss;

	clk_process : process is
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	timing : process(clk) is
	begin
		if (clk = '1' and enable_dec = '1') then
			cycles <= cycles + 1;
		end if;
	end process;

	testing : process is
		variable row, msg : line;
		variable ct_vector, sk_vector, ss_vector : std_logic_vector(15 downto 0);
	begin
		file_open(values, "C:/Users/fabusbo/Desktop/Masterarbeit/VHDL/DEC/frodo_dec_values_vhdl.txt", read_mode);

		while (tests_completed < total_tests) loop
			while (input_done = '0') loop
				enable_dec <= '0';
				if (state = read_ct) then
					readline(values, row);
					hread(row, ct_vector);
					we1_ct_tb <= '1';
					addr1_ct_tb <= std_logic_vector(to_unsigned(counter, 13));
					din1_ct_tb <= ct_vector;
					counter <= counter + 1;
					if (counter = 4859) then
						counter <= 0;
						state <= read_sk;
					end if;
				elsif (state = read_sk) then
					readline(values, row);
					hread(row, sk_vector);
					we1_sk_tb <= '1';
					addr1_sk_tb <= std_logic_vector(to_unsigned(counter, 14));
					din1_sk_tb <= sk_vector;
					counter <= counter + 1;
					if (counter = 9943) then
						counter <= 0;
						state <= read_ss;
					end if;
				elsif (state = read_ss) then
					readline(values, row);
					hread(row, ss_vector);
					we_a <= '1';
					addr_a <= std_logic_vector(to_unsigned(counter, 3));
					din_a <= ss_vector;
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
				we1_ct_tb <= '0';
				we1_sk_tb <= '0';
				we_a <= '0';
				reset_dec <= '1';
				wait for clk_period;
				reset_dec <= '0';
				enable_dec <= '1';
				wait until done_dec = '1';
				state <= compare;
				enable_dec <= '0';
				wait for clk_period;
			elsif (state = compare) then
				while (outputs_compared = '0') loop
					addr_a <= std_logic_vector(to_unsigned(counter, 3));
					addr_ss_tb <= std_logic_vector(to_unsigned(counter, 3));
					counter <= counter + 1;
					wait for 2*clk_period;
					if (dout_a = dout_ss_tb) then
						comparisons <= comparisons + 1;
					end if;
					if (counter = 7) then
						outputs_compared <= '1';
						counter <= 0;
					end if;
				end loop;
				if (comparisons = 7) then
					tests_passed <= tests_passed + 1;
				else
					tests_failed <= tests_failed + 1;
				end if;
				tests_completed <= tests_completed + 1;
				outputs_compared <= '0';
				comparisons <= 0;
				state <= read_ct;
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