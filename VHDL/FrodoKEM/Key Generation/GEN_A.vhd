--Generate one row of A based on a seed using SHAKE

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_a is
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
end entity gen_a;

architecture behave of gen_a is

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

	type states is (s_reset, s_absorb, s_squeeze, s_round, s_done);
	signal state : states;

	signal index : integer := 0;
	signal temp : std_logic_vector(63 downto 0) := (others => '0');
	signal i : integer := 0;
	signal done_absorb, done_squeeze : std_logic := '0';
	signal round_index : integer := 0;
	signal current_word : std_logic_vector(63 downto 0) := (others => '0');

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

	current_word <= pout;
	i_vector <= std_logic_vector(to_unsigned(i, 5));

	process (clk) is
		variable x : std_logic_vector(63 downto 0) := (others => '0');
		variable b, d : std_logic_vector(319 downto 0);
		variable rc : std_logic_vector(63 downto 0);
		variable s, t, a, c : std_logic_vector(1599 downto 0);

	begin
		if rising_edge(clk) then
			done <= '0';
			if (reset = '1') then
				state <= s_reset;
				done <= '0';
			elsif (enable = '1') then
				done <= '0';
				we1_a <= '0';
				we2_a <= '0';

				if (state = s_reset) then
					done <= '0';
					state <= s_absorb;
					addr1_a <= (others => '0');
					addr2_a <= (others => '0');
					index <= 0;
					done_squeeze <= '0';
					i <= 0;
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
					p0 <= seed_A(95 downto 80) & seed_A(111 downto 96) & seed_A(127 downto 112) & seed_A(143 downto 128);
					p1 <= seed_A(31 downto 16) & seed_A(47 downto 32) & seed_A(63 downto 48) & seed_A(79 downto 64);
					p2 <= p2(63 downto 24) & x"1F" & seed_A(15 downto 0);
					p20(63) <= '1';
					state <= s_round;

				elsif (state = s_round) then
					c := p0 & p1 & p2 & p3 & p4 & p5 & p6 & p7 & p8 & p9 & p10 & p11 & p12 & p13 & p14 &
						 p15 & p16 & p17 & p18 & p19 & p20 & p21 & p22 & p23 & p24;	

					b := c(1599 DOWNTO 1280) XOR c(1279 DOWNTO 960) XOR c(959 DOWNTO 640) XOR c(639 DOWNTO 320) XOR c(319 DOWNTO 0);

					d(319 downto 256) := b( 63 downto   0) xor std_logic_vector(rotate_left(unsigned(b(255 downto 192)), 1));
					d(255 downto 192) := b(319 downto 256) xor std_logic_vector(rotate_left(unsigned(b(191 downto 128)), 1));
					d(191 downto 128) := b(255 downto 192) xor std_logic_vector(rotate_left(unsigned(b(127 downto  64)), 1));
					d(127 downto  64) := b(191 downto 128) xor std_logic_vector(rotate_left(unsigned(b( 63 downto   0)), 1));
					d( 63 downto   0) := b(127 downto  64) xor std_logic_vector(rotate_left(unsigned(b(319 downto 256)), 1));

					s(1599 DOWNTO 1536) := c(1599 DOWNTO 1536) xor d(319 downto 256);
					s(1535 DOWNTO 1472) := c(1535 DOWNTO 1472) xor d(255 downto 192);
					s(1471 DOWNTO 1408) := c(1471 DOWNTO 1408) xor d(191 downto 128);
					s(1407 DOWNTO 1344) := c(1407 DOWNTO 1344) xor d(127 downto  64);
					s(1343 DOWNTO 1280) := c(1343 DOWNTO 1280) xor d( 63 downto   0);
					s(1279 DOWNTO 1216) := c(1279 DOWNTO 1216) xor d(319 downto 256);
					s(1215 DOWNTO 1152) := c(1215 DOWNTO 1152) xor d(255 downto 192);
					s(1151 DOWNTO 1088) := c(1151 DOWNTO 1088) xor d(191 downto 128);
					s(1087 DOWNTO 1024) := c(1087 DOWNTO 1024) xor d(127 downto  64);
					s(1023 DOWNTO  960) := c(1023 DOWNTO  960) xor d( 63 downto   0);
					s( 959 DOWNTO  896) := c( 959 DOWNTO  896) xor d(319 downto 256);
					s( 895 DOWNTO  832) := c( 895 DOWNTO  832) xor d(255 downto 192);
					s( 831 DOWNTO  768) := c( 831 DOWNTO  768) xor d(191 downto 128);
					s( 767 DOWNTO  704) := c( 767 DOWNTO  704) xor d(127 downto  64);
					s( 703 DOWNTO  640) := c( 703 DOWNTO  640) xor d( 63 downto   0);
					s( 639 DOWNTO  576) := c( 639 DOWNTO  576) xor d(319 downto 256);
					s( 575 DOWNTO  512) := c( 575 DOWNTO  512) xor d(255 downto 192);
					s( 511 DOWNTO  448) := c( 511 DOWNTO  448) xor d(191 downto 128);
					s( 447 DOWNTO  384) := c( 447 DOWNTO  384) xor d(127 downto  64);
					s( 383 DOWNTO  320) := c( 383 DOWNTO  320) xor d( 63 downto   0);
					s( 319 DOWNTO  256) := c( 319 DOWNTO  256) xor d(319 downto 256);
					s( 255 DOWNTO  192) := c( 255 DOWNTO  192) xor d(255 downto 192);
					s( 191 DOWNTO  128) := c( 191 DOWNTO  128) xor d(191 downto 128);
					s( 127 DOWNTO   64) := c( 127 DOWNTO   64) xor d(127 downto  64);
					s(  63 DOWNTO    0) := c(  63 DOWNTO    0) xor d( 63 downto   0);

					t(1599 DOWNTO 1536) := std_logic_vector(rotate_left(unsigned(s(1599 DOWNTO 1536)),  0));
					t(1535 DOWNTO 1472) := std_logic_vector(rotate_left(unsigned(s(1215 DOWNTO 1152)), 44));
					t(1471 DOWNTO 1408) := std_logic_vector(rotate_left(unsigned(s( 831 DOWNTO  768)), 43));
					t(1407 DOWNTO 1344) := std_logic_vector(rotate_left(unsigned(s( 447 DOWNTO  384)), 21));
					t(1343 DOWNTO 1280) := std_logic_vector(rotate_left(unsigned(s(  63 DOWNTO    0)), 14));
					t(1279 DOWNTO 1216) := std_logic_vector(rotate_left(unsigned(s(1407 DOWNTO 1344)), 28));
					t(1215 DOWNTO 1152) := std_logic_vector(rotate_left(unsigned(s(1023 DOWNTO  960)), 20));
					t(1151 DOWNTO 1088) := std_logic_vector(rotate_left(unsigned(s( 959 DOWNTO  896)),  3));
					t(1087 DOWNTO 1024) := std_logic_vector(rotate_left(unsigned(s( 575 DOWNTO  512)), 45));
					t(1023 DOWNTO  960) := std_logic_vector(rotate_left(unsigned(s( 191 DOWNTO  128)), 61));
					t( 959 DOWNTO  896) := std_logic_vector(rotate_left(unsigned(s(1535 DOWNTO 1472)),  1));
					t( 895 DOWNTO  832) := std_logic_vector(rotate_left(unsigned(s(1151 DOWNTO 1088)),  6));
					t( 831 DOWNTO  768) := std_logic_vector(rotate_left(unsigned(s( 767 DOWNTO  704)), 25));
					t( 767 DOWNTO  704) := std_logic_vector(rotate_left(unsigned(s( 383 DOWNTO  320)),  8));
					t( 703 DOWNTO  640) := std_logic_vector(rotate_left(unsigned(s( 319 DOWNTO  256)), 18));
					t( 639 DOWNTO  576) := std_logic_vector(rotate_left(unsigned(s(1343 DOWNTO 1280)), 27));
					t( 575 DOWNTO  512) := std_logic_vector(rotate_left(unsigned(s(1279 DOWNTO 1216)), 36));
					t( 511 DOWNTO  448) := std_logic_vector(rotate_left(unsigned(s( 895 DOWNTO  832)), 10));
					t( 447 DOWNTO  384) := std_logic_vector(rotate_left(unsigned(s( 511 DOWNTO  448)), 15));
					t( 383 DOWNTO  320) := std_logic_vector(rotate_left(unsigned(s( 127 DOWNTO   64)), 56));
					t( 319 DOWNTO  256) := std_logic_vector(rotate_left(unsigned(s(1471 DOWNTO 1408)), 62));
					t( 255 DOWNTO  192) := std_logic_vector(rotate_left(unsigned(s(1087 DOWNTO 1024)), 55));
					t( 191 DOWNTO  128) := std_logic_vector(rotate_left(unsigned(s( 703 DOWNTO  640)), 39));
					t( 127 DOWNTO   64) := std_logic_vector(rotate_left(unsigned(s( 639 DOWNTO  576)), 41));
					t(  63 DOWNTO    0) := std_logic_vector(rotate_left(unsigned(s( 255 DOWNTO  192)),  2));

					a(1599 DOWNTO 1536) := t(1599 DOWNTO 1536) xor ((not(t(1535 DOWNTO 1472))) and t(1471 DOWNTO 1408));
					a(1535 DOWNTO 1472) := t(1535 DOWNTO 1472) xor ((not(t(1471 DOWNTO 1408))) and t(1407 DOWNTO 1344));
					a(1471 DOWNTO 1408) := t(1471 DOWNTO 1408) xor ((not(t(1407 DOWNTO 1344))) and t(1343 DOWNTO 1280));
					a(1407 DOWNTO 1344) := t(1407 DOWNTO 1344) xor ((not(t(1343 DOWNTO 1280))) and t(1599 DOWNTO 1536));
					a(1343 DOWNTO 1280) := t(1343 DOWNTO 1280) xor ((not(t(1599 DOWNTO 1536))) and t(1535 DOWNTO 1472));
					a(1279 DOWNTO 1216) := t(1279 DOWNTO 1216) xor ((not(t(1215 DOWNTO 1152))) and t(1151 DOWNTO 1088));
					a(1215 DOWNTO 1152) := t(1215 DOWNTO 1152) xor ((not(t(1151 DOWNTO 1088))) and t(1087 DOWNTO 1024));
					a(1151 DOWNTO 1088) := t(1151 DOWNTO 1088) xor ((not(t(1087 DOWNTO 1024))) and t(1023 DOWNTO  960));
					a(1087 DOWNTO 1024) := t(1087 DOWNTO 1024) xor ((not(t(1023 DOWNTO  960))) and t(1279 DOWNTO 1216));
					a(1023 DOWNTO  960) := t(1023 DOWNTO  960) xor ((not(t(1279 DOWNTO 1216))) and t(1215 DOWNTO 1152));
					a( 959 DOWNTO  896) := t( 959 DOWNTO  896) xor ((not(t( 895 DOWNTO  832))) and t( 831 DOWNTO  768));
					a( 895 DOWNTO  832) := t( 895 DOWNTO  832) xor ((not(t( 831 DOWNTO  768))) and t( 767 DOWNTO  704));
					a( 831 DOWNTO  768) := t( 831 DOWNTO  768) xor ((not(t( 767 DOWNTO  704))) and t( 703 DOWNTO  640));
					a( 767 DOWNTO  704) := t( 767 DOWNTO  704) xor ((not(t( 703 DOWNTO  640))) and t( 959 DOWNTO  896));
					a( 703 DOWNTO  640) := t( 703 DOWNTO  640) xor ((not(t( 959 DOWNTO  896))) and t( 895 DOWNTO  832));
					a( 639 DOWNTO  576) := t( 639 DOWNTO  576) xor ((not(t( 575 DOWNTO  512))) and t( 511 DOWNTO  448));
					a( 575 DOWNTO  512) := t( 575 DOWNTO  512) xor ((not(t( 511 DOWNTO  448))) and t( 447 DOWNTO  384));
					a( 511 DOWNTO  448) := t( 511 DOWNTO  448) xor ((not(t( 447 DOWNTO  384))) and t( 383 DOWNTO  320));
					a( 447 DOWNTO  384) := t( 447 DOWNTO  384) xor ((not(t( 383 DOWNTO  320))) and t( 639 DOWNTO  576));
					a( 383 DOWNTO  320) := t( 383 DOWNTO  320) xor ((not(t( 639 DOWNTO  576))) and t( 575 DOWNTO  512));
					a( 319 DOWNTO  256) := t( 319 DOWNTO  256) xor ((not(t( 255 DOWNTO  192))) and t( 191 DOWNTO  128));
					a( 255 DOWNTO  192) := t( 255 DOWNTO  192) xor ((not(t( 191 DOWNTO  128))) and t( 127 DOWNTO   64));
					a( 191 DOWNTO  128) := t( 191 DOWNTO  128) xor ((not(t( 127 DOWNTO   64))) and t(  63 DOWNTO    0));
					a( 127 DOWNTO   64) := t( 127 DOWNTO   64) xor ((not(t(  63 DOWNTO    0))) and t( 319 DOWNTO  256));
					a(  63 DOWNTO    0) := t(  63 DOWNTO    0) xor ((not(t( 319 DOWNTO  256))) and t( 255 DOWNTO  192));

					case ROUND_INDEX is				
						when  0 => RC := X"0000000000000001";
						when  1 => RC := X"0000000000008082";
						when  2 => RC := X"800000000000808A";
						when  3 => RC := X"8000000080008000";
						when  4 => RC := X"000000000000808B";
						when  5 => RC := X"0000000080000001";
						when  6 => RC := X"8000000080008081";
						when  7 => RC := X"8000000000008009";
						when  8 => RC := X"000000000000008A";
						when  9 => RC := X"0000000000000088";
						when 10 => RC := X"0000000080008009";
						when 11 => RC := X"000000008000000A";
						when 12 => RC := X"000000008000808B";
						when 13 => RC := X"800000000000008B";
						when 14 => RC := X"8000000000008089";
						when 15 => RC := X"8000000000008003";
						when 16 => RC := X"8000000000008002";
						when 17 => RC := X"8000000000000080";
						when 18 => RC := X"000000000000800A";
						when 19 => RC := X"800000008000000A";
						when 20 => RC := X"8000000080008081";
						when 21 => RC := X"8000000000008080";
						when 22 => RC := X"0000000080000001";
						when 23 => RC := X"8000000080008008";
						when others => RC := X"0000000000000000";
					end case ;

					--a(1599 DOWNTO 1536) := a(1599 DOWNTO 1536) XOR RC;
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
					we1_a <= '1';
					we2_a <= '1';
					if (index < 640) then
						addr1_a <= std_logic_vector(to_unsigned(index, 10));
						addr2_a <= std_logic_vector(to_unsigned(index+1, 10));
						index <= index + 2;
						if ((to_unsigned(index, 10)(1 downto 0) = "10")) then
							i <= i + 1;
							if (i = 20) then
								state <= s_round;
								i <= 0;
							end if;
						end if;
						if ((to_unsigned(index, 10)(1 downto 0) = "00")) then
							din1_a <= pout(15 downto 0);
							din2_a <= pout(31 downto 16);
						else
							din1_a <= pout(47 downto 32);
							din2_a <= pout(63 downto 48);
						end if;
					else
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