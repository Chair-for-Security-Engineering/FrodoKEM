library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity read_S is
	port(
		clk : in std_logic;
		reset : in std_logic;
		enable : in std_logic;
		done : out std_logic;

		addr_sk : out std_logic_vector(13 downto 0);
		dout_sk : in std_logic_vector(15 downto 0);

		we_out : out std_logic;
		addr_out : out std_logic_vector(9 downto 0);
		din_out : out std_logic_vector(15 downto 0)
	);
end entity read_S;

architecture behave of read_S is

	type states is (s_reset, s_read, s_done);
	signal state : states := s_reset;
	signal i, in_index, out_index, outputs_done, offset : integer := 0;

begin

	process (clk) is
	begin
		if (rising_edge(clk)) then
			done <= '0';
			we_out <= '0';
			if (reset = '1') then
				state <= s_reset;

			elsif (enable = '1') then
				if (state = s_reset) then
					state <= s_read;
					i <= 0;
					in_index <= 0;
					out_index <= 0;
					outputs_done <= 0;
					offset <= 0;

				elsif (state = s_read) then
					state <= s_read;
					i <= i + 1;
					in_index <= in_index + 640;
					if (in_index >= 4480) then
						in_index <= 0;
						offset <= offset + 1;
					end if;
					addr_sk <= std_logic_vector(to_unsigned(in_index+4816+offset, 14));
					if (i >= 2) then
						out_index <= out_index + 1;
						outputs_done <= outputs_done + 1;
						we_out <= '1';
						addr_out <= std_logic_vector(to_unsigned(out_index, 10));
						din_out <= dout_sk(7 downto 0) & dout_sk(15 downto 8);
						if (out_index = 7) then
							out_index <= 0;
						end if;
						if (outputs_done = 5119) then
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