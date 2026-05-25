
-- Jay Patel
-- barrel_shifter.vhd


library IEEE;
use IEEE.std_logic_1164.all;

entity barrel_shifter is
  port(
    i_A     : in  std_logic_vector(31 downto 0);
    i_shamt : in  std_logic_vector(4  downto 0);  -- shift amount [4:0]
    i_arith : in  std_logic;                       -- 0=logical  1=arithmetic
    i_left  : in  std_logic;                       -- 0=right    1=left
    o_result: out std_logic_vector(31 downto 0)
  );
end barrel_shifter;

architecture structural of barrel_shifter is

 
  -- Component declarations
  

  component mux2t1_N is
    generic(N : integer := 32);
    port(
      i_S  : in  std_logic;
      i_D0 : in  std_logic_vector(N-1 downto 0);
      i_D1 : in  std_logic_vector(N-1 downto 0);
      o_O  : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component mux2t1 is
    port(
      i_S  : in  std_logic;
      i_D0 : in  std_logic;
      i_D1 : in  std_logic;
      o_O  : out std_logic
    );
  end component;

  component andg2 is
    port(i_A : in std_logic; i_B : in std_logic; o_F : out std_logic);
  end component;

  component invg is
    port(i_A : in std_logic; o_F : out std_logic);
  end component;

    -- Internal signals
  

  -- bit-reversed input  (used for left shift input stage)
  signal s_A_rev      : std_logic_vector(31 downto 0);

  -- data fed into the right-shift stages (normal or reversed)
  signal s_shift_in   : std_logic_vector(31 downto 0);

  -- fill bit:  '0' for logical / left,  i_A(31) for arithmetic right
  signal s_not_left   : std_logic;
  signal s_arith_right: std_logic;   -- i_arith AND NOT(i_left)
  signal s_fill       : std_logic;

  -- intermediate stage outputs
  signal s_L0         : std_logic_vector(31 downto 0);  -- after stage 0 (shift 1)
  signal s_L1         : std_logic_vector(31 downto 0);  -- after stage 1 (shift 2)
  signal s_L2         : std_logic_vector(31 downto 0);  -- after stage 2 (shift 4)
  signal s_L3         : std_logic_vector(31 downto 0);  -- after stage 3 (shift 8)
  signal s_L4         : std_logic_vector(31 downto 0);  -- after stage 4 (shift 16)

  -- shifted candidate for each stage (D1 input to that stage's mux)
  signal s_L0s        : std_logic_vector(31 downto 0);
  signal s_L1s        : std_logic_vector(31 downto 0);
  signal s_L2s        : std_logic_vector(31 downto 0);
  signal s_L3s        : std_logic_vector(31 downto 0);
  signal s_L4s        : std_logic_vector(31 downto 0);

  -- right-shift result before possible output reversal
  signal s_right_out  : std_logic_vector(31 downto 0);

  -- bit-reversed right-shift result (used for left shift output stage)
  signal s_right_out_rev : std_logic_vector(31 downto 0);

begin

 
  -- FILL BIT LOGIC
  --   s_fill = i_A(31) AND i_arith AND NOT(i_left)
  --   Structural: invg + andg2 + andg2
 
  INV_LEFT: invg
    port map(i_A => i_left, o_F => s_not_left);

  AND_ARITH: andg2
    port map(i_A => i_arith, i_B => s_not_left, o_F => s_arith_right);

  AND_FILL: andg2
    port map(i_A => s_arith_right, i_B => i_A(31), o_F => s_fill);

  
  -- BIT REVERSAL OF INPUT (wiring only ? zero gates)
  -- s_A_rev(i) = i_A(31-i)
  
  G_REV_IN: for i in 0 to 31 generate
    s_A_rev(i) <= i_A(31-i);
  end generate G_REV_IN;

   -- SELECT INPUT TO RIGHT SHIFTER
  --   i_left=0  ? use i_A directly
  --   i_left=1  ? use reversed i_A
 
  MUX_INPUT: mux2t1_N
    generic map(N => 32)
    port map(
      i_S  => i_left,
      i_D0 => i_A,
      i_D1 => s_A_rev,
      o_O  => s_shift_in
    );

    -- 5-STAGE RIGHT BARREL SHIFTER


  -- STAGE 0: shift right by 1
  s_L0s(31)          <= s_fill;
  s_L0s(30 downto 0) <= s_shift_in(31 downto 1);

  MUX_S0: mux2t1_N
    generic map(N => 32)
    port map(
      i_S  => i_shamt(0),
      i_D0 => s_shift_in,
      i_D1 => s_L0s,
      o_O  => s_L0
    );

  -- STAGE 1: shift right by 2
  s_L1s(31)          <= s_fill;
  s_L1s(30)          <= s_fill;
  s_L1s(29 downto 0) <= s_L0(31 downto 2);

  MUX_S1: mux2t1_N
    generic map(N => 32)
    port map(
      i_S  => i_shamt(1),
      i_D0 => s_L0,
      i_D1 => s_L1s,
      o_O  => s_L1
    );

  -- STAGE 2: shift right by 4
  s_L2s(31)          <= s_fill;
  s_L2s(30)          <= s_fill;
  s_L2s(29)          <= s_fill;
  s_L2s(28)          <= s_fill;
  s_L2s(27 downto 0) <= s_L1(31 downto 4);

  MUX_S2: mux2t1_N
    generic map(N => 32)
    port map(
      i_S  => i_shamt(2),
      i_D0 => s_L1,
      i_D1 => s_L2s,
      o_O  => s_L2
    );

  -- STAGE 3: shift right by 8
  s_L3s(31 downto 24) <= (others => s_fill);
  s_L3s(23 downto 0)  <= s_L2(31 downto 8);

  MUX_S3: mux2t1_N
    generic map(N => 32)
    port map(
      i_S  => i_shamt(3),
      i_D0 => s_L2,
      i_D1 => s_L3s,
      o_O  => s_L3
    );

  -- STAGE 4: shift right by 16
  s_L4s(31 downto 16) <= (others => s_fill);
  s_L4s(15 downto 0)  <= s_L3(31 downto 16);

  MUX_S4: mux2t1_N
    generic map(N => 32)
    port map(
      i_S  => i_shamt(4),
      i_D0 => s_L3,
      i_D1 => s_L4s,
      o_O  => s_L4
    );

  s_right_out <= s_L4;

  
  -- BIT REVERSAL OF OUTPUT (wiring only ? zero gates)
  
  G_REV_OUT: for i in 0 to 31 generate
    s_right_out_rev(i) <= s_right_out(31-i);
  end generate G_REV_OUT;

  
  -- SELECT FINAL OUTPUT
  --   i_left=0  ? right-shift result directly
  --   i_left=1  ? reversed right-shift result (= left-shift result)
 
  MUX_OUTPUT: mux2t1_N
    generic map(N => 32)
    port map(
      i_S  => i_left,
      i_D0 => s_right_out,
      i_D1 => s_right_out_rev,
      o_O  => o_result
    );

end structural;