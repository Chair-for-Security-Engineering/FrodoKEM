--Encoding of mu

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encode is
	port(
		clk : in std_logic;
		reset : in std_logic;
		enable : in std_logic;
		done : out std_logic;

		addr_mu : out std_logic_vector(2 downto 0);
		dout_mu : in std_logic_vector(15 downto 0);

		we_V : out std_logic;
		addr_V : out std_logic_vector(5 downto 0);
		din_V : out std_logic_vector(15 downto 0)
	);
end entity encode;

architecture behave of encode is

	type states is (s_reset, s_done, s_encode);
	signal state : states := s_reset;

	signal i, j, k : integer := 0;
	signal temp : std_logic_vector(15 downto 0) := (others => '0');

begin

	process(clk) is
	begin
		if (rising_edge(clk)) then
			done <= '0';
			we_V <= '0';
			if (reset = '1') then
				state <= s_reset;
				i <= 0;
				j <= 0;
				k <= 0;

			elsif (enable = '1') then
				if (state = s_reset) then
					state <= s_encode;

				elsif (state = s_encode) then
					state <= s_encode;
					addr_mu <= std_logic_vector(to_unsigned(k, 3));
					i <= i + 1;
					if (i >= 2) then
						if (i = 2) then
							temp <= dout_mu(7 downto 0) & dout_mu(15 downto 8);
						elsif (i > 2) then
							we_V <= '1';
							addr_V <= std_logic_vector(to_unsigned(j, 6));
							din_V <= "0" & temp(1 downto 0) & b"0000000000000";
							temp <= temp(1 downto 0) & temp(15 downto 2);
							j <= j + 1;
							if (to_unsigned(j, 3) = "111") then
								k <= k + 1;
								i <= 0;
								if(j = 63) then
									state <= s_done;
								end if;
							end if;
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