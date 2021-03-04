--Discrete Gaussian sampling
--Sampled value is instantly computed by using a large amount of comparators

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
		end if;
	end process;
end behave;