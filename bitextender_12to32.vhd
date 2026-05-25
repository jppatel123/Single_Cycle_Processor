-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- bitextender_12to32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Implementing a 12 bit to 32-bit sign extension that will work for I, S, and SB types of RISC-V 
--
--
-- NOTES:(for myself more than anyone else) this component handles extension NOT instruction-type immediate organization.... 
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
--use work.types_package.all; 

entity bitextender_12to32 is

port(	imm12_in		: in std_logic_vector(11 downto 0);
	sign_select		: in std_logic; -- 1 = sign extend, 0 = zero extend 
	imm32_out		: out std_logic_vector(31 downto 0)
	);

end bitextender_12to32;

architecture behavioral of bitextender_12to32 is


begin

	-- Lower bits always copied
	imm32_out(11 downto 0) <= imm12_in; 
	
	--takes the 11th bit and extends that out one way or the other
	imm32_out(31 downto 12) <= (others => imm12_in(11)) when sign_select = '1'
						     else (others => '0'); 


  
end behavioral;