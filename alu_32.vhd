
-- Jay Patel (amended)
-- alu_32.vhd

library IEEE;
use IEEE.std_logic_1164.all;

entity alu_32 is
  port(
    i_A      : in  std_logic_vector(31 downto 0);  -- operand A (rs1, PC, or zero -- see datapath)
    i_B      : in  std_logic_vector(31 downto 0);  -- operand B (rs2 or imm)
    i_ALUCtrl: in  std_logic_vector(3  downto 0);  -- from alu_control.vhd

    o_Result : out std_logic_vector(31 downto 0);
    o_Zero   : out std_logic;                       -- 1 when result == 0
    o_SLT    : out std_logic_vector(31 downto 0);   -- exposed for branch logic
    o_SLTU   : out std_logic_vector(31 downto 0)    -- exposed for branch logic
  );
end alu_32;

architecture structural of alu_32 is

  component addsub_32 is
    port(
      i_A        : in  std_logic_vector(31 downto 0);
      i_B        : in  std_logic_vector(31 downto 0);
      i_nAdd_Sub : in  std_logic;
      o_Sum      : out std_logic_vector(31 downto 0);
      o_Cout     : out std_logic;
      o_Overflow : out std_logic;
      o_SLT      : out std_logic_vector(31 downto 0);
      o_SLTU     : out std_logic_vector(31 downto 0)
    );
  end component;

  component barrel_shifter is
    port(
      i_A     : in  std_logic_vector(31 downto 0);
      i_shamt : in  std_logic_vector(4  downto 0);
      i_arith : in  std_logic;
      i_left  : in  std_logic;
      o_result: out std_logic_vector(31 downto 0)
    );
  end component;

  component andg2 is
    port(i_A : in std_logic; i_B : in std_logic; o_F : out std_logic);
  end component;

  component org2 is
    port(i_A : in std_logic; i_B : in std_logic; o_F : out std_logic);
  end component;

  component xorg2 is
    port(i_A : in std_logic; i_B : in std_logic; o_F : out std_logic);
  end component;

  component invg is
    port(i_A : in std_logic; o_F : out std_logic);
  end component;

  signal s_add_result  : std_logic_vector(31 downto 0);
  signal s_sub_result  : std_logic_vector(31 downto 0);
  signal s_slt_result  : std_logic_vector(31 downto 0);
  signal s_sltu_result : std_logic_vector(31 downto 0);
  signal s_sll_result  : std_logic_vector(31 downto 0);
  signal s_srl_result  : std_logic_vector(31 downto 0);
  signal s_sra_result  : std_logic_vector(31 downto 0);
  signal s_and_result  : std_logic_vector(31 downto 0);
  signal s_or_result   : std_logic_vector(31 downto 0);
  signal s_xor_result  : std_logic_vector(31 downto 0);

  signal s_Cout_add    : std_logic;
  signal s_Cout_sub    : std_logic;
  signal s_Ovf_add     : std_logic;
  signal s_Ovf_sub     : std_logic;

  signal s_shamt       : std_logic_vector(4 downto 0);
  signal s_result      : std_logic_vector(31 downto 0);
  signal s_or_chain    : std_logic_vector(30 downto 0);

begin

  s_shamt <= i_B(4 downto 0);

  ADDER_INST: addsub_32
    port map(
      i_A        => i_A,
      i_B        => i_B,
      i_nAdd_Sub => '0',
      o_Sum      => s_add_result,
      o_Cout     => s_Cout_add,
      o_Overflow => s_Ovf_add,
      o_SLT      => open,
      o_SLTU     => open
    );

  SUBBER_INST: addsub_32
    port map(
      i_A        => i_A,
      i_B        => i_B,
      i_nAdd_Sub => '1',
      o_Sum      => s_sub_result,
      o_Cout     => s_Cout_sub,
      o_Overflow => s_Ovf_sub,
      o_SLT      => s_slt_result,
      o_SLTU     => s_sltu_result
    );

  SHIFT_LEFT: barrel_shifter
    port map(
      i_A      => i_A,
      i_shamt  => s_shamt,
      i_arith  => '0',
      i_left   => '1',
      o_result => s_sll_result
    );

  SHIFT_RIGHT_L: barrel_shifter
    port map(
      i_A      => i_A,
      i_shamt  => s_shamt,
      i_arith  => '0',
      i_left   => '0',
      o_result => s_srl_result
    );

  SHIFT_RIGHT_A: barrel_shifter
    port map(
      i_A      => i_A,
      i_shamt  => s_shamt,
      i_arith  => '1',
      i_left   => '0',
      o_result => s_sra_result
    );

  G_AND: for i in 0 to 31 generate
    AND_INST: andg2
      port map(i_A => i_A(i), i_B => i_B(i), o_F => s_and_result(i));
  end generate G_AND;

  G_OR: for i in 0 to 31 generate
    OR_INST: org2
      port map(i_A => i_A(i), i_B => i_B(i), o_F => s_or_result(i));
  end generate G_OR;

  G_XOR: for i in 0 to 31 generate
    XOR_INST: xorg2
      port map(i_A => i_A(i), i_B => i_B(i), o_F => s_xor_result(i));
  end generate G_XOR;

  -- OUTPUT MUX
  -- "1010" = LUI: pass i_B (immediate) straight through.
  -- i_A must be driven to zero by the datapath for LUI (handled in skeleton).
  -- i_A must be driven to PC for AUIPC (handled in skeleton).
  with i_ALUCtrl select
    s_result <=
      s_add_result    when "0000",   -- ADD / ADDI / AUIPC (i_A=PC from datapath)
      s_sub_result    when "0001",   -- SUB / branch compare
      s_and_result    when "0010",   -- AND / ANDI
      s_or_result     when "0011",   -- OR  / ORI
      s_xor_result    when "0100",   -- XOR / XORI
      s_slt_result    when "0101",   -- SLT / SLTI / BLT / BGE
      s_sltu_result   when "0110",   -- SLTU/ SLTIU / BLTU/ BGEU
      s_sll_result    when "0111",   -- SLL / SLLI
      s_srl_result    when "1000",   -- SRL / SRLI
      s_sra_result    when "1001",   -- SRA / SRAI
      i_B             when "1010",   -- LUI: immediate passthrough 
      (others => '0') when others;

  o_Result <= s_result;

  -- Expose SLT/SLTU directly for use in branch condition logic in the skeleton.
  -- The fetch unit currently only accepts ZERO -- blt/bge/bltu/bgeu will need
  -- additional condition handling upstream. See fetch unit ZERO input limitation.
  o_SLT  <= s_slt_result;
  o_SLTU <= s_sltu_result;

  -- ZERO FLAG: OR-reduce all 32 result bits then invert.
  -- Correctly detects beq/bne (SUB result = 0 means equal).
  -- NOTE: s_or_chain is now 31 bits (indices 0 to 30) to match the
  -- 31 org2 instances needed to OR-reduce 32 bits down to one.
  OR_CHAIN_0: org2
    port map(i_A => s_result(0), i_B => s_result(1), o_F => s_or_chain(0));

  G_OR_CHAIN: for i in 1 to 30 generate
    OR_Ci: org2
      port map(i_A => s_or_chain(i-1), i_B => s_result(i+1), o_F => s_or_chain(i));
  end generate G_OR_CHAIN;

  ZERO_INV: invg
    port map(i_A => s_or_chain(30), o_F => o_Zero);

end structural;