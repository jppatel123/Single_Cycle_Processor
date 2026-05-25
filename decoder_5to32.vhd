-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- decoder_5to32.vhd 
-------------------------------------------------------------------------
-- DESCRIPTION: 
--
--
-- NOTES:
--Based on an example from "Free Range VHDL", as suggested by the Lab 2 PDF
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity decoder_5to32 is
port( input_address 		: in std_logic_vector(4 downto 0);
      enabled_line_out		: out std_logic_vector(31 downto 0)

);  

end decoder_5to32;

architecture dataflow of decoder_5to32 is
 

begin

  with input_address select
        enabled_line_out <= 
            x"00000001" when "00000",  -- bit 0  (register 0)
            x"00000002" when "00001",  -- bit 1  (register 1)
            x"00000004" when "00010",  -- bit 2  (register 2)
            x"00000008" when "00011",  -- bit 3  (register 3)
            x"00000010" when "00100",  -- bit 4  (register 4)
            x"00000020" when "00101",  -- bit 5  (register 5)
            x"00000040" when "00110",  -- bit 6  (register 6)
            x"00000080" when "00111",  -- bit 7  (register 7)
            x"00000100" when "01000",  -- bit 8  (register 8)
            x"00000200" when "01001",  -- bit 9  (register 9)
            x"00000400" when "01010",  -- bit 10 (register 10)
            x"00000800" when "01011",  -- bit 11 (register 11)
            x"00001000" when "01100",  -- bit 12 (register 12)
            x"00002000" when "01101",  -- bit 13 (register 13)
            x"00004000" when "01110",  -- bit 14 (register 14)
            x"00008000" when "01111",  -- bit 15 (register 15)
            x"00010000" when "10000",  -- bit 16 (register 16)
            x"00020000" when "10001",  -- bit 17 (register 17)
            x"00040000" when "10010",  -- bit 18 (register 18)
            x"00080000" when "10011",  -- bit 19 (register 19)
            x"00100000" when "10100",  -- bit 20 (register 20)
            x"00200000" when "10101",  -- bit 21 (register 21)
            x"00400000" when "10110",  -- bit 22 (register 22)
            x"00800000" when "10111",  -- bit 23 (register 23)
            x"01000000" when "11000",  -- bit 24 (register 24)
            x"02000000" when "11001",  -- bit 25 (register 25 / x25)
            x"04000000" when "11010",  -- bit 26 (register 26 / x26)
            x"08000000" when "11011",  -- bit 27 (register 27 / x27)
            x"10000000" when "11100",  -- bit 28 (register 28)
            x"20000000" when "11101",  -- bit 29 (register 29)
            x"40000000" when "11110",  -- bit 30 (register 30)
            x"80000000" when "11111",  -- bit 31 (register 31)
            x"00000000" when others;
            
end dataflow;