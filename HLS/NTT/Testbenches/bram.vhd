library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_bram is
	generic(
		awidth : integer := 10;
		dwidth : integer := 16
	);
	port(
		clk : in std_logic;
		we : in std_logic;
		addr : in std_logic_vector(awidth-1 downto 0);
		din : in std_logic_vector(dwidth-1 downto 0);
		dout : out std_logic_vector(dwidth-1 downto 0)
	);
end entity single_port_bram;

architecture behave of single_port_bram is
	
	type ram_type is array(2**awidth-1 downto 0) of std_logic_vector(dwidth-1 downto 0);
	shared variable ram_single_port : ram_type := (others => (others => '0'));

	attribute ram_style : string;
	attribute ram_style of ram_single_port : variable is "block";

begin

	process(clk) is
	begin
		if(clk'event and clk = '1') then
			dout <= ram_single_port(to_integer(unsigned(addr)));
			if(we = '1') then
				ram_single_port(to_integer(unsigned(addr))) := din;
			end if;
		end if;
	end process;

end behave;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_distributed_ram is
	generic(
		awidth : integer := 10;
		dwidth : integer := 16
	);
	port(
		clk : in std_logic;
		we : in std_logic;
		addr : in std_logic_vector(awidth-1 downto 0);
		din : in std_logic_vector(dwidth-1 downto 0);
		dout : out std_logic_vector(dwidth-1 downto 0)
	);
end entity single_port_distributed_ram;

architecture behave of single_port_distributed_ram is
	
	type ram_type is array(2**awidth-1 downto 0) of std_logic_vector(dwidth-1 downto 0);
	shared variable ram : ram_type := (others => (others => '0'));

	attribute ram_style : string;
	attribute ram_style of ram : variable is "distributed";

begin
	process (clk) is
	begin
		if (clk'event and clk = '1') then
			dout <= ram(to_integer(unsigned(addr)));
			if (we = '1') then
				ram(to_integer(unsigned(addr))) := din;
			end if;
		end if;
	end process;
end behave;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity true_dual_port_bram is
	generic(
		--mem_type : string := "block";
		awidth : integer := 10;
		dwidth : integer := 16
	);
	port(
		clk : in std_logic;
		we1 : in std_logic;
		addr1 : in std_logic_vector(awidth-1 downto 0);
		din1 : in std_logic_vector(dwidth-1 downto 0);
		dout1 : out std_logic_vector(dwidth-1 downto 0);
		we2 : in std_logic;
		addr2 : in std_logic_vector(awidth-1 downto 0);
		din2 : in std_logic_vector(dwidth-1 downto 0);
		dout2 : out std_logic_vector(dwidth-1 downto 0)
	);
end entity true_dual_port_bram;

architecture behave of true_dual_port_bram is
	
	type ram_type is array(2**awidth-1 downto 0) of std_logic_vector(dwidth-1 downto 0);
	shared variable ram : ram_type := (others => (others => '0'));

	attribute ram_style : string;
	attribute ram_style of ram : variable is "block";

	--attribute syn_ramstyle : string;
	--attribute syn_ramstyle of ram : signal is "block_ram";

begin

	process(clk) is
	begin
		if (clk'event and clk = '1') then
			dout1 <= ram(to_integer(unsigned(addr1)));
			if (we1 = '1') then
				ram(to_integer(unsigned(addr1))) := din1;
			end if;
		end if;
	end process;

	process (clk) is
	begin
		if (clk'event and clk = '1') then
			dout2 <= ram(to_integer(unsigned(addr2)));
			if (we2 = '1') then
				ram(to_integer(unsigned(addr2))) := din2;
			end if;
		end if;
	end process;
end behave;
