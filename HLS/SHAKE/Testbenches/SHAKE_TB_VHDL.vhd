library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity shake_tb is
end entity shake_tb;

architecture behave of shake_tb is

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

	component shake is
		port (
		    ap_clk : IN STD_LOGIC;
		    ap_rst : IN STD_LOGIC;
		    ap_start : IN STD_LOGIC;
		    ap_done : OUT STD_LOGIC;
		    ap_idle : OUT STD_LOGIC;
		    ap_ready : OUT STD_LOGIC;
		    output_r_address0 : OUT STD_LOGIC_VECTOR (14 downto 0);
		    output_r_ce0 : OUT STD_LOGIC;
		    output_r_we0 : OUT STD_LOGIC;
		    output_r_d0 : OUT STD_LOGIC_VECTOR (15 downto 0);
		    outlen : IN STD_LOGIC_VECTOR (15 downto 0);
		    input_r_address0 : OUT STD_LOGIC_VECTOR (13 downto 0);
		    input_r_ce0 : OUT STD_LOGIC;
		    input_r_q0 : IN STD_LOGIC_VECTOR (15 downto 0);
		    input_r_address1 : OUT STD_LOGIC_VECTOR (13 downto 0);
		    input_r_ce1 : OUT STD_LOGIC;
		    input_r_q1 : IN STD_LOGIC_VECTOR (15 downto 0);
		    inlen : IN STD_LOGIC_VECTOR (15 downto 0) );
	end component;
	
	file values : text;

	signal clk : std_logic := '1';

	type states is (read_lengths, read_input, read_output, execute, compare);
	signal state : states := read_lengths;

	signal counter : integer := 0;
	signal input_done : std_logic := '0';
	signal tests_passed, tests_failed, comparisons, tests_completed : integer := 0;
	signal outputs_compared : std_logic := '0';
	signal total_cycles : integer := 0;

	signal reset_shake, start_shake, done_shake, idle_shake, ready_shake : std_logic;
	signal output_r_address0 : std_logic_vector(14 downto 0);
	signal output_r_ce0, output_r_we0 : std_logic;
	signal output_r_d0 : std_logic_vector(15 downto 0);
	signal outlen, inlen : std_logic_vector(15 downto 0);
	signal input_r_address0, input_r_address1 : std_logic_vector(13 downto 0);
	signal input_r_ce0, input_r_ce1 : std_logic;
	signal input_r_q0, input_r_q1 : std_logic_vector(15 downto 0);

	signal we1_a, we2_a, we1_a_tb, we2_a_tb : std_logic;
	signal addr1_a, addr2_a, addr1_a_tb, addr2_a_tb : std_logic_vector(13 downto 0);
	signal din1_a, din2_a, din1_a_tb, din2_a_tb, dout1_a, dout2_a, dout1_a_tb, dout2_a_tb : std_logic_vector(15 downto 0);

	signal we_b, we_b_tb : std_logic;
	signal addr_b, addr_b_tb : std_logic_vector(14 downto 0);
	signal din_b, din_b_tb, dout_b, dout_b_tb : std_logic_vector(15 downto 0);

	signal we_r, we_r_tb : std_logic;
	signal addr_r, addr_r_tb : std_logic_vector(14 downto 0);
	signal din_r, din_r_tb, dout_r, dout_r_tb : std_logic_vector(15 downto 0);


	constant clk_period : time := 10 ns;
	constant total_tests : integer := 8;

