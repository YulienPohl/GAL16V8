library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity GAL16V8_tb is
end GAL16V8_tb;

architecture tb of GAL16V8_tb is
	signal d_in       : std_logic_vector(7 downto 0) := (others => '0');
	signal clk, oe_in : std_logic := '0';
	signal q_inout    : std_logic_vector(7 downto 0) := (others => '0');
	
	signal done : std_logic := '0';
	
	constant PERIOD     : time   := 20 ns;
	constant TESTFILE   : string := "GAL16V8_tb_data.txt";
	constant REPORTFILE : string := "GAL16V8_tb_report.txt";

begin
	UUT : entity work.GAL16V8_tb 
	generic map ("Gatter.hex")
	port map (
		d_in,
		clk, oe_in,
		q_inout);

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

		variable v_D_IN         : std_logic_vector(7 downto 0)
		variable v_CLK, V_OE_IN : std_logic := '0';
		variable v_Q_INOUT      : std_logic_vector(7 downto 0)
		
	begin
		report "Test started." severity NOTE;
	
		file_open(ifile, TESTFILE, read_mode);
		file_open(ofile, REPORTFILE, write_mode);
	
		while not endfile(ifile) loop
			readline(ifile, iline);
			next when iline'length = 0;
			
			read(iline, v_D_IN, good);
			assert good report "Text I/O read error" severity ERROR;
			
			read(iline, v_CLK, good);
			assert good report "Text I/O read error" severity ERROR;
			
			read(iline, V_OE_IN, good);
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
