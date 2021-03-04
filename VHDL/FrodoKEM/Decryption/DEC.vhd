library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frodo_dec is
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
end entity frodo_dec;

architecture behave of frodo_dec is

	component single_port_distributed_ram is
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
	end component single_port_distributed_ram;

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

	component unpack is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			outlen : in integer;
			offset : in integer;

			addr1_in : out std_logic_vector(13 downto 0);
			dout1_in : in std_logic_vector(15 downto 0);

			we1_out : out std_logic;
			addr1_out : out std_logic_vector(9 downto 0);
			din1_out : out std_logic_vector(15 downto 0)
		);
	end component unpack;

	component matrix_mul is
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
	end component matrix_mul;

	component matrix_sub is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			addr_B : out std_logic_vector(9 downto 0);
			dout_B : in std_logic_vector(15 downto 0);

			addr_C : out std_logic_vector(5 downto 0);
			dout_C : in std_logic_vector(15 downto 0);

			we_M : out std_logic;
			addr_M : out std_logic_vector(5 downto 0);
			din_M : out std_logic_vector(15 downto 0)
		);
	end component matrix_sub;

	component decode is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			addr_M : out std_logic_vector(5 downto 0);
			dout_M : in std_logic_vector(15 downto 0);

			we_mu : out std_logic;
			addr_mu : out std_logic_vector(2 downto 0);
			din_mu : out std_logic_vector(15 downto 0)
		);
	end component decode;


	component absorb_block is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			inlen : in integer;
			outlen : in integer;
			offset : in integer;

			addr1_in : out std_logic_vector(12 downto 0);
			dout1_in : in std_logic_vector(15 downto 0);
			addr2_in : out std_logic_vector(12 downto 0);
			dout2_in : in std_logic_vector(15 downto 0);

			we_out : out std_logic;
			addr_out : out std_logic_vector(3 downto 0);
			din_out : out std_logic_vector(15 downto 0)
		);
	end component absorb_block;

	component shake_gen_SE is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			low1 : in integer;
			high1 : in integer;
			low2 : in integer;
			high2 : in integer;
			length1 : in integer;
			length2 : in integer;

			seed_SE : in std_logic_vector(191 downto 0);

			we1_s : out std_logic;
			addr1_s : out std_logic_vector(9 downto 0);
			din1_s : out std_logic_vector(15 downto 0);
			we2_s : out std_logic;
			addr2_s : out std_logic_vector(9 downto 0);
			din2_s : out std_logic_vector(15 downto 0);

			we1_e : out std_logic;
			addr1_e : out std_logic_vector(9 downto 0);
			din1_e : out std_logic_vector(15 downto 0);
			we2_e : out std_logic;
			addr2_e : out std_logic_vector(9 downto 0);
			din2_e : out std_logic_vector(15 downto 0)
		);
	end component shake_gen_SE;

	component compare is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			identical : out std_logic;
			n : in integer;

			addr_b : out std_logic_vector(9 downto 0);
			dout_b : in std_logic_vector(15 downto 0);

			addr_e : out std_logic_vector(9 downto 0);
			dout_e : in std_logic_vector(15 downto 0)
		);
	end component compare;

	component encode is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			addr_mu : out std_logic_vector(2 downto 0);
			dout_mu : in std_logic_vector(15 downto 0);

			we_V : out std_logic;
			addr_V : out std_logic_vector(5 downto 0);
			din_V : out std_logic_vector(15 downto 0)
		);
	end component encode;

	component matrix_add is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			addr_V : out std_logic_vector(5 downto 0);
			dout_V : in std_logic_vector(15 downto 0);

			addr_B : out std_logic_vector(9 downto 0);
			dout_B : in std_logic_vector(15 downto 0);

			we_C : out std_logic;
			addr_C : out std_logic_vector(5 downto 0);
			din_C : out std_logic_vector(15 downto 0)
		);
	end component matrix_add;

	type states is (s_reset, s_done, unpack_C, unpack_B, matmul1, matmul2, subtract, 
		decode_mu, prepare_hashpkh, hashpkh, write_seedSE, pregen_SE, mul1, mul2,
		unmul1, unmul2, add_mu, final_unpack, final_compare, write_input,
		final_hash);
	signal state : states := s_reset;

	signal dummy : std_logic := '0';
	signal i, j : integer := 0;
	signal seed_A : std_logic_vector(143 downto 0) := (others => '0');
	signal shake_seedSE : std_logic_vector(191 downto 0) := (others => '0');
	signal check1, check2 : std_logic := '0';

	------------Unpack signals------------
	signal reset_unpack, enable_unpack : std_logic := '0';
	signal done_unpack : std_logic;
	signal outlen_unpack, offset_unpack : integer := 0;
	signal addr1_in_unpack : std_logic_vector(13 downto 0);
	signal we1_out_unpack : std_logic;
	signal addr1_out_unpack : std_logic_vector(9 downto 0);
	signal dout1_in_unpack, din1_out_unpack : std_logic_vector(15 downto 0);

	------------Matrix signals------------
	signal reset_matrix, enable_matrix, use_A_matrix, use_S_matrix : std_logic := '0';
	signal done_matrix : std_logic;
	signal seedA_matrix : std_logic_vector(143 downto 0);
	signal n_matrix, offset_e_matrix, offset_b_matrix : integer := 0;
	signal addr_s_matrix, addr_e_matrix : std_logic_vector(9 downto 0);
	signal dout_s_matrix, dout_e_matrix : std_logic_vector(15 downto 0);
	signal addr_pk_matrix : std_logic_vector(13 downto 0);
	signal addr_sk_matrix : std_logic_vector(13 downto 0);
	signal dout_pk_matrix, dout_sk_matrix : std_logic_vector(15 downto 0);
	signal we1_b_matrix, we2_b_matrix : std_logic;
	signal addr1_b_matrix, addr2_b_matrix : std_logic_vector(9 downto 0);
	signal din1_b_matrix, din2_b_matrix, dout1_b_matrix, dout2_b_matrix : std_logic_vector(15 downto 0);

	------------Sub signals------------
	signal reset_sub, enable_sub : std_logic := '0';
	signal done_sub : std_logic;
	signal addr_B_sub : std_logic_vector(9 downto 0);
	signal addr_C_sub, addr_M_sub : std_logic_vector(5 downto 0);
	signal we_M_sub : std_logic;
	signal dout_B_sub, dout_C_sub, din_M_sub : std_logic_vector(15 downto 0);

	------------Decode signals------------
	signal reset_decode, enable_decode : std_logic := '0';
	signal done_decode : std_logic;
	signal addr_M_decode : std_logic_vector(5 downto 0);
	signal we_mu_decode : std_logic;
	signal addr_mu_decode : std_logic_vector(2 downto 0);
	signal dout_M_decode, din_mu_decode : std_logic_vector(15 downto 0);

	------------Absorb_block signals------------
	signal reset_hash, enable_hash : std_logic := '0';
	signal done_hash : std_logic;
	signal inlen_hash, outlen_hash, offset_hash : integer := 0;
	signal addr1_in_hash, addr2_in_hash : std_logic_vector(12 downto 0);
	signal we_out_hash : std_logic;
	signal addr_out_hash : std_logic_vector(3 downto 0);
	signal dout1_in_hash, dout2_in_hash, din_out_hash : std_logic_vector(15 downto 0);

	------------shake_gen_SE signals------------
	signal reset_gen, enable_gen : std_logic := '0';
	signal done_gen : std_logic;
	signal low1_gen, low2_gen, high1_gen, high2_gen, length1_gen, length2_gen : integer := 0;
	signal we1_s_gen, we2_s_gen, we1_e_gen, we2_e_gen : std_logic;
	signal addr1_s_gen, addr2_s_gen, addr1_e_gen, addr2_e_gen : std_logic_vector(9 downto 0);
	signal din1_s_gen, din2_s_gen, din1_e_gen, din2_e_gen : std_logic_vector(15 downto 0);

	------------Compare signals------------
	signal reset_compare, enable_compare : std_logic := '0';
	signal done_compare : std_logic;
	signal identical_compare : std_logic;
	signal n_compare : integer;
	signal addr_b_compare, addr_e_compare : std_logic_vector(9 downto 0);
	signal dout_b_compare, dout_e_compare : std_logic_vector(15 downto 0);

	------------Encode signals------------
	signal reset_encode, enable_encode : std_logic := '0';
	signal done_encode : std_logic;
	signal addr_mu_encode : std_logic_vector(2 downto 0);
	signal addr_V_encode : std_logic_vector(5 downto 0);
	signal we_V_encode : std_logic;
	signal dout_mu_encode, din_V_encode : std_logic_vector(15 downto 0);

	------------Add signals------------
	signal reset_add, enable_add : std_logic := '0';
	signal done_add : std_logic;
	signal addr_V_add, addr_C_add : std_logic_vector(5 downto 0);
	signal we_C_add : std_logic;
	signal addr_B_add : std_logic_vector(9 downto 0);
	signal dout_V_add, dout_B_add, din_C_add : std_logic_vector(15 downto 0);

	------------S_1 signals------------
	signal we1_S1, we2_S1 : std_logic;
	signal addr1_S1, addr2_S1 : std_logic_vector(9 downto 0);
	signal din1_S1, din2_S1, dout1_S1, dout2_S1 : std_logic_vector(15 downto 0);

	------------S_2 signals------------
	signal we1_S2, we2_S2 : std_logic;
	signal addr1_S2, addr2_S2 : std_logic_vector(9 downto 0);
	signal din1_S2, din2_S2, dout1_S2, dout2_S2 : std_logic_vector(15 downto 0);

	------------B_1 signals------------
	signal we1_B1, we2_B1 : std_logic;
	signal addr1_B1, addr2_B1 : std_logic_vector(9 downto 0);
	signal din1_B1, din2_B1, dout1_B1, dout2_B1 : std_logic_vector(15 downto 0);

	------------B_2 signals------------
	signal we1_B2, we2_B2 : std_logic;
	signal addr1_B2, addr2_B2 : std_logic_vector(9 downto 0);
	signal din1_B2, din2_B2, dout1_B2, dout2_B2 : std_logic_vector(15 downto 0);
	------Inside Dec------
	signal we1_B2_dec, we2_B2_dec : std_logic;
	signal addr1_B2_dec, addr2_B2_dec : std_logic_vector(9 downto 0);
	signal din1_B2_dec, din2_B2_dec, dout1_B2_dec, dout2_B2_dec : std_logic_vector(15 downto 0);

	------------E_1 signals------------
	signal we1_E1, we2_E1 : std_logic;
	signal addr1_E1, addr2_E1 : std_logic_vector(9 downto 0);
	signal din1_E1, din2_E1, dout1_E1, dout2_E1 : std_logic_vector(15 downto 0);

	------------E_2 signals------------
	signal we1_E2, we2_E2 : std_logic;
	signal addr1_E2, addr2_E2 : std_logic_vector(9 downto 0);
	signal din1_E2, din2_E2, dout1_E2, dout2_E2 : std_logic_vector(15 downto 0);

	------------X_1 signals------------
	signal we1_X1, we2_X1 : std_logic;
	signal addr1_X1, addr2_X1 : std_logic_vector(9 downto 0);
	signal din1_X1, din2_X1, dout1_X1, dout2_X1 : std_logic_vector(15 downto 0);

	------------X_2 signals------------
	signal we1_X2, we2_X2 : std_logic;
	signal addr1_X2, addr2_X2 : std_logic_vector(9 downto 0);
	signal din1_X2, din2_X2, dout1_X2, dout2_X2 : std_logic_vector(15 downto 0);

	------------C signals------------
	signal we_C : std_logic;
	signal addr_C : std_logic_vector(5 downto 0);
	signal din_C, dout_C : std_logic_vector(15 downto 0);

	------------M signals------------
	signal we_M : std_logic;
	signal addr_M : std_logic_vector(5 downto 0);
	signal din_M, dout_M : std_logic_vector(15 downto 0);

	------------mu signals------------
	signal we_mu : std_logic;
	signal addr_mu : std_logic_vector(2 downto 0);
	signal din_mu, dout_mu : std_logic_vector(15 downto 0);
	------Inside dec------
	signal we_mu_dec : std_logic;
	signal addr_mu_dec : std_logic_vector(2 downto 0);
	signal din_mu_dec, dout_mu_dec : std_logic_vector(15 downto 0);

	------------seedSE signals------------
	signal we_seedSE : std_logic;
	signal addr_seedSE : std_logic_vector(3 downto 0);
	signal din_seedSE, dout_seedSE : std_logic_vector(15 downto 0);
	------Inside dec------
	signal we_seedSE_dec : std_logic;
	signal addr_seedSE_dec : std_logic_vector(3 downto 0);
	signal din_seedSE_dec, dout_seedSE_dec : std_logic_vector(15 downto 0);

	-----sk inside dec------
	signal addr1_sk_dec, addr2_sk_dec : std_logic_vector(13 downto 0);
	signal dout1_sk_dec, dout2_sk_dec : std_logic_vector(15 downto 0);


