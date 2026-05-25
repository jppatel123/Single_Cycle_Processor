--------------------
-- Shawn Robinson 
-- 
-- 
--------------------


-- full_adder.vhd 
---------------------------
-- DESCRIPTION: Implementation of a full_adder for Lab 1 
-- takes three single-bit inputs and produces two single-bit outputs: a sum and a carry 


-- NOTES: 
-------------------------------

library IEEE; 
use IEEE.std_logic_1164.all; 

entity full_adder is 
Port( A, B, Cin : in std_logic; 
	Cout, Sum : out std_logic);

end full_adder; 


architecture structure of full_adder is 
-- Describing the basic logic gate components getting used in this one (?) 
-- TPU_MV_Element says this is not strictly necessary, but good practice I'm assuming? 

component andg2
	port(i_A          : in std_logic;
       	     i_B          : in std_logic;
             o_F          : out std_logic);
end component; 

component xorg2
        port(i_A          : in std_logic;
             i_B          : in std_logic;
             o_F          : out std_logic);
end component; 

component org2
	port(i_A          : in std_logic;
             i_B          : in std_logic;
             o_F          : out std_logic);
end component; 


-- should I create intermediate signals here for the result of i_D1 AND i_S , as well as i_D0 AND ~i_S ? 
-- 
signal s_abxor_intm    : std_logic;
signal s_abcinand_intm : std_logic;
signal s_aband_intm    : std_logic;



begin 
ABand: andg2 
	port MAP(i_A => A,
		 i_B => B,
		 o_F => s_aband_intm);
ABxor: xorg2
	port MAP(i_A => A,
		 i_B => B,
		 o_F => s_abxor_intm); 
ABCinand: andg2
	port MAP(i_A => s_abxor_intm,
		 i_B => Cin,
		 o_F => s_abcinand_intm);  
Cout_or: org2
	port MAP(i_A => s_abcinand_intm,
		 i_B => s_aband_intm,
		 o_F => Cout); 
Sum_xor: xorg2
	port MAP(i_A => s_abxor_intm,
		 i_B => Cin,
		 o_F => Sum); 

end structure; 