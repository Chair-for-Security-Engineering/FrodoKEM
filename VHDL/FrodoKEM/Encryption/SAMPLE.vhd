--Sampling from a discrete Gaussian distribution using a large amount of comparators

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sample is
	port(
		clk : in std_logic;
		data_in : in std_logic_vector(15 downto 0);
		data_in2 : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0);
		data_out2 : out std_logic_vector(15 downto 0)
	);
end entity sample;

architecture behave of sample is

	type states is (s_reset, s_sample, s_done);
	signal state : states := s_reset;
	signal sign_a, sign_a_2 : std_logic;
	signal prnd_a, prnd_a_2 : std_logic_vector(14 downto 0);
	signal i : integer := 0;

begin
	sign_a <= data_in(0);
	prnd_a <= data_in(15 downto 1);
	sign_a_2 <= data_in2(0);
	prnd_a_2 <= data_in2(15 downto 1);

	process (clk) is
		variable sample_a : integer;
		variable sample_a_2 : integer;
	begin
		if (rising_edge(clk)) then
			if (sign_a = '0') then
				if (to_integer(unsigned(prnd_a)) > 32766) then
					data_out <= std_logic_vector(to_unsigned(12, 16));
				elsif (to_integer(unsigned(prnd_a)) > 32762) then
					data_out <= std_logic_vector(to_unsigned(11, 16));
				elsif (to_integer(unsigned(prnd_a)) > 32745) then
					data_out <= std_logic_vector(to_unsigned(10, 16));
				elsif (to_integer(unsigned(prnd_a)) > 32689) then
					data_out <= std_logic_vector(to_unsigned(9, 16));
				elsif (to_integer(unsigned(prnd_a)) > 32525) then
					data_out <= std_logic_vector(to_unsigned(8, 16));
				elsif (to_integer(unsigned(prnd_a)) > 32103) then
					data_out <= std_logic_vector(to_unsigned(7, 16));
				elsif (to_integer(unsigned(prnd_a)) > 31145) then
					data_out <= std_logic_vector(to_unsigned(6, 16));
				elsif (to_integer(unsigned(prnd_a)) > 29227) then
					data_out <= std_logic_vector(to_unsigned(5, 16));
				elsif (to_integer(unsigned(prnd_a)) > 25843) then
					data_out <= std_logic_vector(to_unsigned(4, 16));
				elsif (to_integer(unsigned(prnd_a)) > 20579) then
					data_out <= std_logic_vector(to_unsigned(3, 16));
				elsif (to_integer(unsigned(prnd_a)) > 13363) then
					data_out <= std_logic_vector(to_unsigned(2, 16));
				elsif (to_integer(unsigned(prnd_a)) >  4643) then
					data_out <= std_logic_vector(to_unsigned(1, 16));
				else
					data_out <= std_logic_vector(to_unsigned(0, 16));
				end if;
			else
				if (to_integer(unsigned(prnd_a)) > 32766) then
					data_out <= std_logic_vector(to_signed(-12, 16));
				elsif (to_integer(unsigned(prnd_a)) > 32762) then
					data_out <= std_logic_vector(to_signed(-11, 16));
				elsif (to_integer(unsigned(prnd_a)) > 32745) then
					data_out <= std_logic_vector(to_signed(-10, 16));
				elsif (to_integer(unsigned(prnd_a)) > 32689) then
					data_out <= std_logic_vector(to_signed(-9, 16));
				elsif (to_integer(unsigned(prnd_a)) > 32525) then
					data_out <= std_logic_vector(to_signed(-8, 16));
				elsif (to_integer(unsigned(prnd_a)) > 32103) then
					data_out <= std_logic_vector(to_signed(-7, 16));
				elsif (to_integer(unsigned(prnd_a)) > 31145) then
					data_out <= std_logic_vector(to_signed(-6, 16));
				elsif (to_integer(unsigned(prnd_a)) > 29227) then
					data_out <= std_logic_vector(to_signed(-5, 16));
				elsif (to_integer(unsigned(prnd_a)) > 25843) then
					data_out <= std_logic_vector(to_signed(-4, 16));
				elsif (to_integer(unsigned(prnd_a)) > 20579) then
					data_out <= std_logic_vector(to_signed(-3, 16));
				elsif (to_integer(unsigned(prnd_a)) > 13363) then
					data_out <= std_logic_vector(to_signed(-2, 16));
				elsif (to_integer(unsigned(prnd_a)) >  4643) then
					data_out <= std_logic_vector(to_signed(-1, 16));
				else
					data_out <= std_logic_vector(to_signed(-0, 16));
				end if;
			end if;

			if (sign_a = '1') then
				--data_out <= std_logic_vector(to_signed(- sample_a, 16));
			else
				--data_out <= std_logic_vector(to_unsigned(sample_a, 16));
			end if;

			if (sign_a_2 = '0') then
				if (to_integer(unsigned(prnd_a_2)) > 32766) then
					data_out2 <= std_logic_vector(to_unsigned(12, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 32762) then
					data_out2 <= std_logic_vector(to_unsigned(11, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 32745) then
					data_out2 <= std_logic_vector(to_unsigned(10, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 32689) then
					data_out2 <= std_logic_vector(to_unsigned(9, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 32525) then
					data_out2 <= std_logic_vector(to_unsigned(8, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 32103) then
					data_out2 <= std_logic_vector(to_unsigned(7, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 31145) then
					data_out2 <= std_logic_vector(to_unsigned(6, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 29227) then
					data_out2 <= std_logic_vector(to_unsigned(5, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 25843) then
					data_out2 <= std_logic_vector(to_unsigned(4, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 20579) then
					data_out2 <= std_logic_vector(to_unsigned(3, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 13363) then
					data_out2 <= std_logic_vector(to_unsigned(2, 16));
				elsif (to_integer(unsigned(prnd_a_2)) >  4643) then
					data_out2 <= std_logic_vector(to_unsigned(1, 16));
				else
					data_out2 <= std_logic_vector(to_unsigned(0, 16));
				end if;
			else
				if (to_integer(unsigned(prnd_a_2)) > 32766) then
					data_out2 <= std_logic_vector(to_signed(-12, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 32762) then
					data_out2 <= std_logic_vector(to_signed(-11, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 32745) then
					data_out2 <= std_logic_vector(to_signed(-10, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 32689) then
					data_out2 <= std_logic_vector(to_signed(-9, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 32525) then
					data_out2 <= std_logic_vector(to_signed(-8, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 32103) then
					data_out2 <= std_logic_vector(to_signed(-7, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 31145) then
					data_out2 <= std_logic_vector(to_signed(-6, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 29227) then
					data_out2 <= std_logic_vector(to_signed(-5, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 25843) then
					data_out2 <= std_logic_vector(to_signed(-4, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 20579) then
					data_out2 <= std_logic_vector(to_signed(-3, 16));
				elsif (to_integer(unsigned(prnd_a_2)) > 13363) then
					data_out2 <= std_logic_vector(to_signed(-2, 16));
				elsif (to_integer(unsigned(prnd_a_2)) >  4643) then
					data_out2 <= std_logic_vector(to_signed(-1, 16));
				else
					data_out2 <= std_logic_vector(to_signed(-0, 16));
				end if;
			end if;

			if (sign_a_2 = '1') then
				--data_out2 <= std_logic_vector(to_signed(- sample_a_2, 16));
			else
				--data_out2 <= std_logic_vector(to_unsigned(sample_a_2, 16));
			end if;
		end if;
	end process;



	--process (clk) is
	--	variable sample_a : integer;
	--	variable x : integer;
	--begin
	--	if (rising_edge(clk)) then
	--		we1 <= '0';
	--		we2 <= '0';
	--		done <= '0';
	--		if (reset = '1') then
	--			state <= s_reset;

	--		elsif (enable = '1') then
	--			case state is
	--				when s_reset =>	state <= s_sample;
	--								i <= 0;

	--				when s_sample =>	state <= s_sample;
	--									addr1 <= std_logic_vector(to_unsigned(i, 10));
	--									i <= i + 1;
	--									x := to_integer(unsigned(prnd_a));
	--									if (i >= 2) then
	--										--if (x > 32766) then
	--										--	sample_a := 12;
	--										--elsif (x > 32762) then
	--										--	sample_a := 11;
	--										--elsif (x > 32745) then
	--										--	sample_a := 10;
	--										--elsif (x > 32689) then
	--										--	sample_a :=  9;
	--										--elsif (x > 32525) then
	--										--	sample_a :=  8;
	--										--elsif (x > 32103) then
	--										--	sample_a :=  7;
	--										--elsif (x > 31145) then
	--										--	sample_a :=  6;
	--										--elsif (x > 29227) then
	--										--	sample_a :=  5;
	--										--elsif (x > 25843) then
	--										--	sample_a :=  4;
	--										--elsif (x > 20579) then
	--										--	sample_a :=  3;
	--										--elsif (x > 13363) then
	--										--	sample_a :=  2;
	--										--elsif (x >  4643) then
	--										--	sample_a :=  1;
	--										--else
	--										--	sample_a :=  0;
	--										--end if;
	--										--if (sign_a = '1') then
	--										--	sample_a := - sample_a;
	--										--end if;
	--										we2 <= '1';
	--										addr2 <= std_logic_vector(to_unsigned(i-2, 10));
	--										if (sign_a = '0') then
	--											if (x > 32766) then
	--												din2 <= std_logic_vector(to_unsigned(12, 16));
	--											elsif (x > 32762) then
	--												din2 <= std_logic_vector(to_unsigned(11, 16));
	--											elsif (x > 32745) then
	--												din2 <= std_logic_vector(to_unsigned(10, 16));
	--											elsif (x > 32689) then
	--												din2 <= std_logic_vector(to_unsigned( 9, 16));
	--											elsif (x > 32525) then
	--												din2 <= std_logic_vector(to_unsigned( 8, 16));
	--											elsif (x > 32103) then
	--												din2 <= std_logic_vector(to_unsigned( 7, 16));
	--											elsif (x > 31145) then
	--												din2 <= std_logic_vector(to_unsigned( 6, 16));
	--											elsif (x > 29227) then
	--												din2 <= std_logic_vector(to_unsigned( 5, 16));
	--											elsif (x > 25843) then
	--												din2 <= std_logic_vector(to_unsigned( 4, 16));
	--											elsif (x > 20579) then
	--												din2 <= std_logic_vector(to_unsigned( 3, 16));
	--											elsif (x > 13363) then
	--												din2 <= std_logic_vector(to_unsigned( 2, 16));
	--											elsif (x >  4643) then
	--												din2 <= std_logic_vector(to_unsigned( 1, 16));
	--											else
	--												din2 <= std_logic_vector(to_unsigned( 0, 16));
	--											end if;
	--										else
	--											if (x > 32766) then
	--												din2 <= std_logic_vector(to_unsigned(-12, 16));
	--											elsif (x > 32762) then
	--												din2 <= std_logic_vector(to_unsigned(-11, 16));
	--											elsif (x > 32745) then
	--												din2 <= std_logic_vector(to_unsigned(-10, 16));
	--											elsif (x > 32689) then
	--												din2 <= std_logic_vector(to_unsigned( -9, 16));
	--											elsif (x > 32525) then
	--												din2 <= std_logic_vector(to_unsigned( -8, 16));
	--											elsif (x > 32103) then
	--												din2 <= std_logic_vector(to_unsigned( -7, 16));
	--											elsif (x > 31145) then
	--												din2 <= std_logic_vector(to_unsigned( -6, 16));
	--											elsif (x > 29227) then
	--												din2 <= std_logic_vector(to_unsigned( -5, 16));
	--											elsif (x > 25843) then
	--												din2 <= std_logic_vector(to_unsigned( -4, 16));
	--											elsif (x > 20579) then
	--												din2 <= std_logic_vector(to_unsigned( -3, 16));
	--											elsif (x > 13363) then
	--												din2 <= std_logic_vector(to_unsigned( -2, 16));
	--											elsif (x >  4643) then
	--												din2 <= std_logic_vector(to_unsigned( -1, 16));
	--											else
	--												din2 <= std_logic_vector(to_unsigned( -0, 16));
	--											end if;
	--										end if;
	--										--din2 <= std_logic_vector(to_unsigned(sample_a, 16));
	--									end if;
	--									if (i = n+2) then
	--										state <= s_done;
	--									end if;

	--				when s_done =>	done <= '1';
	--								state <= s_reset;
	--			end case;

	--		end if;
	--	end if;

	--end process;

end behave;