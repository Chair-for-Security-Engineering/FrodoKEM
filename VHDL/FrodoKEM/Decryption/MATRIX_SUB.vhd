--Subtract two matrices of 64 elements

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity matrix_sub is
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
end entity matrix_sub;

architecture behave of matrix_sub is

	type states is (s_done, s_reset, s_sub);
	signal state : states := s_reset;

	signal i, j, k : integer := 0;

begin

	process (clk) is
	begin
		if (rising_edge(clk)) then
			done <= '0';
			we_M <= '0';
			if (reset = '1') then
				state <= s_reset;

			elsif (enable = '1') then
				if (state = s_reset) then
					state <= s_sub;
					i <= 0;
					j <= 0;
					k <= 0;

				elsif (state = s_sub) then
					i <= i + 1;
					addr_B <= std_logic_vector(to_unsigned(i, 10));
					addr_C <= std_logic_vector(to_unsigned(i, 6));
					if (i >= 2) then
						we_M <= '1';
						addr_M <= std_logic_vector(to_unsigned(i-2, 6));
						din_M <= std_logic_vector(to_unsigned(to_integer(unsigned(dout_C)) - to_integer(unsigned(dout_B(14 downto 0))), 16));
						if (i = 65) then
							state <= s_done;
						end if;
					end if;

				elsif (state = s_done) then
					state <= s_reset;
					done <= '1';

				end if;
			end if;
		end if;
	end process;

end behave;