begin

	a : true_dual_port_bram
	generic map(
		awidth => 14,
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

	b : single_port_bram
	generic map(
		awidth => 15,
		dwidth => 16
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
		awidth => 15,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_r,
		addr => addr_r,
		din => din_r,
		dout => dout_r
	);

	hash : shake
	port map(
		ap_clk => clk,
		ap_rst => reset_shake,
		ap_start => start_shake,
		ap_done => done_shake,
		ap_idle => idle_shake,
		ap_ready => ready_shake,
		output_r_address0 => output_r_address0,
		output_r_ce0 => output_r_ce0,
		output_r_we0 => output_r_we0,
		output_r_d0 => output_r_d0,
		outlen => outlen,
		input_r_address0 => input_r_address0,
		input_r_ce0 => input_r_ce0,
		input_r_q0 => input_r_q0,
		input_r_address1 => input_r_address1,
		input_r_ce1 => input_r_ce1,
		input_r_q1 => input_r_q1,
		inlen => inlen
	);

	we1_a <= we1_a_tb;
	addr1_a <= addr1_a_tb when start_shake = '0' else input_r_address0;
	din1_a <= din1_a_tb;
	input_r_q0 <= dout1_a;
	we2_a <= we2_a_tb;
	addr2_a <= addr2_a_tb when start_shake = '0' else input_r_address1;
	din2_a <= din2_a_tb;
	input_r_q1 <= dout2_a;
	we_b <= we_b_tb when start_shake = '0' else output_r_we0;
	addr_b <= addr_b_tb when start_shake = '0' else output_r_address0;
	din_b <= din_b_tb when start_shake = '0' else output_r_d0;
	dout_b_tb <= dout_b;
	we_r <= we_r_tb;
	addr_r <= addr_r_tb;
	din_r <= din_r_tb;
	dout_r_tb <= dout_r;

	clk_process : process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	timing : process (clk) is
	begin
		if (clk = '1' and start_shake = '1') then
			total_cycles <= total_cycles + 1;
		end if;
	end process;

	testing : process
		variable row : line;
		variable a_vector, b_vector : std_logic_vector(15 downto 0);
		variable i_vector, o_vector : integer;
		variable msg : line;
	begin
		file_open(values, "C:/Users/fabusbo/Desktop/Masterarbeit/HLS/SHAKE/shakevalues_vhdl.txt", read_mode);
	
		while (tests_completed < total_tests) loop
			while (input_done = '0') loop
				if (state = read_lengths) then
					readline(values, row);
					read(row, i_vector);
					inlen <= std_logic_vector(to_unsigned(i_vector, 16));
					readline(values, row);
					read(row, o_vector);
					outlen <= std_logic_vector(to_unsigned(o_vector, 16));
					state <= read_input;
					start_shake <= '0';
				elsif (state = read_input) then
					readline(values, row);
					hread(row, a_vector);
					we1_a_tb <= '1';
					addr1_a_tb <= std_logic_vector(to_unsigned(counter, 14));
					din1_a_tb <= a_vector;
					counter <= counter + 1;
					if (counter = to_integer(unsigned(inlen))/2-1) then
						counter <= 0;
						state <= read_output;
					end if;
				elsif (state = read_output) then
					readline(values, row);
					hread(row, b_vector);
					we_r_tb <= '1';
					addr_r_tb <= std_logic_vector(to_unsigned(counter, 15));
					din_r_tb <= b_vector;
					counter <= counter + 1;
					if (counter = to_integer(unsigned(outlen))/2-1) then
						counter <= 0;
						state <= execute;
						input_done <= '1';
					end if;
				end if;
				wait for clk_period;
			end loop;
			if (state = execute) then
				we1_a_tb <= '0';
				we_r_tb <= '0';
				reset_shake <= '1';
				wait for clk_period;
				reset_shake <= '0';
				start_shake <= '1';
				wait for clk_period;
				while (done_shake = '0') loop
					wait for clk_period;
				end loop;
				start_shake <= '0';
				state <= compare;
				wait for clk_period;
			elsif (state = compare) then
				reset_shake <= '1';
				start_shake <= '0';
				while (outputs_compared = '0') loop
					addr_b_tb <= std_logic_vector(to_unsigned(counter, 15));
					addr_r_tb <= std_logic_vector(to_unsigned(counter, 15));
					counter <= counter + 1;
					wait for 2*clk_period;
					if (dout_b_tb = dout_r_tb) then
						comparisons <= comparisons + 1;
					end if;
					if (counter = to_integer(unsigned(outlen))/2-1) then
						outputs_compared <= '1';
					end if;
					wait for clk_period;
				end loop;
				if (comparisons = to_integer(unsigned(outlen))/2-1) then
					tests_passed <= tests_passed + 1;
				else
					tests_failed <= tests_failed + 1;
				end if;
				outputs_compared <= '0';
				tests_completed <= tests_completed + 1;
				comparisons <= 0;
				input_done <= '0';
				state <= read_lengths;
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
		write(msg, total_cycles/total_tests);
		write(msg, string'(" clock cycles."));
		assert false report msg.all severity failure;
		wait for clk_period;
	end process;

end behave;