-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- mux_32to1.vhd 
-------------------------------------------------------------------------
-- DESCRIPTION: 32 to 1 mux using a dataflow approach 
--
--
-- NOTES:
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux_32to1 is
port( select_lines 		: in std_logic_vector(4 downto 0);
      data_inputs		: in std_logic_vector(31 downto 0);
      output_data		: out std_logic);

end mux_32to1;

architecture dataflow of mux_32to1 is
 

begin

with select_lines select
	output_data <=		data_inputs(0)  when "00000",
                    		data_inputs(1)  when "00001",
                    		data_inputs(2)  when "00010",
                    		data_inputs(3)  when "00011",
                    		data_inputs(4)  when "00100",
                    		data_inputs(5)  when "00101",
                    		data_inputs(6)  when "00110",
                    		data_inputs(7)  when "00111",
                    		data_inputs(8)  when "01000",
                    		data_inputs(9)  when "01001",
                    		data_inputs(10) when "01010",
                    		data_inputs(11) when "01011",
                    		data_inputs(12) when "01100",
                    		data_inputs(13) when "01101",
                    		data_inputs(14) when "01110",
                    		data_inputs(15) when "01111",
                    		data_inputs(16) when "10000",
                    		data_inputs(17) when "10001",
                    		data_inputs(18) when "10010",
                    		data_inputs(19) when "10011",
                    		data_inputs(20) when "10100",
                    		data_inputs(21) when "10101",
                    		data_inputs(22) when "10110",
                    		data_inputs(23) when "10111",
                    		data_inputs(24) when "11000",
                    		data_inputs(25) when "11001",
                    		data_inputs(26) when "11010",
                    		data_inputs(27) when "11011",
                    		data_inputs(28) when "11100",
                    		data_inputs(29) when "11101",
                    		data_inputs(30) when "11110",
                    		data_inputs(31) when "11111",
                    		'0'             when others; 
end dataflow;