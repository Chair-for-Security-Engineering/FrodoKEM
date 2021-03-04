--Hash function SHAKE-128. Absrbing of the input can stop/resume in the middle 
--of a block

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity absorb_block is
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
end entity absorb_block;

architecture behave of absorb_block is

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

	type states is (s_reset, s_absorb, s_round, s_squeeze, s_done, read_inlen, s_rotate, s_pad);
	signal state : states := s_reset;
	type keccak_state is array(0 to 24) of std_logic_vector(63 downto 0);
	signal current_state : keccak_state := (others => (others => '0'));
	signal in_index, out_index, i, j, round_index, k, v, f : integer := 0;
	signal done_absorb : std_logic := '0';
	signal input_length : integer;
	signal temp : std_logic_vector(63 downto 0) := (others => '0');

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
	
	process (clk) is
		variable b, d : std_logic_vector(319 downto 0);
		variable RC : std_logic_vector(63 downto 0);
		variable s, t, a, c : std_logic_vector(1599 downto 0);
		variable x : std_logic_vector(63 downto 0) := (others => '0');
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= s_reset;
				temp <= (others => '0');
				i <= 0;
				f <= 0;
				k <= 0;
				v <= 0;
				in_index <= 0;
				x := (others => '0');
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

			elsif (enable = '1') then
				done <= '0';
				we_out <= '0';
				if (state = s_reset) then
					state <= read_inlen;
					in_index <= 0;
					out_index <= 0;
					k <= 0;
					j <= 0;
					done_absorb <= '0';
					temp <= (others => '0');

				elsif (state = read_inlen) then
					input_length <= inlen;
					state <= s_absorb;

				--Absorbing phase. Inputs are always absorbed into p0 and the state is
				--then rotated
				elsif (state = s_absorb) then
					state <= s_absorb;
					if (in_index < input_length) then
						--Absorb a maximum of 21 words
						if (f < 22) then
							addr1_in <= std_logic_vector(to_unsigned(k, 10));
							addr2_in <= std_logic_vector(to_unsigned(k+1, 10));
							j <= j + 1;
							k <= k + 2;
							if (j >= 2) then
								in_index <= in_index + 2;
								if (v = 0 or in_index = 0) then
									if (to_unsigned(j, 1)(0) = '0') then
										temp <= ((dout2_in(7 downto 0) & dout2_in(15 downto 8) & dout1_in(7 downto 0) & dout1_in(15 downto 8)) xor p0(31 downto  0)) & x"00000000";
									else
										temp <= ((dout2_in(7 downto 0) & dout2_in(15 downto 8) & dout1_in(7 downto 0) & dout1_in(15 downto 8)) xor p0(63 downto 32)) & temp(63 downto 32);
									end if;
								else
									if (to_unsigned(j, 1)(0) = '0') then
										temp <= ((dout2_in(7 downto 0) & dout2_in(15 downto 8) & dout1_in(7 downto 0) & dout1_in(15 downto 8)) xor p1(31 downto  0)) & x"00000000";
									else
										temp <= ((dout2_in(7 downto 0) & dout2_in(15 downto 8) & dout1_in(7 downto 0) & dout1_in(15 downto 8)) xor p0(63 downto 32)) & temp(63 downto 32);
									end if;
								end if;

								if (to_unsigned(j, 10)(0) = '1' and j > 2) then
									i <= i + 1;
									v <= v + 1;
									f <= f + 1;
								end if;

								if (to_unsigned(j, 10)(0) = '0' and j > 3) then
									p20 <= temp;
									p0 <= p1;
									p1 <= p2;
									p2 <= p3;
									p3 <= p4;
									p4 <= p5;
									p5 <= p6;
									p6 <= p7;
									p7 <= p8;
									p8 <= p9;
									p9 <= p10;
									p10 <= p11;
									p11 <= p12;
									p12 <= p13;
									p13 <= p14;
									p14 <= p15;
									p15 <= p16;
									p16 <= p17;
									p17 <= p18;
									p18 <= p19;
									p19 <= p20;
								end if;
							end if;
						--Permute the state when 21 words have been absorbed
						else
							state <= s_round;
							in_index <= in_index - 4;
							k <= k - 8;
							i <= 0;
							f <= 0;
							v <= 0;
							j <= 0;
						end if;
					--If all inputs have been absorbed:
					--	If squeezing is necessary: pad the input
					--  Else write the last input word to p0 and finish
					else
						if (outlen > 0) then
							state <= s_pad;
							done_absorb <= '1';
						else
							p20 <= temp;
							p0 <= p1;
							p1 <= p2;
							p2 <= p3;
							p3 <= p4;
							p4 <= p5;
							p5 <= p6;
							p6 <= p7;
							p7 <= p8;
							p8 <= p9;
							p9 <= p10;
							p10 <= p11;
							p11 <= p12;
							p12 <= p13;
							p13 <= p14;
							p14 <= p15;
							p15 <= p16;
							p16 <= p17;
							p17 <= p18;
							p18 <= p19;
							p19 <= p20;
							k <= k - 4;
							state <= s_done;
						end if;
					end if;

				--Apply the padding
				elsif (state = s_pad) then
					p20 <= temp;
					p0 <= p1 xor x"000000000000001F";
					p1 <= p2;
					p2 <= p3;
					p3 <= p4;
					p4 <= p5;
					p5 <= p6;
					p6 <= p7;
					p7 <= p8;
					p8 <= p9;
					p9 <= p10;
					p10 <= p11;
					p11 <= p12;
					p12 <= p13;
					p13 <= p14;
					p14 <= p15;
					p15 <= p16;
					p16 <= p17;
					p17 <= p18;
					p18 <= p19;
					p19 <= p20;
					state <= s_rotate;

				--Rotate the state until it is in the right position (maximum of 21 times)
				elsif (state = s_rotate) then
					if (i < 21) then
						p20 <= p0;
						p0 <= p1;
						p1 <= p2;
						p2 <= p3;
						p3 <= p4;
						p4 <= p5;
						p5 <= p6;
						p6 <= p7;
						p7 <= p8;
						p8 <= p9;
						p9 <= p10;
						p10 <= p11;
						p11 <= p12;
						p12 <= p13;
						p13 <= p14;
						p14 <= p15;
						p15 <= p16;
						p16 <= p17;
						p17 <= p18;
						p18 <= p19;
						p19 <= p20;
						i <= i + 1;
					else
						p20(63) <= p20(63) xor '1';
						state <= s_round;
						i <= 0;
						f <= 0;
						v <= 0;
					end if;

				--Round permutation
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

					round_index <= round_index + 1;

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

					--If input is done: start squeezing, else absorb more input
					if (round_index = 23) then
						round_index <= 0;
						if (done_absorb = '1') then
							state <= s_squeeze;
						else
							state <= s_absorb;
						end if;
					end if;

				--Squeeze the output
				elsif (state = s_squeeze) then
					state <= s_squeeze;
					if (out_index < outlen and i < 21) then
						addr_out <= std_logic_vector(to_unsigned(out_index, 3));
						out_index <= out_index + 1;
						we_out <= '1';
						case (to_unsigned(out_index, 2)) is
							when "00" => din_out <= pout(7 downto 0) & pout(15 downto 8);
							when "01" => din_out <= pout(23 downto 16) & pout(31 downto 24);
							when "10" => din_out <= pout(39 downto 32) & pout(47 downto 40);
							when "11" => din_out <= pout(55 downto 48) & pout(63 downto 56);
						end case;
						if (to_unsigned(out_index, 2) = "11") then
							i <= i + 1;
						end if;
					elsif (out_index = outlen) then
						state <= s_done;
						i <= 0;
					end if;

				elsif (state = s_done) then 
					done <= '1';
					state <= s_reset;

				end if;
			end if;
		end if;
	end process;
end behave;