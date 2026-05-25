-------------------------------------------------------------------------
-- Jay Patel 
-- sc_processor_control_unit.vhd
--
-- Main control unit for RISC-V single-cycle processor.
-- Decodes the 7-bit opcode and drives all datapath control signals.
--
-- Supported opcodes (section 3.1 baseline):
--   R-type  : 0110011  (add, sub, and, or, xor, slt, sltu, sll, srl, sra)
--   I-ALU   : 0010011  (addi, andi, ori, xori, slti, sltiu, slli, srli, srai)
--   Load    : 0000011  (lw, lh, lb, lhu, lbu)
--   Store   : 0100011  (sw)
--   Branch  : 1100011  (beq, bne, blt, bge, bltu, bgeu)
--   JAL     : 1101111
--   JALR    : 1100111
--   LUI     : 0110111
--   AUIPC   : 0010111
--
-- ALUOp encoding (feeds into alu_control.vhd):
--   "000" = force ADD         (loads, stores)
--   "001" = force SUB         (branches -- for comparison)
--   "010" = R-type decode     (use funct3 + funct7)
--   "011" = I-type ALU decode (use funct3 only)
--   "100" = LUI force pass through 
--   "101" = AUIPC PC+imm 
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity sc_processor_control_unit is
  port(
    i_opcode   : in  std_logic_vector(6 downto 0);  -- instruction [6:0]

    o_ALUSrc   : out std_logic;                      -- 0=rs2  1=imm
    o_MemToReg : out std_logic_vector(1 downto 0);                      -- 0=ALU  1=mem
    o_RegWrite : out std_logic;                      -- 1=write rd
    o_MemRead  : out std_logic;                      -- 1=read  data mem
    o_MemWrite : out std_logic;                      -- 1=write data mem
    o_Branch   : out std_logic;                      -- 1=conditional branch
    o_Jump     : out std_logic;                      -- 1=unconditional jump (jal/jalr)
    o_PC_SRC   : out std_logic; 		     -- 1= use rs1 as PC base (JALR only) 
    o_ALUOp    : out std_logic_vector(2 downto 0);   -- ALU operation selector
    o_Halt     : out std_logic		     	     -- 1=halt (WFI instruction)
  );
end sc_processor_control_unit;

architecture dataflow of sc_processor_control_unit is

-----------------------------------------------------------------------
-- s_ctrl bit layout (13 bits):
--   [12]   Halt
--   [11]   PC_SRC
--   [10]   ALUSrc
--   [9:8]  MemToReg
--   [7]    RegWrite
--   [6]    MemRead
--   [5]    MemWrite
--   [4]    Branch
--   [3]    Jump
--   [2:0]  ALUOp
-----------------------------------------------------------------------
signal s_ctrl : std_logic_vector(12 downto 0);

begin
with i_opcode select
  s_ctrl <=
    -- R-type:  PC_SRC=0 ALUSrc=0 MTR=00 RW=1 MR=0 MW=0 Br=0 Jmp=0 ALUOp=010
    "0000010000010" when "0110011",

    -- I-ALU:   PC_SRC=0 ALUSrc=1 MTR=00 RW=1 MR=0 MW=0 Br=0 Jmp=0 ALUOp=011
    "0010010000011" when "0010011",

    -- Load:    PC_SRC=0 ALUSrc=1 MTR=01 RW=1 MR=1 MW=0 Br=0 Jmp=0 ALUOp=000
    "0010111000000" when "0000011",

    -- Store:   PC_SRC=0 ALUSrc=1 MTR=00 RW=0 MR=0 MW=1 Br=0 Jmp=0 ALUOp=000
    "0010000100000" when "0100011",

    -- Branch:  PC_SRC=0 ALUSrc=0 MTR=00 RW=0 MR=0 MW=0 Br=1 Jmp=0 ALUOp=001
    "0000000010001" when "1100011",

    -- JAL:     PC_SRC=0 ALUSrc=0 MTR=10 RW=1 MR=0 MW=0 Br=0 Jmp=1 ALUOp=000
    "0001010001000" when "1101111",

    -- JALR:    PC_SRC=1 ALUSrc=1 MTR=10 RW=1 MR=0 MW=0 Br=0 Jmp=1 ALUOp=000
    "0111010001000" when "1100111",

    -- LUI:     PC_SRC=0 ALUSrc=1 MTR=00 RW=1 MR=0 MW=0 Br=0 Jmp=0 ALUOp=100
    "0010010000100" when "0110111",

    -- AUIPC:   PC_SRC=0 ALUSrc=1 MTR=00 RW=1 MR=0 MW=0 Br=0 Jmp=0 ALUOp=101
    "0010010000101" when "0010111",

    -- Halt: WFI 
    "1000000000000" when "1110011",
    -- Default: all disabled
    "0000000000000" when others;

-----------------------------------------------------------------------
-- Unpack
-----------------------------------------------------------------------
o_Halt	   <= s_ctrl(12);
o_PC_SRC   <= s_ctrl(11);
o_ALUSrc   <= s_ctrl(10);
o_MemToReg <= s_ctrl(9 downto 8);
o_RegWrite <= s_ctrl(7);
o_MemRead  <= s_ctrl(6);
o_MemWrite <= s_ctrl(5);
o_Branch   <= s_ctrl(4);
o_Jump     <= s_ctrl(3);
o_ALUOp    <= s_ctrl(2 downto 0);

end dataflow;
