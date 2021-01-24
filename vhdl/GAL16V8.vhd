library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity GAL16V8 is
	generic (FUSE_FILE : string);
	port (
		D_IN       : in    std_logic_vector(7 downto 0);
		CLK, OE_IN : in    std_logic;
		Q_INOUT    : inout std_logic_vector(7 downto 0));
end GAL16V8;

architecture Behavioral of GAL16V8 is
	type dtype is array(0 to 64) of std_logic_vector(31 downto 0);

	-- load fuses from file into rom
	impure function Fuse_Init(constant filename : string) return dtype is
		file ifile : text open read_mode is filename;
		variable iline : line;
		variable res   : dtype := (others => (others => '0'));
	begin
        readline(ifile, iline); -- ignore header
		for i in dtype'range loop
			exit when endfile(ifile);
		
			readline(ifile, iline);
			hread(iline, res(i));
		end loop;
	
		file_close(ifile);	
		return res;
	end function;
	
	-- programmable fuses
	constant Fuse_ROM : dtype := Fuse_Init(FUSE_FILE);
	alias olmc_fuse : std_logic_vector(31 downto 0) is Fuse_ROM(64);
	
	-- olmc control fuses
	signal ac0, ac1_n, ac1_m, xor_n : std_logic_vector(7 downto 0) := (others => '0');
	
	-- olmc data output and writeback  
	signal c_in, q_in, q_out, q_wb, oe : std_logic_vector(7 downto 0) := (others => '0');
	
	-- from, to product matrix
	signal sig  : std_logic_vector(0 to 31)     := (others => '0'); -- reversed input
	signal prod : std_logic_vector(63 downto 0) := (others => '0');
	
begin
	q_in <= Q_INOUT;
	c_in <= OE_IN & q_in(7 downto 5) & q_in(2 downto 0) & CLK;
	
	-- fuse routing of individual olmc
	ac0   <= (not olmc_fuse(15)) & (5 downto 0 => olmc_fuse(14)) & (not olmc_fuse(15));
	ac1_n <= olmc_fuse(23 downto 16);
	ac1_m <= olmc_fuse(15) & ac1_n(2 downto 0) & ac1_n(7 downto 5) & olmc_fuse(15);
	xor_n <= olmc_fuse(31 downto 24);
	
	GAL_GEN : for i in 0 to 7 generate
		-- signal routing of data and writeback for product matrix
		sig(4*i to 4*(i+1)-1) <= D_IN(i) & (not D_IN(i)) & q_wb(i) & (not q_wb(i));
		
		-- individual configurable tristate io
		with oe(i) select Q_INOUT(i) <=
			q_out(i) when '1',
			'Z'      when others;
		
		FUSE_GEN : entity work.Product_Matrix 	
			port map (
				sig,
				Fuse_ROM(8*i+7) & Fuse_ROM(8*i+6) & Fuse_ROM(8*i+5) & Fuse_ROM(8*i+4)
				& Fuse_ROM(8*i+3) & Fuse_ROM(8*i+2) & Fuse_ROM(8*i+1) & Fuse_ROM(8*i),
				prod(8*(i+1)-1 downto 8*i));
		
		OLMC_GEN : entity work.OLMC 
			port map (
				prod(8*(i+1)-1 downto 8*i),
				c_in(i),
				q_in(i),
				ac0(7-i),
				ac1_n(7-i),
				ac1_m(7-i),
				xor_n(7-i),
				OE_IN,
				CLK,
				q_out(i),
				q_wb(i),
				oe(i));
	end generate;
end Behavioral;
