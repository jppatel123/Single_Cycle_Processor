--------------------
-- Shawn Robinson 
-- 
-- 
--------------------


-- mux2t1.vhd 
---------------------------
-- DESCRIPTION: Implementation of a 2:1 mux for Lab 1 



-- NOTES: 
-------------------------------

library IEEE; 
use IEEE.std_logic_1164.all; 

entity mux2t1 is 
Port( i_D0, i_D1, i_S : in std_logic; 
	o_O : out std_logic);

end mux2t1; 


architecture structure of mux2t1 is 
-- Describing the basic logic gate components getting used in this one (?) 
-- TPU_MV_Element says this is not strictly necessary, but good practice I'm assuming? 

component andg2
	port(i_A          : in std_logic;
       	     i_B          : in std_logic;
             o_F          : out std_logic);
end component; 

component invg
	port(i_A          : in std_logic;
             o_F          : out std_logic);
end component; 

component org2
	port(i_A          : in std_logic;
             i_B          : in std_logic;
             o_F          : out std_logic);
end component; 


-- should I create intermediate signals here for the result of i_D1 AND i_S , as well as i_D0 AND ~i_S ? 
-- 
signal s_0 : std_logic;
signal s_1 : std_logic;
signal not_s : std_logic;

-- ?? 

begin 
select_not: invg
	port MAP(i_A => i_S,
		 o_F => not_s);  

w1And: andg2 
	port MAP(i_A => i_D1,
		 i_B => i_S,
		 o_F => s_1);
w0And: andg2
	port MAP(i_A => i_D0,
		 i_B => not_s,
		 o_F => s_0); 
last_or: org2
	port MAP(i_A => s_1,
		 i_B => s_0,
		 o_F => o_O); 

end structure; 