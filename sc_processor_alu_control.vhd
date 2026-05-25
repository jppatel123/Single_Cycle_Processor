-------------------------------------------------------------------------
-- Jay Patel
-- sc_processor_alu_control.vhd
--
-- ALU control unit for RISC-V single-cycle processor.
-- Takes ALUOp from the main control unit + funct3 + funct7 bit 5
-- and outputs a 4-bit ALU operation code.
--
-- ALUOp from control_unit.vhd:
--   "00" -> ADD  (loads, stores)
--   "01" -> SUB  (branches)
--   "10" -> decode funct3 + funct7_5  (R-type)
--   "11" -> decode funct3 only        (I-type ALU: addi, xori, etc.)
--
-- o_ALUCtrl encoding:
--   "0000" = ADD
--   "0001" = SUB
--   "0010" = AND
--   "0011" = OR
--   "0100" = XOR
--   "0101" = SLT  (signed)
--   "0110" = SLTU (unsigned)
--   "0111" = SLL
--   "1000" = SRL
--   "1001" = SRA
--   "1010" = LUI passthrough (B input straight through -- used by datapath)
--   "1111" = default / undefined
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity sc_processor_alu_control is
  port(
    i_ALUOp   : in  std_logic_vector(2 downto 0);  -- from control_unit
    i_funct3  : in  std_logic_vector(2 downto 0);  -- instruction [14:12]
    i_funct7_5: in  std_logic;                      -- instruction bit 30 (funct7[5])

    o_ALUCtrl : out std_logic_vector(3 downto 0)   -- to ALU operation select
  );
end sc_processor_alu_control;

architecture dataflow of sc_processor_alu_control is

  -----------------------------------------------------------------------
  -- Combine inputs into one select key:
  --   key = ALUOp(2) & ALUOp(1) & ALUOp(0) & funct3(2) & funct3(1) & funct3(0) & funct7_5
  --   7 bits total
  -----------------------------------------------------------------------
  signal s_key : std_logic_vector(6 downto 0);

