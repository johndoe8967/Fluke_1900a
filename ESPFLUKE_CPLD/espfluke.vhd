library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity espfluke is
	port (	CLK_MASTER : in std_logic;
		SCL_IN : in std_logic;
		SDA_BI : inout std_logic;
		OUT_IN : in std_logic_vector (3 downto 0);
		AS_IN  : in std_logic_vector (6 downto 1);
		OVFL_IN: in std_logic;
		DS_IN  : in std_logic;
		MUP_IN : in std_logic;
		ML_IN  : in std_logic;
		RNG2_IN: in std_logic;
		LED    : out std_logic
	);
end;
 
architecture espfluke_arch of espfluke is
  component I2C_SLAVE
  	port (
		scl              : inout std_logic;
		sda              : inout std_logic;
		clk              : in    std_logic;
		rst              : in    std_logic;
		    -- User interface
		transfer	 : out   std_logic;
		read_req         : out   std_logic;
		stop	     	 : out   std_logic;
		data_to_master   : in    std_logic_vector(7 downto 0)
	);
  end component;
  signal READ_REQ_SIG 		: std_logic;
  signal DATA_VALID_SIG		: std_logic;
  signal DATA_TO_MASTER_SIG	: std_logic_vector(7 downto 0);
  signal DATA_FROM_MASTER_SIG	: std_logic_vector(7 downto 0);

  signal BCD1_SIG		: std_logic_vector(3 downto 0);
  signal BCD2_SIG		: std_logic_vector(3 downto 0);
  signal BCD3_SIG		: std_logic_vector(3 downto 0);
  signal BCD4_SIG		: std_logic_vector(3 downto 0);
  signal BCD5_SIG		: std_logic_vector(3 downto 0);
  signal BCD6_SIG		: std_logic_vector(3 downto 0);
  signal STATUS_SIG		: std_logic_vector(6 downto 0);

  signal CNT_SIG		: std_logic_vector(1 downto 0);

  signal TRANSFER_SIG		: std_logic;
  signal STOP_SIG		: std_logic;
  signal UPDATE_SIG		: std_logic;

  signal N			: std_logic;
  signal M			: std_logic;
  signal L			: std_logic;
  signal OVFL_SIG		: std_logic;
  signal TRIGGER_SIG		: std_logic; -- '1'->neue Messung verfügbar
  signal ML_SIG			: std_logic; -- '1'->kHz 		'0'->MHz
  signal FREQ_SIG		: std_logic; -- '1'->Frequenzmessung 	'0'->Periodendauermessung
begin

  I2C_1: I2C_SLAVE port map (
	scl => SCL_IN,
	sda => SDA_BI,
	clk => CLK_MASTER,
	rst => '0',
	transfer => TRANSFER_SIG,
	read_req => READ_REQ_SIG,
	stop	 => STOP_SIG,
	data_to_master => DATA_TO_MASTER_SIG
  );


  LATCH_BCD: process (AS_IN, UPDATE_SIG) 
  begin
    if UPDATE_SIG = '1' then
	if rising_edge(AS_IN(1)) then
		BCD1_SIG <= OUT_IN;
	end if;
	if rising_edge(AS_IN(2)) then
		BCD2_SIG <= OUT_IN;
	end if;
	if rising_edge(AS_IN(3)) then
		BCD3_SIG <= OUT_IN;
	end if;
	if rising_edge(AS_IN(4)) then
		BCD4_SIG <= OUT_IN;
	end if;
	if rising_edge(AS_IN(5)) then
		BCD5_SIG <= OUT_IN;
	end if;
	if rising_edge(AS_IN(6)) then
		BCD6_SIG <= OUT_IN;
	end if;
    end if;

  end process LATCH_BCD;

  I2CREAD: process (CLK_MASTER, TRANSFER_SIG, READ_REQ_SIG, STATUS_SIG, BCD1_SIG, BCD2_SIG, BCD3_SIG, BCD4_SIG, BCD5_SIG, BCD6_SIG) --, DATA1_SYNC, DATA2_SYNC, DATA3_SYNC, DATA4_SYNC)
  begin
	if rising_edge(CLK_MASTER) then
		if READ_REQ_SIG='1' then
			CNT_SIG <= CNT_SIG + 1;
		end if;
		if TRANSFER_SIG='0' then
			CNT_SIG <= "00";
		end if;
	end if;
		case CNT_SIG is
		  when "00" => DATA_TO_MASTER_SIG <= BCD1_SIG & BCD2_SIG;
		  when "01" => DATA_TO_MASTER_SIG <= BCD3_SIG & BCD4_SIG;
		  when "10" => DATA_TO_MASTER_SIG <= BCD5_SIG & BCD6_SIG;
		  when "11" => DATA_TO_MASTER_SIG <= "0" & STATUS_SIG;
		end case;
  end process I2CREAD;

  STATUS: process (AS_IN, DS_IN, MUP_IN, OVFL_IN, RNG2_IN, ML_IN, UPDATE_SIG, STOP_SIG)
  begin
    if rising_edge(MUP_IN) then
	TRIGGER_SIG <= '1';
    end if;
    if (STOP_SIG = '1') then
	TRIGGER_SIG <= '0';
    end if;
    if UPDATE_SIG = '1' then
	if falling_edge(AS_IN(2)) then
		N <= DS_IN;
	end if;
	if falling_edge(AS_IN(3)) then
		M <= DS_IN;
	end if;
	if falling_edge(AS_IN(4)) then
		L <= DS_IN;
	end if;
	if rising_edge(AS_IN(6)) then
		OVFL_SIG <= OVFL_IN;
		FREQ_SIG <= RNG2_IN;
		ML_SIG   <= not ML_IN;	
	end if;
    end if;
    STATUS_SIG <= TRIGGER_SIG & OVFL_SIG &FREQ_SIG & ML_SIG & N & M & L;
	
	
  end process STATUS;


  UPDATE_GEN: process (CLK_MASTER, AS_IN(1), AS_IN(6), TRANSFER_SIG)
  begin
	if rising_edge(CLK_MASTER) then
		if (TRANSFER_SIG = '0' and AS_IN(6) = '1') then
			UPDATE_SIG <= '1';
		end if;
		if (AS_IN(1) = '1') then
			UPDATE_SIG <= '0';
		end if;
	end if;
  end process UPDATE_GEN;

  LED <= UPDATE_SIG;
end espfluke_arch;
