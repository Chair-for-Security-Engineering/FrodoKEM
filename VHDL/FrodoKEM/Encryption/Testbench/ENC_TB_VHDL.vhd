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

	component mu_bram is
		port(
			clk : in std_logic;
			we : in std_logic;
			addr : in std_logic_vector(2 downto 0);
			din : in std_logic_vector(15 downto 0);
			dout : out std_logic_vector(15 downto 0)
		);
	end component mu_bram;

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

	component frodo_enc is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			addr_mu : out std_logic_vector(2 downto 0);
			dout_mu : in std_logic_vector(15 downto 0);

			addr1_pk : out std_logic_vector(12 downto 0);
			dout1_pk : in std_logic_vector(15 downto 0);
			addr2_pk : out std_logic_vector(12 downto 0);
			dout2_pk : in std_logic_vector(15 downto 0);

			we1_ct : out std_logic;
			addr1_ct : out std_logic_vector(12 downto 0);
			din1_ct : out std_logic_vector(15 downto 0);
			dout1_ct : in std_logic_vector(15 downto 0);
			we2_ct : out std_logic;
			addr2_ct : out std_logic_vector(12 downto 0);
			din2_ct : out std_logic_vector(15 downto 0);
			dout2_ct : in std_logic_vector(15 downto 0);

			we_ss : out std_logic;
			addr_ss : out std_logic_vector(2 downto 0);
			din_ss : out std_logic_vector(15 downto 0)
		);
	end component;

	file values : text;

	signal clk : std_logic := '1';

	type states is (read_mu, read_pk, read_ct, read_ss, execute, compare);
	signal state : states := read_mu;

	signal counter, tests_passed, tests_failed, tests_completed, comparisons, cycles : integer := 0;
	signal input_done, outputs_compared, ct_done, ss_done : std_logic := '0';
	signal comparisons_ct, comparisons_ss : integer := 0;

	signal reset_enc, enable_enc, done_enc : std_logic;
	signal addr_mu_enc, addr_ss_enc : std_logic_vector(2 downto 0);
	signal we1_ct_enc, we2_ct_enc, we_ss_enc : std_logic;
	signal addr1_pk_enc, addr2_pk_enc, addr1_ct_enc, addr2_ct_enc : std_logic_vector(12 downto 0);
	signal dout_mu_enc, dout1_pk_enc, dout2_pk_enc, din1_ct_enc, din2_ct_enc, din_ss_enc, dout1_ct_enc, dout2_ct_enc : std_logic_vector(15 downto 0);

	signal we_mu, we_mu_tb : std_logic;
	signal addr_mu, addr_mu_tb : std_logic_vector(2 downto 0);
	signal din_mu, dout_mu, din_mu_tb, dout_mu_tb : std_logic_vector(15 downto 0);

	signal we1_pk, we1_pk_tb, we2_pk, we2_pk_tb : std_logic;
	signal addr1_pk, addr1_pk_tb, addr2_pk, addr2_pk_tb : std_logic_vector(12 downto 0);
	signal din1_pk, dout1_pk, din1_pk_tb, dout1_pk_tb, din2_pk, dout2_pk, din2_pk_tb, dout2_pk_tb : std_logic_vector(15 downto 0);

	signal we_a : std_logic;
	signal addr_a : std_logic_vector(12 downto 0);
	signal din_a, dout_a : std_logic_vector(15 downto 0);

	signal we1_ct, we1_ct_tb, we2_ct, we2_ct_tb : std_logic;
	signal addr1_ct, addr1_ct_tb, addr2_ct, addr2_ct_tb : std_logic_vector(12 downto 0);
	signal din1_ct, dout1_ct, din1_ct_tb, dout1_ct_tb, din2_ct, dout2_ct, din2_ct_tb, dout2_ct_tb : std_logic_vector(15 downto 0);

	signal we_b : std_logic;
	signal addr_b : std_logic_vector(2 downto 0);
	signal din_b, dout_b : std_logic_vector(15 downto 0);

	signal we_ss, we_ss_tb : std_logic;
	signal addr_ss, addr_ss_tb : std_logic_vector(2 downto 0);
	signal din_ss, dout_ss, din_ss_tb, dout_ss_tb : std_logic_vector(15 downto 0);

	constant clk_period : time := 10 ns;
	constant total_tests : integer := 2;

