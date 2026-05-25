-------------------------------------------------------------------------
-- Shawn Robinson (amended)
-------------------------------------------------------------------------
-- immediate_generator.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Generating the correct RISC-V 32I immediate out,
-- having been fed the full instruction.
--
-- CHANGES FROM ORIGINAL:
--   - B-type and J-type now have implicit LSB '0' appended after
--     sign extension to correctly represent 2-byte aligned offsets
--   - Removed unused signals: s_branch_and_zero, s_12_bits, s_20_bits
--   - Added s_b_shifted and s_j_shifted for corrected offsets
--
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity immediate_generator is
  port(
    instruction        : in  std_logic_vector(31 downto 0);
    immediate_generate : out std_logic_vector(31 downto 0)
  );
end immediate_generator;

architecture dataflow of immediate_generator is

  signal s_opcode  : std_logic_vector(6 downto 0);

  -- Raw bit extractions per format
  signal s_i_bits  : std_logic_vector(11 downto 0);  -- I-type
  signal s_s_bits  : std_logic_vector(11 downto 0);  -- S-type
  signal s_b_bits  : std_logic_vector(11 downto 0);  -- B-type
  signal s_u_bits  : std_logic_vector(19 downto 0);  -- U-type
  signal s_j_bits  : std_logic_vector(19 downto 0);  -- J-type

  -- Sign-extended intermediates
  signal s_i_ext   : std_logic_vector(31 downto 0);
  signal s_s_ext   : std_logic_vector(31 downto 0);
  signal s_b_ext   : std_logic_vector(31 downto 0);
  signal s_j_ext   : std_logic_vector(31 downto 0);
  signal s_u_ext   : std_logic_vector(31 downto 0);

  -- Shifted versions for B and J (insert implicit LSB '0')
  signal s_b_shifted : std_logic_vector(31 downto 0);
  signal s_j_shifted : std_logic_vector(31 downto 0);

  component bitextender_12to32 is
    port(imm12_in    : in  std_logic_vector(11 downto 0);
         sign_select : in  std_logic;
         imm32_out   : out std_logic_vector(31 downto 0));
  end component;

  component bitextender_20to32 is
    port(imm20_in    : in  std_logic_vector(19 downto 0);
         sign_select : in  std_logic;
         imm32_out   : out std_logic_vector(31 downto 0));
  end component;

begin

  s_opcode <= instruction(6 downto 0);

  -----------------------------------------------------------------------
  -- Bit extractions
  -- I-type: [31:20]
  -- S-type: [31:25] & [11:7]
  -- B-type: [31|7|30:25|11:8]  (bit 0 implicit '0', added after extension)
  -- U-type: [31:12]             (bits [11:0] = 0, handled in s_u_ext)
  -- J-type: [31|19:12|20|30:21] (bit 0 implicit '0', added after extension)
  -----------------------------------------------------------------------
  s_i_bits <= instruction(31 downto 20);
  s_s_bits <= instruction(31 downto 25) & instruction(11 downto 7);
  s_b_bits <= instruction(31) & instruction(7) &
              instruction(30 downto 25) & instruction(11 downto 8);
  s_u_bits <= instruction(31 downto 12);
  s_j_bits <= instruction(31) & instruction(19 downto 12) &
              instruction(20) & instruction(30 downto 21);

  -----------------------------------------------------------------------
  -- Sign extension instances
  -----------------------------------------------------------------------
  I_EXT: bitextender_12to32
    port map(imm12_in    => s_i_bits,
             sign_select => '1',
             imm32_out   => s_i_ext);

  S_EXT: bitextender_12to32
    port map(imm12_in    => s_s_bits,
             sign_select => '1',
             imm32_out   => s_s_ext);

  B_EXT: bitextender_12to32
    port map(imm12_in    => s_b_bits,
             sign_select => '1',
             imm32_out   => s_b_ext);

  J_EXT: bitextender_20to32
    port map(imm20_in    => s_j_bits,
             sign_select => '1',
             imm32_out   => s_j_ext);

  -----------------------------------------------------------------------
  -- U-type: shift bits [31:12] into position, zero-fill lower 12 bits
  -----------------------------------------------------------------------
  s_u_ext <= s_u_bits & x"000";

  -----------------------------------------------------------------------
  -- B-type and J-type: append implicit LSB '0' after sign extension.
  -- RISC-V branch and jump offsets are always 2-byte aligned so bit 0
  -- is never encoded in the instruction -- it is always '0'.
  -- The sign bit is preserved in bit 31 after the shift.
  -----------------------------------------------------------------------
  s_b_shifted <= s_b_ext(30 downto 0) & '0';
  s_j_shifted <= s_j_ext(30 downto 0) & '0';

  -----------------------------------------------------------------------
  -- Output mux: select immediate format based on opcode
  -----------------------------------------------------------------------
  with s_opcode select
    immediate_generate <=
      s_i_ext     when "0010011",   -- I-ALU  (addi, xori, etc.)
      s_i_ext     when "0000011",   -- Load   (lw, lh, lb, etc.)
      s_i_ext     when "1100111",   -- JALR
      s_s_ext     when "0100011",   -- Store  (sw)
      s_b_shifted when "1100011",   -- Branch (beq, bne, blt, etc.)
      s_u_ext     when "0110111",   -- LUI
      s_u_ext     when "0010111",   -- AUIPC
      s_j_shifted when "1101111",   -- JAL
      x"00000000" when others;

end dataflow;