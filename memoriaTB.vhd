--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:52:46 11/06/2016
-- Design Name:   
-- Module Name:   E:/Trabalho/memoriaTB.vhd
-- Project Name:  Trabalho
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: memoria
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.Numeric_Std.all;

 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY memoriaTB IS
END memoriaTB;
 
ARCHITECTURE behavior OF memoriaTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT memoria
    PORT(
         clock : IN  std_logic;
         we : IN  std_logic;
         address : IN  std_logic_vector(7 downto 0);
         datain : IN  std_logic_vector(7 downto 0);
         dataout : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';
   signal we : std_logic := '0';
   signal address : std_logic_vector(7 downto 0) := (others => '0');
   signal datain : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal dataout : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
	
	--Matriz Imagem
	type matriz_imagem is array (0 to 15, 0 to 15) of std_logic_vector(7 downto 0);
	signal imagem : matriz_imagem := (
	--  0	    1      2      3		 4		  5		6		 7		  8		9		10		 11		12		 13	  14		15
	(x"01", x"A0", x"B2", x"90", x"9F", x"80", x"70", x"60", x"44", x"ED", x"34", x"12", x"45", x"09", x"12", x"11"), --0
	(x"03", x"09", x"FF", x"15", x"E3", x"12", x"11", x"43", x"12", x"34", x"3E", x"40", x"50", x"69", x"FF", x"10"), --1
	(x"60", x"ED", x"54", x"23", x"11", x"10", x"12", x"45", x"78", x"A9", x"3E", x"2E", x"2F", x"65", x"45", x"65"), --2
	(x"01", x"A0", x"B2", x"90", x"9F", x"80", x"70", x"60", x"44", x"ED", x"34", x"12", x"45", x"09", x"12", x"11"), --3
	(x"60", x"ED", x"54", x"23", x"11", x"10", x"12", x"45", x"78", x"A9", x"3E", x"2E", x"2F", x"65", x"45", x"65"), --4 
	(x"03", x"09", x"FF", x"15", x"E3", x"12", x"11", x"43", x"12", x"34", x"3E", x"40", x"50", x"69", x"FF", x"10"), --5
	(x"01", x"A0", x"B2", x"90", x"9F", x"80", x"70", x"60", x"44", x"ED", x"34", x"12", x"45", x"09", x"12", x"11"), --6
	(x"60", x"ED", x"54", x"23", x"11", x"10", x"12", x"45", x"78", x"A9", x"3E", x"2E", x"2F", x"65", x"45", x"65"), --7
	(x"89", x"98", x"5D", x"5C", x"4E", x"4C", x"6F", x"7F", x"8F", x"9E", x"56", x"4F", x"43", x"23", x"23", x"23"), --8
	(x"03", x"09", x"FF", x"15", x"E3", x"12", x"11", x"43", x"12", x"34", x"3E", x"40", x"50", x"69", x"FF", x"10"), --9
	(x"01", x"A0", x"B2", x"90", x"9F", x"80", x"70", x"60", x"44", x"ED", x"34", x"12", x"45", x"09", x"12", x"11"), --10
	(x"60", x"ED", x"54", x"23", x"11", x"10", x"12", x"45", x"78", x"A9", x"3E", x"2E", x"2F", x"65", x"45", x"65"), --11
	(x"89", x"98", x"5D", x"5C", x"4E", x"4C", x"6F", x"7F", x"8F", x"9E", x"56", x"4F", x"43", x"23", x"23", x"23"), --12
	(x"03", x"09", x"FF", x"15", x"E3", x"12", x"11", x"43", x"12", x"34", x"3E", x"40", x"50", x"69", x"FF", x"10"), --13
	(x"01", x"A0", x"B2", x"90", x"9F", x"80", x"70", x"60", x"44", x"ED", x"34", x"12", x"45", x"09", x"12", x"11"), --14
	(x"60", x"ED", x"54", x"23", x"11", x"10", x"12", x"45", x"78", x"A9", x"3E", x"2E", x"2F", x"65", x"45", x"65")  --15
	);
	
signal contador : integer:=0;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: memoria PORT MAP (
          clock => clock,
          we => we,
          address => address,
          datain => datain,
          dataout => dataout
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      --wait for 100 ns;	

      --wait for clock_period*10;

      -- insert stimulus here 
		we <= '1';
		for linha in 0 to 15 loop
			for coluna in 0 to 15 loop
				contador <= contador+1;
				address <=  std_logic_vector(to_unsigned(contador, 8));
				datain <= imagem(linha, coluna);
				wait for 10 ns;
			end loop;
		end loop;	
		we <= '0';
      wait;

      wait;
   end process;

END;
