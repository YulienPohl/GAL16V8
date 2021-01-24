library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity Product_Matrix_tb is
end Product_Matrix_tb;

architecture tb of Product_Matrix_tb is
	signal sig  : std_logic_vector(31  downto 0) := (others => '0');
	signal fuse : std_logic_vector(255 downto 0) := (others => '0');
	signal prod : std_logic_vector(7   downto 0) := (others => '0');
	
	constant PERIOD     : time   := 20 ns;
	constant TESTFILE   : string := "Product_Matrix_tb_data.txt";
	constant REPORTFILE : string := "Product_Matrix_tb_report.txt";

begin
	UUT : entity work.Product_Matrix
        port map (sig, fuse, prod);

	stimulus : process
		file     ifile, ofile : text;
		variable iline, oline : line;
		variable good : boolean;

		variable failed_test, test_n : integer := 0;

		variable v_SIG  : std_logic_vector(31 downto 0);
		variable v_FUSE : std_logic_vector(31 downto 0);
		variable v_PROD : std_logic_vector(7 downto 0);
		
	begin
		report "Test started." severity NOTE;
	
		file_open(ifile, TESTFILE, read_mode);
		file_open(ofile, REPORTFILE, write_mode);

		while not endfile(ifile) loop
			readline(ifile, iline);
			next when iline'length = 0;
			
			read(iline, v_SIG, good);
			assert good report "Text I/O read error" severity ERROR;
			
			read(iline, v_FUSE, good);
			assert good report "Text I/O read error" severity ERROR;
			
			read(iline, v_PROD, good);
			assert good report "Text I/O read error" severity ERROR;
			
			sig  <= v_SIG;
			fuse <= v_FUSE & v_FUSE & v_FUSE & v_FUSE & 
					v_FUSE & v_FUSE & v_FUSE & v_FUSE; -- 8x same module

			wait for PERIOD;
			
			if (prod /= v_PROD) then
				
				failed_test := failed_test + 1;
				
				write(oline, string'("#"));
				write(oline, test_n);
				write(oline, string'(":"));
				
				write(oline, v_SIG, right, 33);
				write(oline, v_FUSE, right, 33);
				
				write(oline, string'(" =>"));
				
				write(oline, v_PROD, right, 9);
				
				write(oline, string'(" !="));
				
				write(oline, prod, right, 9);
				
				writeline(ofile, oline);
			end if;

			test_n := test_n + 1;		
		end loop;

		write(oline, string'(" "));
		writeline(ofile, oline);
	
		write(oline, string'("Total Tests:  "));
		write(oline, test_n);
		writeline(ofile, oline);
	
		write(oline, string'("Failed Tests: "));
		write(oline, failed_test);
		writeline(ofile, oline);
		
		--write(oline, string'("Total Time: "));
		--write(oline, to_real(NOW) * get_resolution);
		--writeline(ofile, oline);

		file_close(ifile);
		file_close(ofile);
		
		report "Test Finished." severity NOTE;
		report "Detailed Report: " & REPORTFILE severity NOTE;
		report "Total Tests:  " & integer'image(test_n) severity NOTE;
		assert failed_test = 0 report "Failed Tests: " & integer'image(failed_test) severity WARNING;	
		
		wait;
	end process;
end tb;
