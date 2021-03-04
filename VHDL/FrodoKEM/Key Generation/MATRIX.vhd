--Matrix multiplication of the key generation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity matrix_mul is 
	port(
		clk : in std_logic;
		reset : in std_logic;
		enable : in std_logic;
		done : out std_logic;

		seedA : in std_logic_vector(143 downto 0);

		offset_b : in integer;

		addr_s : out std_logic_vector(9 downto 0);
		dout_s : in std_logic_vector(15 downto 0);

		addr_e : out std_logic_vector(9 downto 0);
		dout_e : in std_logic_vector(15 downto 0);

		we_b : out std_logic;
		addr_b : out std_logic_vector(12 downto 0);
		din_b : out std_logic_vector(15 downto 0);
		dout_b : in std_logic_vector(15 downto 0)
	);
end entity matrix_mul;

architecture behave of matrix_mul is

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

	component gen_a is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			seed_A : in std_logic_vector(143 downto 0);

			we1_a : out std_logic;
			addr1_a : out std_logic_vector(9 downto 0);
			din1_a : out std_logic_vector(15 downto 0);

			we2_a : out std_logic;
			addr2_a : out std_logic_vector(9 downto 0);
			din2_a : out std_logic_vector(15 downto 0)
		);
	end component gen_a;

	type states is (s_reset, s_done, pregen, mul1, mul2, mul3);
	signal state : states := s_reset;

	signal pregen_done : std_logic := '0';
	signal i, j, k : integer := 0;
	signal a, e, s, b : unsigned(15 downto 0);
	signal as : unsigned(31 downto 0);
	signal ast : unsigned(31 downto 0);
	signal aste : unsigned(31 downto 0);

	------------Gen_A signals------------
	signal reset_gen, enable_gen, done_gen : std_logic;
	signal seed_A_gen : std_logic_vector(143 downto 0);
	signal we1_a_gen, we2_a_gen : std_logic;
	signal addr1_a_gen, addr2_a_gen : std_logic_vector(9 downto 0);
	signal din1_a_gen, din2_a_gen : std_logic_vector(15 downto 0);

	------------A_1 signals------------
	signal we1_A1, we2_A1 : std_logic;
	signal addr1_A1, addr2_A1, addr_A1_matrix : std_logic_vector(9 downto 0);
	signal din1_A1, din2_A1, dout1_A1, dout2_A1 : std_logic_vector(15 downto 0);

	------------A_2 signals------------
	signal we1_A2, we2_A2 : std_logic;
	signal addr1_A2, addr2_A2, addr_A2_matrix : std_logic_vector(9 downto 0);
	signal din1_A2, din2_A2, dout1_A2, dout2_A2 : std_logic_vector(15 downto 0);

