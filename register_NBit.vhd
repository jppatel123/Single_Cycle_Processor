-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- register_NBit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 
--
--
-- NOTES:
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity register_NBit is
generic(N : integer := 32); 
port(D		: in std_logic_vector(N-1 downto 0); 
     RST	: in std_logic;
     WE		: in std_logic;
     CLK	: in std_logic;
     Q		: out std_logic_vector(N-1 downto 0));  

end register_NBit;

architecture structural of register_NBit is
  component dffg is 
  port(i_CLK	: in std_logic; 
       i_RST	: in std_logic; 
       i_WE	: in std_logic; 
       i_D	: in std_logic; 
       o_Q	: out std_logic); 

  end component; 

begin

G_Register_NBit: for i in 0 to N-1 generate
	REGI: dffg port map(
	-- All instances share the same reset, clock, and write enable? 
	i_RST 	=> RST,
	i_WE	=> WE,
	i_CLK	=> CLK,
	
	-- ith instance data input and output
	i_D	=> D(i),
	o_Q	=> Q(i));
  end generate G_Register_NBit; 
  
  
end structural;