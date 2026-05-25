-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- branch_resolver.vhd
-------------------------------------------------------------------------
-- Resolves the correct branch taken/not-taken signal from ALU outputs
-- and funct3. Output feeds directly into fetch unit ZERO input.
--
-- funct3 encoding for branches:
--   000 = beq  : taken if Zero=1
--   001 = bne  : taken if Zero=0
--   100 = blt  : taken if SLT result != 0
--   101 = bge  : taken if SLT result == 0
--   110 = bltu : taken if SLTU result != 0
--   111 = bgeu : taken if SLTU result == 0
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.types_package.all; 

entity branch_resolver is

port(i_funct3		: in std_logic_vector(2 downto 0); 
     i_Zero		: in std_logic; 
     i_SLT		: in std_logic_vector(31 downto 0); 
     i_SLTU		: in std_logic_vector(31 downto 0); 
     o_taken		: out std_logic
);

end branch_resolver;

architecture dataflow of branch_resolver is

  signal s_slt_nonzero	: std_logic; 
  signal s_sltu_nonzero	: std_logic; 
	

begin
	-- SLT/SLTU results are 32-bit but only bit 0 is meaningful (why?) 
	s_slt_nonzero	<= i_SLT(0); 
	s_sltu_nonzero	<= i_SLTU(0); 

	with i_funct3 select
	o_taken <=
      		i_Zero          when "000",   -- beq:  taken if equal
      		not i_Zero      when "001",   -- bne:  taken if not equal
      		s_slt_nonzero   when "100",   -- blt:  taken if A < B (signed)
      		not s_slt_nonzero  when "101",-- bge:  taken if A >= B (signed)
      		s_sltu_nonzero  when "110",   -- bltu: taken if A < B (unsigned)
      		not s_sltu_nonzero when "111",-- bgeu: taken if A >= B (unsigned)
      		'0'             when others;
  
  
end dataflow;