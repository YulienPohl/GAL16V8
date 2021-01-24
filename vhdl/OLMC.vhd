library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity OLMC is
	port (
		PROD                     : in  std_logic_vector(7 downto 0);
		C_IN, Q_IN               : in  std_logic;
		AC0, AC1_N, AC1_M, XOR_N : in  std_logic;	
		OE_IN, CLK               : in  std_logic;
		Q_OUT, Q_WB, OE_OUT      : out std_logic);
end OLMC;

architecture Behavioral of OLMC is
	subtype ac is std_logic_vector(1 downto 0);

	signal s0, s1, s2, s3 : std_logic := '0';
	signal mem, oe : std_logic := '0';
	
begin
	s0 <= PROD(0) and (AC0 nand AC1_N);
	s1 <= or_reduce(PROD(7 downto 1) & s0);
	s2 <= s1 xor XOR_N;

	process (CLK)
	begin
		if (rising_edge(CLK)) then
			mem <= s2;
		end if;
	end process;
	
	with (AC0 and not AC1_N) select s3 <=
		s2  when '0',
		mem when '1',
		'0' when others;
	Q_OUT <= not s3;
		
	with ac'(AC0, AC1_N) select OE_OUT <=
		'1'       when "00",
		'0'       when "01",
		not OE_IN when "10",
		PROD(0)   when "11",
		'0'       when others;
		
	with ac'(AC0, AC1_N) select Q_WB <=
		AC1_M and C_IN when "00" | "01",
		not mem        when "10",
		Q_IN           when "11",
		'0'            when others;
end Behavioral;
