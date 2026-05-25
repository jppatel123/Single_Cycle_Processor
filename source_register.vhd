-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- source_register.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This is a sort of intermediary step to model a RISC-V source register, 
-- as a structural component for the register file 
--
--
-- NOTES:
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.RISCV_types.all;

entity source_register is

port(register_lines		: in bus_32_t;  
     address_select_lines	: in std_logic_vector(4 downto 0);
     output_lines		: out std_logic_vector(31 downto 0)); 
    

end source_register;

architecture structural of source_register is
 

  component mux_32to1 is 
  port(select_lines	: in std_logic_vector(4 downto 0); 
       data_inputs	: in std_logic_vector(31 downto 0); 
       output_data	: out std_logic); 

  end component; 

type transposed_bus_t is array(31 downto 0) of std_logic_vector(31 downto 0); 
signal mux_input_bus : transposed_bus_t; 


begin

G_TRANSPOSE_OUTER: for i in 0 to 31 generate
	G_TRANSPOSE_INNER: for j in 0 to 31 generate
		mux_input_bus(i)(j) <= register_lines(j)(i);
	end generate G_TRANSPOSE_INNER; 
 end generate G_TRANSPOSE_OUTER;




G_MUX_RS: for i in 0 to 31 generate
	SRC_REGI: mux_32to1 port map(
	-- All instances share the same selects, right? 
	select_lines 	=> address_select_lines,
	
	-- ith instance data input (registerlines[i] accesses its particular 32 bits of data) and output
	data_inputs	=> mux_input_bus(i),
	output_data	=> output_lines(i));
  end generate G_MUX_RS; 
  
  
end structural;
