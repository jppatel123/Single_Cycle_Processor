-------------------------------------------------------------------------
-- Shawn Robinson 
-------------------------------------------------------------------------


-- fetch_unit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Fetch unit ready for implementation, with functioning PC Register 
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

--library work;
--use work.RISCV_types.all;

entity fetch_unit is
  generic(N : integer := 32);
  port(iCLK            		: in std_logic;
       iRST            		: in std_logic;
       rs1			: in std_logic_vector(31 downto 0); 
       PC_SRC			: in std_logic; 
       JUMP			: in std_logic; 
       BRANCH			: in std_logic; 
       ZERO			: in std_logic; 
       immediate_generate 	: in std_logic_vector(31 downto 0);
       o_PC         		: out std_logic_vector(31 downto 0); --THIS WIRES DIRECTLY TO SKELETON s_PC! 
       Pc_plus4			: out std_logic_vector(31 downto 0)); 
end  fetch_unit;


architecture structure of fetch_unit is

	constant c_immediate_four 	: std_logic_vector(31 downto 0) := x"00000004"; 
	signal s_next_PC		: std_logic_vector(31 downto 0); 
	signal s_pc_base		: std_logic_vector(31 downto 0); 
	signal s_pc_offset			: std_logic_vector(31 downto 0); 
	signal s_branch_or_jump		: std_logic; 
	signal s_branch_and_zero	: std_logic; 
	signal s_current_PC		: std_logic_vector(31 downto 0); 
	signal s_pc_plus4		: std_logic_vector(31 downto 0); 

	--handling a risc-v shift left one requirement
	signal s_imm_shifted		: std_logic_vector(31 downto 0); 
	

  component register_NBit is 
	generic(N: integer := 32); 
	port(D		: in std_logic_vector(N-1 downto 0); 
		RST	: in std_logic; 
		WE	: in std_logic; 
		CLK	: in std_logic; 
		Q	: out std_logic_vector(N-1 downto 0));
  end component;  		


  component andg2 is 
    port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

  end component; 


  component org2 is
    port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

  end component; 

  
 component mux2t1_N is 
  generic(N : integer);
  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));

 end component;
 

  component ripple_carry_adderN is
  generic(N : integer); 
  port(A         : in std_logic_vector(N-1 downto 0);
       B         : in std_logic_vector(N-1 downto 0);
       Cin       : in std_logic := '0';
       Sum	 : out std_logic_vector(N-1 downto 0);  
       Cout      : out std_logic); 

  end component;

begin
  s_imm_shifted <= immediate_generate; 

  s_PC 		<= s_current_PC; 
  PC_plus4	<= s_pc_plus4; 

  PC_REG: register_NBit
	generic map(N => 32)
	port map(D	=> s_next_PC,
		 RST	=> iRST,
		 WE	=> '1', -- pc always updates every cycle
		 CLK	=> iCLK,
		 Q	=> s_current_PC); 



  BranchZero_And : andg2
    port map(i_A 	=> BRANCH,
	     i_B 	=> ZERO,
             o_F 	=> s_branch_and_zero
	     );

  Jump_BZ_Or	: org2
    port map(i_A 	=> JUMP,
             i_B 	=> s_branch_and_zero, 
	     o_F 	=> s_branch_or_jump
	     ); 

  PC_AUX: mux2t1_N
    generic map(N => 32)
    port map(   i_S	=> s_branch_or_jump,
		i_D0	=> c_immediate_four,
		i_D1	=> immediate_generate,
		o_O	=>  s_pc_offset
		);
  PC_BASE: mux2t1_N
    generic map(N => 32)
    port map(   i_S	=> PC_SRC,
		i_D0	=> s_current_PC,
		i_D1	=> rs1,
		o_O	=>  s_pc_base
		);

  NEXT_PC_ADD: ripple_carry_adderN 
    generic map(N => 32)
    port map(	A	=> s_pc_offset,
		B	=> s_pc_base,
		Sum 	=> s_next_PC,
		Cout	=> open
		); 
  PC4_ADD:	ripple_carry_adderN
	generic map(N => 32)
	port map(A	=> s_current_PC,
		 B	=> c_immediate_four,
		 Sum	=> s_pc_plus4,
		 Cout	=> open);

end structure;