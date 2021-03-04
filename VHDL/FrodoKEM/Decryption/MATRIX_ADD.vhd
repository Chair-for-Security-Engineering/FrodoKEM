--Add 2 matrices with 64 elements each

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity matrix_add is
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
end entity matrix_add;

architecture behave of matrix_add is

	type states is (s_done, s_add, s_reset);
	signal state : states := s_reset;

	signal i, j, k : integer := 0;

begin

	process (clk) is
	begin
		if (rising_edge(clk)) then
			done <= '0';
			we_C <= '0';
			if (reset = '1') then
				state <= s_reset;
				i <= 0;
				j <= 0;
				k <= 0;

			elsif (enable = '1') then
				if (state = s_reset) then
					state <= s_add;

				elsif (state = s_add) then
					state <= s_add;
					i <= i + 1;
					addr_V <= std_logic_vector(to_unsigned(i, 6));
					addr_B <= std_logic_vector(to_unsigned(i, 10));
					if (i >= 2) then
						we_C <= '1';
						addr_C <= std_logic_vector(to_unsigned(i-2, 6));
						din_C <= std_logic_vector(to_unsigned(to_integer(unsigned(dout_V)) + to_integer(unsigned(dout_B)), 16)) and x"7FFF";
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