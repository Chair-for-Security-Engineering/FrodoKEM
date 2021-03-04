library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pack is
	port(
		clk : in std_logic;
		reset : in std_logic;
		enable : in std_logic;
		done : out std_logic;

		inlen : in integer;
		offset : in integer;

		addr_a : out std_logic_vector(9 downto 0);
		dout_a : in std_logic_vector(15 downto 0);

		we1_ct : out std_logic;
		addr1_ct : out std_logic_vector(12 downto 0);
		din1_ct : out std_logic_vector(15 downto 0);
		we1_x : out std_logic;
		addr1_x : out std_logic_vector(9 downto 0);
		din1_x : out std_logic_vector(15 downto 0)
	);
end entity pack;

architecture behave of pack is
	
	type states is (s_reset, s_pack, s_done);
	signal state : states := s_reset;
	signal i, out_index, in_index : integer := 0;
	signal k : integer := 0;
	signal length : integer;
	signal rows_done : integer := 0;

begin
	
	process (clk) is
		--variable in_index : integer := 0;
		variable temp : std_logic_vector(31 downto 0) := (others => '0');
	begin
		if (rising_edge(clk)) then
			we1_ct <= '0';
			we1_x <= '0';
			done <= '0';
			if (reset = '1') then
				state <= s_reset;
			
			elsif (enable = '1') then
				case state is
					when s_reset =>	state <= s_pack;
									length <= inlen;
									in_index <= 0;
									out_index <= 0;
									rows_done <= 0;
									addr_a <= "0000000000";
									addr1_ct <= "0000000000000";

					when s_pack =>	state <= s_pack;
									addr_a <= std_logic_vector(to_unsigned(in_index, 10));
									if (i = 0) then
										--temp(31 downto 17) := dout_a(14 downto 0);
									elsif (i >= 2 and i < 18) then
										if (i = 2) then
											temp(31 downto 17) := dout_a(14 downto 0);
										else
											temp(16+k downto 2+k) := dout_a(14 downto 0);
											we1_ct <= '1';
											addr1_ct <= std_logic_vector(to_unsigned(out_index + offset, 13));
											din1_ct <= temp(31 downto 16);
											we1_x <= '1';
											addr1_x <= std_logic_vector(to_unsigned(out_index, 10));
											din1_x <= temp(31 downto 16);
											out_index <= out_index + 1;
											temp := temp(15 downto 0) & x"0000";
											k <= k + 1;
										end if;
									end if;
									if (in_index < 16*(rows_done+1)) then
										in_index <= in_index + 1;
									end if;
									i <= i + 1;
									if (i = 18) then
										rows_done <= rows_done+1;
										state <= s_pack;
										i <= 0;
										k <= 0;
										length <= length - 16;
										if (length - 16 = 0) then
											state <= s_done;
										end if;
									end if;
					when s_done => 	done <= '1';
									state <= s_reset;
				end case;
			end if;
		end if;
	end process;

end behave;