begin

	A_1 : true_dual_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we1 => we1_A1,
		addr1 => addr1_A1, 
		din1 => din1_A1,
		dout1 => dout1_A1,
		we2 => we2_A1,
		addr2 => addr2_A1,
		din2 => din2_A1,
		dout2 => dout2_A1
	);

	A_2 : true_dual_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we1 => we1_A2,
		addr1 => addr1_A2, 
		din1 => din1_A2,
		dout1 => dout1_A2,
		we2 => we2_A2,
		addr2 => addr2_A2,
		din2 => din2_A2,
		dout2 => dout2_A2
	);

	generate_a : gen_a
	port map(
		clk => clk,
		reset => reset_gen,
		enable => enable_gen,
		done => done_gen,

		seed_A => seed_A_gen,

		we1_a => we1_a_gen,
		addr1_a => addr1_a_gen,
		din1_a => din1_a_gen,
		we2_a => we2_a_gen,
		addr2_a => addr2_a_gen,
		din2_a => din2_a_gen
	);

	------------Selecting for A_1------------
	with state select we1_A1 <=
		we1_a_gen 			when mul1,
		'0'					when others;

	with state select we2_A1 <=
		we2_a_gen 			when mul1,
		'0'					when others;

	addr1_A1 <=	addr1_a_gen 	when (state = mul1) else
				addr_A1_matrix 	when (state = mul1 and j = 0) else
				addr_A1_matrix 	when (state = mul2) else
				addr_A1_matrix 	when (state = mul3) else
				(others => '0');

	addr2_A1 <= addr2_a_gen 	when (state = mul1) else
				(others => '0');

	with state select din1_A1 <=
		din1_a_gen 			when mul1,
		x"0000"				when others;

	with state select din2_A1 <=
		din2_a_gen			when mul1,
		x"0000"				when others;

	------------Selecting for A_2------------
	with state select we1_A2 <=
		we1_a_gen 			when pregen,
		we1_a_gen			when mul2,
		'0'					when others;

	with state select we2_A2 <=
		we2_a_gen 			when pregen,
		we2_a_gen			when mul2,
		'0'					when others;

	addr1_A2 <=	addr1_a_gen		when (state = pregen) else
				addr_A2_matrix	when (state = mul2 and j = 0) else
				addr1_a_gen 	when (state = mul2)	else
				addr_A2_matrix	when (state = mul1) else
				(others => '0');

	addr2_A2 <= addr2_a_gen		when (state = pregen) else
				addr2_a_gen 	when (state = mul2) else
				(others => '0');

	with state select din1_A2 <=
		din1_a_gen 			when pregen,
		din1_a_gen			when mul2,
		x"0000"				when others;

	with state select din2_A2 <=
		din2_a_gen 			when pregen,
		din2_a_gen			when mul2,
		x"0000"				when others;

	a <=	unsigned(dout1_A1) when (state = mul1 and j = 0) else
			unsigned(dout1_A2) when (state = mul1) else
			unsigned(dout1_A2) when (state = mul2 and j = 0) else
			unsigned(dout1_A1) when (state = mul2) else
			unsigned(dout1_A1) when (state = mul3) else
			x"0000";

	s <= 	unsigned(dout_s);

	e <= 	unsigned(dout_e) when (j = 2 and i > 0) else
			unsigned(dout_e) when (j = 2 and state = mul3) else
			x"0000";

	addr_A1_matrix <= std_logic_vector(to_unsigned(j, 10));
	addr_A2_matrix <= std_logic_vector(to_unsigned(j, 10));
	addr_s <= 	std_logic_vector(to_unsigned(j, 10));
	addr_e <= 	std_logic_vector(to_unsigned(639, 10)) when (state = mul3) else
				std_logic_vector(to_unsigned(i-1, 10));

	process (clk) is
	begin
		if (rising_edge(clk)) then
			done <= '0';
			we_b <= '0';

			if (reset = '1') then
				state <= s_reset;
				pregen_done <= '0';
				reset_gen <= '1';
				k <= 0;

			elsif (enable = '1') then
				if (state = s_reset) then
					seed_A_gen <= (others => '0');
					i <= 0;

					--If the first row of A has not been pregenerated yet: go to pregeneration
					--Else start with the multiplication
					if (pregen_done = '0') then
						state <= pregen;
						reset_gen <= '0';
						enable_gen <= '1';
						seed_A_gen <= std_logic_vector(to_unsigned(0, 16)) & seedA(127 downto 0);
					else
						state <= mul1;
						reset_gen <= '0';
						enable_gen <= '1';
						seed_A_gen <= std_logic_vector(to_unsigned(1, 16)) & seedA(127 downto 0);
					end if;

				--Pregen the first row of A, set seedA for the next row
				elsif (state = pregen) then
					if (done_gen = '1') then
						state <= mul1;
						seed_A_gen <= std_logic_vector(to_unsigned(1, 16)) & seedA(127 downto 0);
						pregen_done <= '1';
					end if;

				--Multiplication of S with current row of A, next row is generated in parallel
				elsif (state = mul1) then
					if (done_gen = '1') then
						enable_gen <= '0';
						if (i = 638) then
							seed_A_gen <= x"0000" & seedA(127 downto 0);
						else
							seed_A_gen <= std_logic_vector(to_unsigned(i+2, 16)) & seedA(127 downto 0);	
						end if;
					end if;
					if (j = 639) then
						enable_gen <= '1';
						state <= mul2;
						i <= i + 1;
					end if;
					--Write the result into B once it is available
					if (j = 3 and i > 0) then
						we_b <= '1';
						addr_b <= std_logic_vector(to_unsigned(k, 13));
						din_b <= std_logic_vector(aste(15 downto 0));
						k <= k + 8;
					end if;

				elsif (state = mul2) then
					if (done_gen = '1') then
						enable_gen <= '0';
						seed_A_gen <= std_logic_vector(to_unsigned(i+2, 16)) & seedA(127 downto 0);
					end if;
					if (j = 639) then
						enable_gen <= '1';
						state <= mul1;
						i <= i + 1;
						if (i = 639) then
							state <= mul3;
							i <= 0;
							enable_gen <= '0';
						end if;
					end if;
					if (j = 3 and i > 0) then
						we_b <= '1';
						addr_b <= std_logic_vector(to_unsigned(k, 13));
						din_b <= std_logic_vector(aste(15 downto 0));
						k <= k + 8;
					end if;

				--Finish the last multiplications
				elsif (state = mul3) then
					if (j = 3) then
						state <= s_done;
						we_b <= '1';
						addr_b <= std_logic_vector(to_unsigned(k, 13));
						din_b <= std_logic_vector(aste(15 downto 0));
						k <= k - 5111;
					end if;

				elsif (state = s_done) then
					done <= '1';
					state <= s_reset;
				end if;
			end if;
		end if;
	end process;

	--Actual multiplication in a pipelined way:
	--Calculate as = a * s
	--			ast = as + ast (the previous accumulated result)
	--			aste =  ast + e (addition of error term)
	mult : process (clk) is
	begin
		if (rising_edge(clk)) then
			if (enable = '1') then
				if (i = 0 and j = 0 and state /= mul3) then
					as <= (others => '0');
				else					
					as <= a*s;
				end if;
				if ((j <= 1 and i = 0 and state /= mul3) or (j = 2 and i > 0)) then
					ast <= as;
				else
					ast <= ast + as;
				end if;

				aste <= ast + e;

				if (state = mul1 or state = mul2) then
					j <= j + 1;
					if (j = 639) then
						j <= 0;
					end if;
				elsif (state = mul3) then
					j <= j + 1;
					if (j = 3) then
						j <= 0;
					end if;
				elsif (state = s_reset) then
					j <= 0;
				end if;
			end if;
		end if;
	end process;

end behave;