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

	component frodo_dec is
	port (
	    ap_clk : IN STD_LOGIC;
	    ap_rst : IN STD_LOGIC;
	    ap_start : IN STD_LOGIC;
	    ap_done : OUT STD_LOGIC;
	    ap_idle : OUT STD_LOGIC;
	    ap_ready : OUT STD_LOGIC;
	    ss_address0 : OUT STD_LOGIC_VECTOR (2 downto 0);
	    ss_ce0 : OUT STD_LOGIC;
	    ss_we0 : OUT STD_LOGIC;
	    ss_d0 : OUT STD_LOGIC_VECTOR (15 downto 0);
	    ct_address0 : OUT STD_LOGIC_VECTOR (12 downto 0);
	    ct_ce0 : OUT STD_LOGIC;
	    ct_q0 : IN STD_LOGIC_VECTOR (15 downto 0);
	    sk_address0 : OUT STD_LOGIC_VECTOR (13 downto 0);
	    sk_ce0 : OUT STD_LOGIC;
	    sk_q0 : IN STD_LOGIC_VECTOR (15 downto 0) );
	end component;

	file values : text;

	signal clk : std_logic := '1';

	type states is (read_ct, read_sk, read_ss, execute, compare);
	signal state : states := read_ct;

	signal counter, tests_passed, tests_failed, tests_completed, comparisons, cycles : integer := 0;
	signal input_done, outputs_compared : std_logic := '0';

	signal reset_dec, start_dec, done_dec, idle_dec, ready_dec : std_logic;
	signal ss_ce0, ss_we0, ct_ce0, sk_ce0 : std_logic;
	signal ss_address0 : std_logic_vector(2 downto 0);
	signal ct_address0 : std_logic_vector(12 downto 0);
	signal sk_address0 : std_logic_vector(13 downto 0);
	signal ss_d0, ct_q0, sk_q0 : std_logic_vector(15 downto 0);

	signal we_ct, we_ct_tb : std_logic;
	signal addr_ct, addr_ct_tb : std_logic_vector(12 downto 0);
	signal din_ct, dout_ct, din_ct_tb, dout_ct_tb : std_logic_vector(15 downto 0);

	signal we_sk, we_sk_tb : std_logic;
	signal addr_sk, addr_sk_tb : std_logic_vector(13 downto 0);
	signal din_sk, dout_sk, din_sk_tb, dout_sk_tb : std_logic_vector(15 downto 0);

	signal we_a : std_logic;
	signal addr_a : std_logic_vector(2 downto 0);
	signal din_a, dout_a : std_logic_vector(15 downto 0);

	signal we_ss, we_ss_tb : std_logic;
	signal addr_ss, addr_ss_tb : std_logic_vector(2 downto 0);
	signal din_ss, dout_ss, din_ss_tb, dout_ss_tb : std_logic_vector(15 downto 0);

	constant clk_period : time := 10 ns;
	constant total_tests : integer := 1;

begin

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

	decryption : frodo_dec
	port map(
		ap_clk => clk,
		ap_rst => reset_dec,
		ap_start => start_dec,
		ap_done => done_dec,
		ap_idle => idle_dec,
		ap_ready => ready_dec,
		ss_address0 => ss_address0,
		ss_ce0 => ss_ce0,
		ss_we0 => ss_we0,
		ss_d0 => ss_d0,
		ct_address0 => ct_address0,
		ct_ce0 => ct_ce0,
		ct_q0 => ct_q0,
		sk_address0 => sk_address0,
		sk_ce0 => sk_ce0,
		sk_q0 => sk_q0
	);

	we_ct <= we_ct_tb;
	addr_ct <= addr_ct_tb when start_dec = '0' else ct_address0;
	din_ct <= din_ct_tb;
	ct_q0 <= dout_ct;

	we_sk <= we_sk_tb;
	addr_sk <= addr_sk_tb when start_dec = '0' else sk_address0;
	din_sk <= din_sk_tb;
	sk_q0 <= dout_sk;

	we_ss <= we_ss_tb when start_dec = '0' else ss_we0;
	addr_ss <= addr_ss_tb when start_dec = '0' else ss_address0;
	din_ss <= din_ss_tb when start_dec = '0' else ss_d0;
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
		if (clk = '1' and start_dec = '1') then
			cycles <= cycles + 1;
		end if;
	end process;

	testing : process
		variable row, msg : line;
		variable ct_vector, sk_vector, ss_vector : std_logic_vector(15 downto 0);
	begin
		file_open(values, "C:/Users/fabusbo/Desktop/Masterarbeit/HLS/FrodoKEM-640/Dec/frodo_dec_values_vhdl.txt", read_mode);

		while (tests_completed < total_tests) loop
			while (input_done = '0') loop
				start_dec <= '0';
				if (state = read_ct) then
					readline(values, row);
					hread(row, ct_vector);
					we_ct_tb <= '1';
					addr_ct_tb <= std_logic_vector(to_unsigned(counter, 13));
					din_ct_tb <= ct_vector;
					counter <= counter + 1;
					if (counter = 4859) then
						counter <= 0;
						state <= read_sk;
					end if;
				elsif (state = read_sk) then
					readline(values, row);
					hread(row, sk_vector);
					we_sk_tb <= '1';
					addr_sk_tb <= std_logic_vector(to_unsigned(counter, 14));
					din_sk_tb <= sk_vector;
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
				we_ct_tb <= '0';
				we_sk_tb <= '0';
				we_a <= '0';
				reset_dec <= '1';
				wait for clk_period;
				reset_dec <= '0';
				start_dec <= '1';
				wait until done_dec = '1';
				start_dec <= '0';
				state <= compare;
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
					wait for clk_period;
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
