--Decoding of mu

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode is
	port(
		clk : in std_logic;
		reset : in std_logic;
		enable : in std_logic;
		done : out std_logic;

		addr_M : out std_logic_vector(5 downto 0);
		dout_M : in std_logic_vector(15 downto 0);

		we_mu : out std_logic;
		addr_mu : out std_logic_vector(2 downto 0);
		din_mu : out std_logic_vector(15 downto 0)
	);
end entity decode;

architecture behave of decode is

	type states is (s_reset, s_decode, s_done);
	signal state : states := s_reset;

	signal i, j, k : integer := 0;
	signal templong : std_logic_vector(15 downto 0);

begin

	process (clk) is
		variable temp : std_logic_vector(15 downto 0) := (others => '0');
	begin
		if (rising_edge(clk)) then
			done <= '0';
			we_mu <= '0';

			if (reset = '1') then
				state <= s_reset;
			elsif (enable = '1') then
				if (state = s_reset) then
					state <= s_decode;
					i <= 0;
					j <= 0;
					k <= 0;
					temp := (others => '0');
					templong <= (others => '0');

				elsif (state = s_decode) then
					state <= s_decode;
					i <= i + 1;
					addr_M <= std_logic_vector(to_unsigned(i, 6));
					if (i >= 2) then
						we_mu <= '0';
						temp := b"00000000000000" & dout_M(14 downto 13);
						if (dout_M(12) = '1') then
							temp := std_logic_vector(to_unsigned(to_integer(unsigned(temp)) + 1, 16));
						end if;
						templong <= temp(1 downto 0) & templong(15 downto 2);
						if (to_unsigned(i, 3) = "010" and i > 3) then
							j <= j + 1;
							we_mu <= '1';
							addr_mu <= std_logic_vector(to_unsigned(j, 3));
							din_mu <= templong;
						end if;
						if (i = 67) then
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