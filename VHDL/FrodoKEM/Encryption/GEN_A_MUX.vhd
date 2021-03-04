library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_a_mux is
	port(
		d0  : in std_logic_vector(63 downto 0);
		d1  : in std_logic_vector(63 downto 0);
		d2  : in std_logic_vector(63 downto 0);
		d3  : in std_logic_vector(63 downto 0);
		d4  : in std_logic_vector(63 downto 0);
		d5  : in std_logic_vector(63 downto 0);
		d6  : in std_logic_vector(63 downto 0);
		d7  : in std_logic_vector(63 downto 0);
		d8  : in std_logic_vector(63 downto 0);
		d9  : in std_logic_vector(63 downto 0);
		d10 : in std_logic_vector(63 downto 0);
		d11 : in std_logic_vector(63 downto 0);
		d12 : in std_logic_vector(63 downto 0);
		d13 : in std_logic_vector(63 downto 0);
		d14 : in std_logic_vector(63 downto 0);
		d15 : in std_logic_vector(63 downto 0);
		d16 : in std_logic_vector(63 downto 0);
		d17 : in std_logic_vector(63 downto 0);
		d18 : in std_logic_vector(63 downto 0);
		d19 : in std_logic_vector(63 downto 0);
		d20 : in std_logic_vector(63 downto 0);
		d21 : in std_logic_vector(63 downto 0);
		d22 : in std_logic_vector(63 downto 0);
		d23 : in std_logic_vector(63 downto 0);
		d24 : in std_logic_vector(63 downto 0);
		index : in std_logic_vector(4 downto 0);
		dout : out std_logic_vector(63 downto 0)
	);
end entity gen_a_mux;

architecture rtl of gen_a_mux is

	signal sel : std_logic_vector(4 downto 0);

	signal mux_1_0 : std_logic_vector(63 downto 0);
	signal mux_1_1 : std_logic_vector(63 downto 0);
	signal mux_1_2 : std_logic_vector(63 downto 0);
	signal mux_1_3 : std_logic_vector(63 downto 0);
	signal mux_1_4 : std_logic_vector(63 downto 0);
	signal mux_1_5 : std_logic_vector(63 downto 0);
	signal mux_1_6 : std_logic_vector(63 downto 0);
	signal mux_1_7 : std_logic_vector(63 downto 0);
	signal mux_1_8 : std_logic_vector(63 downto 0);
	signal mux_1_9 : std_logic_vector(63 downto 0);
	signal mux_1_10 : std_logic_vector(63 downto 0);
	signal mux_1_11 : std_logic_vector(63 downto 0);
	signal mux_1_12 : std_logic_vector(63 downto 0);

	signal mux_2_0 : std_logic_vector(63 downto 0);
	signal mux_2_1 : std_logic_vector(63 downto 0);
	signal mux_2_2 : std_logic_vector(63 downto 0);
	signal mux_2_3 : std_logic_vector(63 downto 0);
	signal mux_2_4 : std_logic_vector(63 downto 0);
	signal mux_2_5 : std_logic_vector(63 downto 0);
	signal mux_2_6 : std_logic_vector(63 downto 0);

	signal mux_3_0 : std_logic_vector(63 downto 0);
	signal mux_3_1 : std_logic_vector(63 downto 0);
	signal mux_3_2 : std_logic_vector(63 downto 0);
	signal mux_3_3 : std_logic_vector(63 downto 0);

	signal mux_4_0 : std_logic_vector(63 downto 0);
	signal mux_4_1 : std_logic_vector(63 downto 0);

	signal mux_5_0 : std_logic_vector(63 downto 0);

begin
	
	sel <= index;

	mux_1_0 <= d0  when sel(0) = '0' else d1;
	mux_1_1 <= d2  when sel(0) = '0' else d3;
	mux_1_2 <= d4  when sel(0) = '0' else d5;
	mux_1_3 <= d6  when sel(0) = '0' else d7;
	mux_1_4 <= d8  when sel(0) = '0' else d9;
	mux_1_5 <= d10 when sel(0) = '0' else d11;
	mux_1_6 <= d12 when sel(0) = '0' else d13;
	mux_1_7 <= d14 when sel(0) = '0' else d15;
	mux_1_8 <= d16 when sel(0) = '0' else d17;
	mux_1_9 <= d18 when sel(0) = '0' else d19;
	mux_1_10 <= d20 when sel(0) = '0' else d21;
	mux_1_11 <= d22 when sel(0) = '0' else d23;
	mux_1_12 <= d24;

	mux_2_0 <= mux_1_0 when sel(1) = '0' else mux_1_1;
	mux_2_1 <= mux_1_2 when sel(1) = '0' else mux_1_3;
	mux_2_2 <= mux_1_4 when sel(1) = '0' else mux_1_5;
	mux_2_3 <= mux_1_6 when sel(1) = '0' else mux_1_7;
	mux_2_4 <= mux_1_8 when sel(1) = '0' else mux_1_9;
	mux_2_5 <= mux_1_10 when sel(1) = '0' else mux_1_11;
	mux_2_6 <= mux_1_12;

	mux_3_0 <= mux_2_0 when sel(2) = '0' else mux_2_1;
	mux_3_1 <= mux_2_2 when sel(2) = '0' else mux_2_3;
	mux_3_2 <= mux_2_4 when sel(2) = '0' else mux_2_5;
	mux_3_3 <= mux_2_6;

	mux_4_0 <= mux_3_0 when sel(3) = '0' else mux_3_1;
	mux_4_1 <= mux_3_2 when sel(3) = '0' else mux_3_3;

	mux_5_0 <= mux_4_0 when sel(4) = '0' else mux_4_1;

	dout <= mux_5_0; 
end rtl;