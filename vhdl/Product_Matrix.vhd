library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity Product_Matrix is
	port (
		SIG  : in  std_logic_vector(31  downto 0);
		FUSE : in  std_logic_vector(255 downto 0);
		PROD : out std_logic_vector(7   downto 0));
end Product_Matrix;

architecture Behavioral of Product_Matrix is
begin
	-- 8 x 32 product matrix
	FUSES : for i in 0 to 7 generate
		PROD(i) <= nand_reduce(FUSE(32*(i+1)-1 downto 32*i) or SIG)
				   nor and_reduce(FUSE(32*(i+1)-1 downto 32*i));
	end generate;
end Behavioral;
