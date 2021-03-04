--Frodo packing

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
		in_offset : in integer;
		offset_pk : in integer;
		offset_sk : in integer;

		addr_a : out std_logic_vector(12 downto 0);
		dout_a : in std_logic_vector(15 downto 0);

		we1_S : out std_logic;
		addr1_S : out std_logic_vector(9 downto 0);
		din1_S : out std_logic_vector(15 downto 0);
		we1_pk : out std_logic;
		addr1_pk : out std_logic_vector(12 downto 0);
		din1_pk : out std_logic_vector(15 downto 0);
		we1_sk : out std_logic;
		addr1_sk : out std_logic_vector(13 downto 0);
		din1_sk : out std_logic_vector(15 downto 0)
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
		variable temp : std_logic_vector(31 downto 0) := (others => '0');
	begin
		if (rising_edge(clk)) then
			we1_S <= '0';
			we1_pk <= '0';
			we1_sk <= '0';
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
									i <= 0;
									k <= 0;
									temp := (others => '0');

					when s_pack =>	state <= s_pack;
									addr_a <= std_logic_vector(to_unsigned(in_index + in_offset, 13));
									if (i >= 2 and i < 18) then
										--The first input element has to be loaded, but output cannot start yet
										--as we only take 15 input bits, but need 16 output bits
										if (i = 2) then
											temp(31 downto 17) := dout_a(14 downto 0);
										--Once the second input element has been loaded, output can be generated
										--and temp be rotated 16 elements to the left
										--Output needs to be written to public key, secret key and local array S
										else
											temp(16+k downto 2+k) := dout_a(14 downto 0);
											we1_S <= '1';
											addr1_S <= std_logic_vector(to_unsigned(out_index, 10));
											din1_S <= temp(31 downto 16);
											we1_pk <= '1';
											addr1_pk <= std_logic_vector(to_unsigned(out_index + offset_pk, 13));
											din1_pk <= temp(31 downto 16);
											we1_sk <= '1';
											addr1_sk <= std_logic_vector(to_unsigned(out_index + offset_sk, 14));
											din1_sk <= temp(31 downto 16);
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