--Unpacking

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unpack is
	port(
		clk : in std_logic;
		reset : in std_logic;
		enable : in std_logic;
		done : out std_logic;

		outlen : in integer;
		offset : in integer;

		addr1_in : out std_logic_vector(13 downto 0);
		dout1_in : in std_logic_vector(15 downto 0);

		we1_out : out std_logic;
		addr1_out : out std_logic_vector(9 downto 0);
		din1_out : out std_logic_vector(15 downto 0)
	);
end entity unpack;

architecture behave of unpack is

	type states is (s_reset, s_done, s_pack);
	signal state : states := s_reset;

	signal i, j, k, in_index, out_index : integer := 0;
	signal temp : std_logic_vector(31 downto 0) := (others => '0');

begin
	
	process(clk) is
	begin
		if (rising_edge(clk)) then
			done <= '0';
			we1_out <= '0';
			if (reset = '1') then
				state <= s_reset;
			elsif (enable = '1') then
				if (state = s_reset) then
					state <= s_pack;
					temp <= (others => '0');
					i <= 0;
					j <= 0; 
					k <= 0;
					in_index <= 0;
					out_index <= 0;
					temp <= (others => '0');

				elsif (state = s_pack) then
					k <= k + 1;
					if (j < 15) then
						in_index <= in_index + 1;
						j <= j + 1;
					end if;
					addr1_in <= std_logic_vector(to_unsigned(in_index+offset, 14));
					if (k = 18) then
						k <= 3;
					end if;
					if (k >= 2) then
						--At the start, write the input element into the left of temp...
						if (k = 2) then
							temp(31 downto 16) <= dout1_in;
						else
							i <= i + 1;
							---...in the other iterations, take 15 bits from temp for the
							--output, shift temp 15 to the left, and write the next input
							--to the right of the remaining bits
							--Only in the 16th iteration, no new input is used as 15 
							--bits are remaining from the 15 previous inputs
							if (i < 14) then
								temp <= std_logic_vector(shift_left(unsigned(temp), 15)) or std_logic_vector(shift_left(resize(unsigned(dout1_in), 32), (15-i)));
							elsif (i = 14) then
								temp <= std_logic_vector(shift_left(unsigned(temp), 15));
							else
								temp(31 downto 16) <= dout1_in;
							end if;
							we1_out <= '1';
							din1_out <= "0" & temp(31 downto 17);
							addr1_out <= std_logic_vector(to_unsigned(out_index, 10));
							out_index <= out_index + 1;

							if (i = 12) then
								j <= 0;
							end if;

							if (i = 15) then
								i <= 0;
								--k <= 3;
							end if;

							if (out_index = outlen-1) then
								state <= s_done;
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