begin

	mu : mu_bram
	port map(
		clk => clk,
		we => we_mu,
		addr => addr_mu,
		din => din_mu,
		dout => dout_mu
	);

	pk : ct_bram
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

	ss : mu_bram
	port map(
		clk => clk,
		we => we_ss,
		addr => addr_ss,
		din => din_ss,
		dout => dout_ss
	);

	encryption : frodo_enc
	port map(
		clk => clk,
		reset => reset_enc,
		enable => enable_enc,
		done => done_enc,

		addr_mu => addr_mu_enc,
		dout_mu => dout_mu_enc,

		addr1_pk => addr1_pk_enc,
		dout1_pk => dout1_pk_enc,
		addr2_pk => addr2_pk_enc,
		dout2_pk => dout2_pk_enc,

		we1_ct => we1_ct_enc,
		addr1_ct => addr1_ct_enc,
		din1_ct => din1_ct_enc,
		dout1_ct => dout1_ct_enc,
		we2_ct => we2_ct_enc,
		addr2_ct => addr2_ct_enc,
		din2_ct => din2_ct_enc,
		dout2_ct => dout2_ct_enc,

		we_ss => we_ss_enc,
		addr_ss => addr_ss_enc,
		din_ss => din_ss_enc
	);

	we_mu <= we_mu_tb;
	addr_mu <= addr_mu_tb when enable_enc = '0' else addr_mu_enc;
	din_mu <= din_mu_tb;
	dout_mu_enc <= dout_mu;

	we1_pk <= we1_pk_tb;
	addr1_pk <= addr1_pk_tb when enable_enc = '0' else addr1_pk_enc;
	din1_pk <= din1_pk_tb;
	dout1_pk_enc <= dout1_pk;
	we2_pk <= we2_pk_tb;
	addr2_pk <= addr2_pk_tb when enable_enc = '0' else addr2_pk_enc;
	din2_pk <= din2_pk_tb;
	dout2_pk_enc <= dout2_pk;


	we1_ct <= we1_ct_tb when enable_enc = '0' else we1_ct_enc;
	addr1_ct <= addr1_ct_tb when enable_enc = '0' else addr1_ct_enc;
	din1_ct <= din1_ct_tb when enable_enc = '0' else din1_ct_enc;
	dout1_ct_tb <= dout1_ct;
	dout1_ct_enc <= dout1_ct;
	we2_ct <= we2_ct_tb when enable_enc = '0' else we2_ct_enc;
	addr2_ct <= addr2_ct_tb when enable_enc = '0' else addr2_ct_enc;
	din2_ct <= din2_ct_tb when enable_enc = '0' else din2_ct_enc;
	dout2_ct_tb <= dout2_ct;
	dout2_ct_enc <= dout2_ct;

	we_ss <= we_ss_tb when enable_enc = '0' else we_ss_enc;
	addr_ss <= addr_ss_tb when enable_enc = '0' else addr_ss_enc;
	din_ss <= din_ss_tb when enable_enc = '0' else din_ss_enc;
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
		if (clk = '1' and enable_enc = '1') then
			cycles <= cycles + 1;
		end if;
	end process;

	testing : process
		variable row, msg : line;
		variable mu_vector, pk_vector, ct_vector, ss_vector : std_logic_vector(15 downto 0);
	begin
		file_open(values, "C:/Users/fabusbo/Desktop/Masterarbeit/VHDL/Encryption/frodo_enc_values_vhdl.txt", read_mode);
	
		while (tests_completed < total_tests) loop
			while (input_done = '0') loop
				enable_enc <= '0';
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
					we1_pk_tb <= '1';
					addr1_pk_tb <= std_logic_vector(to_unsigned(counter, 13));
					din1_pk_tb <= pk_vector;
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
				we1_pk_tb <= '0';
				we_a <= '0';
				we_b <= '0';
				reset_enc <= '1';
				wait for clk_period;
				reset_enc <= '0';
				enable_enc <= '1';
				wait until done_enc = '1';
				state <= compare;
				enable_enc <= '0';
				wait for clk_period;
			elsif (state = compare) then
				while (ct_done = '0') loop
					addr_a <= std_logic_vector(to_unsigned(counter, 13));
					addr1_ct_tb <= std_logic_vector(to_unsigned(counter, 13));
					counter <= counter + 1;
					wait for 2*clk_period;
					if (dout_a = dout1_ct_tb) then
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