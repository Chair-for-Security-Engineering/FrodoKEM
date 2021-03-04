--Generation of S and E with SHAKE and a discrete Gaussian sampler

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shake_gen_SE is
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
end entity shake_gen_SE;

architecture behave of shake_gen_SE is
	
	component sample is
		port (
			clk : in std_logic;
			data_in : in std_logic_vector(15 downto 0);
			data_in2 : in std_logic_vector(15 downto 0);
			data_out : out std_logic_vector(15 downto 0);
			data_out2 : out std_logic_vector(15 downto 0)
		);
	end component sample;

	component gen_a_mux is
		port(
			d0  : in std_logic_vector(63 downto 0);
			d1  : in std_logic_vector(63 downto 0);
			d2  : in std_logic_vector(63 downto 0);
			d3  : in std_logic_vector(63 downto 0);
			d4  : in std_logic_vector(63 downto 0);
			d5  : in std_logic_vector(63 downto 0);
			d6  : in std_logic_vector(63 downto 0);
			d7  : in std_logic_vector(63 downto 0);
			d8  : in std_logic_vector(63 downto 0);
			d9  : in std_logic_vector(63 downto 0);
			d10 : in std_logic_vector(63 downto 0);
			d11 : in std_logic_vector(63 downto 0);
			d12 : in std_logic_vector(63 downto 0);
			d13 : in std_logic_vector(63 downto 0);
			d14 : in std_logic_vector(63 downto 0);
			d15 : in std_logic_vector(63 downto 0);
			d16 : in std_logic_vector(63 downto 0);
			d17 : in std_logic_vector(63 downto 0);
			d18 : in std_logic_vector(63 downto 0);
			d19 : in std_logic_vector(63 downto 0);
			d20 : in std_logic_vector(63 downto 0);
			d21 : in std_logic_vector(63 downto 0);
			d22 : in std_logic_vector(63 downto 0);
			d23 : in std_logic_vector(63 downto 0);
			d24 : in std_logic_vector(63 downto 0);
			index : in std_logic_vector(4 downto 0);
			dout : out std_logic_vector(63 downto 0)
		);
	end component;

	type states is (s_reset, s_absorb, s_round, s_squeeze, s_done);
	signal state : states := s_reset;
	signal in_index, out_index_s, out_index_e, index : integer := 0;
	signal round_index : integer := 0;
	signal i, j : integer := 0;
	signal word_counter : integer := 0;
	signal current_word : std_logic_vector(63 downto 0) := (others => '0');
	signal temp1, temp2 : std_logic_vector(15 downto 0);
	signal sample1, sample2 : std_logic_vector(15 downto 0);
	signal words_done : integer := 0;

	signal p0  : std_logic_vector(63 downto 0) := (others => '0');
	signal p1  : std_logic_vector(63 downto 0) := (others => '0');
	signal p2  : std_logic_vector(63 downto 0) := (others => '0');
	signal p3  : std_logic_vector(63 downto 0) := (others => '0');
	signal p4  : std_logic_vector(63 downto 0) := (others => '0');
	signal p5  : std_logic_vector(63 downto 0) := (others => '0');
	signal p6  : std_logic_vector(63 downto 0) := (others => '0');
	signal p7  : std_logic_vector(63 downto 0) := (others => '0');
	signal p8  : std_logic_vector(63 downto 0) := (others => '0');
	signal p9  : std_logic_vector(63 downto 0) := (others => '0');
	signal p10 : std_logic_vector(63 downto 0) := (others => '0');
	signal p11 : std_logic_vector(63 downto 0) := (others => '0');
	signal p12 : std_logic_vector(63 downto 0) := (others => '0');
	signal p13 : std_logic_vector(63 downto 0) := (others => '0');
	signal p14 : std_logic_vector(63 downto 0) := (others => '0');
	signal p15 : std_logic_vector(63 downto 0) := (others => '0');
	signal p16 : std_logic_vector(63 downto 0) := (others => '0');
	signal p17 : std_logic_vector(63 downto 0) := (others => '0');
	signal p18 : std_logic_vector(63 downto 0) := (others => '0');
	signal p19 : std_logic_vector(63 downto 0) := (others => '0');
	signal p20 : std_logic_vector(63 downto 0) := (others => '0');
	signal p21 : std_logic_vector(63 downto 0) := (others => '0');
	signal p22 : std_logic_vector(63 downto 0) := (others => '0');
	signal p23 : std_logic_vector(63 downto 0) := (others => '0');
	signal p24 : std_logic_vector(63 downto 0) := (others => '0');
	signal pout : std_logic_vector(63 downto 0) := (others => '0');
	signal i_vector : std_logic_vector(4 downto 0) := (others => '0');

