
-- Jay Patel
-- addsub_32.vhd
--


library IEEE;
use IEEE.std_logic_1164.all;

entity addsub_32 is
  port(
    i_A        : in  std_logic_vector(31 downto 0);
    i_B        : in  std_logic_vector(31 downto 0);
    i_nAdd_Sub : in  std_logic;                       -- 0=ADD  1=SUB

    o_Sum      : out std_logic_vector(31 downto 0);
    o_Cout     : out std_logic;
    o_Overflow : out std_logic;
    o_SLT      : out std_logic_vector(31 downto 0);  -- signed  less-than
    o_SLTU     : out std_logic_vector(31 downto 0)   -- unsigned less-than
  );
end addsub_32;

architecture structural of addsub_32 is


  -- Component declarations


  component carry_lookahead_adderN is
    generic(N : integer := 32);
    port(
      A    : in  std_logic_vector(N-1 downto 0);
      B    : in  std_logic_vector(N-1 downto 0);
      Cin  : in  std_logic;
      Sum  : out std_logic_vector(N-1 downto 0);
      Cout : out std_logic
    );
  end component;

  component xorg2 is
    port(i_A : in std_logic; i_B : in std_logic; o_F : out std_logic);
  end component;

  component andg2 is
    port(i_A : in std_logic; i_B : in std_logic; o_F : out std_logic);
  end component;

  component invg is
    port(i_A : in std_logic; o_F : out std_logic);
  end component;


 
  

  -- B XOR nAdd_Sub  (inverts B for subtraction)
  signal s_B_xor   : std_logic_vector(31 downto 0);

  -- adder result and carry
  signal s_Sum     : std_logic_vector(31 downto 0);
  signal s_Cout    : std_logic;

  -- overflow computation signals
  signal s_Bxor31       : std_logic;  -- B[31] XOR nAdd_Sub
  signal s_AB_same_sign : std_logic;  -- NOT (A[31] XOR s_Bxor31)
  signal s_AB_xor_pre   : std_logic;  -- A[31] XOR s_Bxor31  (intermediate)
  signal s_res_diff_sign: std_logic;  -- A[31] XOR Result[31]
  signal s_overflow     : std_logic;

  -- SLT
  signal s_slt_bit  : std_logic;  -- Result[31] XOR overflow
  signal s_sltu_bit : std_logic;  -- NOT Cout

begin

  
  -- XOR each B bit with nAdd_Sub to conditionally invert B
 
  G_B_XOR: for i in 0 to 31 generate
    XOR_INST: xorg2
      port map(i_A => i_B(i), i_B => i_nAdd_Sub, o_F => s_B_xor(i));
  end generate G_B_XOR;

  -- RIPPLE CARRY ADDER
  --   ADD: A + B + 0
  --   SUB: A + ~B + 1  (i_nAdd_Sub fed as Cin)
  
  ADDER: carry_lookahead_adderN
    generic map(N => 32)
    port map(
      A    => i_A,
      B    => s_B_xor,
      Cin  => i_nAdd_Sub,
      Sum  => s_Sum,
      Cout => s_Cout
    );


  -- SIGNED OVERFLOW DETECTION
  --   s_Bxor31       = B[31] XOR nAdd_Sub   (effective sign of B into adder)
  --   s_AB_xor_pre   = A[31] XOR s_Bxor31
  --   s_AB_same_sign = NOT(s_AB_xor_pre)
  --   s_res_diff     = A[31] XOR Result[31]
  --   s_overflow     = s_AB_same_sign AND s_res_diff

  XOR_BCTRL: xorg2
    port map(i_A => i_B(31), i_B => i_nAdd_Sub, o_F => s_Bxor31);

  XOR_AB: xorg2
    port map(i_A => i_A(31), i_B => s_Bxor31, o_F => s_AB_xor_pre);

  INV_AB: invg
    port map(i_A => s_AB_xor_pre, o_F => s_AB_same_sign);

  XOR_RESULT: xorg2
    port map(i_A => i_A(31), i_B => s_Sum(31), o_F => s_res_diff_sign);

  AND_OVF: andg2
    port map(i_A => s_AB_same_sign, i_B => s_res_diff_sign, o_F => s_overflow);

 
  -- SLT  (signed less-than)
  --   slt_bit = Result[31] XOR overflow
 
  XOR_SLT: xorg2
    port map(i_A => s_Sum(31), i_B => s_overflow, o_F => s_slt_bit);


  -- SLTU  (unsigned less-than)
  --   sltu_bit = NOT Cout  (borrow means A < B unsigned)
 
  INV_COUT: invg
    port map(i_A => s_Cout, o_F => s_sltu_bit);


  -- OUTPUTS
  
  o_Sum      <= s_Sum;
  o_Cout     <= s_Cout;
  o_Overflow <= s_overflow;

  -- SLT result: only bit 0 meaningful, upper bits = 0
  o_SLT  <= (31 downto 1 => '0') & s_slt_bit;
  o_SLTU <= (31 downto 1 => '0') & s_sltu_bit;

end structural;
