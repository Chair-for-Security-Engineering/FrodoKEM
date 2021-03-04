--Matrix multiplication. Implements 3 different multiplications using one DSP
--use_A = '1' and use_S = '0' => A on the right
--use_A = '0' and use_S = '1' => S on the right
--use_A = '0' and use_S = '0' => B on the right

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

		n : in integer := 640;

		use_A : in std_logic;
		use_S : in std_logic;
		offset_e : in integer;
		offset_b : in integer;

		addr_s : out std_logic_vector(9 downto 0);
		dout_s : in std_logic_vector(15 downto 0);

		addr_e : out std_logic_vector(9 downto 0);
		dout_e : in std_logic_vector(15 downto 0);

		addr_pk : out std_logic_vector(13 downto 0);
		dout_pk : in std_logic_vector(15 downto 0);

		addr_sk : out std_logic_vector(13 downto 0);
		dout_sk : in std_logic_vector(15 downto 0);

		we1_b : out std_logic;
		addr1_b : out std_logic_vector(9 downto 0);
		din1_b : out std_logic_vector(15 downto 0);
		dout1_b : in std_logic_vector(15 downto 0);
		we2_b : out std_logic;
		addr2_b : out std_logic_vector(9 downto 0);
		din2_b : out std_logic_vector(15 downto 0);
		dout2_b : in std_logic_vector(15 downto 0)
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

	component unpack_8 is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			outlen : in integer;

			addr1_pk : out std_logic_vector(13 downto 0);
			dout1_pk : in std_logic_vector(15 downto 0);

			we1_out : out std_logic;
			addr1_out : out std_logic_vector(9 downto 0);
			din1_out : out std_logic_vector(15 downto 0)
		);
	end component unpack_8;

	component read_S is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			addr_sk : out std_logic_vector(13 downto 0);
			dout_sk : in std_logic_vector(15 downto 0);

			we_out : out std_logic;
			addr_out : out std_logic_vector(9 downto 0);
			din_out : out std_logic_vector(15 downto 0)
		);
	end component read_S;

	type states is (s_reset, s_done, pregen, mul1, mul2, mul3, pregen_unpack, mul4, mul5, mul6, pregen_read, mul7, mul8, mul9);
	signal state : states := s_reset;

	signal pregen_done : std_logic := '0';
	signal i, j, k : integer := 0;
	signal a, e, s, b : unsigned(15 downto 0);
	signal as : unsigned(31 downto 0);
	signal ase : unsigned(31 downto 0);
	signal aseb : unsigned(31 downto 0);

	------------Gen_A signals------------
	signal reset_gen, enable_gen : std_logic := '0';
	signal done_gen : std_logic;
	signal we1_a_gen, we2_a_gen : std_logic;
	signal addr1_a_gen, addr2_a_gen : std_logic_vector(9 downto 0);
	signal din1_a_gen, din2_a_gen : std_logic_vector(15 downto 0);
	signal seed_A_separated : std_logic_vector(143 downto 0);

	------------Unpack signals------------
	signal reset_un, enable_un : std_logic := '0';
	signal done_un : std_logic;
	signal outlen_un : integer := 0;
	signal addr1_pk_un : std_logic_vector(13 downto 0);
	signal we1_out_un : std_logic;
	signal addr1_out_un : std_logic_vector(9 downto 0);
	signal dout1_pk_un, din1_out_un : std_logic_vector(15 downto 0);

	------------Read_S signals------------
	signal reset_read, enable_read : std_logic := '0';
	signal done_read : std_logic;
	signal we_out_read : std_logic;
	signal addr_out_read : std_logic_vector(9 downto 0);
	signal din_out_read : std_logic_vector(15 downto 0);

	------------A_1 signals------------
	signal we1_A1, we2_A1 : std_logic;
	signal addr1_A1, addr2_A1 : std_logic_vector(9 downto 0);
	signal din1_A1, din2_A1, dout1_A1, dout2_A1 : std_logic_vector(15 downto 0);
	signal addr1_A1_matrix, addr2_A1_matrix : std_logic_vector(9 downto 0);
	signal dout1_A1_matrix, dout2_A1_matrix : std_logic_vector(15 downto 0);

	------------A_2 signals------------
	signal we1_A2, we2_A2 : std_logic;
	signal addr1_A2, addr2_A2 : std_logic_vector(9 downto 0);
	signal din1_A2, din2_A2, dout1_A2, dout2_A2 : std_logic_vector(15 downto 0);
	signal addr1_A2_matrix, addr2_A2_matrix : std_logic_vector(9 downto 0);
	signal dout1_A2_matrix, dout2_A2_matrix : std_logic_vector(15 downto 0);

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

		seed_A => seed_A_separated,

		we1_a => we1_a_gen,
		addr1_a => addr1_a_gen,
		din1_a => din1_a_gen,

		we2_a => we2_a_gen,
		addr2_a => addr2_a_gen,
		din2_a => din2_a_gen
	);

	unpacking : unpack_8
	port map(
		clk => clk,
		reset => reset_un,
		enable => enable_un,
		done => done_un,

		outlen => outlen_un,

		addr1_pk => addr1_pk_un,
		dout1_pk => dout1_pk_un,

		we1_out => we1_out_un,
		addr1_out => addr1_out_un,
		din1_out => din1_out_un
	);

	reading : read_S
	port map(
		clk => clk,
		reset => reset_read,
		enable => enable_read,
		done => done_read,

		addr_sk => addr_sk,
		dout_sk => dout_sk,

		we_out => we_out_read,
		addr_out => addr_out_read,
		din_out => din_out_read
	);

	------------Selecting for A_1------------
	with state select we1_A1 <=
		we1_a_gen 			when mul1,
		we1_out_un 			when mul4,
		we_out_read 		when mul7,
		'0'					when others;

	with state select we2_A1 <=
		we2_a_gen 			when mul1,
		'0'					when others;

	addr1_A1 <= addr1_a_gen when (state = mul1) else
				addr1_A1_matrix when (state = mul2) else
				addr1_A1_matrix when (state = mul3) else
				addr1_out_un when (state = mul4) else
				addr1_A1_matrix when (state = mul5) else
				addr1_A1_matrix when (state = mul6) else
				addr_out_read when (state = mul7) else
				addr1_A1_matrix when (state = mul8) else
				addr1_A1_matrix when (state = mul9) else
				(others => '0');

	with state select addr2_A1 <=
		addr2_a_gen 		when mul1,
		addr2_A1_matrix 	when mul2,
		(others => '0')		when others;

	with state select din1_A1 <=
		din1_a_gen 			when mul1,
		din1_out_un 		when mul4,
		din_out_read 		when mul7,
		x"0000" 			when others;

	with state select din2_A1 <=
		din2_a_gen 			when mul1,
		x"0000" 			when others;


	------------Selecting for A_2------------
	with state select we1_A2 <= 
		we1_a_gen 			when pregen,
		we1_a_gen 			when mul2,
		we1_out_un 			when pregen_unpack,
		we1_out_un 			when mul5,
		we_out_read 		when pregen_read,
		we_out_read 		when mul8,
		'0' 				when others;

	with state select we2_A2 <=
		we2_a_gen 			when pregen,
		we2_a_gen 			when mul2,
		'0' 				when others;

	addr1_A2 <= addr1_a_gen when (state = pregen) else
				addr1_A2_matrix when (state = mul2 and (j = 0)) else
				addr1_a_gen when (state = mul2) else
				addr1_A2_matrix when (state = mul1) else
				addr1_out_un when (state = pregen_unpack) else
				addr1_A2_matrix when (state = mul5 and (j = 0)) else
				addr1_out_un when (state = mul5) else
				addr1_A2_matrix when (state = mul4) else
				addr_out_read when (state = pregen_read) else
				addr1_A2_matrix when (state = mul8 and (j = 0)) else
				addr_out_read when (state = mul8) else
				addr1_A2_matrix when (state = mul7) else
				(others => '0');

	with state select addr2_A2 <=
		addr2_a_gen 		when pregen,
		addr2_a_gen 		when mul2,
		addr2_A2_matrix 	when mul1,
		b"0000000000" 		when others;

	with state select din1_A2 <=
		din1_a_gen 			when pregen,
		din1_a_gen 			when mul2,
		din1_out_un 		when pregen_unpack,
		din1_out_un 		when mul5,
		din_out_read 		when pregen_read,
		din_out_read 		when mul8,
		x"0000" 			when others;

	with state select din2_A2 <=
		din2_a_gen 			when pregen,
		din2_a_gen 			when mul2,
		x"0000" 			when others;

	addr_pk <= std_logic_vector(to_unsigned(to_integer(unsigned(addr1_pk_un)) + 16, 14));   -- addr1_pk_un + 8;
	dout1_pk_un <= dout_pk;

	a <= unsigned(dout1_A1) when (state = mul1 and j = 0) else
		 unsigned(dout1_A2) when state = mul1 else 
		 unsigned(dout1_A2) when (state = mul2 and j = 0) else 
		 unsigned(dout1_A1) when state = mul2 else
		 unsigned(dout1_A1) when state = mul3 else
		 unsigned(dout1_A1) when (state = mul4 and j = 0) else
		 unsigned(dout1_A2) when state = mul4 else
		 unsigned(dout1_A2) when (state = mul5 and j = 0) else
		 unsigned(dout1_A1) when state = mul5 else
		 unsigned(dout1_A1) when state = mul6 else
		 unsigned(dout1_A1) when (state = mul7 and j = 0) else
		 unsigned(dout1_A2) when state = mul7 else
		 unsigned(dout1_A2) when (state = mul8 and j = 0) else
		 unsigned(dout1_A1) when state = mul8 else
		 unsigned(dout1_A1) when state = mul9;
	e <= x"0000" when (state = mul3 or state = mul6 or state = mul7 or state = mul8 or state = mul9) else
		 unsigned(dout_e) when (i = 0 or (i = 1 and j <= 1)) else 
		 x"0000";
	s <= unsigned(dout_s);
	b <= unsigned(dout1_b) when (state = mul3 or state = mul6 or state = mul9) else
	 	 x"0000" when (i = 0 or (i = 1 and j <= 2)) else 
	 	 unsigned(dout1_b);

	process (clk) is
	begin
		if (rising_edge(clk)) then
			done <= '0';
			if (reset = '1') then
				state <= s_reset;
				pregen_done <= '0';
				reset_gen <= '1';
				reset_un <= '1';
				reset_read <= '1';
				i <= 0;
				k <= 0;

			elsif (enable = '1') then
				if (state = s_reset) then
					if (use_A = '1') then
						reset_gen <= '0';
						if (pregen_done = '1') then
							state <= mul1;
							enable_gen <= '1';
							seed_A_separated <= std_logic_vector(to_unsigned(1, 16)) & seedA(127 downto 0);
						else
							state <= pregen;
							enable_gen <= '1';
							seed_A_separated <= std_logic_vector(to_unsigned(0, 16)) & seedA(127 downto 0);
						end if;

					elsif (use_A = '0' and use_S = '1') then
						state <= pregen_read;
						enable_read <= '1';
						reset_read <= '0';

					else
						state <= pregen_unpack;
						enable_un <= '1';
						reset_un <= '0';
						outlen_un <= 4800;
					end if;	

				--Generate the first row of A
				elsif (state = pregen) then
					if (done_gen = '1') then
						state <= mul1;
						seed_A_separated <= std_logic_vector(to_unsigned(1, 16)) & seedA(127 downto 0);
						pregen_done <= '1';
					end if;

				--Parallel multiplication and generation of A
				elsif (state = mul1) then
					if (done_gen = '1') then
						enable_gen <= '0';
						if (i = 638) then
							seed_A_separated <= x"0000" & seedA(127 downto 0);
						else
							seed_A_separated <= std_logic_vector(to_unsigned(i+2, 16)) & seedA(127 downto 0);
						end if;
					end if;
					if (j = 639) then
						enable_gen <= '1';
						state <= mul2;
						i <= i + 1;
					end if;

				elsif (state = mul2) then
					if (done_gen = '1') then
						enable_gen <= '0';
						seed_A_separated <= std_logic_vector(to_unsigned(i+2, 16)) & seedA(127 downto 0);
					end if;
					if (j = 639) then
						enable_gen <= '1';
						state <= mul1;
						i <= i + 1;
						if (i = 639) then
							state <= mul3;
							enable_gen <= '0';
							i <= 0;
						end if; 
					end if;

				--Finish the last 3 multiplications
				elsif (state = mul3) then
					if (j = 3) then
						state <= s_done;
					end if;

				--Generate the first row of B and then start multiplications
				elsif (state = pregen_unpack) then
					state <= pregen_unpack;
					if (j = 12) then
						state <= mul4;
					end if;

				elsif (state = mul4) then
					if (j = 7) then
						i <= i + 1;
						state <= mul5;
						if (i = 639) then
							state <= mul6;
							enable_un <= '0';
							reset_un <= '1';
							i <= 0;
						end if;
					end if;

				elsif (state = mul5) then
					if (j = 7) then
						i <= i + 1;
						state <= mul4;
						if (i = 639) then
							state <= mul6;
							enable_un <= '0';
							reset_un <= '1';
							i <= 0;
						end if;
					end if;

				elsif (state = mul6) then
					if (j = 3) then
						state <= s_done;
					end if;

				--Generate the first row of S and then start multiplications
				elsif (state = pregen_read) then
					if (j = 11) then
						state <= mul7;
					end if;

				elsif (state = mul7) then
					if (j = 7) then
						i <= i + 1;
						state <= mul8;
						if (i = 639) then
							state <= mul9;
							enable_read <= '0';
							reset_read <= '1';
							i <= 0;
						end if;
					end if;

				elsif (state = mul8) then
					if (j = 7) then
						i <= i + 1;
						state <= mul7;
						if (i = 639) then
							state <= mul9;
							enable_read <= '0';
							reset_read <= '1';
							i <= 0;
						end if;
					end if;

				elsif (state = mul9) then
					if (j = 3) then
						state <= s_done;
						reset_read <= '1';
					end if;

				elsif (state = s_done) then
					state <= s_reset;
					done <= '1';
				end if;
			end if;
		end if;
	end process;


	addr1_A1_matrix <= std_logic_vector(to_unsigned(j, 10));
	addr1_A2_matrix <= std_logic_vector(to_unsigned(j, 10));
	addr_s <= std_logic_vector(to_unsigned(i, 10)) when (state = mul1 or state = mul2 or state = mul4 or state = mul5 or state = mul7 or state = mul8) else
			  std_logic_vector(to_unsigned(639, 10)) when (state = mul3 or state = mul6 or state = mul9);
	addr_e <= std_logic_vector(to_unsigned(j-1+offset_e, 10)) when (j > 0) else
			  std_logic_vector(to_unsigned(j+n-1+offset_e, 10));
	addr1_b <= std_logic_vector(to_unsigned(j-2+offset_b, 10)) when (j > 1) else
			   std_logic_vector(to_unsigned(j+n-2+offset_b, 10));
	addr2_b <= std_logic_vector(to_unsigned(j-4+offset_b, 10)) when (j > 3) else
			   std_logic_vector(to_unsigned(j+n-4+offset_b, 10));
	din2_b <= std_logic_vector(aseb(15 downto 0));
	we2_b <= '0' when (state = pregen_unpack or state = pregen_read) else
			 '1' when (state = mul3 or state = mul6 or state = mul9) else
			 '1' when ((i = 0 and j >= 4)) else
			 '1' when (i > 0) else
			 '0';

	--Multiplication. Performs a*s+e+b in a pipelined manner
	mult : process (clk) is
	begin
		if (rising_edge(clk)) then
			if (enable = '1') then
				as <= a*s;
				ase <= as+e;
				aseb <= ase+b;
				if (state = mul1 or state = mul2) then
					j <= j + 1;
					if (j = n-1) then
						j <= 0;
					end if;
				elsif (state = mul3 or state = mul6 or state = mul9) then
					j <= j + 1;
					if (j = 3) then
						j <= 0;
					end if;
				elsif (state = pregen_unpack) then
					j <= j + 1;
					if (j = 12) then
						j <= 0;
					end if;
				elsif (state = mul4 or state = mul5) then
					j <= j + 1;
					if (j = 7) then
						j <= 0;
					end if;
				elsif (state = pregen_read) then
					j <= j + 1;
					if (j = 11) then
						j <= 0;
					end if;
				elsif (state = mul7 or state = mul8) then
					j <= j + 1;
					if (j = 7) then
						j <= 0;
					end if;
				end if;
			end if;
		end if;
	end process;

end behave;