begin

  s_key <= i_ALUOp & i_funct3 & i_funct7_5;

  -----------------------------------------------------------------------
 
  -----------------------------------------------------------------------
  with s_key select
    o_ALUCtrl <=

      -------------------------------------------------------------------
      -- ALUOp = "000" : force ADD (loads, stores)
      -- all 16 funct3/funct7_5 combinations
      -------------------------------------------------------------------
      "0000" when "0000000",
      "0000" when "0000001",
      "0000" when "0000010",
      "0000" when "0000011",
      "0000" when "0000100",
      "0000" when "0000101",
      "0000" when "0000110",
      "0000" when "0000111",
      "0000" when "0001000",
      "0000" when "0001001",
      "0000" when "0001010",
      "0000" when "0001011",
      "0000" when "0001100",
      "0000" when "0001101",
      "0000" when "0001110",
      "0000" when "0001111",

      -------------------------------------------------------------------
      -- ALUOp = "001" : branches (decode funct3, funct7_5 don't-care)
      --   funct3=000 -> beq  -> SUB (check zero)
      --   funct3=001 -> bne  -> SUB (check zero, inverted)
      --   funct3=100 -> blt  -> SLT
      --   funct3=101 -> bge  -> SLT (inverted in branch logic)
      --   funct3=110 -> bltu -> SLTU
      --   funct3=111 -> bgeu -> SLTU (inverted in branch logic)
      --   funct3=010/011 -> undefined in RISC-V, default
      -------------------------------------------------------------------
      "0001" when "0010000",   -- beq,  funct7_5=0
      "0001" when "0010001",   -- beq,  funct7_5=1
      "0001" when "0010010",   -- bne,  funct7_5=0
      "0001" when "0010011",   -- bne,  funct7_5=1
      "1111" when "0010100",   -- undefined funct3=010, funct7_5=0
      "1111" when "0010101",   -- undefined funct3=010, funct7_5=1
      "1111" when "0010110",   -- undefined funct3=011, funct7_5=0
      "1111" when "0010111",   -- undefined funct3=011, funct7_5=1
      "0101" when "0011000",   -- blt,  funct7_5=0
      "0101" when "0011001",   -- blt,  funct7_5=1
      "0101" when "0011010",   -- bge,  funct7_5=0
      "0101" when "0011011",   -- bge,  funct7_5=1
      "0110" when "0011100",   -- bltu, funct7_5=0
      "0110" when "0011101",   -- bltu, funct7_5=1
      "0110" when "0011110",   -- bgeu, funct7_5=0
      "0110" when "0011111",   -- bgeu, funct7_5=1

      -------------------------------------------------------------------
      -- ALUOp = "010" : R-type (funct3 + funct7_5 fully decoded)
      -- undefined funct3/funct7_5 combinations -> default
      -------------------------------------------------------------------
      "0000" when "0100000",   -- ADD  funct3=000 funct7_5=0
      "0001" when "0100001",   -- SUB  funct3=000 funct7_5=1
      "0111" when "0100010",   -- SLL  funct3=001 funct7_5=0
      "1111" when "0100011",   -- undefined
      "0101" when "0100100",   -- SLT  funct3=010 funct7_5=0
      "1111" when "0100101",   -- undefined
      "0110" when "0100110",   -- SLTU funct3=011 funct7_5=0
      "1111" when "0100111",   -- undefined
      "0100" when "0101000",   -- XOR  funct3=100 funct7_5=0
      "1111" when "0101001",   -- undefined
      "1000" when "0101010",   -- SRL  funct3=101 funct7_5=0
      "1001" when "0101011",   -- SRA  funct3=101 funct7_5=1
      "0011" when "0101100",   -- OR   funct3=110 funct7_5=0
      "1111" when "0101101",   -- undefined
      "0010" when "0101110",   -- AND  funct3=111 funct7_5=0
      "1111" when "0101111",   -- undefined

      -------------------------------------------------------------------
      -- ALUOp = "011" : I-type ALU (funct3 decoded, funct7_5 only for srai)
      -------------------------------------------------------------------
      "0000" when "0110000",   -- ADDI  funct3=000 funct7_5=0
      "0000" when "0110001",   -- ADDI  funct3=000 funct7_5=1 (don't-care)
      "0111" when "0110010",   -- SLLI  funct3=001 funct7_5=0
      "1111" when "0110011",   -- undefined (funct7_5=1 invalid for SLLI)
      "0101" when "0110100",   -- SLTI  funct3=010 funct7_5=0
      "0101" when "0110101",   -- SLTI  funct3=010 funct7_5=1 (don't-care)
      "0110" when "0110110",   -- SLTIU funct3=011 funct7_5=0
      "0110" when "0110111",   -- SLTIU funct3=011 funct7_5=1 (don't-care)
      "0100" when "0111000",   -- XORI  funct3=100 funct7_5=0
      "0100" when "0111001",   -- XORI  funct3=100 funct7_5=1 (don't-care)
      "1000" when "0111010",   -- SRLI  funct3=101 funct7_5=0
      "1001" when "0111011",   -- SRAI  funct3=101 funct7_5=1
      "0011" when "0111100",   -- ORI   funct3=110 funct7_5=0
      "0011" when "0111101",   -- ORI   funct3=110 funct7_5=1 (don't-care)
      "0010" when "0111110",   -- ANDI  funct3=111 funct7_5=0
      "0010" when "0111111",   -- ANDI  funct3=111 funct7_5=1 (don't-care)

      -------------------------------------------------------------------
      -- ALUOp = "100" : LUI -> passthrough immediate (all 16 don't-care)
      -------------------------------------------------------------------
      "1010" when "1000000",
      "1010" when "1000001",
      "1010" when "1000010",
      "1010" when "1000011",
      "1010" when "1000100",
      "1010" when "1000101",
      "1010" when "1000110",
      "1010" when "1000111",
      "1010" when "1001000",
      "1010" when "1001001",
      "1010" when "1001010",
      "1010" when "1001011",
      "1010" when "1001100",
      "1010" when "1001101",
      "1010" when "1001110",
      "1010" when "1001111",

      -------------------------------------------------------------------
      -- ALUOp = "101" : AUIPC -> ADD PC + immediate (all 16 don't-care)
      -------------------------------------------------------------------
      "0000" when "1010000",
      "0000" when "1010001",
      "0000" when "1010010",
      "0000" when "1010011",
      "0000" when "1010100",
      "0000" when "1010101",
      "0000" when "1010110",
      "0000" when "1010111",
      "0000" when "1011000",
      "0000" when "1011001",
      "0000" when "1011010",
      "0000" when "1011011",
      "0000" when "1011100",
      "0000" when "1011101",
      "0000" when "1011110",
      "0000" when "1011111",

      -------------------------------------------------------------------
      -- Default
      -------------------------------------------------------------------
      "1111" when others;

end dataflow;