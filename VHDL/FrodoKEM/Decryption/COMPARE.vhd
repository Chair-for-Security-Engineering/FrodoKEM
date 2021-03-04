--Compare two vectors. Identical is 0 if they are identical and 1 else

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity compare is
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
end entity compare;

architecture behave of compare is

	type states is (s_reset, s_compare, s_done);
	signal state : states := s_reset;

	signal i, j : integer := 0;

begin

	process (clk) is
	begin
		if (rising_edge(clk)) then
			done <= '0';
			if (reset = '1') then
				state <= s_reset;
			elsif (enable = '1') then
				if (state = s_reset) then
					i <= 0;
					j <= 0;
					identical <= '0';
					state <= s_compare;

				elsif (state = s_compare) then
					i <= i + 1;
					addr_b <= std_logic_vector(to_unsigned(i, 10));
					addr_e <= std_logic_vector(to_unsigned(i, 10));
					if (i >= 2) then
						j <= j + 1;
						--Compare two elements, set identical to '1' if difference occurs
						if (dout_e(12 downto 0) /= dout_b(12 downto 0)) then
							identical <= '1';
						end if;
						if (j = n-1) then
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