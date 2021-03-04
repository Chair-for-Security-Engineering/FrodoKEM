--Frodo Encapsulation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frodo_enc is
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
end entity frodo_enc;

architecture behave of frodo_enc is

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

	component matrix_mul is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			seedA : in std_logic_vector(143 downto 0);

			n : in integer := 640;

			use_A : in std_logic;
			offset_e : in integer;
			offset_b : in integer;

			addr_s : out std_logic_vector(9 downto 0);
			dout_s : in std_logic_vector(15 downto 0);

			addr_e : out std_logic_vector(9 downto 0);
			dout_e : in std_logic_vector(15 downto 0);

			addr_pk : out std_logic_vector(12 downto 0);
			dout_pk : in std_logic_vector(15 downto 0);

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

	component pack is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			inlen : in integer;
			offset : in integer;

			addr_a : out std_logic_vector(9 downto 0);
			dout_a : in std_logic_vector(15 downto 0);

			we1_ct : out std_logic;
			addr1_ct : out std_logic_vector(12 downto 0);
			din1_ct : out std_logic_vector(15 downto 0);
			we1_x : out std_logic;
			addr1_x : out std_logic_vector(9 downto 0);
			din1_x : out std_logic_vector(15 downto 0)
		);
	end component pack;

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

	type states is (s_reset, s_done, hash_pk, write_mu, hash_pkh, write_seedSE, pregen_SE, mul1, mul2, nexte, unmul1, unmul2, add_cv, pack_c, write_k, final_hash);
	signal state : states := s_reset;

	signal dummy : std_logic := '0';
	signal i : integer := 0;
	signal shake_seedSE : std_logic_vector(191 downto 0) := (others => '0');
	signal seed_A : std_logic_vector(143 downto 0) := (others => '0');

	------------Absorb_Block signals------------
	signal reset_hash, enable_hash : std_logic := '0';
	signal done_hash : std_logic;
	signal inlen_hash, outlen_hash, offset_hash : integer;
	signal addr1_in_hash, addr2_in_hash : std_logic_vector(12 downto 0);
	signal dout1_in_hash, dout2_in_hash, din_out_hash : std_logic_vector(15 downto 0);
	signal we_out_hash : std_logic;
	signal addr_out_hash : std_logic_vector(3 downto 0);

	------------shake_gen_SE signals------------
	signal reset_gen, enable_gen : std_logic := '0';
	signal done_gen : std_logic;
	signal low1_gen, low2_gen, high1_gen, high2_gen, length1_gen, length2_gen : integer := 0;
	signal we1_s_gen, we2_s_gen, we1_e_gen, we2_e_gen : std_logic;
	signal addr1_s_gen, addr2_s_gen, addr1_e_gen, addr2_e_gen : std_logic_vector(9 downto 0);
	signal din1_s_gen, din2_s_gen, din1_e_gen, din2_e_gen : std_logic_vector(15 downto 0);

	------------matrix signals------------
	signal reset_matrix, enable_matrix : std_logic := '0';
	signal done_matrix : std_logic;
	signal n_matrix : integer := 640;
	signal addr_s_matrix, addr_e_matrix, addr1_b_matrix, addr2_b_matrix : std_logic_vector(9 downto 0);
	signal dout_s_matrix, dout_e_matrix, din1_b_matrix, din2_b_matrix, dout1_b_matrix, dout2_b_matrix : std_logic_vector(15 downto 0);
	signal we1_b_matrix, we2_b_matrix : std_logic;
	signal use_A_matrix : std_logic := '1';
	signal addr_pk_matrix : std_logic_vector(12 downto 0);
	signal dout_pk_matrix : std_logic_vector(15 downto 0);
	signal offset_e_matrix, offset_b_matrix : integer := 0;

	------------Pack signals------------
	signal reset_pack, enable_pack : std_logic := '0';
	signal done_pack : std_logic;
	signal inlen_pack, offset_pack : integer := 0;
	signal addr_a_pack : std_logic_vector(9 downto 0);
	signal we1_ct_pack : std_logic;
	signal addr1_ct_pack : std_logic_vector(12 downto 0);
	signal dout_a_pack, din1_ct_pack : std_logic_vector(15 downto 0);
	signal we1_x_pack : std_logic;
	signal addr1_x_pack : std_logic_vector(9 downto 0);
	signal din1_x_pack : std_logic_vector(15 downto 0);

	------------Encode signals------------
	signal reset_encode, enable_encode : std_logic := '0';
	signal done_encode : std_logic;
	signal addr_mu_encode : std_logic_vector(2 downto 0);
	signal we_V_encode : std_logic;
	signal addr_V_encode : std_logic_vector(5 downto 0);
	signal dout_mu_encode, din_V_encode : std_logic_vector(15 downto 0);

	------------MatrixAdd signals------------
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
	------Inside Enc------
	signal we1_S2_enc, we2_S2_enc : std_logic;
	signal addr1_S2_enc, addr2_S2_enc : std_logic_vector(9 downto 0);
	signal din1_S2_enc, din2_S2_enc, dout1_S2_enc, dout2_S2_enc : std_logic_vector(15 downto 0);

	------------E_1 signals------------
	signal we1_E1, we2_E1 : std_logic;
	signal addr1_E1, addr2_E1 : std_logic_vector(9 downto 0);
	signal din1_E1, din2_E1, dout1_E1, dout2_E1 : std_logic_vector(15 downto 0);

	------------E_2 signals------------
	signal we1_E2, we2_E2 : std_logic;
	signal addr1_E2, addr2_E2 : std_logic_vector(9 downto 0);
	signal din1_E2, din2_E2, dout1_E2, dout2_E2 : std_logic_vector(15 downto 0);

	------------B_1 signals------------
	signal we1_B1, we2_B1 : std_logic;
	signal addr1_B1, addr2_B1 : std_logic_vector(9 downto 0);
	signal din1_B1, din2_B1, dout1_B1, dout2_B1 : std_logic_vector(15 downto 0);

	------------B_2 signals------------
	signal we1_B2, we2_B2 : std_logic;
	signal addr1_B2, addr2_B2 : std_logic_vector(9 downto 0);
	signal din1_B2, din2_B2, dout1_B2, dout2_B2 : std_logic_vector(15 downto 0);

	------------X_1 signals------------
	signal we1_X1, we2_X1 : std_logic;
	signal addr1_X1, addr2_X1 : std_logic_vector(9 downto 0);
	signal din1_X1, din2_X1, dout1_X1, dout2_X1 : std_logic_vector(15 downto 0);

	------------X_2 signals------------
	signal we1_X2, we2_X2 : std_logic;
	signal addr1_X2, addr2_X2 : std_logic_vector(9 downto 0);
	signal din1_X2, din2_X2, dout1_X2, dout2_X2 : std_logic_vector(15 downto 0);
	------Inside Enc------
	signal we1_X2_enc : std_logic;
	signal addr1_X2_enc : std_logic_vector(9 downto 0);
	signal din1_X2_enc : std_logic_vector(15 downto 0);
 
	------------seedSE signals------------
	signal we_seedSE : std_logic;
	signal addr_seedSE : std_logic_vector(3 downto 0);
	signal din_seedSE, dout_seedSE : std_logic_vector(15 downto 0);
	------Inside Enc------
	signal we_seedSE_enc : std_logic;
	signal addr_seedSE_enc : std_logic_vector(3 downto 0);
	signal din_seedSE_enc, dout_seedSE_enc : std_logic_vector(15 downto 0);

	------------mu signals------------
	signal addr_mu_enc : std_logic_vector(2 downto 0);
	signal dout_mu_enc : std_logic_vector(15 downto 0);

	------------pk signals------------
	signal addr1_pk_enc, addr2_pk_enc : std_logic_vector(12 downto 0);
	signal dout1_pk_enc, dout2_pk_enc : std_logic_vector(15 downto 0);

	------------ct signals------------
	signal we1_ct_enc, we2_ct_enc : std_logic;
	signal addr1_ct_enc, addr2_ct_enc : std_logic_vector(12 downto 0);
	signal din1_ct_enc, din2_ct_enc : std_logic_vector(15 downto 0);

	------------ss signals------------
	signal we_ss_enc : std_logic;
	signal addr_ss_enc : std_logic_vector(2 downto 0);
	signal din_ss_enc : std_logic_vector(15 downto 0);

	------------V signals------------
	signal we_V : std_logic;
	signal addr_V : std_logic_vector(5 downto 0);
	signal din_V, dout_V : std_logic_vector(15 downto 0);

	------------C signals------------
	signal we_C : std_logic;
	signal addr_C : std_logic_vector(5 downto 0);
	signal din_C, dout_C : std_logic_vector(15 downto 0);

