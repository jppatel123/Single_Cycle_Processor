-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- register_file.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Putting all the pieces together to create a RISC-V 32-bit register file 
--
--
-- NOTES:
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
--use work.types_package.all; 
use work.RISCV_types.all;
entity register_file is

port(clk 		: in std_logic; 
     reset		: in std_logic; 
     write_enable	: in std_logic; 
     rd_address		: in std_logic_vector(4 downto 0); 
     rd_data		: in std_logic_vector(31 downto 0); 
     rs1_address	: in std_logic_vector(4 downto 0); 
     rs2_address	: in std_logic_vector(4 downto 0); 
     rs1_out		: out std_logic_vector(31 downto 0); 
     rs2_out		: out std_logic_vector(31 downto 0)
);

end register_file;

architecture structural of register_file is

  component decoder_5to32 is 
  port(input_address	: in std_logic_vector(4 downto 0); 
       enabled_line_out	: out std_logic_vector(31 downto 0));

  end component; 

  component register_NBit is
  generic(N : integer := 32); 
  port(D		: in std_logic_vector(N-1 downto 0); 
       RST		: in std_logic;
       WE		: in std_logic;
       CLK		: in std_logic;
       Q		: out std_logic_vector(N-1 downto 0));  

  end component;

  component source_register is
     port(register_lines		: in bus_32_t;  
     address_select_lines	: in std_logic_vector(4 downto 0);
     output_lines		: out std_logic_vector(31 downto 0));
  end component; 
  
  signal decoder_out		: std_logic_vector(31 downto 0);
  signal write_e_mask		: std_logic_vector(31 downto 0);  
  signal gated_write_enable	: std_logic_vector(31 downto 0); 
  signal risc_registers		: bus_32_t; 
	

begin

--Instance of the decoder 
  	WRITE_DECODER: decoder_5to32
		port map(
			input_address => rd_address, 
			enabled_line_out =>  decoder_out); 

-- Disclosure: I researched with Gemini to make sure I got this masking right in VHDL 
	write_e_mask <= (others => write_enable); 
	gated_write_enable <= (decoder_out and write_e_mask) and x"FFFFFFFE";

--RISC-V x0 always zero 
	risc_registers(0) <= x"00000000";

G_32bitRegisters: for i in 1 to 31 generate
  THIRTYTWOREGI: register_NBit 
	generic map (N => 32)
	port map(
		D 	=> rd_data,
		RST	=> reset,
		WE	=> gated_write_enable(i),
		CLK	=> clk,
		Q	=> risc_registers(i)

	);

  end generate G_32bitRegisters; 

	RS1_READ: source_register
		port map(
			register_lines 		=> risc_registers,
			address_select_lines 	=> rs1_address,
			output_lines		=> rs1_out);

	RS2_READ: source_register
		port map(
			register_lines 		=> risc_registers,
			address_select_lines 	=> rs2_address,
			output_lines		=> rs2_out);
  
  
end structural;
