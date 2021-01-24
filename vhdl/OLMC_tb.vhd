library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity OLMC_tb is
end OLMC_tb;

architecture tb of OLMC_tb is
	signal prod : std_logic_vector(7 downto 0) := (others => '0');
	signal c_in, q_in : std_logic := '0';
	signal ac0, ac1_n, ac1_m, xor_n : std_logic := '0';
	signal oe_in, clk : std_logic := '0';
	signal q_out, q_wb, oe_out : std_logic := '0';
	
	signal done : std_logic := '0';
	
	constant PERIOD     : time   := 20 ns;
	constant TESTFILE   : string := "OLMC_tb_data.txt";
	constant REPORTFILE : string := "OLMC_tb_report.txt";

begin
	UUT : entity work.OLMC port map (
		prod, 
		c_in, q_in, 
		ac0, ac1_n, ac1_m, xor_n, 
		oe_in, clk, 
		q_out, q_wb, oe_out);

	clock : process
	begin
		while (done = '0') loop
			clk <= '0';
			wait for PERIOD / 2;
			clk <= '1';
			wait for PERIOD / 2;
		end loop;
	end process;

	stimulus : process
		file     ifile, ofile : text;
		variable iline, oline : line;
		variable good : boolean;

		variable failed_test, test_n : integer := 0;

		variable v_PROD : std_logic_vector(7 downto 0);
		variable v_C_IN, v_Q_IN, v_OE_IN : std_logic;
		variable v_FUSE : std_logic_vector(3 downto 0);
		variable v_Q_OUT, v_Q_WB, v_OE_OUT : std_logic;
		
	begin
		report "Test started." severity NOTE;
	
		file_open(ifile, TESTFILE, read_mode);
		file_open(ofile, REPORTFILE, write_mode);
	
		while not endfile(ifile) loop
			readline(ifile, iline);
			next when iline'length = 0;
			
			read(iline, v_PROD, good);
			assert good report "Text I/O read error" severity ERROR;
			
			read(iline, v_C_IN, good);
			assert good report "Text I/O read error" severity ERROR;
			
			read(iline, v_Q_IN, good);
			assert good report "Text I/O read error" severity ERROR;
			
			read(iline, v_FUSE, good);
			assert good report "Text I/O read error" severity ERROR;
			
			read(iline, v_OE_IN, good);
			assert good report "Text I/O read error" severity ERROR;
			
			read(iline, v_Q_OUT, good);
			assert good report "Text I/O read error" severity ERROR;
			
			read(iline, v_Q_WB, good);
			assert good report "Text I/O read error" severity ERROR;
			
			read(iline, v_OE_OUT, good);
			assert good report "Text I/O read error" severity ERROR;

			prod  <= v_PROD;
			c_in  <= v_C_IN;
			q_in  <= v_Q_IN;
			ac0   <= v_FUSE(3);
			ac1_n <= v_FUSE(2);
			ac1_m <= v_FUSE(1);
			xor_n <= v_FUSE(0);		
			oe_in <= v_OE_IN;

			wait for PERIOD;
			
			if ((q_out  /= v_Q_OUT) or 
				(q_wb   /= v_Q_WB) or 
				(oe_out /= v_OE_OUT)) then
				
				failed_test := failed_test + 1;
				
				write(oline, string'("#"));
				write(oline, test_n);
				write(oline, string'(":"));
				
				write(oline, v_PROD, right, 9);
				write(oline, v_C_IN, right, 2);
				write(oline, v_Q_IN, right, 2);
				write(oline, v_FUSE, right, 5);
				write(oline, v_OE_IN, right, 2);
				
				write(oline, string'(" =>"));
				
				write(oline, v_Q_OUT, right, 2);
				write(oline, v_Q_WB, right, 2);
				write(oline, v_OE_OUT, right, 2);
				
				write(oline, string'(" !="));
				
				write(oline, q_out, right, 2);
				write(oline, q_wb, right, 2);
				write(oline, oe_out, right, 2);
				
				writeline(ofile, oline);
			end if;

			test_n := test_n + 1;		
		end loop;
	
		done <= '1';
	
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
		report "Total Tests:     " & integer'image(test_n) severity NOTE;
		assert failed_test = 0 report "Failed Tests:    " & integer'image(failed_test) severity WARNING;	
		
		wait;
	end process;
end tb;