begin

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

	V : single_port_distributed_ram
	generic map(
		awidth => 6,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_V,
		addr => addr_V,
		din => din_V,
		dout => dout_V
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

	mat_mul : matrix_mul
	port map(
		clk => clk,
		reset => reset_matrix,
		enable => enable_matrix,
		done => done_matrix,

		seedA => seed_A,

		n => n_matrix,

		use_A => use_A_matrix,
		offset_e => offset_e_matrix,
		offset_b => offset_b_matrix,

		addr_s => addr_s_matrix,
		dout_s => dout_s_matrix,

		addr_e => addr_e_matrix,
		dout_e => dout_e_matrix,

		addr_pk => addr_pk_matrix,
		dout_pk => dout_pk_matrix,

		we1_b => we1_b_matrix,
		addr1_b => addr1_b_matrix,
		din1_b => din1_b_matrix,
		dout1_b => dout1_b_matrix,
		we2_b => we2_b_matrix,
		addr2_b => addr2_b_matrix,
		din2_b => din2_b_matrix,
		dout2_b => dout2_b_matrix
	);

	packing : pack
	port map(
		clk => clk,
		reset => reset_pack,
		enable => enable_pack,
		done => done_pack,
		inlen => inlen_pack,
		offset => offset_pack,
		addr_a => addr_a_pack,
		dout_a => dout_a_pack,
		we1_ct => we1_ct_pack,
		addr1_ct => addr1_ct_pack,
		din1_ct => din1_ct_pack,
		we1_x => we1_x_pack,
		addr1_x => addr1_x_pack,
		din1_x => din1_x_pack
	);

	encoding : encode
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
		we1_s_gen 			when mul1,
		we1_s_gen 			when unmul1,
		'0'					when others;

	with state select we2_S1 <=
		we2_s_gen 			when mul1,
		we2_s_gen 			when unmul1,
		'0' 				when others;

	with state select addr1_S1 <=
		addr1_s_gen 		when mul1,
		addr_s_matrix 		when mul2,
		addr1_s_gen 		when unmul1,
		addr_s_matrix 		when unmul2,
		b"0000000000"		when others;

	with state select addr2_S1 <=
		addr2_s_gen 		when mul1,
		addr2_s_gen 		when unmul1,
		b"0000000000" 		when others;

	with state select din1_S1 <=
		din1_s_gen 			when mul1,
		din1_s_gen 			when unmul1,
		x"0000" 			when others;

	with state select din2_S1 <=
		din2_s_gen 			when mul1,
		din2_s_gen 			when unmul1,
		x"0000" 			when others;

	------------Selecting for S_2------------
	with state select we1_S2 <=
		we_out_hash 		when hash_pk,
		we1_S2_enc			when write_mu,
		we1_s_gen			when pregen_SE,
		we1_s_gen 			when mul2,
		we1_s_gen 			when unmul2,
		'0' 				when others;

	with state select we2_S2 <=
		we2_s_gen 			when pregen_SE,
		we2_s_gen 			when mul2,
		we2_s_gen 			when unmul2,
		'0'					when others;

	with state select addr1_S2 <=
		std_logic_vector(resize(unsigned(addr_out_hash), 10))	when hash_pk,
		addr1_S2_enc 				when write_mu,
		addr1_in_hash(9 downto 0)	when hash_pkh,
		addr1_s_gen 				when pregen_SE,
		addr1_s_gen 				when mul2,
		addr_s_matrix 				when mul1,
		addr_s_matrix 				when unmul1,
		addr1_s_gen 				when unmul2,
		b"0000000000" 	 			when others;

	with state select addr2_S2 <=
		addr2_in_hash(9 downto 0) 	when hash_pkh,
		addr2_s_gen 				when pregen_SE,
		addr2_s_gen 				when mul2,
		addr2_s_gen 				when unmul2,
		b"0000000000" 				when others;

	with state select din1_S2 <=
		din_out_hash 		when hash_pk,
		din1_S2_enc 		when write_mu,
		din1_s_gen			when pregen_SE,
		din1_s_gen 			when mul2,
		din1_s_gen 			when unmul2,
		x"0000" 			when others;

	with state select din2_S2 <=
		din2_s_gen 			when pregen_SE,
		din2_s_gen 			when mul2,
		din2_s_gen 			when unmul2,
		x"0000" 			when others;

	with state select dout_s_matrix <=
		dout1_S2 			when mul1,
		dout1_S1			when mul2,
		dout1_S2 			when unmul1,
		dout1_S1 			when unmul2,
		x"0000" 			when others;

	------------Selecting for E_1------------
	with state select we1_E1 <= 
		we1_e_gen 			when mul1,
		we1_e_gen 			when unmul1,
		'0'					when others;

	with state select we2_E1 <=
		we2_e_gen 			when mul1,
		we2_e_gen 			when unmul2,
		'0'					when others;

	with state select addr1_E1 <=
		addr1_e_gen 		when mul1,
		addr_e_matrix 		when mul2,
		addr1_e_gen 		when unmul1,
		addr_e_matrix 		when unmul2,
		b"0000000000" 		when others;

	with state select addr2_E1 <=
		addr2_e_gen 		when mul1,
		addr2_e_gen 		when unmul1,
		b"0000000000" 		when others;

	with state select din1_E1 <=
		din1_e_gen 			when mul1,
		din1_e_gen 			when unmul1,
		x"0000" 			when others;

	with state select din2_E1 <=
		din2_e_gen 			when mul1,
		din2_e_gen 			when unmul1,
		x"0000" 			when others;

	------------Selecting for E_2------------
	with state select we1_E2 <=
		we1_e_gen 			when pregen_SE,
		we1_e_gen			when mul2,
		'0' 				when others;

	with state select we2_E2 <=
		we2_e_gen 			when pregen_SE,
		we2_e_gen			when mul2,
		'0' 				when others;

	with state select addr1_E2 <=
		addr1_e_gen 		when pregen_SE,
		addr1_e_gen			when mul2,
		addr_e_matrix 		when mul1,
		addr_e_matrix 		when unmul1,
		addr_e_matrix 		when unmul2,
		b"0000000000" 		when others;

	with state select addr2_E2 <=
		addr2_e_gen 		when pregen_SE,
		addr2_e_gen			when mul2,
		b"0000000000" 		when others;

	with state select din1_E2 <=
		din1_e_gen 			when pregen_SE,
		din1_e_gen			when mul2,
		x"0000" 			when others;

	with state select din2_E2 <=
		din2_e_gen 			when pregen_SE,
		din2_e_gen			when mul2,
		x"0000" 			when others;

	with state select dout_e_matrix <=
		dout1_E2 			when mul1,
		dout1_E1 			when mul2,
		dout1_E2 			when unmul1,
		dout1_E2 			when unmul2,
		x"0000"				when others;

	------------Selecting for B_1------------
	with state select we1_B1 <=
		we1_b_matrix 		when mul2,
		--we1_b_matrix 		when unmul2,
		'0' 				when others;

	with state select we2_B1 <=
		we2_b_matrix 		when mul2,
		--we2_b_matrix 		when unmul2,
		'0'					when others;

	with state select addr1_B1 <=
		addr1_b_matrix 		when mul2,
		addr_a_pack 		when mul1,
		--addr1_b_matrix 		when unmul2,
		b"0000000000"		when others;

	with state select addr2_B1 <=
		addr2_b_matrix 		when mul2,
		--addr2_b_matrix 		when unmul2,
		b"0000000000" 		when others;

	with state select din1_B1 <=
		din1_b_matrix 		when mul2,
		--din1_b_matrix 		when unmul2,
		x"0000" 			when others;

	with state select din2_B1 <=
		din2_b_matrix 		when mul2,
		--din2_b_matrix 		when unmul2,
		x"0000" 			when others;

	------------Selecting for B_2------------
	with state select we1_B2 <=
		we1_b_matrix 		when mul1,
		we1_b_matrix 		when unmul1,
		we1_b_matrix 		when unmul2,
		'0'					when others;

	with state select we2_B2 <=
		we2_b_matrix 		when mul1,
		we2_b_matrix 		when unmul1,
		we2_b_matrix 		when unmul2,
		'0' 				when others;

	with state select addr1_B2 <=
		addr1_b_matrix 		when mul1,
		addr_a_pack 		when mul2,
		addr1_b_matrix 		when unmul1,
		addr1_b_matrix 		when unmul2,
		addr_B_add 			when add_cv,
		--addr_a_pack 		when pack_c,
		b"0000000000" 		when others;

	with state select addr2_B2 <=
		addr2_b_matrix  	when mul1,
		addr2_b_matrix 		when unmul1,
		addr2_b_matrix 		when unmul2,
		b"0000000000" 		when others;

	with state select din1_B2 <=
		din1_b_matrix 		when mul1,
		din1_b_matrix 		when unmul1,
		din1_b_matrix 		when unmul2,
		x"0000" 			when others;

	with state select din2_B2 <=
		din2_b_matrix	 	when mul1,
		din2_b_matrix 		when unmul1,
		din2_b_matrix 		when unmul2,
		x"0000" 			when others;

	with state select dout1_b_matrix <=
		dout1_B2 			when mul1,
		dout1_B1 			when mul2,
		dout1_B2 			when unmul1,
		dout1_B2 			when unmul2,
		x"0000" 			when others;

	with state select dout2_b_matrix <=
		dout2_B2 			when mul1,
		dout2_B1 			when mul2,
		dout2_B2 			when unmul1,
		dout2_B2 			when unmul2,
		x"0000" 			when others;

	with state select dout_a_pack <=
		dout1_B2			when mul2,
		dout1_B1 			when mul1,
		--dout1_B2 			when pack_c,
		dout_C 				when pack_c,
		x"0000" 			when others;

	dout_B_add <= dout1_B2;

	------------Selecting for X_1------------
	with state select we1_X1 <= 
		we1_x_pack 			when mul1,
		'0'					when others;

	with state select addr1_X1 <=
		addr1_x_pack 		when mul1,
		addr1_in_hash(9 downto 0)	when mul2,
		(others => '0')		when others;

	with state select addr2_X1 <=
		addr2_in_hash(9 downto 0)	when mul2,
		(others => '0')		when others;

	with state select din1_X1 <=
		din1_x_pack 		when mul1,
		x"0000"			 	when others;

	------------Selecting for X_2------------
	with state select we1_X2 <=
		we1_x_pack 			when mul2,
		we1_x_pack 			when pack_c,
		we1_X2_enc 			when write_k,
		'0'					when others;

	with state select addr1_X2 <=
		addr1_x_pack		when mul2,
		addr1_in_hash(9 downto 0)	when mul1,
		addr1_x_pack 		when pack_c,
		addr1_X2_enc 		when write_k,
		addr1_in_hash(9 downto 0) 	when final_hash,
		(others => '0')		when others;

	with state select addr2_X2 <=
		addr2_in_hash(9 downto 0)	when mul1,
		addr2_in_hash(9 downto 0)	when final_hash,
		(others => '0') 	when others;

	with state select din1_X2 <=
		din1_x_pack 		when mul2,
		din1_x_pack 		when pack_c,
		din1_X2_enc 		when write_k,
		x"0000" 			when others;


	------------Selecting for seedSE------------
	with state select we_seedSE <=
		we_out_hash 		when hash_pkh,
		'0' 				when others;

	with state select addr_seedSE <=
		addr_out_hash 		when hash_pkh,
		addr_seedSE_enc 	when write_seedSE,
		addr_seedSE_enc 	when write_k,
		b"0000" 			when others;

	with state select din_seedSE <=
		din_out_hash 		when hash_pkh,
		x"0000" 			when others;

	dout_seedSE_enc <= dout_seedSE;

	------------Selecing for V------------
	with state select we_V <=
		we_V_encode 		when pregen_SE,
		'0' 				when others;

	with state select addr_V <=
		addr_V_encode 		when pregen_SE,
		addr_V_add 			when add_cv,
		(others => '0')		when others;

	with state select din_V <=
		din_V_encode 		when pregen_SE,
		x"0000" 			when others;

	dout_V_add <= dout_V;

	------------Selecting for C------------
	with state select we_C <=
		we_C_add 			when add_cv,
		'0'					when others;

	with state select addr_C <=
		addr_C_add 			when add_cv,
		addr_a_pack(5 downto 0) 	when pack_c,
		(others => '0') 	when others;

	with state select din_C <=
		din_C_add 			when add_cv,
		x"0000" 			when others;

	------------Selecting for pk------------
	with state select addr1_pk <=
		addr1_in_hash		when hash_pk,
		addr1_pk_enc 		when write_seedSE,
		addr_pk_matrix 		when unmul1,
		addr_pk_matrix 		when unmul2,
		b"0000000000000"	when others;

	with state select addr2_pk <=
		addr2_in_hash 		when hash_pk,
		b"0000000000000"	when others;

	with state select dout1_in_hash <= 
		dout1_pk 			when hash_pk,
		dout1_S2 			when hash_pkh,
		--dout1_ct			when final_hash,
		--dout1_ct 			when unmul1,
		--dout1_ct			when unmul2,
		dout1_X2 			when mul1,
		dout1_X1 			when mul2,
		dout1_X2 			when final_hash,
		x"0000" 			when others;

	with state select dout2_in_hash <=
		dout2_pk 			when hash_pk,
		dout2_S2 			when hash_pkh,
		--dout2_ct 			when final_hash,
		--dout2_ct 			when unmul1,
		--dout2_ct			when unmul2,
		dout2_X2 			when mul1,
		dout2_X1			when mul2,
		dout2_X2 			when final_hash,
		x"0000" 			when others;

	dout1_pk_enc <= dout1_pk;
	dout2_pk_enc <= dout2_pk;

	dout_pk_matrix <= dout1_pk;

	------------Selecting for mu------------
	with state select addr_mu <=
		addr_mu_enc 		when write_mu,
		addr_mu_encode		when pregen_SE,
		b"000" 				when others;

	dout_mu_enc <= dout_mu;
	dout_mu_encode <= dout_mu;

	------------Selecting for ct------------
	with state select we1_ct <=
		we1_ct_pack 		when mul2,
		we1_ct_pack 		when mul1,
		we1_ct_pack 		when pack_c,
		--we1_ct_enc 			when write_k,
		'0'					when others;

	with state select addr1_ct <=
		addr1_ct_pack 		when mul2,
		addr1_ct_pack 		when mul1,
		addr1_ct_pack 		when pack_c,
		--addr1_ct_enc 		when write_k,
		--addr1_in_hash 		when final_hash,
		--addr1_in_hash 		when unmul1,
		--addr1_in_hash 		when unmul2,
		(others => '0')		when others;

	with state select din1_ct <=
		din1_ct_pack 		when mul2,
		din1_ct_pack 		when mul1,
		din1_ct_pack 		when pack_c,
		--din1_ct_enc 		when write_k,
		x"0000" 			when others;

	with state select addr2_ct <=
		--addr2_in_hash 		when final_hash,
		--addr2_in_hash 		when unmul1,
		--addr2_in_hash 		when unmul2,
		(others => '0') 	when others;

	------------Selecting for ss------------
	with state select we_ss <=
		we_out_hash 		when final_hash,
		we_out_hash 		when unmul1,
		we_out_hash 		when unmul2,
		'0'					when others;

	with state select addr_ss <=
		addr_out_hash(2 downto 0)	when final_hash,
		addr_out_hash(2 downto 0)	when unmul1,
		addr_out_hash(2 downto 0)	when unmul2,
		(others => '0')		when others;

	with state select din_ss <=
		din_out_hash 		when final_hash,
		din_out_hash 		when unmul1,
		din_out_hash 		when unmul2,
		x"0000" 			when others;


	process (clk) is
		variable temp_seedSE : std_logic_vector(7 downto 0) := x"96";
	begin
		if (rising_edge(clk)) then
			done <= '0';
			we1_S2_enc <= '0';
			we2_S2_enc <= '0';
			we1_X2_enc <= '0';
			we_seedSE_enc <= '0';
			we1_ct_enc <= '0';
			we2_ct_enc <= '0';
			we_ss_enc <= '0';

			if (reset = '1') then
				state <= s_reset;
				dummy <= '1';

			elsif (enable = '1') then
				if (state = s_reset) then
					state <= hash_pk;

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
					shake_seedSE <= (others => '0');
					temp_seedSE := x"96";

					reset_matrix <= '1';
					seed_A <= (others => '0');
					n_matrix <= 0;
					use_A_matrix <= '0';
					offset_e_matrix <= 0;
					offset_b_matrix <= 0;

					reset_pack <= '1';
					inlen_pack <= 0;
					offset_pack <= 0;

					reset_encode <= '1';

					reset_add <= '1';

					i <= 0;

				--Hash the public key
				elsif (state = hash_pk) then
					inlen_hash <= 4806;
					outlen_hash <= 8;
					offset_hash <= 0;
					enable_hash <= '1';
					reset_hash <= '0';
					if (done_hash = '1') then
						enable_hash <= '0';
						reset_hash <= '1';
						state <= write_mu;
					end if;

				--Write mu into S_2, then hash it together with pkh
				elsif (state = write_mu) then
					if (i < 10) then
						addr_mu_enc <= std_logic_vector(to_unsigned(i, 3));
						i <= i + 1;
						if (i >= 2) then
							we1_S2_enc <= '1';
							addr1_S2_enc <= std_logic_vector(to_unsigned(i+6, 10));
							din1_S2_enc <= dout_mu_enc;
						end if;
					else
						we1_S2_enc <= '0';
						i <= 0;
						state <= hash_pkh;
						inlen_hash <= 14;
						outlen_hash <= 16;
						offset_hash <= 0;
						enable_hash <= '1';
						reset_hash <= '0';
					end if;

				elsif (state = hash_pkh) then
					if (done_hash = '1') then
						enable_hash <= '0';
						reset_hash <= '1';
						state <= write_seedSE;
					end if;

				--Write seedSE and seedA
				elsif (state = write_seedSE) then
					if (i < 10) then
						addr_seedSE_enc <= std_logic_vector(to_unsigned(i, 4));
						addr1_pk_enc <= std_logic_vector(to_unsigned(i, 13));
						i <= i + 1;
						if (i >= 2) then
							shake_seedSE <= shake_seedSE(175 downto 64) & dout_seedSE_enc(15 downto 8) & temp_seedSE & x"0000000000000000";
							temp_seedSE := dout_seedSE_enc(7 downto 0);
							seed_A <= seed_A(127 downto 0) & dout1_pk_enc(7 downto 0) & dout1_pk_enc(15 downto 8);
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

						reset_encode <= '0';
						enable_encode <= '1';
					end if;

				--Pregenerate the first row of S and E
				--Encode mu in parallel
				elsif (state = pregen_SE) then
					if (done_encode = '1') then
						enable_encode <= '0';
					end if;
					if (done_gen = '1') then
						state <= mul1;

						n_matrix <= 640;
						use_A_matrix <= '1';
						enable_matrix <= '1';
						reset_matrix <= '0';
						offset_e_matrix <= 0;
						offset_b_matrix <= 0;

						low1_gen <= low1_gen + 320;
						low2_gen <= low2_gen + 320;
						high1_gen <= high1_gen + 320;
						high2_gen <= high2_gen + 320;

						reset_pack <= '0';
						inlen_pack <= 640;
						offset_pack <= 0;

						inlen_hash <= 598;
						outlen_hash <= 0;
						offset_hash <= 0;
						reset_hash <= '0';
					end if;

				--Multiply one row of S with A, add E
				--Generate the next rows of S and E in parallel
				--Once the first row of B' is available: start packing it
				--Once the first row has been packed: hash it as the first part of ct
				elsif (state = mul1) then
					if (done_gen = '1') then
						enable_gen <= '0';
						if (i < 6) then
							low1_gen <= low1_gen + 320;
							low2_gen <= low2_gen + 320;
							high1_gen <= high1_gen + 320;
							high2_gen <= high2_gen + 320;
						else
							low1_gen <= 0;
							high1_gen <= 320;
							low2_gen <= 5120;
							high2_gen <= 5152;
							length2_gen <= 64;
						end if;						
					end if;

					if (done_pack = '1') then
						enable_pack <= '0';
						offset_pack <= offset_pack + 600;
						if (i = 8) then
							enable_hash <= '1';
							state <= mul2;
							i <= i + 1;
						end if;
					end if;

					if (done_hash = '1') then
						enable_hash <= '0';
						if (i = 9) then
							state <= unmul1;
							enable_matrix <= '1';
							enable_gen <= '1';
							reset_matrix <= '0';
							n_matrix <= 8;
							use_A_matrix <= '0';
							i <= 0;
							inlen_hash <= 66;
							outlen_hash <= 8;
							offset_hash <= 4800;
						end if;
					end if;

					if (done_matrix = '1') then
						i <= i + 1;
						state <= mul2;
						enable_gen <= '1';
						if (i >= 7) then
							enable_gen <= '0';
							enable_matrix <= '0';
							reset_matrix <= '1';
						end if;
						if (i >= 0 and i < 8) then
							enable_pack <= '1';
						end if;
						if (i >= 1) then
							enable_hash <= '1';
						end if;
					end if;

				elsif (state = mul2) then
					if (done_gen = '1') then
						enable_gen <= '0';
						if (i < 6) then
							low1_gen <= low1_gen + 320;
							low2_gen <= low2_gen + 320;
							high1_gen <= high1_gen + 320;
							high2_gen <= high2_gen + 320;
						else
							low1_gen <= low1_gen + 320;
							low2_gen <= 0;
							high1_gen <= high1_gen + 320;
							high2_gen <= 0;
							length2_gen <= 0;
						end if;
					end if;

					if (done_pack = '1') then
						enable_pack <= '0';
						offset_pack <= offset_pack + 600;
						if (i = 8) then
							enable_hash <= '1';
							state <= mul1;
							i <= i + 1;
						end if;
					end if;

					if (done_hash = '1') then
						enable_hash <= '0';
						if (i = 9) then
							state <= unmul1;
							enable_matrix <= '1';
							enable_gen <= '1';
							reset_matrix <= '0';
							n_matrix <= 8;
							use_A_matrix <= '0';
							i <= 0;
							inlen_hash <= 66;
							outlen_hash <= 8;
							offset_hash <= 4800;
						end if;
					end if;

					if (done_matrix = '1') then
						i <= i + 1;
						state <= mul1;
						enable_gen <= '1';
						if (i >= 7) then
							enable_gen <= '0';
							enable_matrix <= '0';
							reset_matrix <= '1';
						end if;
						if (i >= 0 and i < 8) then
							enable_pack <= '1';
						end if;
						if (i >= 1) then
							enable_hash <= '1';
						end if;
					end if;

				--Second matrix multiplication V = S'*B + E''
				--Generate the next row of S' and E'' in parallel
				elsif (state = unmul1) then
					if (done_gen = '1') then 
						enable_gen <= '0';
						low1_gen <= low1_gen + 320;
						high1_gen <= high1_gen + 320;
					end if;

					if (done_matrix = '1') then
						state <= unmul2;
						enable_gen <= '1';
						offset_e_matrix <= offset_e_matrix + 8;
						offset_b_matrix <= offset_b_matrix + 8;
						i <= i + 1;
						if (i = 7) then 
							state <= add_cv;
							enable_add <= '1';
							enable_gen <= '0';
							enable_matrix <= '0';
							reset_pack <= '1';
							i <= 0;
						end if;
					end if;

				elsif (state = unmul2) then
					if (done_gen = '1') then
						enable_gen <= '0';
						low1_gen <= low1_gen + 320;
						high1_gen <= high1_gen + 320;
					end if;

					if (done_matrix = '1') then
						state <= unmul1;
						enable_gen <= '1';
						offset_e_matrix <= offset_e_matrix + 8;
						offset_b_matrix <= offset_b_matrix + 8;
						i <= i + 1;
						if (i = 7) then 
							state <= add_cv;
							reset_add <= '0';
							enable_add <= '1';
							enable_gen <= '0';
							enable_matrix <= '0';
							reset_pack <= '1';
							i <= 0;
						end if;
					end if;

				--Add V and the encoded mu
				elsif (state = add_cv) then
					if (done_add = '1') then
						enable_add <= '0';
						state <= pack_c;
						enable_pack <= '1';
						reset_pack <= '0';
						inlen_pack <= 64;
						offset_pack <= 4800;
					end if;

				--Pack the result
				elsif (state = pack_c) then
					if (done_pack = '1') then
						enable_pack <= '0';
						state <= write_k;
					end if;

				--Write k into S_2 for the final step of calculating ss
				elsif (state = write_k) then
					addr_seedSE_enc <= std_logic_vector(to_unsigned(i+8, 4));
					i <= i + 1;
					if (i >= 2) then
						we1_X2_enc <= '1';
						addr1_X2_enc <= std_logic_vector(to_unsigned(i-2+60, 10));
						din1_X2_enc <= dout_seedSE_enc;
						if (i = 10) then
							state <= final_hash;
							enable_hash <= '1';
							reset_hash <= '0';
							i <= 0;
						end if;
					end if;

				--Hash k in S_2 to get ss
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