begin

	sampler : sample
	port map(
		clk => clk,
		data_in => temp1,
		data_in2 => temp2,
		data_out => sample1,
		data_out2 => sample2
	);

	multiplexer : gen_a_mux
	port map(
		d0  => p0,
		d1  => p1,
		d2  => p2,
		d3  => p3,
		d4  => p4,
		d5  => p5,
		d6  => p6,
		d7  => p7,
		d8  => p8,
		d9  => p9,
		d10 => p10,
		d11 => p11,
		d12 => p12,
		d13 => p13,
		d14 => p14,
		d15 => p15,
		d16 => p16,
		d17 => p17,
		d18 => p18,
		d19 => p19,
		d20 => p20,
		d21 => p21,
		d22 => p22,
		d23 => p23,
		d24 => p24,
		index => i_vector,
		dout => pout
	);

	i_vector <= std_logic_vector(to_unsigned(i, 5));

	din1_s <= sample1;
	din2_s <= sample2;
	din1_e <= sample1;
	din2_e <= sample2;

	process (clk) is
		variable b, d : std_logic_vector(319 downto 0);
		variable RC : std_logic_vector(63 downto 0);
		variable s, t, a, c : std_logic_vector(1599 downto 0);
		variable x : std_logic_vector(63 downto 0);
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= s_reset;
			elsif (enable = '1') then
				we1_s <= '0';
				we2_s <= '0';
				we1_e <= '0';
				we2_e <= '0';
				done <= '0';

				if (state = s_reset) then
					state <= s_absorb;
					in_index <= 0;
					out_index_s <= 0;
					out_index_e <= 0;
					index <= 0;
					round_index <= 0;
					i <= 0;
					j <= 0;
					word_counter <= 0;
					words_done <= 0;
					p0  <= (others => '0');
					p1  <= (others => '0');
					p2  <= (others => '0');
					p3  <= (others => '0');
					p4  <= (others => '0');
					p5  <= (others => '0');
					p6  <= (others => '0');
					p7  <= (others => '0');
					p8  <= (others => '0');
					p9  <= (others => '0');
					p10 <= (others => '0');
					p11 <= (others => '0');
					p12 <= (others => '0');
					p13 <= (others => '0');
					p14 <= (others => '0');
					p15 <= (others => '0');
					p16 <= (others => '0');
					p17 <= (others => '0');
					p18 <= (others => '0');
					p19 <= (others => '0');
					p20 <= (others => '0');
					p21 <= (others => '0');
					p22 <= (others => '0');
					p23 <= (others => '0');
					p24 <= (others => '0');

				elsif (state = s_absorb) then
					p0 <= seed_SE(143 downto 128) & seed_SE(159 downto 144) & seed_SE(175 downto 160) & seed_SE(191 downto 176);
					p1 <= seed_SE( 79 downto  64) & seed_SE( 95 downto  80) & seed_SE(111 downto  96) & seed_SE(127 downto 112);
					p2 <= seed_SE( 15 downto   0) & seed_SE( 31 downto  16) & seed_SE( 47 downto  32) & seed_SE( 63 downto  48);
					p20(63) <= '1';
					state <= s_round;

				elsif (state = s_round) then

					c := p0 & p1 & p2 & p3 & p4 & p5 & p6 & p7 & p8 & p9 & p10 & p11 & p12 & p13 & p14 &
						 p15 & p16 & p17 & p18 & p19 & p20 & p21 & p22 & p23 & p24;
										
					b := c(1599 downto 1280) xor c(1279 downto 960) xor c(959 downto 640) xor c(639 downto 320) xor c(319 downto 0);

					d(319 downto 256) := b( 63 downto   0) xor std_logic_vector(rotate_left(unsigned(b(255 downto 192)), 1));
					d(255 downto 192) := b(319 downto 256) xor std_logic_vector(rotate_left(unsigned(b(191 downto 128)), 1));
					d(191 downto 128) := b(255 downto 192) xor std_logic_vector(rotate_left(unsigned(b(127 downto  64)), 1));
					d(127 downto  64) := b(191 downto 128) xor std_logic_vector(rotate_left(unsigned(b( 63 downto   0)), 1));
					d( 63 downto   0) := b(127 downto  64) xor std_logic_vector(rotate_left(unsigned(b(319 downto 256)), 1));

					s(1599 downto 1536) := c(1599 downto 1536) xor d(319 downto 256);
					s(1535 downto 1472) := c(1535 downto 1472) xor d(255 downto 192);
					s(1471 downto 1408) := c(1471 downto 1408) xor d(191 downto 128);
					s(1407 downto 1344) := c(1407 downto 1344) xor d(127 downto  64);
					s(1343 downto 1280) := c(1343 downto 1280) xor d( 63 downto   0);
					s(1279 downto 1216) := c(1279 downto 1216) xor d(319 downto 256);
					s(1215 downto 1152) := c(1215 downto 1152) xor d(255 downto 192);
					s(1151 downto 1088) := c(1151 downto 1088) xor d(191 downto 128);
					s(1087 downto 1024) := c(1087 downto 1024) xor d(127 downto  64);
					s(1023 downto  960) := c(1023 downto  960) xor d( 63 downto   0);
					s( 959 downto  896) := c( 959 downto  896) xor d(319 downto 256);
					s( 895 downto  832) := c( 895 downto  832) xor d(255 downto 192);
					s( 831 downto  768) := c( 831 downto  768) xor d(191 downto 128);
					s( 767 downto  704) := c( 767 downto  704) xor d(127 downto  64);
					s( 703 downto  640) := c( 703 downto  640) xor d( 63 downto   0);
					s( 639 downto  576) := c( 639 downto  576) xor d(319 downto 256);
					s( 575 downto  512) := c( 575 downto  512) xor d(255 downto 192);
					s( 511 downto  448) := c( 511 downto  448) xor d(191 downto 128);
					s( 447 downto  384) := c( 447 downto  384) xor d(127 downto  64);
					s( 383 downto  320) := c( 383 downto  320) xor d( 63 downto   0);
					s( 319 downto  256) := c( 319 downto  256) xor d(319 downto 256);
					s( 255 downto  192) := c( 255 downto  192) xor d(255 downto 192);
					s( 191 downto  128) := c( 191 downto  128) xor d(191 downto 128);
					s( 127 downto   64) := c( 127 downto   64) xor d(127 downto  64);
					s(  63 downto    0) := c(  63 downto    0) xor d( 63 downto   0);

					t(1599 downto 1536) := std_logic_vector(rotate_left(unsigned(s(1599 downto 1536)),  0));
					t(1535 downto 1472) := std_logic_vector(rotate_left(unsigned(s(1215 downto 1152)), 44));
					t(1471 downto 1408) := std_logic_vector(rotate_left(unsigned(s( 831 downto  768)), 43));
					t(1407 downto 1344) := std_logic_vector(rotate_left(unsigned(s( 447 downto  384)), 21));
					t(1343 downto 1280) := std_logic_vector(rotate_left(unsigned(s(  63 downto    0)), 14));
					t(1279 downto 1216) := std_logic_vector(rotate_left(unsigned(s(1407 downto 1344)), 28));
					t(1215 downto 1152) := std_logic_vector(rotate_left(unsigned(s(1023 downto  960)), 20));
					t(1151 downto 1088) := std_logic_vector(rotate_left(unsigned(s( 959 downto  896)),  3));
					t(1087 downto 1024) := std_logic_vector(rotate_left(unsigned(s( 575 downto  512)), 45));
					t(1023 downto  960) := std_logic_vector(rotate_left(unsigned(s( 191 downto  128)), 61));
					t( 959 downto  896) := std_logic_vector(rotate_left(unsigned(s(1535 downto 1472)),  1));
					t( 895 downto  832) := std_logic_vector(rotate_left(unsigned(s(1151 downto 1088)),  6));
					t( 831 downto  768) := std_logic_vector(rotate_left(unsigned(s( 767 downto  704)), 25));
					t( 767 downto  704) := std_logic_vector(rotate_left(unsigned(s( 383 downto  320)),  8));
					t( 703 downto  640) := std_logic_vector(rotate_left(unsigned(s( 319 downto  256)), 18));
					t( 639 downto  576) := std_logic_vector(rotate_left(unsigned(s(1343 downto 1280)), 27));
					t( 575 downto  512) := std_logic_vector(rotate_left(unsigned(s(1279 downto 1216)), 36));
					t( 511 downto  448) := std_logic_vector(rotate_left(unsigned(s( 895 downto  832)), 10));
					t( 447 downto  384) := std_logic_vector(rotate_left(unsigned(s( 511 downto  448)), 15));
					t( 383 downto  320) := std_logic_vector(rotate_left(unsigned(s( 127 downto   64)), 56));
					t( 319 downto  256) := std_logic_vector(rotate_left(unsigned(s(1471 downto 1408)), 62));
					t( 255 downto  192) := std_logic_vector(rotate_left(unsigned(s(1087 downto 1024)), 55));
					t( 191 downto  128) := std_logic_vector(rotate_left(unsigned(s( 703 downto  640)), 39));
					t( 127 downto   64) := std_logic_vector(rotate_left(unsigned(s( 639 downto  576)), 41));
					t(  63 downto    0) := std_logic_vector(rotate_left(unsigned(s( 255 downto  192)),  2));

					a(1599 downto 1536) := t(1599 downto 1536) xor ((not(t(1535 downto 1472))) and t(1471 downto 1408));
					a(1535 downto 1472) := t(1535 downto 1472) xor ((not(t(1471 downto 1408))) and t(1407 downto 1344));
					a(1471 downto 1408) := t(1471 downto 1408) xor ((not(t(1407 downto 1344))) and t(1343 downto 1280));
					a(1407 downto 1344) := t(1407 downto 1344) xor ((not(t(1343 downto 1280))) and t(1599 downto 1536));
					a(1343 downto 1280) := t(1343 downto 1280) xor ((not(t(1599 downto 1536))) and t(1535 downto 1472));
					a(1279 downto 1216) := t(1279 downto 1216) xor ((not(t(1215 downto 1152))) and t(1151 downto 1088));
					a(1215 downto 1152) := t(1215 downto 1152) xor ((not(t(1151 downto 1088))) and t(1087 downto 1024));
					a(1151 downto 1088) := t(1151 downto 1088) xor ((not(t(1087 downto 1024))) and t(1023 downto  960));
					a(1087 downto 1024) := t(1087 downto 1024) xor ((not(t(1023 downto  960))) and t(1279 downto 1216));
					a(1023 downto  960) := t(1023 downto  960) xor ((not(t(1279 downto 1216))) and t(1215 downto 1152));
					a( 959 downto  896) := t( 959 downto  896) xor ((not(t( 895 downto  832))) and t( 831 downto  768));
					a( 895 downto  832) := t( 895 downto  832) xor ((not(t( 831 downto  768))) and t( 767 downto  704));
					a( 831 downto  768) := t( 831 downto  768) xor ((not(t( 767 downto  704))) and t( 703 downto  640));
					a( 767 downto  704) := t( 767 downto  704) xor ((not(t( 703 downto  640))) and t( 959 downto  896));
					a( 703 downto  640) := t( 703 downto  640) xor ((not(t( 959 downto  896))) and t( 895 downto  832));
					a( 639 downto  576) := t( 639 downto  576) xor ((not(t( 575 downto  512))) and t( 511 downto  448));
					a( 575 downto  512) := t( 575 downto  512) xor ((not(t( 511 downto  448))) and t( 447 downto  384));
					a( 511 downto  448) := t( 511 downto  448) xor ((not(t( 447 downto  384))) and t( 383 downto  320));
					a( 447 downto  384) := t( 447 downto  384) xor ((not(t( 383 downto  320))) and t( 639 downto  576));
					a( 383 downto  320) := t( 383 downto  320) xor ((not(t( 639 downto  576))) and t( 575 downto  512));
					a( 319 downto  256) := t( 319 downto  256) xor ((not(t( 255 downto  192))) and t( 191 downto  128));
					a( 255 downto  192) := t( 255 downto  192) xor ((not(t( 191 downto  128))) and t( 127 downto   64));
					a( 191 downto  128) := t( 191 downto  128) xor ((not(t( 127 downto   64))) and t(  63 downto    0));
					a( 127 downto   64) := t( 127 downto   64) xor ((not(t(  63 downto    0))) and t( 319 downto  256));
					a(  63 downto    0) := t(  63 downto    0) xor ((not(t( 319 downto  256))) and t( 255 downto  192));

					case round_index is				
						when  0 => rc := x"0000000000000001";
						when  1 => rc := x"0000000000008082";
						when  2 => rc := x"800000000000808a";
						when  3 => rc := x"8000000080008000";
						when  4 => rc := x"000000000000808b";
						when  5 => rc := x"0000000080000001";
						when  6 => rc := x"8000000080008081";
						when  7 => rc := x"8000000000008009";
						when  8 => rc := x"000000000000008a";
						when  9 => rc := x"0000000000000088";
						when 10 => rc := x"0000000080008009";
						when 11 => rc := x"000000008000000a";
						when 12 => rc := x"000000008000808b";
						when 13 => rc := x"800000000000008b";
						when 14 => rc := x"8000000000008089";
						when 15 => rc := x"8000000000008003";
						when 16 => rc := x"8000000000008002";
						when 17 => rc := x"8000000000000080";
						when 18 => rc := x"000000000000800a";
						when 19 => rc := x"800000008000000a";
						when 20 => rc := x"8000000080008081";
						when 21 => rc := x"8000000000008080";
						when 22 => rc := x"0000000080000001";
						when 23 => rc := x"8000000080008008";
						when others => rc := x"0000000000000000";
					end case ;

					p0  <= a(1599 downto 1536) xor RC;
					p1  <= a(1535 downto 1472);
					p2  <= a(1471 downto 1408);
					p3  <= a(1407 downto 1344);
					p4  <= a(1343 downto 1280);
					p5  <= a(1279 downto 1216);
					p6  <= a(1215 downto 1152);
					p7  <= a(1151 downto 1088);
					p8  <= a(1087 downto 1024);
					p9  <= a(1023 downto  960);
					p10 <= a( 959 downto  896);
					p11 <= a( 895 downto  832);
					p12 <= a( 831 downto  768);
					p13 <= a( 767 downto  704);
					p14 <= a( 703 downto  640);
					p15 <= a( 639 downto  576);
					p16 <= a( 575 downto  512);
					p17 <= a( 511 downto  448);
					p18 <= a( 447 downto  384);
					p19 <= a( 383 downto  320);
					p20 <= a( 319 downto  256);
					p21 <= a( 255 downto  192);
					p22 <= a( 191 downto  128);
					p23 <= a( 127 downto   64);
					p24 <= a(  63 downto    0);
					round_index <= round_index + 1;

					if (round_index = 23) then
						state <= s_squeeze;
						round_index <= 0;
					end if;

				elsif (state = s_squeeze) then
					if (to_unsigned(index, 10)(1 downto 0) = "00") then
						temp1 <= pout(15 downto 0);
						temp2 <= pout(31 downto 16);
					else
						temp1 <= pout(47 downto 32);
						temp2 <= pout(63 downto 48);
					end if;

					state <= s_squeeze;
					we1_s <= '0';
					we2_s <= '0';
					we1_e <= '0';
					we2_e <= '0';
					index <= index + 2;
					if (to_unsigned(index, 10)(1 downto 0) = "10") then
						i <= i + 1;
					end if;
					if (index >= 2) then
						if ((out_index_s < length1 or out_index_e < length2) and j < 42) then
							word_counter <= word_counter + 1;
							j <= j + 1;
							if (word_counter >= low1 and word_counter <= high1 and out_index_s <= length1-2) then
								out_index_s <= out_index_s + 2;
								words_done <= words_done + 2;
								we1_s <= '1';
								we2_s <= '1';
								addr1_s <= std_logic_vector(to_unsigned(out_index_s, 10));
								addr2_s <= std_logic_vector(to_unsigned(out_index_s+1, 10));
							elsif (word_counter >= low2 and word_counter <= high2 and out_index_e <= length2-2) then
								out_index_e <= out_index_e + 2;
								words_done <= words_done + 2;
								we1_e <= '1';
								we2_e <= '1';
								addr1_e <= std_logic_vector(to_unsigned(out_index_e, 10));
								addr2_e <= std_logic_vector(to_unsigned(out_index_e+1, 10));
							end if;
						elsif (j = 42) then
							j <= 0;
							i <= 0;
							state <= s_round;
							index <= 0;
						elsif ((out_index_s = length1 and out_index_e = length2)) then
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


end architecture behave;