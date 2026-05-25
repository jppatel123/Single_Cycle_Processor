-------------------------------------------------------------------------
-- Shawn Robinson and Jay Patel
-------------------------------------------------------------------------

-- carry_lookahead_adderN.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 32-bit Carry Lookahead Adder.
-- Drop-in replacement for ripple_carry_adderN -- identical port map:
--   A, B, Cin, Sum, Cout
--
-- Built from 8 explicit cla_block_4bit instances (bits 0-3, 4-7, ...
-- 28-31), matching the structural style of ripple_carry_adderN.
-- No generate loops, no behavioral VHDL -- pure structural/dataflow.
--
-- REQUIRES: cla_block_4bit.vhd compiled before this file.
-- Fixed at N=32 to avoid generate-loop synthesis issues in Quartus.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity carry_lookahead_adderN is
  generic(N : integer := 32);
  port(A    : in  std_logic_vector(N-1 downto 0);
       B    : in  std_logic_vector(N-1 downto 0);
       Cin  : in  std_logic;
       Sum  : out std_logic_vector(N-1 downto 0);
       Cout : out std_logic);
end carry_lookahead_adderN;

architecture structural of carry_lookahead_adderN is

  component cla_block_4bit is
    port(A     : in  std_logic_vector(3 downto 0);
         B     : in  std_logic_vector(3 downto 0);
         c_in  : in  std_logic;
         Sum   : out std_logic_vector(3 downto 0);
         c_out : out std_logic);
  end component;

  -- Inter-group carry chain (8 groups for 32 bits)
  signal s_c1, s_c2, s_c3, s_c4, s_c5, s_c6, s_c7 : std_logic;

begin

  -- Group 0: bits 3 downto 0
  BLK0: cla_block_4bit
    port map(A     => A(3  downto 0),
             B     => B(3  downto 0),
             c_in  => Cin,
             Sum   => Sum(3  downto 0),
             c_out => s_c1);

  -- Group 1: bits 7 downto 4
  BLK1: cla_block_4bit
    port map(A     => A(7  downto 4),
             B     => B(7  downto 4),
             c_in  => s_c1,
             Sum   => Sum(7  downto 4),
             c_out => s_c2);

  -- Group 2: bits 11 downto 8
  BLK2: cla_block_4bit
    port map(A     => A(11 downto 8),
             B     => B(11 downto 8),
             c_in  => s_c2,
             Sum   => Sum(11 downto 8),
             c_out => s_c3);

  -- Group 3: bits 15 downto 12
  BLK3: cla_block_4bit
    port map(A     => A(15 downto 12),
             B     => B(15 downto 12),
             c_in  => s_c3,
             Sum   => Sum(15 downto 12),
             c_out => s_c4);

  -- Group 4: bits 19 downto 16
  BLK4: cla_block_4bit
    port map(A     => A(19 downto 16),
             B     => B(19 downto 16),
             c_in  => s_c4,
             Sum   => Sum(19 downto 16),
             c_out => s_c5);

  -- Group 5: bits 23 downto 20
  BLK5: cla_block_4bit
    port map(A     => A(23 downto 20),
             B     => B(23 downto 20),
             c_in  => s_c5,
             Sum   => Sum(23 downto 20),
             c_out => s_c6);

  -- Group 6: bits 27 downto 24
  BLK6: cla_block_4bit
    port map(A     => A(27 downto 24),
             B     => B(27 downto 24),
             c_in  => s_c6,
             Sum   => Sum(27 downto 24),
             c_out => s_c7);

  -- Group 7: bits 31 downto 28
  BLK7: cla_block_4bit
    port map(A     => A(31 downto 28),
             B     => B(31 downto 28),
             c_in  => s_c7,
             Sum   => Sum(31 downto 28),
             c_out => Cout);

end structural;