begin

	S_1 : true_dual_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we1 => we1_S1,
		addr1 => addr1_S1,
		din1 => din1_S1,
		dout1 => dout1_S1,
		we2 => we2_S1,
		addr2 => addr2_S1,
		din2 => din2_S1,
		dout2 => dout2_S1
	);

	S_2 : true_dual_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we1 => we1_S2,
		addr1 => addr1_S2,
		din1 => din1_S2,
		dout1 => dout1_S2,
		we2 => we2_S2,
		addr2 => addr2_S2,
		din2 => din2_S2,
		dout2 => dout2_S2
	);

	B_1 : true_dual_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we1 => we1_B1,
		addr1 => addr1_B1,
		din1 => din1_B1,
		dout1 => dout1_B1,
		we2 => we2_B1,
		addr2 => addr2_B1,
		din2 => din2_B1,
		dout2 => dout2_B1
	);

	B_2 : true_dual_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we1 => we1_B2,
		addr1 => addr1_B2,
		din1 => din1_B2,
		dout1 => dout1_B2,
		we2 => we2_B2,
		addr2 => addr2_B2,
		din2 => din2_B2,
		dout2 => dout2_B2
	);

	E_1 : true_dual_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we1 => we1_E1,
		addr1 => addr1_E1,
		din1 => din1_E1,
		dout1 => dout1_E1,
		we2 => we2_E1,
		addr2 => addr2_E1,
		din2 => din2_E1,
		dout2 => dout2_E1
	);

	E_2 : true_dual_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we1 => we1_E2,
		addr1 => addr1_E2,
		din1 => din1_E2,
		dout1 => dout1_E2,
		we2 => we2_E2,
		addr2 => addr2_E2,
		din2 => din2_E2,
		dout2 => dout2_E2
	);

	X_1 : true_dual_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we1 => we1_X1,
		addr1 => addr1_X1,
		din1 => din1_X1,
		dout1 => dout1_X1,
		we2 => we2_X1,
		addr2 => addr2_X1,
		din2 => din2_X1,
		dout2 => dout2_X1
	);

	X_2 : true_dual_port_bram
	generic map(
		awidth => 10,
		dwidth => 16
	)
	port map(
		clk => clk,
		we1 => we1_X2,
		addr1 => addr1_X2,
		din1 => din1_X2,
		dout1 => dout1_X2,
		we2 => we2_X2,
		addr2 => addr2_X2,
		din2 => din2_X2,
		dout2 => dout2_X2
	);

	C : single_port_distributed_ram
	generic map(
		awidth => 6,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_C,
		addr => addr_C,
		din => din_C,
		dout => dout_C
	);

	M : single_port_distributed_ram
	generic map(
		awidth => 6,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_M,
		addr => addr_M,
		din => din_M,
		dout => dout_M
	);

	mu : single_port_distributed_ram
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

	seedSE : single_port_distributed_ram
	generic map(
		awidth => 4,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_seedSE,
		addr => addr_seedSE,
		din => din_seedSE,
		dout => dout_seedSE
	);

	unpacking : unpack
	port map(
		clk => clk,
		reset => reset_unpack,
		enable => enable_unpack,
		done => done_unpack,

		outlen => outlen_unpack,
		offset => offset_unpack,

		addr1_in => addr1_in_unpack,
		dout1_in => dout1_in_unpack,

		we1_out => we1_out_unpack,
		addr1_out => addr1_out_unpack,
		din1_out => din1_out_unpack
	);

	matrix : matrix_mul
	port map(
		clk => clk,
		reset => reset_matrix,
		enable => enable_matrix,
		done => done_matrix,

		seedA => seed_A,

		n => n_matrix,

		use_A => use_A_matrix,
		use_S => use_S_matrix,
		offset_e => offset_e_matrix,
		offset_b => offset_b_matrix,

		addr_s => addr_s_matrix,
		dout_s => dout_s_matrix,

		addr_e => addr_e_matrix,
		dout_e => dout_e_matrix,

		addr_pk => addr_pk_matrix,
		dout_pk => dout_pk_matrix,

		addr_sk => addr_sk_matrix,
		dout_sk => dout_sk_matrix,

		we1_b => we1_b_matrix,
		addr1_b => addr1_b_matrix,
		din1_b => din1_b_matrix,
		dout1_b => dout1_b_matrix,
		we2_b => we2_b_matrix,
		addr2_b => addr2_b_matrix,
		din2_b => din2_b_matrix,
		dout2_b => dout2_b_matrix
	);

	subber : matrix_sub
	port map(
		clk => clk,
		reset => reset_sub,
		enable => enable_sub,
		done => done_sub,

		addr_B => addr_B_sub,
		dout_B => dout_B_sub,

		addr_C => addr_C_sub,
		dout_C => dout_C_sub,

		we_M => we_M_sub,
		addr_M => addr_M_sub,
		din_M => din_M_sub
	);

	decoder : decode
	port map(
		clk => clk,
		reset => reset_decode,
		enable => enable_decode,
		done => done_decode,

		addr_M => addr_M_decode,
		dout_M => dout_M_decode,

		we_mu => we_mu_decode,
		addr_mu => addr_mu_decode,
		din_mu => din_mu_decode
	);

	hashing : absorb_block
	port map(
		clk => clk,
		reset => reset_hash,
		enable => enable_hash,
		done => done_hash,

		inlen => inlen_hash,
		outlen => outlen_hash,
		offset => offset_hash,

		addr1_in => addr1_in_hash,
		dout1_in => dout1_in_hash,
		addr2_in => addr2_in_hash,
		dout2_in => dout2_in_hash,

		we_out => we_out_hash,
		addr_out => addr_out_hash,
		din_out => din_out_hash
	);

	shake_gen : shake_gen_SE
	port map(
		clk => clk,
		reset => reset_gen,
		enable => enable_gen,
		done => done_gen,

		low1 => low1_gen,
		high1 => high1_gen,
		low2 => low2_gen,
		high2 => high2_gen,
		length1 => length1_gen,
		length2 => length2_gen,

		seed_SE => shake_seedSE,

		we1_s => we1_s_gen,
		addr1_s => addr1_s_gen,
		din1_s => din1_s_gen,
		we2_s => we2_s_gen,
		addr2_s => addr2_s_gen,
		din2_s => din2_s_gen,

		we1_e => we1_e_gen,
		addr1_e => addr1_e_gen,
		din1_e => din1_e_gen,
		we2_e => we2_e_gen,
		addr2_e => addr2_e_gen,
		din2_e => din2_e_gen
	);

	comparator : compare
	port map(
		clk => clk,
		reset => reset_compare,
		enable => enable_compare,
		done => done_compare,

		identical => identical_compare,
		n => n_compare,

		addr_b => addr_b_compare,
		dout_b => dout_b_compare,

		addr_e => addr_e_compare,
		dout_e => dout_e_compare
	);

	encoder : encode
	port map(
		clk => clk,
		reset => reset_encode,
		enable => enable_encode,
		done => done_encode,

		addr_mu => addr_mu_encode,
		dout_mu => dout_mu_encode,

		we_V => we_V_encode,
		addr_V => addr_V_encode,
		din_V => din_V_encode
	);

	adder : matrix_add
	port map(
		clk => clk,
		reset => reset_add,
		enable => enable_add,
		done => done_add,

		addr_V => addr_V_add,
		dout_V => dout_V_add,

		addr_B => addr_B_add,
		dout_B => dout_B_add,

		we_C => we_C_add,
		addr_C => addr_C_add,
		din_C => din_C_add
	);


	------------Selecting for S_1------------
	with state select we1_S1 <=
		we1_out_unpack 		when unpack_B,
		we1_out_unpack 		when matmul2,
		we1_s_gen 			when mul1,
		we1_s_gen 			when unmul1,
		'0'					when others;

	with state select we2_S1 <=
		we2_s_gen 			when mul1,
		we2_s_gen 			when unmul1,
		'0'					when others;

	with state select addr1_S1 <=
		addr1_out_unpack 	when unpack_B,
		addr_s_matrix 		when matmul1,
		addr1_out_unpack 	when matmul2,
		addr1_s_gen 		when mul1,
		addr_s_matrix 		when mul2,
		addr1_s_gen 		when unmul1,
		addr_s_matrix 		when unmul2,
		(others => '0')		when others;

	with state select addr2_S1 <=
		addr2_s_gen 		when mul1,
		addr2_s_gen 		when unmul1,
		(others => '0') 	when others;

	with state select din1_S1 <=
		din1_out_unpack 	when unpack_B,
		din1_out_unpack 	when matmul2,
		din1_s_gen 			when mul1,
		din1_s_gen 			when unmul1,
		x"0000"	 			when others;

	with state select din2_S1 <=
		din2_s_gen 			when mul1,
		din2_s_gen 			when unmul1,
		x"0000"				when others;

	------------Selecting for S_2------------
	with state select we1_S2 <=
		we1_out_unpack 		when matmul1,
		we1_s_gen 			when pregen_SE,
		we1_s_gen			when mul2,
		we1_s_gen 			when unmul2,
		'0'					when others;

	with state select we2_S2 <= 
		we2_s_gen 			when pregen_SE,
		we2_s_gen 			when mul2,
		we2_s_gen 			when unmul2,
		'0' 				when others;

	with state select addr1_S2 <=
		addr1_out_unpack 	when matmul1,
		addr_s_matrix 		when matmul2,
		addr1_s_gen 		when pregen_SE,
		addr_s_matrix 		when mul1,
		addr1_s_gen 		when mul2,
		addr_s_matrix 		when unmul1,
		addr1_s_gen			when unmul2,
		(others => '0') 	when others;

	with state select addr2_S2 <=
		addr2_s_gen 		when pregen_SE,
		addr2_s_gen			when mul2,
		addr2_s_gen 		when unmul2,
		(others => '0')		when others;

	with state select din1_S2 <=
		din1_out_unpack 	when matmul1,
		din1_s_gen 			when pregen_SE,
		din1_s_gen 			when mul2,
		din1_s_gen 			when unmul2,
		x"0000"				when others;

	with state select din2_S2 <=
		din2_s_gen 			when pregen_SE,
		din2_s_gen			when mul2,
		din2_s_gen 			when unmul2,
		x"0000"				when others;

	------------Selecting for B_1------------
	with state select we1_B1 <=
		we1_b_matrix 		when mul2,
		'0'					when others;

	with state select we2_B1 <=
		we2_b_matrix 		when mul2,
		'0'					when others;

	with state select addr1_B1 <=
		addr1_b_matrix 		when mul2,
		addr_b_compare 		when mul1,
		(others => '0')		when others;

	with state select addr2_B1 <=
		addr2_b_matrix 		when mul2,
		(others => '0')		when others;

	with state select din1_B1 <=
		din1_b_matrix 		when mul2,
		x"0000" 			when others;

	with state select din2_B1 <=
		din2_b_matrix 		when mul2,
		x"0000"				when others;

	------------Selecting for B_2------------
	with state select we1_B2 <=
		we1_b_matrix 		when matmul1,
		we1_b_matrix 		when matmul2,
		we1_B2_dec			when prepare_hashpkh,
		we1_b_matrix 		when mul1,
		we1_b_matrix 		when unmul1,
		we1_b_matrix 		when unmul2,
		we1_B2_dec 			when write_input,
		'0'					when others;

	with state select we2_B2 <=
		we2_b_matrix 		when matmul1,
		we2_b_matrix		when matmul2,
		we2_B2_dec 			when prepare_hashpkh,
		we2_b_matrix 		when mul1,
		we2_b_matrix 		when unmul1,
		we2_b_matrix 		when unmul2,
		'0'					when others;

	with state select addr1_B2 <=
		addr1_b_matrix 		when matmul1,
		addr1_b_matrix 		when matmul2,
		addr_B_sub 			when subtract,
		addr1_B2_dec 		when prepare_hashpkh,
		addr1_in_hash(9 downto 0) 	when hashpkh,
		addr1_b_matrix 		when mul1,
		addr_b_compare 		when mul2,
		addr1_b_matrix 		when unmul1,
		addr1_b_matrix 		when unmul2,
		addr_B_add 			when add_mu,
		addr1_B2_dec 		when write_input,
		addr1_in_hash(9 downto 0)	when final_hash,
		(others => '0') 	when others;

	with state select addr2_B2 <=
		addr2_b_matrix 		when matmul1,
		addr2_b_matrix 		when matmul2,
		addr2_B2_dec 		when prepare_hashpkh,
		addr2_in_hash(9 downto 0)	when hashpkh,
		addr2_b_matrix		when mul1,
		addr2_b_matrix 		when unmul1,
		addr2_b_matrix 		when unmul2,
		addr2_in_hash(9 downto 0)	when final_hash,
		(others => '0') 	when others;

	with state select din1_B2 <=
		din1_b_matrix 		when matmul1,
		din1_b_matrix		when matmul2,
		din1_B2_dec 		when prepare_hashpkh,
		din1_b_matrix 		when mul1,
		din1_b_matrix 		when unmul1,
		din1_b_matrix 		when unmul2,
		din1_B2_dec 		when write_input,
		x"0000" 			when others;

	with state select din2_B2 <=
		din2_b_matrix 		when matmul1,
		din2_b_matrix		when matmul2,
		din2_B2_dec 		when prepare_hashpkh,
		din2_b_matrix		when mul1,
		din2_b_matrix 		when unmul1,
		din2_b_matrix 		when unmul2,
		x"0000" 			when others;

	------------Selecting for E_1------------
	with state select we1_E1 <=
		we1_e_gen 			when mul1,
		'0'					when others;

	with state select we2_E1 <=
		we2_e_gen 			when mul1,
		'0'					when others;

	with state select addr1_E1 <=
		addr1_e_gen 		when mul1,
		addr_e_matrix 		when mul2,
		(others => '0')		when others;

	with state select addr2_E1 <=
		addr2_e_gen 		when mul1,
		(others => '0')		when others;

	with state select din1_E1 <=
		din1_e_gen			when mul1,
		x"0000"				when others;

	with state select din2_E1 <=
		din2_e_gen			when mul1,
		x"0000"				when others;

	------------Selecting for E_2------------
	with state select we1_E2 <=
		we1_e_gen 			when pregen_SE,
		we1_e_gen 			when mul2,
		'0'					when others;

	with state select we2_E2 <=
		we2_e_gen 			when pregen_SE,
		we2_e_gen 			when mul2,
		'0'					when others;

	with state select addr1_E2 <=
		addr1_e_gen 		when pregen_SE,
		addr_e_matrix 		when mul1,
		addr1_e_gen 		when mul2,
		addr_e_matrix 		when unmul1,
		addr_e_matrix 		when unmul2,
		(others => '0') 	when others;

	with state select addr2_E2 <=
		addr2_e_gen 		when pregen_SE,
		addr2_e_gen 		when mul2,
		(others => '0')		when others;

	with state select din1_E2 <=
		din1_e_gen 			when pregen_SE,
		din1_e_gen			when mul2,
		x"0000" 			when others;

	with state select din2_E2 <=
		din2_e_gen 			when pregen_SE,
		din2_e_gen 			when mul2,
		x"0000"				when others;

	------------Selecting for X_1------------
	with state select we1_X1 <=
		we1_out_unpack 		when mul2,
		'0'					when others;

	with state select addr1_X1 <=
		addr1_out_unpack 	when mul2,
		addr_e_compare 		when mul1,
		(others => '0') 	when others;

	with state select din1_X1 <=
		din1_out_unpack 	when mul2,
		x"0000"				when others;

	------------Selecting for X_2------------
	with state select we1_X2 <=
		we1_out_unpack 		when mul1,
		we1_out_unpack 		when final_unpack,
		'0'					when others;

	with state select addr1_X2 <=
		addr1_out_unpack 	when mul1,
		addr_e_compare 		when mul2,
		addr1_out_unpack 	when final_unpack,
		addr_e_compare 		when final_compare,
		(others => '0')		when others;

	with state select din1_X2 <=
		din1_out_unpack 	when mul1,
		din1_out_unpack 	when final_unpack,
		x"0000"				when others;

	------------Selecting for C------------
	with state select we_C <=
		we1_out_unpack 		when unpack_C,
		we_C_add 			when add_mu,
		'0'					when others;

	with state select addr_C <=
		addr1_out_unpack(5 downto 0)	when unpack_C,
		addr_C_sub 			when subtract,
		addr_C_add 			when add_mu,
		addr_b_compare(5 downto 0)		when final_compare,
		(others => '0')		when others;

	with state select din_C <=
		din1_out_unpack 	when unpack_C,
		din_C_add 			when add_mu,
		x"0000" 			when others;

	------------Selecting for M------------
	with state select we_M <=
		we_M_sub 			when subtract,
		we_V_encode 		when unmul1,
		'0'					when others;

	with state select addr_M <=
		addr_M_sub 			when subtract,
		addr_M_decode		when decode_mu,
		addr_V_encode 		when unmul1,
		addr_V_add 			when add_mu,
		(others => '0') 	when others;

	with state select din_M <=
		din_M_sub 			when subtract,
		din_V_encode 		when unmul1,
		x"0000" 			when others;

	------------Selecting for mu------------
	with state select we_mu <=
		we_mu_decode 		when decode_mu,
		'0'					when others;

	with state select addr_mu <=
		addr_mu_decode 		when decode_mu,
		addr_mu_dec 		when prepare_hashpkh,
		addr_mu_encode 		when unmul1,
		(others => '0')		when others;

	with state select din_mu <=
		din_mu_decode 		when decode_mu,
		x"0000"				when others;

	------------Selecting for seedSE------------
	with state select we_seedSE <=
		we_out_hash 		when hashpkh,
		'0'					when others;

	with state select addr_seedSE <=
		addr_out_hash 		when hashpkh,
		addr_seedSE_dec		when write_seedSE,
		addr_seedSE_dec 	when write_input,
		(others => '0')		when others;

	with state select din_seedSE <=
		din_out_hash 		when hashpkh,
		x"0000" 			when others;

	------------Selecting for ct------------
	with state select addr1_ct <=
		addr1_in_unpack(12 downto 0)	when unpack_C,
		addr1_in_unpack(12 downto 0) 	when unpack_B,
		addr1_in_unpack(12 downto 0)	when matmul1,
		addr1_in_unpack(12 downto 0)	when matmul2,
		addr1_in_unpack(12 downto 0) 	when mul1,
		addr1_in_unpack(12 downto 0)	when mul2,
		addr1_in_unpack(12 downto 0) 	when final_unpack,
		addr1_in_hash 					when unmul1,
		addr1_in_hash 					when unmul2,
		(others => '0')					when others;

	with state select addr2_ct <=
		addr2_in_hash 		when unmul1,
		addr2_in_hash 		when unmul2,
		(others => '0')		when others;

	------------Selecting for sk------------
	with state select addr1_sk <=
		addr_sk_matrix 		when matmul1,
		addr_sk_matrix 		when matmul2,
		addr1_sk_dec 		when prepare_hashpkh,
		addr1_sk_dec 		when write_seedSE,
		addr_pk_matrix 		when unmul1,
		addr_pk_matrix 		when unmul2,
		addr1_sk_dec 		when write_input,
		--addr1_in_unpack		when mul1,
		(others => '0')		when others;

	------------Selecting for ss------------
	with state select we_ss <=
		we_out_hash 		when unmul1,
		we_out_hash 		when unmul2,
		we_out_hash 		when final_hash,
		'0'					when others;

	with state select addr_ss <=
		addr_out_hash(2 downto 0) 	when unmul1,
		addr_out_hash(2 downto 0) 	when unmul2,
		addr_out_hash(2 downto 0) 	when final_hash,
		(others => '0')		when others;

	with state select din_ss <=
		din_out_hash 		when unmul1,
		din_out_hash 		when unmul2,
		din_out_hash 		when final_hash,
		x"0000"				when others;

	------------Selecting outputs------------
	with state select dout1_in_unpack <=
		dout1_ct 			when unpack_C,
		dout1_ct 			when unpack_B,
		dout1_ct 			when matmul1,
		dout1_ct 			when matmul2,
		--dout1_sk 			when mul1,
		dout1_ct 			when mul1,
		dout1_ct 			when mul2,
		dout1_ct 			when final_unpack,
		x"0000" 			when others;

	with state select dout_sk_matrix <=
		dout1_sk 			when matmul1,
		dout1_sk 			when matmul2,
		x"0000"				when others;

	with state select dout1_b_matrix <=
		dout1_B2 			when matmul1,
		dout1_B2 			when matmul2,
		dout1_B2 			when mul1,
		dout1_B1 			when mul2,
		dout1_B2 			when unmul1,
		dout1_B2 			when unmul2,
		x"0000"				when others;

	with state select dout2_b_matrix <=
		dout2_B2 			when matmul1,
		dout2_B1 			when matmul2,
		dout2_B2 			when mul1,
		dout2_B1 			when mul2,
		dout2_B2 			when unmul1,
		dout2_B2 			when unmul2,
		x"0000"				when others;

	with state select dout_s_matrix <=
		dout1_S1 			when matmul1,
		dout1_S2 			when matmul2,
		dout1_S2			when mul1,
		dout1_S1 			when mul2,
		dout1_S2 			when unmul1,
		dout1_S1 			when unmul2,
		x"0000" 			when others;

	with state select dout_e_matrix	<=
		dout1_E2 			when mul1,
		dout1_E1 			when mul2,
		dout1_E2 			when unmul1,
		dout1_E2 			when unmul2,
		x"0000"				when others;

	with state select dout1_in_hash <=
		dout1_B2 			when hashpkh,
		dout1_ct 			when unmul1,
		dout1_ct 			when unmul2,
		dout1_B2 			when final_hash,
		x"0000" 			when others;

	with state select dout2_in_hash <=
		dout2_B2 			when hashpkh,
		dout2_ct			when unmul1,
		dout2_ct 			when unmul2,
		dout2_B2 			when final_hash,
		x"0000"				when others;

	with state select dout_b_compare <=
		dout1_B2 			when mul2,
		dout1_B1 			when mul1,
		dout_C 				when final_compare,
		x"0000"				when others;

	with state select dout_e_compare <=
		dout1_X2 			when mul2,
		dout1_X1 			when mul1,
		dout1_X2 			when final_compare,
		x"0000"				when others;

	dout_B_sub <= dout1_B2;
	dout_C_sub <= dout_C;

	dout_M_decode <= dout_M;

	dout1_sk_dec <= dout1_sk;
	dout_mu_dec <= dout_mu;

	dout_seedSE_dec <= dout_seedSE;

	dout_pk_matrix <= dout1_sk;

	dout_mu_encode <= dout_mu;

	dout_B_add <= dout1_B2;

	dout_V_add <= dout_M;


	process (clk) is
		variable temp_seedSE : std_logic_vector(7 downto 0) := x"96";
	begin
		if (rising_edge(clk)) then
			done <= '0';
			we1_B2_dec <= '0';
			we2_B2_dec <= '0';
			we_mu_dec <= '0';
			we_seedSE_dec <= '0';

			if (reset = '1') then
				state <= s_reset;
				dummy <= '1';

			elsif (enable = '1') then
				if (state = s_reset) then
					reset_unpack <= '1';
					outlen_unpack <= 0;
					offset_unpack <= 0;

					reset_matrix <= '1';
					n_matrix <= 0;
					use_A_matrix <= '0';
					use_S_matrix <= '0';
					offset_e_matrix <= 0;
					offset_b_matrix <= 0;

					reset_sub <= '1';

					reset_decode <= '1';

					reset_hash <= '1';
					inlen_hash <= 0;
					outlen_hash <= 0;
					offset_hash <= 0;

					reset_gen <= '1';
					low1_gen <= 0;
					low2_gen <= 0;
					high1_gen <= 0;
					high2_gen <= 0;
					length1_gen <= 0;
					length2_gen <= 0;
					temp_seedSE := x"96";

					reset_compare <= '1';
					n_compare <= 0;

					reset_encode <= '1';

					reset_add <= '1';

					i <= 0;
					j <= 0;
					seed_A <= (others => '0');
					shake_seedSE <= (others => '0');
					check1 <= '0';
					check2 <= '0';

					state <= unpack_C;

				--Unpack C from ct
				elsif (state = unpack_C) then
					reset_unpack <= '0';
					enable_unpack <= '1';
					outlen_unpack <= 64;
					offset_unpack <= 4800;
					if (done_unpack = '1') then
						state <= unpack_B;
						outlen_unpack <= 640;
						offset_unpack <= 0;
					end if;

				--Unpack the first row of B' from ct
				elsif (state = unpack_B) then
					outlen_unpack <= 640;
					reset_unpack <= '0';
					enable_unpack <= '1';
					if (done_unpack = '1') then
						state <= matmul1;
						offset_unpack <= offset_unpack + 600;
						
						n_matrix <= 8;
						use_A_matrix <= '0';
						use_S_matrix <= '1';
						offset_e_matrix <= 0;
						offset_b_matrix <= 0;
						reset_matrix <= '0';
						enable_matrix <= '1';
					end if;

				--Multiply one row of B' with S on the right, generate next row
				--in parallel
				elsif (state = matmul1) then
					if (done_unpack = '1') then
						enable_unpack <= '0';
						offset_unpack <= offset_unpack + 600;
						if (i = 6) then
							enable_unpack <= '0';
							reset_unpack <= '1';
							offset_unpack <= 0;
						end if;
					end if;

					if (done_matrix = '1') then
						i <= i + 1;
						state <= matmul2;
						offset_b_matrix <= offset_b_matrix + 8;
						enable_unpack <= '1';
						if (i >= 6) then
							enable_unpack <= '0';
						end if;
						if (i = 7) then
							enable_matrix <= '0';
							reset_matrix <= '1';
							offset_b_matrix <= 0;
							state <= subtract;
							enable_sub <= '1';
							reset_sub <= '0';
							i <= 0;
						end if;
					end if;

				--Multiply one row of B' with S on the right, generate next row
				--in parallel
				elsif (state = matmul2) then
					if (done_unpack = '1') then
						enable_unpack <= '0';
						offset_unpack <= offset_unpack + 600;
						if (i = 6) then
							enable_unpack <= '0';
							reset_unpack <= '1';
							offset_unpack <= 0;
						end if;
					end if;

					if (done_matrix = '1') then
						i <= i + 1;
						state <= matmul1;
						offset_b_matrix <= offset_b_matrix + 8;
						enable_unpack <= '1';
						if (i >= 6) then
							enable_unpack <= '0';
						end if;
						if (i = 7) then
							enable_matrix <= '0';
							reset_matrix <= '1';
							offset_b_matrix <= 0;
							state <= subtract;
							enable_sub <= '1';
							reset_sub <= '0';
							i <= 0;
						end if;
					end if;

				--M = C - B'*s
				elsif (state = subtract) then
					if (done_sub = '1') then
						enable_sub <= '0';
						state <= decode_mu;
						reset_decode <= '0';
						enable_decode <= '1';
					end if;

				--Decode M into mu
				elsif (state = decode_mu) then
					if (done_decode = '1') then
						enable_decode <= '0';
						state <= prepare_hashpkh;
					end if;

				elsif (state = prepare_hashpkh) then
					i <= i + 1;
					addr1_sk_dec <= std_logic_vector(to_unsigned(i+9936, 14));
					addr_mu_dec <= std_logic_vector(to_unsigned(i, 3));
					if (i >= 2) then
						j <= j + 1;
						we1_B2_dec <= '1';
						we2_B2_dec <= '1';
						addr1_B2_dec <= std_logic_vector(to_unsigned(j, 10));
						addr2_B2_dec <= std_logic_vector(to_unsigned(j+8, 10));
						din1_B2_dec <= dout1_sk_dec;
						din2_B2_dec <= dout_mu_dec(7 downto 0) & dout_mu_dec(15 downto 8);
						if (i = 10) then
							state <= hashpkh;
							reset_hash <= '0';
							enable_hash <= '1';
							inlen_hash <= 16;
							outlen_hash <= 16;
							offset_hash <= 0;
							i <= 0;
						end if;
					end if;

				--Hash pkh||mu'
				elsif (state = hashpkh) then
					if (done_hash = '1') then
						enable_hash <= '0';
						reset_hash <= '1';
						state <= write_seedSE;
					end if;

				elsif (state = write_seedSE) then
					i <= i + 1;
					if (i < 10) then
						addr_seedSE_dec <= std_logic_vector(to_unsigned(i, 4));
						addr1_sk_dec <= std_logic_vector(to_unsigned(i+8, 14));
						if (i >= 2) then
							shake_seedSE <= shake_seedSE(175 downto 64) & dout_seedSE_dec(15 downto 8) & temp_seedSE & x"0000000000000000";
							temp_seedSE := dout_seedSE_dec(7 downto 0);
							seed_A <= seed_A(127 downto 0) & dout1_sk_dec(7 downto 0) & dout1_sk_dec(15 downto 8);
						end if;
					elsif (i = 10) then
						shake_seedSE(63 downto 0) <= x"1F" & temp_seedSE & x"000000000000";
						i <= 0;
						state <= pregen_SE;
						reset_gen <= '0';
						enable_gen <= '1';
						low1_gen <= 0;
						high1_gen <= 320;
						low2_gen <= 2560;
						high2_gen <= 2880;
						length1_gen <= 640;
						length2_gen <= 640;
					end if;

				--Generate first row of S' and E'
				elsif (state = pregen_SE) then
					if (done_gen = '1') then
						low1_gen <= low1_gen + 320;
						low2_gen <= low2_gen + 320;
						high1_gen <= high1_gen + 320;
						high2_gen <= high2_gen + 320;
						state <= mul1;
						n_matrix <= 640;
						reset_matrix <= '0';
						enable_matrix <= '1';
						use_A_matrix <= '1';
						use_S_matrix <= '0';
						offset_e_matrix <= 0;
						offset_b_matrix <= 0;

						outlen_unpack <= 640;
						offset_unpack <= 0;
						reset_unpack <= '0';
						enable_unpack <= '1';
					end if;

				--Calculate B''=S'*A + E' row-wise, generate next rows of S' and E'
				--on the fly
				--Unpack B' again row-wise
				--Compare B'' and B'
				elsif (state = mul1) then
					if (done_gen = '1') then
						if (i < 6) then
							low1_gen <= low1_gen + 320;
							low2_gen <= low2_gen + 320;
							high1_gen <= high1_gen + 320;
							high2_gen <= high2_gen + 320;
						else
							low1_gen <= 0;
							low2_gen <= 5120;
							high1_gen <= 320;
							high2_gen <= 5152;
							length2_gen <= 64;
						end if;
						--state <= mul2;
						--i <= i + 1;
						enable_gen <= '0';
					end if;

					if (done_unpack = '1') then
						enable_unpack <= '0';
						offset_unpack <= offset_unpack + 600;
					end if;

					if (done_compare = '1') then
						enable_compare <= '0';
						check1 <= check1 or identical_compare;
						if (i = 8) then
							reset_compare <= '1';
							i <= 0;
							state <= unmul1;
							low1_gen <= low1_gen + 320;
							high1_gen <= high1_gen + 320;
							low2_gen <= 0;
							high2_gen <= 0;
							length2_gen <= 0;
							enable_gen <= '1';
							enable_matrix <= '1';
							reset_matrix <= '0';
							n_matrix <= 8;
							use_A_matrix <= '0';
							use_S_matrix <= '0';
							offset_e_matrix <= 0;
							offset_b_matrix <= 0;

							reset_encode <= '0';
							enable_encode <= '1';

							reset_hash <= '0';
							enable_hash <= '1';
							inlen_hash <= 4860;
							outlen_hash <= 0;
							offset_hash <= 0;
						end if;	
					end if;

					if (done_matrix = '1') then
						i <= i + 1;
						enable_gen <= '1';
						enable_unpack <= '1';
						state <= mul2;
						if (i >= 7) then
							enable_gen <= '0';
							enable_matrix <= '0';
							enable_unpack <= '0';
							reset_matrix <= '1';
						end if;
						if (i >= 0) then
							reset_compare <= '0';
							enable_compare <= '1';
							n_compare <= 640;
						end if;
					end if;

				elsif (state = mul2) then
					if (done_gen = '1') then
						if (i < 6) then
							low1_gen <= low1_gen + 320;
							low2_gen <= low2_gen + 320;
							high1_gen <= high1_gen + 320;
							high2_gen <= high2_gen + 320;
						else
							low1_gen <= 0;
							low2_gen <= 5120;
							high1_gen <= 320;
							high2_gen <= 5152;
							length2_gen <= 64;
						end if;
						--state <= mul1;
						--i <= i + 1;
						enable_gen <= '0';
					end if;

					if (done_unpack = '1') then
						enable_unpack <= '0';
						offset_unpack <= offset_unpack + 600;
					end if;

					if (done_compare = '1') then
						enable_compare <= '0';
						check1 <= check1 or identical_compare;
						if (i = 8) then
							reset_compare <= '1';
							i <= 0;
							state <= unmul1;
							low1_gen <= low1_gen + 320;
							high1_gen <= high1_gen + 320;
							low2_gen <= 0;
							high2_gen <= 0;
							length2_gen <= 0;
							enable_gen <= '1';
							enable_matrix <= '1';
							reset_matrix <= '0';
							n_matrix <= 8;
							use_A_matrix <= '0';
							use_S_matrix <= '0';
							offset_e_matrix <= 0;
							offset_b_matrix <= 0;

							reset_encode <= '0';
							enable_encode <= '1';

							reset_hash <= '0';
							enable_hash <= '1';
							inlen_hash <= 4860;
							outlen_hash <= 0;
							offset_hash <= 0;
						end if;		
					end if;

					if (done_matrix = '1') then
						i <= i + 1;
						enable_gen <= '1';
						enable_unpack <= '1';
						state <= mul1;
						if (i >= 7) then
							enable_gen <= '0';
							enable_matrix <= '0';
							enable_unpack <= '0';
							reset_matrix <= '1';
						end if;
						if (i >= 0) then
							reset_compare <= '0';
							enable_compare <= '1';
							n_compare <= 640;
						end if;
					end if;

				--Calculate V = S'*B + E'' row-wise
				--Hash ct at the same time
				--Encode mu once into M
				elsif (state = unmul1) then
					if (done_gen = '1') then
						enable_gen <= '0';
						low1_gen <= low1_gen + 320;
						high1_gen <= high1_gen + 320;
					end if; 

					if (done_encode = '1') then
						enable_encode <= '0';
					end if;

					if (done_hash = '1') then
						enable_hash <= '0';
						inlen_hash <= 8;
						outlen_hash <= 8;
					end if;

					if (done_matrix = '1') then
						state <= unmul2;
						enable_gen <= '1';
						offset_e_matrix <= offset_e_matrix + 8;
						offset_b_matrix <= offset_b_matrix + 8;
						i <= i + 1;
						if (i = 7) then
							enable_gen <= '0';
							enable_matrix <= '0';
							state <= add_mu;
							reset_add <= '0';
							enable_add <= '1';
						end if;
					end if;

				elsif (state = unmul2) then
					if (done_gen = '1') then
						enable_gen <= '0';
						low1_gen <= low1_gen + 320;
						high1_gen <= high1_gen + 320;
					end if;

					if (done_hash = '1') then
						enable_hash <= '0';
						inlen_hash <= 8;
						outlen_hash <= 8;
					end if;

					if (done_matrix = '1') then
						state <= unmul1;
						enable_gen <= '1';
						offset_e_matrix <= offset_e_matrix + 8;
						offset_b_matrix <= offset_b_matrix + 8;
						i <= i + 1;
						if (i = 7) then
							enable_gen <= '0';
							enable_matrix <= '0';
							state <= add_mu;
							reset_add <= '0';
							enable_add <= '1';
						end if;
					end if;

				--C = V + Encode(mu)
				elsif (state = add_mu) then
					if (done_add = '1') then
						enable_add <= '0';

						state <= final_unpack;
						reset_unpack <= '0';
						enable_unpack <= '1';
						outlen_unpack <= 64;
						offset_unpack <= 4800;
					end if;

				--Unpack C again
				elsif (state = final_unpack) then
					if (done_unpack = '1') then
						enable_unpack <= '0';
						state <= final_compare;
						reset_compare <= '0';
						enable_compare <= '1';
						n_compare <= 64;
					end if;

				--Compare C and C'
				elsif (state = final_compare) then
					if (done_compare = '1') then
						enable_compare <= '0';
						check2 <= identical_compare;
						state <= write_input;
						i <= 0;
					end if; 

				--Write either k' or s into the input for shake
				elsif (state = write_input) then
					i <= i + 1;
					addr_seedSE_dec <= std_logic_vector(to_unsigned(i+8, 4));
					addr1_sk_dec <= std_logic_vector(to_unsigned(i, 14));
					if (i >= 2) then
						we1_B2_dec <= '1';
						addr1_B2_dec <= std_logic_vector(to_unsigned(i-2, 10));
						if (check1 = '0' and check2 = '0') then
							din1_B2_dec <= dout_seedSE_dec;
						else
							din1_B2_dec <= dout1_sk_dec;
						end if;
						if (i = 10) then
							i <= 0;
							state <= final_hash;
							enable_hash <= '1';
						end if;
					end if;

				--Perform the final hash to calculate ss
				elsif (state = final_hash) then
					if (done_hash = '1') then
						enable_hash <= '0';
						state <= s_done;
					end if;

				elsif (state = s_done) then
					done <= '1';
					state <= s_reset;
				end if;
			end if;
		end if;
	end process;

end behave;