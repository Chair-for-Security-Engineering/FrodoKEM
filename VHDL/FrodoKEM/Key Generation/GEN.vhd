--FrodoKEM Key generation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frodo_gen is
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
end entity frodo_gen;

architecture behave of frodo_gen is

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

			addr1_in : out std_logic_vector(9 downto 0);
			dout1_in : in std_logic_vector(15 downto 0);
			addr2_in : out std_logic_vector(9 downto 0);
			dout2_in : in std_logic_vector(15 downto 0);

			we_out : out std_logic;
			addr_out : out std_logic_vector(2 downto 0);
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
			offset_sk : in integer;

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
			din2_e : out std_logic_vector(15 downto 0);

			we1_sk : out std_logic;
			addr1_sk : out std_logic_vector(13 downto 0);
			din1_sk : out std_logic_vector(15 downto 0);
			we2_sk : out std_logic;
			addr2_sk : out std_logic_vector(13 downto 0);
			din2_sk : out std_logic_vector(15 downto 0)
		);
	end component shake_gen_SE;

	component matrix_mul is 
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
	end component matrix_mul;

	component pack is
		port(
			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			done : out std_logic;

			inlen : in integer;
			in_offset : in integer;
			offset_pk : in integer;
			offset_sk : in integer;

			addr_a : out std_logic_vector(12 downto 0);
			dout_a : in std_logic_vector(15 downto 0);

			we1_S : out std_logic;
			addr1_S : out std_logic_vector(9 downto 0);
			din1_S : out std_logic_vector(15 downto 0);
			we1_pk : out std_logic;
			addr1_pk : out std_logic_vector(12 downto 0);
			din1_pk : out std_logic_vector(15 downto 0);
			we1_sk : out std_logic;
			addr1_sk : out std_logic_vector(13 downto 0);
			din1_sk : out std_logic_vector(15 downto 0)
		);
	end component pack;

	type states is (s_reset, s_done, prepare_seedA, hash_z, write_seeds, pregen_SE,
		mul1, mul2, packhash1, packhash2, hash_seed, write_pkh);
	signal state : states := s_reset;

	signal dummy : std_logic := '0';
	signal i, j : integer := 0;
	signal seed_A : std_logic_vector(143 downto 0) := (others => '0');
	signal shake_seedSE : std_logic_vector(191 downto 0) := (others => '0');

	------------Hash signals------------
	signal enable_hash, reset_hash : std_logic := '0';
	signal done_hash : std_logic;
	signal inlen_hash, outlen_hash, offset_hash : integer := 0;
	signal addr1_in_hash, addr2_in_hash : std_logic_vector(9 downto 0);
	signal we_out_hash : std_logic;
	signal addr_out_hash : std_logic_vector(2 downto 0);
	signal dout1_in_hash, dout2_in_hash, din_out_hash : std_logic_vector(15 downto 0);

	------------shake_gen signals------------
	signal reset_shake, enable_shake : std_logic := '0';
	signal done_shake : std_logic;
	signal low1_shake, low2_shake, high1_shake, high2_shake, length1_shake, length2_shake : integer := 0;
	signal we1_s_shake, we2_s_shake, we1_e_shake, we2_e_shake, we1_sk_shake, we2_sk_shake : std_logic;
	signal addr1_s_shake, addr2_s_shake, addr1_e_shake, addr2_e_shake : std_logic_vector(9 downto 0);
	signal din1_s_shake, din2_s_shake, din1_e_shake, din2_e_shake, din1_sk_shake, din2_sk_shake : std_logic_vector(15 downto 0);
	signal addr1_sk_shake, addr2_sk_shake : std_logic_vector(13 downto 0);
	signal offset_sk_shake : integer;

	------------Matrix signals------------
	signal reset_matrix, enable_matrix : std_logic := '0';
	signal done_matrix : std_logic;
	signal offset_b_matrix : integer := 0;
	signal addr_s_matrix, addr_e_matrix : std_logic_vector(9 downto 0);
	signal we_b_matrix : std_logic;
	signal addr_b_matrix : std_logic_vector(12 downto 0);
	signal dout_s_matrix, dout_e_matrix, din_b_matrix, dout_b_matrix : std_logic_vector(15 downto 0);

	------------Pack signals------------
	signal reset_pack, enable_pack, done_pack : std_logic;
	signal inlen_pack, in_offset_pack, offset_pk_pack, offset_sk_pack : integer;
	signal addr_a_pack, addr1_pk_pack : std_logic_vector(12 downto 0);
	signal we1_S_pack, we1_pk_pack, we1_sk_pack : std_logic;
	signal addr1_sk_pack : std_logic_vector(13 downto 0);
	signal addr1_S_pack : std_logic_vector(9 downto 0);
	signal dout_a_pack, din1_S_pack, din1_pk_pack, din1_sk_pack : std_logic_vector(15 downto 0);

	------------S_1 signals------------
	signal we1_S1, we2_S1 : std_logic;
	signal addr1_S1, addr2_S1 : std_logic_vector(9 downto 0);
	signal din1_S1, din2_S1, dout1_S1, dout2_S1 : std_logic_vector(15 downto 0);

	------------S_2 signals------------
	signal we1_S2, we2_S2 : std_logic;
	signal addr1_S2, addr2_S2 : std_logic_vector(9 downto 0);
	signal din1_S2, din2_S2, dout1_S2, dout2_S2 : std_logic_vector(15 downto 0);
	------Inside gen------
	signal we1_S2_gen, we2_S2_gen : std_logic;
	signal addr1_S2_gen, addr2_S2_gen : std_logic_vector(9 downto 0);
	signal din1_S2_gen, din2_S2_gen, dout1_S2_gen, dout2_S2_gen : std_logic_vector(15 downto 0);

	------------E_1 signals------------
	signal we1_E1, we2_E1 : std_logic;
	signal addr1_E1, addr2_E1 : std_logic_vector(9 downto 0);
	signal din1_E1, din2_E1, dout1_E1, dout2_E1 : std_logic_vector(15 downto 0);

	------------E_2 signals------------
	signal we1_E2, we2_E2 : std_logic;
	signal addr1_E2, addr2_E2 : std_logic_vector(9 downto 0);
	signal din1_E2, din2_E2, dout1_E2, dout2_E2 : std_logic_vector(15 downto 0);

	------------B signals------------
	signal we_B : std_logic;
	signal addr_B : std_logic_vector(12 downto 0);
	signal din_B, dout_B : std_logic_vector(15 downto 0);

	------------seed_A signals------------
	signal we_seedA : std_logic;
	signal addr_seedA : std_logic_vector(2 downto 0);
	signal din_seedA, dout_seedA : std_logic_vector(15 downto 0);
	------Inside gen------
	signal addr_seed_gen : std_logic_vector(2 downto 0);
	signal dout_seed_gen : std_logic_vector(15 downto 0);

	------------rand signals------------
	signal addr_rand_gen : std_logic_vector(4 downto 0);
	signal dout_rand_gen : std_logic_vector(15 downto 0);

	------------pk signals------------
	signal we1_pk_gen, we2_pk_gen : std_logic;
	signal addr1_pk_gen, addr2_pk_gen : std_logic_vector(12 downto 0);
	signal din1_pk_gen, din2_pk_gen : std_logic_vector(15 downto 0);

	------------sk signals------------
	signal we1_sk_gen, we2_sk_gen : std_logic;
	signal addr1_sk_gen, addr2_sk_gen : std_logic_vector(13 downto 0);
	signal din1_sk_gen, din2_sk_gen : std_logic_vector(15 downto 0);

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

	B : single_port_distributed_ram
	generic map(
		awidth => 13,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_B,
		addr => addr_B,
		din => din_B,
		dout => dout_B
	);

	seed : single_port_distributed_ram
	generic map(
		awidth => 3,
		dwidth => 16
	)
	port map(
		clk => clk,
		we => we_seedA,
		addr => addr_seedA,
		din => din_seedA,
		dout => dout_seedA
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
		reset => reset_shake,
		enable => enable_shake,
		done => done_shake,

		low1 => low1_shake,
		high1 => high1_shake,
		low2 => low2_shake,
		high2 => high2_shake,
		length1 => length1_shake,
		length2 => length2_shake,
		offset_sk => offset_sk_shake,

		seed_SE => shake_seedSE,

		we1_s => we1_s_shake,
		addr1_s => addr1_s_shake,
		din1_s => din1_s_shake,
		we2_s => we2_s_shake,
		addr2_s => addr2_s_shake,
		din2_s => din2_s_shake,
		we1_e => we1_e_shake,
		addr1_e => addr1_e_shake,
		din1_e => din1_e_shake,
		we2_e => we2_e_shake,
		addr2_e => addr2_e_shake,
		din2_e => din2_e_shake,

		we1_sk => we1_sk_shake,
		addr1_sk => addr1_sk_shake,
		din1_sk => din1_sk_shake,
		we2_sk => we2_sk_shake,
		addr2_sk => addr2_sk_shake,
		din2_sk => din2_sk_shake
	);

	matrix : matrix_mul
	port map(
		clk => clk,
		reset => reset_matrix,
		enable => enable_matrix,
		done => done_matrix,

		seedA => seed_A,

		offset_b => offset_b_matrix,

		addr_s => addr_s_matrix,
		dout_s => dout_s_matrix,

		addr_e => addr_e_matrix,
		dout_e => dout_e_matrix,

		we_b => we_b_matrix,
		addr_b => addr_b_matrix,
		din_b => din_b_matrix,
		dout_b => dout_b_matrix
	);

	packing : pack
	port map(
		clk => clk,
		reset => reset_pack,
		enable => enable_pack,
		done => done_pack,

		inlen => inlen_pack,
		in_offset => in_offset_pack,
		offset_pk => offset_pk_pack,
		offset_sk => offset_sk_pack,

		addr_a => addr_a_pack,
		dout_a => dout_a_pack,

		we1_S => we1_S_pack,
		addr1_S => addr1_S_pack,
		din1_S => din1_S_pack,
		we1_pk => we1_pk_pack,
		addr1_pk => addr1_pk_pack,
		din1_pk => din1_pk_pack,
		we1_sk => we1_sk_pack,
		addr1_sk => addr1_sk_pack,
		din1_sk => din1_sk_pack
	);

	------------Selecting for E_1------------
	with state select we1_E1 <=
		we1_e_shake 		when mul1,
		'0'					when others;

	with state select we2_E1 <=
		we2_e_shake 		when mul1,
		'0'					when others;

	with state select addr1_E1 <=
		addr1_e_shake 		when mul1,
		addr_e_matrix 		when mul2,
		(others => '0')		when others;

	with state select addr2_E1 <= 
		addr2_e_shake 		when mul1,
		(others => '0')		when others;

	with state select din1_E1 <=
		din1_e_shake 		when mul1,
		x"0000"				when others;

	with state select din2_E1 <=
		din2_e_shake 		when mul1,
		x"0000"				when others;

	------------Selecting for E_2------------
	with state select we1_E2 <=
		we1_e_shake 		when pregen_SE,
		we1_e_shake 		when mul2,
		'0'					when others;

	with state select we2_E2 <=
		we2_e_shake			when pregen_SE,
		we2_e_shake 		when mul2,
		'0'					when others;

	with state select addr1_E2 <=
		addr1_e_shake 		when pregen_SE,
		addr_e_matrix 		when mul1,
		addr1_e_shake 		when mul2,
		(others => '0')		when others;

	with state select addr2_E2 <=
		addr2_e_shake 		when pregen_SE,
		addr2_e_shake 		when mul2,
		(others => '0')		when others;

	with state select din1_E2 <=
		din1_e_shake 		when pregen_SE,
		din1_e_shake 		when mul2,
		x"0000"				when others;

	with state select din2_E2 <=
		din2_e_shake 		when pregen_SE,
		din2_e_shake 		when mul2,
		x"0000"				when others;

	------------Selecting for S_1------------
	with state select we1_S1 <=
		we1_s_shake 		when mul1,
		we1_S_pack 			when packhash2,
		'0'					when others;

	with state select we2_S1 <=
		we2_s_shake 		when mul1,
		'0'					when others;

	with state select addr1_S1 <=
		addr1_s_shake 		when mul1,
		addr_s_matrix 		when mul2,
		addr1_in_hash 		when packhash1,
		addr1_S_pack 		when packhash2,
		(others => '0')		when others;

	with state select addr2_S1 <=
		addr2_s_shake 		when mul1,
		addr2_in_hash 		when packhash1,
		(others => '0')		when others;

	with state select din1_S1 <=
		din1_s_shake 		when mul1,
		din1_S_pack 		when packhash2,
		x"0000" 			when others;

	with state select din2_S1 <=
		din2_s_shake 		when mul1,
		x"0000" 			when others;

	------------Selecting for S_2------------
	with state select we1_S2 <= 
		we1_S2_gen 			when prepare_seedA,
		we1_S2_gen 			when write_seeds,
		we1_s_shake 		when pregen_SE,
		we1_s_shake 		when mul2,
		we1_S_pack			when packhash1,
		'0'					when others;

	with state select we2_S2 <=
		we2_s_shake 		when pregen_SE,
		we2_s_shake 		when mul2,
		'0'					when others;

	with state select addr1_S2 <=
		addr1_S2_gen 				when prepare_seedA,
		addr1_S2_gen 				when write_seeds,
		addr1_in_hash				when hash_z,
		addr1_in_hash				when hash_seed,
		addr1_s_shake 				when pregen_SE,
		addr_s_matrix 				when mul1,
		addr1_s_shake 				when mul2,
		addr1_S_pack 				when packhash1,
		addr1_in_hash				when packhash2,
		(others => '0')				when others;

	with state select addr2_S2 <=
		addr2_in_hash				when hash_z,
		addr2_in_hash				when hash_seed,
		addr2_s_shake 				when pregen_SE,
		addr2_s_shake 				when mul2,
		addr2_in_hash 				when packhash2,
		(others => '0')				when others;

	with state select din1_S2 <=
		din1_S2_gen 		when prepare_seedA,
		din1_S2_gen 		when write_seeds,
		din1_s_shake 		when pregen_SE,
		din1_s_shake 		when mul2,
		din1_S_pack 		when packhash1,
		x"0000"				when others;

	with state select din2_S2 <=
		din2_s_shake 		when pregen_SE,
		din2_s_shake 		when mul2,
		x"0000"				when others;

	------------Selecting for B------------
	with state select we_B <=
		we_b_matrix 		when mul1,
		we_b_matrix 		when mul2,
		'0'					when others;

	with state select addr_B <= 
		addr_b_matrix 		when mul1,
		addr_b_matrix 		when mul2,
		addr_a_pack 		when packhash1,
		addr_a_pack 		when packhash2,
		(others => '0')		when others;

	with state select din_B <=
		din_b_matrix 		when mul1,
		din_b_matrix 		when mul2,
		x"0000" 			when others;

	------------Selecting for seed------------
	with state select we_seedA <=
		we_out_hash 		when hash_z,
		we_out_hash 		when packhash1,
		we_out_hash 		when packhash2,
		'0'					when others;

	with state select addr_seedA <=
		addr_out_hash 		when hash_z,
		addr_seed_gen 		when write_seeds,
		addr_out_hash		when packhash1,
		addr_out_hash 		when packhash2,
		addr_seed_gen		when write_pkh,
		(others => '0')		when others;

	with state select din_seedA <=
		din_out_hash 		when hash_z,
		din_out_hash		when packhash1,
		din_out_hash	 	when packhash2,
		x"0000"				when others;

	------------Selecting for rand------------
	with state select addr_rand <=
		addr_rand_gen 		when prepare_seedA,
		addr_rand_gen 		when write_seeds,
		addr_rand_gen 		when write_pkh,
		(others => '0')		when others;

	------------Selecting for pk------------
	with state select we1_pk <=
		we1_pk_gen 			when write_seeds,
		we1_pk_pack 		when packhash1,
		we1_pk_pack 		when packhash2,
		'0'					when others;

	with state select addr1_pk <=
		addr1_pk_pack 		when packhash1,
		addr1_pk_pack 		when packhash2,
		addr1_pk_gen 		when write_seeds,
		(others => '0') 	when others;

	with state select din1_pk <= 
		din1_pk_gen 		when write_seeds,
		din1_pk_pack 		when packhash1,
		din1_pk_pack 		when packhash2,
		x"0000" 			when others;

	------------Selecting for sk------------
	with state select we1_sk <=
		we1_sk_gen 			when write_seeds,
		we1_sk_shake 		when pregen_SE,
		we1_sk_shake 		when mul1,
		we1_sk_shake 		when mul2,
		we1_sk_pack 		when packhash1,
		we1_sk_pack 		when packhash2,
		we1_sk_gen 			when write_pkh,
		'0'					when others;

	with state select we2_sk <=
		we2_sk_shake 		when pregen_SE,
		we2_sk_shake 		when mul1,
		we2_sk_shake 		when mul2,
		we2_sk_gen 			when write_pkh,
		'0'					when others;

	with state select addr1_sk <=
		addr1_sk_gen 		when write_seeds,
		addr1_sk_shake 		when pregen_SE,
		addr1_sk_shake 		when mul1,
		addr1_sk_shake		when mul2,
		addr1_sk_pack 		when packhash1,
		addr1_sk_pack 		when packhash2,
		addr1_sk_gen		when write_pkh,
		(others => '0')		when others;

	with state select addr2_sk <=
		addr2_sk_shake 		when pregen_SE,
		addr2_sk_shake 		when mul1,
		addr2_sk_shake		when mul2,
		addr2_sk_gen		when write_pkh,
		(others => '0')		when others;

	with state select din1_sk <=
		din1_sk_gen 		when write_seeds,
		din1_sk_shake 		when pregen_SE,
		din1_sk_shake 		when mul1,
		din1_sk_shake 		when mul2,
		din1_sk_pack 		when packhash1,
		din1_sk_pack 		when packhash2,
		din1_sk_gen 		when write_pkh,
		x"0000"				when others;

	with state select din2_sk <=
		din2_sk_shake 		when pregen_SE,
		din2_sk_shake 		when mul1,
		din2_sk_shake 		when mul2,
		din2_sk_gen 		when write_pkh,
		x"0000"				when others;

	------------Selecting outputs------------
	dout_rand_gen <= dout_rand;

	dout_seed_gen <= dout_seedA;

	dout_b_matrix <= dout_B;

	dout_a_pack <= dout_B;

	with state select dout1_in_hash <=
		dout1_S2 			when hash_z,
		dout1_S2 			when hash_seed,
		dout1_S2 			when packhash2,
		dout1_S1 			when packhash1,
		x"0000"				when others;

	with state select dout2_in_hash <=
		dout2_S2 			when hash_z,
		dout2_S2 			when hash_seed,
		dout2_S2 			when packhash2,
		dout2_S1 			when packhash1,
		x"0000"				when others;

	with state select dout_s_matrix <=
		dout1_S2 			when mul1,
		dout1_S1 			when mul2,
		x"0000"				when others;

	with state select dout_e_matrix <= 
		dout1_E2 			when mul1,
		dout1_E1 			when mul2,
		x"0000"				when others;

	process (clk) is
		variable temp_seedSE : std_logic_vector(7 downto 0) := x"5F";
	begin
		if (rising_edge(clk)) then
			done <= '0';
			we1_S2_gen <= '0';
			we2_S2_gen <= '0';
			we1_pk_gen <= '0';
			we2_pk_gen <= '0';
			we1_sk_gen <= '0';
			we2_sk_gen <= '0';

			dummy <= '1';

			if (reset = '1') then
				state <= s_reset;

			elsif (enable = '1') then
				if (state = s_reset) then
					state <= prepare_seedA;
					i <= 0;
					j <= 0;
					seed_A <= (others => '0');
					shake_seedSE <= (others => '0');
					temp_seedSE := x"5F";

					reset_hash <= '1';
					inlen_hash <= 0;
					outlen_hash <= 0;
					offset_hash <= 0;

					reset_shake <= '1';
					low1_shake <= 0;
					low2_shake <= 0;
					high1_shake <= 0;
					high2_shake <= 0;
					length1_shake <= 0;
					length2_shake <= 0;
					offset_sk_shake <= 0;

					reset_matrix <= '1';
					offset_b_matrix <= 0;

					reset_pack <= '1';
					inlen_pack <= 0;
					in_offset_pack <= 0;
					offset_pk_pack <= 0;
					offset_sk_pack <= 0;

				--Write z from randomness into S_2, then hash it to obtain seedA
				elsif (state = prepare_seedA) then
					i <= i + 1;
					addr_rand_gen <= std_logic_vector(to_unsigned(i+16, 5));
					if (i >= 2) then
						we1_S2_gen <= '1';
						addr1_S2_gen <= std_logic_vector(to_unsigned(i-2, 10));
						din1_S2_gen <= dout_rand_gen;
						if (i = 10) then
							i <= 0;
							state <= hash_z;
							reset_hash <= '0';
							enable_hash <= '1';
							inlen_hash <= 8;
							outlen_hash <= 8;
							offset_hash <= 0;
						end if;
					end if;

				elsif (state = hash_z) then
					if (done_hash = '1') then
						enable_hash <= '0';
						reset_hash <= '1';
						state <= write_seeds;
					end if;

				--Set seedA and seedSE, write seedA into pk and sk
				elsif (state = write_seeds) then
					i <= i + 1;
					if (i < 10) then
						addr_rand_gen <= std_logic_vector(to_unsigned(i+8, 5));
						addr_seed_gen <= std_logic_vector(to_unsigned(i, 3));
						if (i >= 2) then
							seed_A <= seed_A(127 downto 0) & dout_seed_gen(7 downto 0) & dout_seed_gen(15 downto 8);
							shake_seedSE <= shake_seedSE(175 downto 64) & dout_rand_gen(15 downto 8) & temp_seedSE & x"0000000000000000";
							temp_seedSE := dout_rand_gen(7 downto 0);
							we1_pk_gen <= '1';
							addr1_pk_gen <= std_logic_vector(to_unsigned(i-2, 13));
							din1_pk_gen <= dout_seed_gen;
							we1_sk_gen <= '1';
							addr1_sk_gen <= std_logic_vector(to_unsigned(i+6, 14));
							din1_sk_gen <= dout_seed_gen;
							we1_S2_gen <= '1';
							addr1_S2_gen <= std_logic_vector(to_unsigned(i-2, 10));
							din1_S2_gen <= dout_seed_gen;
						end if;
					elsif (i = 10) then
						shake_seedSE(63 downto 0) <= x"1F" & temp_seedSE & x"000000000000";
						i <= 0;
						state <= hash_seed;

						reset_hash <= '0';
						enable_hash <= '1';
						inlen_hash <= 8;
						outlen_hash <= 0;
					end if;

				--Hash seedA as the first part of hashing the public key, do not reset
				--the SHAKE state afterwards
				elsif (state = hash_seed) then
					if (done_hash = '1') then
						enable_hash <= '0';

						state <= pregen_SE;
						reset_shake <= '0';
						enable_shake <= '1';
						low1_shake <= 0;
						high1_shake <= 320;
						low2_shake <= 2560;
						high2_shake <= 2880;
						length1_shake <= 640;
						length2_shake <= 640;
						offset_sk_shake <= 4816;
					end if;

				--Pregenerate the first row of S and E
				elsif (state = pregen_SE) then
					if (done_shake = '1') then
						--enable_shake <= '0';
						low1_shake <= low1_shake + 320;
						low2_shake <= low2_shake + 320;
						high1_shake <= high1_shake + 320;
						high2_shake <= high2_shake + 320;
						offset_sk_shake <= offset_sk_shake + 640;

						reset_matrix <= '0';
						enable_matrix <= '1';
						offset_b_matrix <= 0;
						state <= mul1;
					end if;

				--Multiply one row of S with A and add a row of E, generate the next
				--rows in parallel
				elsif (state = mul1) then
					if (done_shake = '1') then
						enable_shake <= '0';
						low1_shake <= low1_shake + 320;
						low2_shake <= low2_shake + 320;
						high1_shake <= high1_shake + 320;
						high2_shake <= high2_shake + 320;
						offset_sk_shake <= offset_sk_shake + 640;
						--state <= mul2;
						--i <= i + 1;
					end if;

					if (done_matrix = '1') then
						enable_shake <= '1';
						i <= i + 1;
						state <= mul2;
						if (i = 7) then
							enable_shake <= '0';
							enable_matrix <= '0';
							i <= 0;

							state <= packhash1;
							reset_pack <= '0';
							enable_pack <= '1';
							inlen_pack <= 640;
							in_offset_pack <= 0;
							offset_pk_pack <= 8;
							offset_sk_pack <= 16;
						end if;
					end if;

				elsif (state = mul2) then
					if (done_shake = '1') then
						enable_shake <= '0';
						low1_shake <= low1_shake + 320;
						low2_shake <= low2_shake + 320;
						high1_shake <= high1_shake + 320;
						high2_shake <= high2_shake + 320;
						offset_sk_shake <= offset_sk_shake + 640;
					end if;

					if (done_matrix = '1') then
						enable_shake <= '1';
						i <= i + 1;
						state <= mul1;
						if (i = 7) then
							enable_shake <= '0';
							enable_matrix <= '0';
							i <= 0;

							state <= packhash1;
							reset_pack <= '0';
							enable_pack <= '1';
							inlen_pack <= 640;
							in_offset_pack <= 0;
							offset_pk_pack <= 8;
							offset_sk_pack <= 16;
						end if;
					end if;

				--Pack one row of B, at the same time hash the packed row once it
				--is available
				elsif (state = packhash1) then
					if (done_pack = '1') then
						i <= i + 1;
						in_offset_pack <= in_offset_pack + 640;
						offset_pk_pack <= offset_pk_pack + 600;
						offset_sk_pack <= offset_sk_pack + 600;
						state <= packhash2;

						enable_hash <= '1';
						inlen_hash <= 600;

						if (i = 7) then
							enable_pack <= '0';
							outlen_hash <= 8;
						end if;
					end if;

					if (done_hash = '1') then
						enable_hash <= '0';
						if (i = 8) then
							i <= 0;
							state <= write_pkh;
						end if;
					end if;

				elsif (state = packhash2) then
					if (done_pack = '1') then
						i <= i + 1;
						in_offset_pack <= in_offset_pack + 640;
						offset_pk_pack <= offset_pk_pack + 600;
						offset_sk_pack <= offset_sk_pack + 600;
						state <= packhash1;

						enable_hash <= '1';
						inlen_hash <= 600;

						if (i = 7) then
							enable_pack <= '0';
							outlen_hash <= 8;
						end if;
					end if;

					if (done_hash = '1') then
						enable_hash <= '0';
						if (i = 8) then
							i <= 0;
							state <= write_pkh;
						end if;
					end if;

				--Write the result of the hashing into sk and write s into sk
				elsif (state = write_pkh) then
					i <= i + 1;
					addr_rand_gen <= std_logic_vector(to_unsigned(i, 5));
					addr_seed_gen <= std_logic_vector(to_unsigned(i, 3));
					if (i >= 2) then
						we1_sk_gen <= '1';
						we2_sk_gen <= '1';
						addr1_sk_gen <= std_logic_vector(to_unsigned(i-2, 14));
						addr2_sk_gen <= std_logic_vector(to_unsigned(i+9934, 14));
						din1_sk_gen <= dout_rand_gen;
						din2_sk_gen <= dout_seed_gen;
						if (i = 10) then
							i <= 0;
							state <= s_done;
						end if;
					end if;

				elsif (state = s_done) then
					done <= '1';
					state <= s_reset;
				end if;
			end if;
		end if;
	end process;

end behave;