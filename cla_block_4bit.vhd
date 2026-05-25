-------------------------------------------------------------------------
-- Shawn Robinson and Jay Patel
-------------------------------------------------------------------------

-- cla_block_4bit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 4-bit Carry Lookahead block.
-- NO external gate dependencies (andg2/xorg2/org2 are NOT used here).
-- Uses only dataflow concurrent signal assignments so this file
-- compiles standalone regardless of toolflow compile order.
-- Pure dataflow -- no behavioral VHDL, no process statements.
--
-- HOW CLA WORKS vs RIPPLE CARRY:
--   Ripple carry: each bit waits for carry from bit before it (serial)
--   CLA: computes two signals per bit with no carry needed:
--     G(i) = A(i) AND B(i)   <- this bit GENERATES a carry
--     P(i) = A(i) XOR B(i)   <- this bit PROPAGATES a carry
--   Then ALL carries are computed simultaneously in parallel:
--     C1 = G0 OR (P0 AND Cin)
--     C2 = G1 OR (P1 AND G0) OR (P1 AND P0 AND Cin)   ...etc
--   This turns a 32-serial-stage chain into ~4 levels of logic.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity cla_block_4bit is
  port(A     : in  std_logic_vector(3 downto 0);
       B     : in  std_logic_vector(3 downto 0);
       c_in  : in  std_logic;
       Sum   : out std_logic_vector(3 downto 0);
       c_out : out std_logic);
end cla_block_4bit;

architecture dataflow of cla_block_4bit is

  signal s_G0, s_G1, s_G2, s_G3 : std_logic;  -- Generate
  signal s_P0, s_P1, s_P2, s_P3 : std_logic;  -- Propagate
  signal s_C1, s_C2, s_C3, s_C4 : std_logic;  -- Lookahead carries

begin

  -- Generate and Propagate (no carry dependency at all)
  s_G0 <= A(0) and B(0);
  s_G1 <= A(1) and B(1);
  s_G2 <= A(2) and B(2);
  s_G3 <= A(3) and B(3);

  s_P0 <= A(0) xor B(0);
  s_P1 <= A(1) xor B(1);
  s_P2 <= A(2) xor B(2);
  s_P3 <= A(3) xor B(3);

  -- All carries computed simultaneously -- none waits for another
  s_C1 <= s_G0 or (s_P0 and c_in);

  s_C2 <= s_G1 or (s_P1 and s_G0) or
                  (s_P1 and s_P0 and c_in);

  s_C3 <= s_G2 or (s_P2 and s_G1) or
                  (s_P2 and s_P1 and s_G0) or
                  (s_P2 and s_P1 and s_P0 and c_in);

  s_C4 <= s_G3 or (s_P3 and s_G2) or
                  (s_P3 and s_P2 and s_G1) or
                  (s_P3 and s_P2 and s_P1 and s_G0) or
                  (s_P3 and s_P2 and s_P1 and s_P0 and c_in);

  -- Sum bits
  Sum(0) <= s_P0 xor c_in;
  Sum(1) <= s_P1 xor s_C1;
  Sum(2) <= s_P2 xor s_C2;
  Sum(3) <= s_P3 xor s_C3;

  c_out <= s_C4;

end dataflow;