-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------
-- bitextender_20to32.vhd
---------------------------
-- DESCRIPTION: Implementing a 20 bit to 32-bit extension.
-- Useful for J-type (sign-extended) and U-type (typically zero-filled).
---------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity bitextender_20to32 is
    port(
        imm20_in     : in std_logic_vector(19 downto 0);
        sign_select  : in std_logic; -- 1 = sign extend, 0 = zero extend 
        imm32_out    : out std_logic_vector(31 downto 0)
    );
end bitextender_20to32;

architecture behavioral of bitextender_20to32 is
begin

    -- Lower 20 bits always copied directly
    imm32_out(19 downto 0) <= imm20_in; 
    
    -- Upper 12 bits (31 down to 20)
    -- Takes the 19th bit (MSB of input) and extends it if sign_select is high
    imm32_out(31 downto 20) <= (others => imm20_in(19)) when sign_select = '1'
                               else (others => '0'); 
  
end behavioral;