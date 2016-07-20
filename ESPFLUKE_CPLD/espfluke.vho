-- VHDL netlist for ESPFLUKE
-- Date: Wed Jul 20 10:17:28 2016
-- Copyright (c) Lattice Semiconductor Corporation
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGAND2_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGAND2_ESPFLUKE;

ARCHITECTURE behav OF PGAND2_ESPFLUKE IS 
BEGIN

    PROCESS (A1, A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A1 AND A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGORF72_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGORF72_ESPFLUKE;

ARCHITECTURE behav OF PGORF72_ESPFLUKE IS 
BEGIN

    PROCESS (A1, A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A1 OR A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGBUFI_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGBUFI_ESPFLUKE;

ARCHITECTURE behav OF PGBUFI_ESPFLUKE IS 
BEGIN

    PROCESS (A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF :=  A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGDFFR_ESPFLUKE IS 
    GENERIC (
        HLCQ : TIME := 1 ns;
        LHCQ : TIME := 1 ns;
        HLRQ : TIME := 1 ns;
        SUD0 : TIME := 0 ns;
        SUD1 : TIME := 0 ns;
        HOLDD0 : TIME := 0 ns;
        HOLDD1 : TIME := 0 ns;
        POSC1 : TIME := 0 ns;
        POSC0 : TIME := 0 ns;
        NEGC1 : TIME := 0 ns;
        NEGC0 : TIME := 0 ns;
        RECRC : TIME := 0 ns;
        HOLDRC : TIME := 0 ns
    );
    PORT (
        RNESET : IN std_logic;
        CD : IN std_logic;
        CLK : IN std_logic;
        D0 : IN std_logic;
        Q0 : OUT std_logic
    );
END PGDFFR_ESPFLUKE;

ARCHITECTURE behav OF PGDFFR_ESPFLUKE IS 
BEGIN

    PROCESS (RNESET, CD, CLK, D0)
	variable iQ0 : std_logic;
	variable pQ0 : std_logic;

	begin

		if (CD OR NOT (RNESET)) = '1' then
			if NOT (iQ0='0') then
			  iQ0 := '0';
			  Q0 <= transport iQ0  after HLRQ;
			end if;
		elsif (CD OR NOT (RNESET)) = '0' AND CLK= '1' AND CLK'EVENT then
			pQ0 := iQ0;
			if (D0'EVENT) then
				iQ0 := D0'LAST_VALUE;
			elsif NOT (D0'EVENT) then
				iQ0 := D0;
			end if;
      if pQ0 = iQ0 then 
         Q0 <= transport iQ0;
      elsif iQ0 = '1' then Q0 <= transport iQ0 after LHCQ;
      elsif iQ0 = '0' then Q0 <= transport iQ0 after HLCQ;
      else
          Q0 <= transport iQ0;
      end if;
		end if;
    END PROCESS;

	process(CLK, CD)
	 begin
		if CD'EVENT AND CD='0' AND CLK='1' then
			assert (CLK'LAST_EVENT >= HOLDRC) 
			report("HOLD TIME VIOLAION ON CD (HOLDRC)  ")
            severity WARNING;
		end if;
		if CLK'EVENT  AND CLK ='1' AND CD ='0' then
			assert ( CD'LAST_EVENT >= RECRC) 
			report("RECOVERY TIME VIOLATION on CD(RECRC) ")
            severity WARNING;
		end if;
	end process;

	process(CLK,RNESET)
	 begin
		if RNESET'EVENT AND NOT(RNESET)='0' AND CLK='1' then
			assert (CLK'LAST_EVENT >= HOLDRC) 
			report("HOLD TIME VIOLAION ON RNESET (HOLDRC)  ")
            severity WARNING;
		end if;
		if CLK'EVENT  AND CLK ='1' AND NOT(RNESET) ='0' then
			assert ( RNESET'LAST_EVENT >= RECRC) 
			report("RECOVERY TIME VIOLATION on RNESET(RECRC) ")
            severity WARNING;
		end if;
	end process;

	process(D0, CLK)

	variable R_EDGE1 : TIME := 0 ns;
	variable R_EDGE0 : TIME := 0 ns;
	variable F_EDGE1 : TIME := 0 ns;
	variable F_EDGE0 : TIME := 0 ns;

	begin
		if CLK='1' AND CLK'LAST_VALUE='0' AND NOT(D0'EVENT) then
		   if D0='1' then
			R_EDGE1 := NOW;
			assert((R_EDGE1-F_EDGE1) >= NEGC1) 
			report("NEGATIVE PULSE WIDTH VIOLATION (NEGC1) ON CLK at ")
            severity WARNING;
			elsif D0='0' then
			 R_EDGE0 := NOW;
			 assert((R_EDGE0-F_EDGE0) >= NEGC0) 
			 report("NEGATIVE PULSE WIDTH VIOLATION (NEGC0) ON CLK at ")
             severity WARNING;
			end if;
		end if;

		if CLK ='0' AND CLK'LAST_VALUE = '1' AND NOT(D0'EVENT) then
			if D0='1' then
			  F_EDGE1 := NOW;
			  assert ((F_EDGE1-R_EDGE1) >= POSC1) 
			  report("POSITIVE PULSE WIDTH VIOLATION (POSC1) ON CLK at ")
              severity WARNING;
			elsif D0='0' then
			  F_EDGE0 := NOW;
			  assert ((F_EDGE0-R_EDGE0) >= POSC0) 
			  report("POSITIVE PULSE WIDTH VIOLATION (POSC0) ON CLK at ")
              severity WARNING;
			end if;
		end if;

	end process;

	process(D0, CLK)

	begin
		if CLK = '1' AND CLK'EVENT then 
			if D0='1' then
               assert(D0'LAST_EVENT >= SUD1) 
 			   report("DATA SET-UP VIOLATION (SUD1) ")
               severity WARNING;
			elsif D0='0' then
               assert(D0'LAST_EVENT >= SUD0) 
 			   report("DATA SET-UP VIOLATION (SUD0) ")
               severity WARNING;
			end if;
		end if;

		if CLK='1' AND D0'EVENT then 
			if D0'LAST_VALUE ='1' then
			   assert(CLK'LAST_EVENT >= HOLDD1)
			   report("DATA HOLD VIOLATION (HOLDD1) ")
               severity WARNING;
			elsif D0'LAST_VALUE='0' then
			   assert(CLK'LAST_EVENT >= HOLDD0)
			   report("DATA HOLD VIOLATION (HOLDD0) ")
               severity WARNING;
			end if;
		end if;

	end process;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGINVI_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A0 : IN std_logic;
        ZN0 : OUT std_logic
    );
END PGINVI_ESPFLUKE;

ARCHITECTURE behav OF PGINVI_ESPFLUKE IS 
BEGIN

    PROCESS (A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := NOT A0;
        if ZDF ='1' then
            ZN0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            ZN0 <= transport ZDF after TFALL;
        else
            ZN0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGXOR2_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGXOR2_ESPFLUKE;

ARCHITECTURE behav OF PGXOR2_ESPFLUKE IS 
BEGIN

    PROCESS (A1, A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A1 XOR A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGAND3_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGAND3_ESPFLUKE;

ARCHITECTURE behav OF PGAND3_ESPFLUKE IS 
BEGIN

    PROCESS (A2, A1, A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A2 AND A1 AND A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGAND9_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A8 : IN std_logic;
        A7 : IN std_logic;
        A6 : IN std_logic;
        A5 : IN std_logic;
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGAND9_ESPFLUKE;

ARCHITECTURE behav OF PGAND9_ESPFLUKE IS 
BEGIN

    PROCESS (A8, A7, A6, A5, 
		A4, A3, A2, A1, 
		A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A8 AND A7 AND A6 AND 
            A5 AND A4 AND A3 AND A2 AND 
            A1 AND A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGAND6_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A5 : IN std_logic;
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGAND6_ESPFLUKE;

ARCHITECTURE behav OF PGAND6_ESPFLUKE IS 
BEGIN

    PROCESS (A5, A4, A3, A2, 
		A1, A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A5 AND A4 AND A3 AND 
            A2 AND A1 AND A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGAND7_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A6 : IN std_logic;
        A5 : IN std_logic;
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGAND7_ESPFLUKE;

ARCHITECTURE behav OF PGAND7_ESPFLUKE IS 
BEGIN

    PROCESS (A6, A5, A4, A3, 
		A2, A1, A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A6 AND A5 AND A4 AND 
            A3 AND A2 AND A1 AND A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGAND4_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGAND4_ESPFLUKE;

ARCHITECTURE behav OF PGAND4_ESPFLUKE IS 
BEGIN

    PROCESS (A3, A2, A1, A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A3 AND A2 AND A1 AND 
            A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGORF75_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGORF75_ESPFLUKE;

ARCHITECTURE behav OF PGORF75_ESPFLUKE IS 
BEGIN

    PROCESS (A4, A3, A2, A1, 
		A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A4 OR A3 OR A2 OR 
            A1 OR A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGORF74_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGORF74_ESPFLUKE;

ARCHITECTURE behav OF PGORF74_ESPFLUKE IS 
BEGIN

    PROCESS (A3, A2, A1, A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A3 OR A2 OR A1 OR 
            A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGORF73_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGORF73_ESPFLUKE;

ARCHITECTURE behav OF PGORF73_ESPFLUKE IS 
BEGIN

    PROCESS (A2, A1, A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A2 OR A1 OR A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGAND8_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A7 : IN std_logic;
        A6 : IN std_logic;
        A5 : IN std_logic;
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGAND8_ESPFLUKE;

ARCHITECTURE behav OF PGAND8_ESPFLUKE IS 
BEGIN

    PROCESS (A7, A6, A5, A4, 
		A3, A2, A1, A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A7 AND A6 AND A5 AND 
            A4 AND A3 AND A2 AND A1 AND 
            A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGAND10_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A9 : IN std_logic;
        A8 : IN std_logic;
        A7 : IN std_logic;
        A6 : IN std_logic;
        A5 : IN std_logic;
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGAND10_ESPFLUKE;

ARCHITECTURE behav OF PGAND10_ESPFLUKE IS 
BEGIN

    PROCESS (A9, A8, A7, A6, 
		A5, A4, A3, A2, 
		A1, A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A9 AND A8 AND A7 AND 
            A6 AND A5 AND A4 AND A3 AND 
            A2 AND A1 AND A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PGAND5_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PGAND5_ESPFLUKE;

ARCHITECTURE behav OF PGAND5_ESPFLUKE IS 
BEGIN

    PROCESS (A4, A3, A2, A1, 
		A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF := A4 AND A3 AND A2 AND 
            A1 AND A0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PXIN_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        XI0 : IN std_logic;
        Z0 : OUT std_logic
    );
END PXIN_ESPFLUKE;

ARCHITECTURE behav OF PXIN_ESPFLUKE IS 
BEGIN

    PROCESS (XI0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF :=  XI0;
        if ZDF ='1' then
            Z0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            Z0 <= transport ZDF after TFALL;
        else
            Z0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PXTRI_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns;
        HZ : TIME := 1 ns;
        ZH : TIME := 1 ns;
        LZ : TIME := 1 ns;
        ZL : TIME := 1 ns
    );
    PORT (
        OE : IN std_logic;
        A0 : IN std_logic;
        XO0 : OUT std_logic
    );
END PXTRI_ESPFLUKE;

ARCHITECTURE behav OF PXTRI_ESPFLUKE IS 
BEGIN

    PROCESS (OE, A0)
	variable pXO : std_logic ;
	variable iXO : std_logic ;
	begin
		if OE='1' then
			pXO := iXO;
			iXO := A0;
			if pXO = iXO then 
				XO0 <= transport iXO after 0 ns;
			elsif pXO = '0' OR pXO = '1' then 
				if iXO = '1' then 
					XO0 <= transport iXO after TRISE ;
				else 
					XO0 <= transport iXO after TFALL ;
				end if;
			elsif NOT (pXO ='0' OR pXO='1') then
				if iXO = '1' then 
					XO0 <= transport iXO after ZH ;
				else 
					XO0 <= transport iXO after ZL ;
				end if;
			else 
				XO0 <= transport iXO after 0 ns;
			end if;
		elsif OE = '0' OR (OE = '0' AND NOT(A0'EVENT)) then
			pXO := iXO;
			iXO := 'Z';
      if iXO = pXO then 
         XO0 <= transport iXO;
      elsif pXO = '1' then XO0 <= transport iXO after HZ;
      elsif pXO = '0' then XO0 <= transport iXO after LZ;
      else
          XO0 <= transport iXO;
      end if;
		end if;
	end process;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY PXOUT_ESPFLUKE IS 
    GENERIC (
        TRISE : TIME := 1 ns;
        TFALL : TIME := 1 ns
    );
    PORT (
        A0 : IN std_logic;
        XO0 : OUT std_logic
    );
END PXOUT_ESPFLUKE;

ARCHITECTURE behav OF PXOUT_ESPFLUKE IS 
BEGIN

    PROCESS (A0)
    VARIABLE ZDF : std_logic;
    BEGIN
        ZDF :=  A0;
        if ZDF ='1' then
            XO0 <= transport ZDF after TRISE;
        elsif ZDF ='0' then
            XO0 <= transport ZDF after TFALL;
        else
            XO0 <= transport ZDF;
        end if;
    END PROCESS;
END behav;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.all;

ENTITY ESPFLUKE IS 
    PORT (
        XRESET : IN std_logic;
        SCL_IN : IN std_logic;
        RNG2_IN : IN std_logic;
        OVFL_IN : IN std_logic;
        MUP_IN : IN std_logic;
        ML_IN : IN std_logic;
        DS_IN : IN std_logic;
        CLK_MASTER : IN std_logic;
        SDA_BI : INOUT std_logic;
        LED : OUT std_logic;
        INT : OUT std_logic;
        OUT_IN :  in  std_logic_vector (3 downto 0);
        AS_IN :  in  std_logic_vector (6 downto 1)
    );
END ESPFLUKE;


ARCHITECTURE ESPFLUKE_STRUCTURE OF ESPFLUKE IS
SIGNAL VCC : std_logic := '1';
SIGNAL GND : std_logic := '0';
SIGNAL  UQNNONMCK_99, UQNNONMCK_100, UQNNONMCK_101, UQNNONMCK_102,
	 UQNNONMCK_103, UQNNONMCK_104, UQNNONMCK_105, UQNNONMCK_106,
	 UQNNONMCK_107, UQNNONMCK_108, OVFL_SIG_grpi, UQNNONMCK_109,
	 UQNNONMCK_110, UQNNONMCK_111, UPDATE_SIG_grpi, BUF_2403_ck2f,
	 UQNN_N28_grpi, UQNN_N26_grpi, UQNN_N24_grpi, TRANSFER_SIG_grpi,
	 UQNN_N21_grpi, UQNN_N32_grpi, UQNN_N22_grpi, STOP_SIG_grpi,
	 UQNN_N13_grpi, UQNN_N19_grpi, READ_REQ_SIG_grpi, OR_1148_grpi,
	 UQNN_N23_grpi, UQNN_N166_grpi, UQNN_N29_grpi, UQNN_N30_grpi,
	 UQNN_N35_grpi, UQNN_N14_grpi, UQNN_N15_grpi, UQNN_N16_grpi,
	 UQNN_N17_grpi, UQNN_N18_grpi, N_grpi, UQNNONMCK_112,
	 UQNNONMCK_113, UQNNONMCK_114, UQNNONMCK_115, UQNN_N27_grpi,
	 UQNN_N9_grpi, UQNN_N10_grpi, UQNN_N11_grpi, UQNN_N12_grpi,
	 L_grpi, UQNN_N42_grpi, UQNN_N39_grpi, UQNN_N38_grpi,
	 UQNNONMCK_116, UQNNONMCK_117, UQNNONMCK_118, UQNNONMCK_119,
	 UQNNONMCK_120, UQNNONMCK_121, UQNNONMCK_122, UQNNONMCK_123,
	 ML_SIG_grpi, TRIGGER_SIG_grpi, FREQ_SIG_grpi, UQNN_N36_grpi,
	 UQNN_N37_grpi, UQNN_N40_grpi, UQNN_N41_grpi, UQNN_N43_grpi,
	 UQNN_N47_grpi, UQNNONMCK_124, UQNNONMCK_125, UQNNONMCK_126,
	 OR_1154_grpi, UQNNONMCK_127, UQNNONMCK_128, UQNNONMCK_129,
	 UQNNONMCK_130, UQNNONMCK_131, M_grpi, UQNNONMCK_132,
	 UQNN_N108_grpi, UQNN_N31_grpi, UQNNONMCK_133, UQNNONMCK_134,
	 L2L_KEYWD_RESETb, IO25_OE, BUF_2402_oe, IO25_IBUFO,
	 IO25_OBUFI, UQNN_N25_iomux, IO26_IBUFO, IO17_IBUFO,
	 IO33_IBUFO, IO30_IBUFO, IO29_IBUFO, IO28_IBUFO,
	 IO27_IBUFO, IO34_IBUFO, IO35_IBUFO, IO36_IBUFO,
	 CLK_MASTERX, IO24_IBUFO, IO19_IBUFO, IO20_IBUFO,
	 IO21_IBUFO, IO22_IBUFO, IO23_IBUFO, IO16_OBUFI,
	 UPDATE_SIG_iomux, IO49_OBUFI, TRIGGER_SIG_iomux, UQNNONMCK_135,
	 UQNNONMCK_136, UQNNONMCK_137, OVFL_SIG, A1_CLK,
	 A1_F3, A1_F2, A1_F1, A1_F0,
	 OVFL_INX_grp, A1_P16, A1_IN1, A1_P15,
	 A1_IN4, A1_P11, A1_IN9, UQNNONMCK_138,
	 A1_P10, A1_IN16, A1_P7, A1_IN8,
	 UQNNONMCK_139, A1_P6, A1_IN17, A1_P3,
	 A1_IN0, A1_IN3, A1_P2, A1_IN3B,
	 A1_IN7, TRANSFER_SIG, UQNN_N24, UQNN_N26,
	 UQNN_N28, A2_CLK, A2_P4_xa, A2_X2O,
	 A2_P8_xa, A2_X1O, A2_P13_xa, A2_X0O,
	 A2_G3, A2_G2, A2_G1, A2_F1,
	 A2_F0, A2_P13, A2_IN3, A2_IN6B,
	 A2_P8, A2_P7, A2_IN1B, A2_IN5B,
	 A2_P4, A2_IN3B, A2_IN6, TRANSFER_SIG_ffb,
	 A2_P3, A2_IN17, A2_P2, A2_IN0B,
	 A2_IN2, READ_REQ_SIG, A4_CLK, OR_1148,
	 A4_X3O, A4_X2O, A4_G1, A4_G0,
	 A4_F0, A4_P3, A4_IN1, A4_IN2B,
	 A4_IN6, A4_P2, A4_IN0, A4_IN3,
	 A4_IN8, A4_IN9, A4_IN10B, A4_IN11B,
	 A4_IN13B, A4_IN14B, A4_IN15B, N,
	 A5_CLK, A5_CLKP, A5_F3, A5_P16,
	 A5_IN3, A5_IN4, N_ffb, A5_P15,
	 A5_IN3B, A5_IN16, A5_P12, A5_IN6,
	 UQNNONMCK_140, UQNNONMCK_141, UQNNONMCK_142, UQNNONMCK_143,
	 A6_CLKP, A6_F3, A6_F2, A6_F1,
	 A6_F0, A6_P16, A6_IN10, UQNNONMCK_144,
	 A6_P15, A6_IN16, UQNNONMCK_145, A6_P12,
	 A6_IN6, A6_P11, A6_IN9, UQNNONMCK_146,
	 A6_P10, A6_IN17, A6_P7, A6_IN8,
	 A6_P6, A6_IN1, A6_P3, A6_IN3,
	 A6_IN11, A6_P2, A6_IN0, A6_IN3B,
	 UQNN_N14, UQNN_N15, UQNN_N16, UQNN_N35,
	 A7_CLK, A7_P0_xa, A7_X3O, A7_P4_xa,
	 A7_X2O, A7_P8_xa, A7_X1O, A7_P13_xa,
	 A7_X0O, A7_G3, A7_G2, A7_G1,
	 A7_G0, A7_F5, A7_F4, A7_F1,
	 A7_F0, A7_P16, A7_IN11, A7_P15,
	 A7_P13, A7_P12, A7_IN10, A7_P11,
	 A7_P8, UQNN_N16_ffb, A7_P7, A7_IN17,
	 A7_P6, A7_P4, A7_IN5B, UQNN_N35_ffb,
	 A7_P3, A7_IN16, A7_P2, A7_IN4,
	 A7_IN6, A7_P0, A7_IN1, A7_IN2B,
	 A7_IN4B, A7_IN5, A7_IN6B, A7_IN7,
	 A7_IN15B, L, B0_CLK, B0_CLKP,
	 B0_F2, B0_P12, B0_IN4, B0_P11,
	 B0_IN3, B0_IN15, L_ffb, B0_P10,
	 B0_IN3B, B0_IN16, UQNN_N17, UQNN_N18,
	 UQNN_N29, UQNN_N30, B2_CLK, B2_P0_xa,
	 B2_X3O, B2_P4_xa, B2_X2O, B2_P8_xa,
	 B2_X1O, B2_P13_xa, B2_X0O, B2_G3,
	 B2_G2, B2_G1, B2_G0, B2_F5,
	 B2_F4, B2_F1, B2_F0, B2_P16,
	 B2_IN0, B2_P15, B2_P13, UQNN_N18_ffb,
	 B2_P12, B2_IN17, B2_P11, B2_P8,
	 UQNN_N29_ffb, B2_P7, B2_IN16, B2_P6,
	 B2_IN6, B2_P4, B2_IN4B, B2_P3,
	 B2_IN3, B2_P2, B2_IN5, B2_P0,
	 B2_IN1, B2_IN2B, B2_IN4, B2_IN5B,
	 B2_IN6B, B2_IN7, B2_IN15B, UQNN_N38,
	 UQNN_N39, UQNN_N42, B3_CLK, B3_X2O,
	 B3_X1O, B3_X0O, B3_G3, B3_G2,
	 B3_G1, B3_F5, B3_F4, B3_F1,
	 B3_F0, B3_P17, B3_IN4, UQNN_N39_ffb,
	 B3_P16, B3_IN17, B3_P15, B3_IN13,
	 B3_P14, B3_IN0, B3_P13, B3_IN3,
	 B3_P12, B3_IN12, B3_P11, B3_IN6,
	 B3_P10, B3_IN9, B3_P9, B3_IN5,
	 B3_P8, B3_IN1, B3_P7, B3_IN15,
	 UQNN_N38_ffb, B3_P3, B3_IN7B, B3_IN16,
	 B3_P2, B3_IN10, B3_IN14, B3_P1,
	 B3_IN8, B3_IN11, B3_P0, B3_IN2,
	 B3_IN7, B3_IN10B, B3_IN11B, UQNNONMCK_147,
	 FREQ_SIG, ML_SIG, BUF_2402, B5_CLK,
	 B5_F3, B5_F2, B5_F1, B5_P19,
	 B5_IN2, B5_P16, B5_IN4, ML_INX_grp,
	 B5_P15, B5_IN3B, RNG2_INX_grp, B5_P11,
	 B5_IN1, FREQ_SIG_ffb, B5_P10, B5_IN16,
	 B5_P7, B5_IN8, B5_IN10, UQNNONMCK_148,
	 B5_P6, B5_IN8B, B5_IN17, UQNN_N25,
	 UPDATE_SIG, B6_CLK, B6_X1O, B6_G2,
	 B6_F3, B6_F1, B6_F0, UPDATE_SIG_ffb,
	 B6_P16, B6_IN16, B6_P15, B6_IN3,
	 B6_IN7B, B6_IN11B, B6_P7, B6_IN13,
	 B6_P6, B6_IN8, B6_P5, B6_IN12,
	 B6_P4, B6_IN0, B6_IN14B, B6_P3,
	 B6_IN2, B6_P2, B6_IN1, B6_IN6,
	 B6_P1, B6_IN10, B6_IN15, B6_P0,
	 B6_IN4, B6_IN5, B6_IN6B, B6_IN9,
	 B6_IN14, B6_IN15B, UQNNONMCK_149, UQNNONMCK_150,
	 UQNNONMCK_151, UQNNONMCK_152, B7_CLKP, B7_F3,
	 B7_F2, B7_F1, B7_F0, B7_P16,
	 B7_IN14, UQNNONMCK_153, B7_P15, B7_IN16,
	 B7_P12, B7_IN5, B7_P11, B7_IN9,
	 UQNNONMCK_154, B7_P10, B7_IN17, B7_P7,
	 B7_IN8, B7_P6, B7_IN10, B7_P3,
	 B7_IN0, B7_IN3, B7_P2, B7_IN3B,
	 B7_IN11, UQNN_N13, C0_CLK, OR_1154,
	 C0_X3O, C0_P4_xa, C0_X2O, C0_P8_xa,
	 BUF_2403, C0_X1O, C0_P13_xa, UQNN_N166,
	 C0_X0O, C0_G3, C0_G2, C0_G1,
	 C0_G0, C0_F5, C0_P18, C0_P17,
	 C0_IN5, C0_P16, C0_IN15, C0_P15,
	 C0_IN13, C0_P14, C0_IN0B, C0_IN10,
	 C0_P13, C0_IN0, C0_IN1B, C0_IN7,
	 C0_IN8, C0_IN9B, C0_IN11B, UQNNONMCK_155,
	 C0_P8, C0_IN12, C0_P4, C0_IN14,
	 UQNNONMCK_156, UQNNONMCK_157, UQNNONMCK_158, UQNNONMCK_159,
	 C1_CLKP, C1_F3, C1_F2, C1_F1,
	 C1_F0, C1_P16, C1_IN5, C1_P15,
	 C1_IN11, UQNNONMCK_160, C1_P12, C1_IN12,
	 C1_P11, C1_IN15, UQNNONMCK_161, C1_P10,
	 C1_IN16, C1_P7, C1_IN6, UQNNONMCK_162,
	 C1_P6, C1_IN17, C1_P3, C1_IN3,
	 C1_IN7, C1_P2, C1_IN7B, C1_IN8,
	 UQNNONMCK_163, UQNNONMCK_164, UQNNONMCK_165, UQNNONMCK_166,
	 C2_CLKP, C2_F3, C2_F2, C2_F1,
	 C2_F0, C2_P16, C2_IN6, UQNNONMCK_167,
	 C2_P15, C2_IN16, UQNNONMCK_168, C2_P12,
	 C2_IN11, C2_P11, C2_IN4, UQNNONMCK_169,
	 C2_P10, C2_IN17, C2_P7, C2_IN7,
	 C2_P6, C2_IN14, C2_P3, C2_IN5,
	 C2_IN12, C2_P2, C2_IN12B, C2_IN15,
	 M, C3_CLK, C3_CLKP, C3_F3,
	 DS_INX_grp, C3_P16, C3_IN11, C3_IN12,
	 M_ffb, C3_P15, C3_IN12B, C3_IN16,
	 UQNNONMCK_170, C3_P12, C3_IN10, UQNN_N19,
	 UQNN_N36, UQNN_N37, UQNN_N43, C4_CLK,
	 C4_P0_xa, C4_X3O, C4_X2O, C4_X1O,
	 C4_G2, C4_G1, C4_G0, C4_F4,
	 C4_F3, C4_F1, C4_F0, UQNN_N43_ffb,
	 C4_P16, C4_IN16, C4_P15, C4_IN0,
	 C4_P14, C4_IN7, C4_P13, C4_IN11,
	 UQNN_N37_ffb, C4_P12, C4_IN17, C4_P11,
	 C4_IN2, C4_P10, C4_IN5, C4_P9,
	 C4_IN14, C4_P8, C4_IN3, C4_P7,
	 C4_IN15, C4_P6, C4_IN10, C4_P3,
	 C4_IN12B, C4_IN13, C4_P2, C4_IN1,
	 C4_IN4B, C4_IN8, C4_P1, C4_IN1B,
	 C4_IN4, C4_IN6, C4_IN12, C4_P0,
	 C4_IN9, UQNN_N27, UQNN_N10, UQNN_N11,
	 UQNN_N12, C5_CLK, C5_P0_xa, C5_X3O,
	 C5_P13_xa, C5_X0O, C5_G3, C5_G0,
	 C5_F5, C5_F2, C5_F1, C5_F0,
	 C5_P16, C5_P15, C5_P13, C5_P11,
	 C5_P10, C5_P9, C5_IN10, C5_P8,
	 C5_P7, C5_IN8B, C5_P6, C5_IN15,
	 C5_P5, C5_IN9, C5_IN15B, C5_P4,
	 C5_IN0, C5_IN4B, C5_IN8, C5_IN11B,
	 C5_P3, C5_IN4, UQNN_N27_ffb, C5_P2,
	 C5_IN17B, UQNN_N12_ffb, C5_P1, C5_IN0B,
	 C5_IN9B, C5_IN10B, C5_IN12, C5_IN13B,
	 C5_IN16, C5_P0, STOP_SIG, UQNN_N20,
	 UQNN_N22, UQNN_N31, C6_CLK, C6_P0_xa,
	 C6_X3O, C6_P4_xa, C6_X2O, C6_P8_xa,
	 C6_X1O, C6_G2, C6_G1, C6_G0,
	 C6_F3, C6_P16, C6_IN9B, UQNN_N31_ffb,
	 C6_P15, C6_IN5B, C6_IN16, C6_P14,
	 C6_IN5, C6_IN9, C6_P8, C6_IN13B,
	 C6_IN17, C6_P4, SCL_INX_grp, SDA_BI_Z0_grp,
	 UQNN_N20_ffb, C6_P0, C6_IN12, C6_IN13,
	 C6_IN14, C6_IN17B, UQNN_N32, UQNN_N47,
	 D0_CLK, D0_F3, D0_F2, D0_P16,
	 D0_IN6, D0_P15, D0_IN11B, UQNN_N47_ffb,
	 D0_P14, D0_IN16, D0_P11, D0_IN7B,
	 UQNN_N32_ffb, D0_P10, D0_IN3B, D0_IN17,
	 D0_P9, D0_IN0B, D0_IN2B, D0_IN4B,
	 D0_IN5B, D0_IN6B, D0_IN11, D0_IN12,
	 D0_IN13, D0_IN14B, D0_IN15B, UQNNONMCK_171,
	 UQNNONMCK_172, UQNNONMCK_173, UQNNONMCK_174, D1_CLKP,
	 D1_F3, D1_F2, D1_F1, D1_F0,
	 UQNNONMCK_175, D1_P16, D1_IN5, D1_P15,
	 D1_IN11, UQNNONMCK_176, D1_P12, D1_IN8,
	 UQNNONMCK_177, D1_P11, D1_IN6, UQNNONMCK_178,
	 D1_P10, D1_IN16, UQNNONMCK_179, D1_P7,
	 D1_IN7, UQNNONMCK_180, D1_P6, D1_IN17,
	 UQNNONMCK_181, D1_P3, D1_IN12, D1_IN15,
	 D1_P2, D1_IN3, D1_IN12B, UQNNONMCK_182,
	 UQNNONMCK_183, UQNN_N40, UQNN_N41, D3_CLK,
	 D3_X1O, D3_X0O, D3_G3, D3_G2,
	 D3_F5, D3_F4, D3_F1, D3_F0,
	 D3_P17, D3_IN1, UQNN_N40_ffb, D3_P16,
	 D3_IN16, D3_P15, D3_IN10, D3_P14,
	 D3_IN4, D3_P13, D3_IN8, D3_P12,
	 D3_IN7, D3_IN12B, D3_P11, D3_IN3,
	 D3_P10, D3_IN5, D3_P9, D3_IN9,
	 D3_P8, D3_IN11, D3_IN12, D3_P7,
	 D3_P6, D3_IN17, UQNNONMCK_184, D3_P5,
	 D3_IN17B, D3_P3, D3_IN0B, D3_IN13,
	 D3_P2, D3_IN0, D3_IN13B, D3_IN15,
	 TRIGGER_SIG, D4_CD, D4_CLKP, D4_P8_xa,
	 D4_X1O, D4_P13_xa, UQNN_N108, D4_X0O,
	 D4_G3, D4_G2, D4_P19, D4_IN15,
	 D4_P13, D4_IN0B, D4_IN1, D4_IN6B,
	 D4_IN9, D4_IN10, D4_IN11, D4_IN12,
	 D4_IN15B, MUP_INX_grp, D4_P12, D4_IN13,
	 D4_P8, UQNN_N33, UQNN_N23, UQNN_N21,
	 UQNN_N9, L2L_KEYWD_RESET_glbb, D5_CLK, CLK_MASTERX_clk1,
	 D5_F3, D5_F2, D5_F1, D5_F0,
	 D5_P16, D5_IN8B, D5_P15, D5_IN0,
	 D5_IN15, D5_P14, D5_IN0B, D5_IN8,
	 D5_IN15B, UQNN_N21_ffb, D5_P11, D5_IN16,
	 D5_P10, D5_IN14, D5_P9, D5_IN3,
	 D5_IN7, D5_IN11B, D5_P7, D5_IN11,
	 D5_P6, D5_IN5B, D5_P3, D5_IN5,
	 D5_P2, D5_IN9, D5_P1, D5_IN7B,
	 UQNN_N33_ffb, D5_P0, D5_IN3B, D5_IN4B,
	 D5_IN12, D5_IN13B, D5_IN17 : std_logic;


  COMPONENT PGAND2_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGAND2_ESPFLUKE use entity work.PGAND2_ESPFLUKE(behav);

  COMPONENT PGORF72_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGORF72_ESPFLUKE use entity work.PGORF72_ESPFLUKE(behav);

  COMPONENT PGBUFI_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGBUFI_ESPFLUKE use entity work.PGBUFI_ESPFLUKE(behav);

  COMPONENT PGDFFR_ESPFLUKE
    GENERIC (HLCQ, LHCQ, HLRQ, SUD0, 
        SUD1, HOLDD0, HOLDD1, POSC1, 
        POSC0, NEGC1, NEGC0, RECRC, 
        HOLDRC : TIME);
    PORT (
        RNESET : IN std_logic;
        CD : IN std_logic;
        CLK : IN std_logic;
        D0 : IN std_logic;
        Q0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGDFFR_ESPFLUKE use entity work.PGDFFR_ESPFLUKE(behav);

  COMPONENT PGINVI_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A0 : IN std_logic;
        ZN0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGINVI_ESPFLUKE use entity work.PGINVI_ESPFLUKE(behav);

  COMPONENT PGXOR2_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGXOR2_ESPFLUKE use entity work.PGXOR2_ESPFLUKE(behav);

  COMPONENT PGAND3_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGAND3_ESPFLUKE use entity work.PGAND3_ESPFLUKE(behav);

  COMPONENT PGAND9_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A8 : IN std_logic;
        A7 : IN std_logic;
        A6 : IN std_logic;
        A5 : IN std_logic;
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGAND9_ESPFLUKE use entity work.PGAND9_ESPFLUKE(behav);

  COMPONENT PGAND6_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A5 : IN std_logic;
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGAND6_ESPFLUKE use entity work.PGAND6_ESPFLUKE(behav);

  COMPONENT PGAND7_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A6 : IN std_logic;
        A5 : IN std_logic;
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGAND7_ESPFLUKE use entity work.PGAND7_ESPFLUKE(behav);

  COMPONENT PGAND4_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGAND4_ESPFLUKE use entity work.PGAND4_ESPFLUKE(behav);

  COMPONENT PGORF75_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGORF75_ESPFLUKE use entity work.PGORF75_ESPFLUKE(behav);

  COMPONENT PGORF74_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGORF74_ESPFLUKE use entity work.PGORF74_ESPFLUKE(behav);

  COMPONENT PGORF73_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGORF73_ESPFLUKE use entity work.PGORF73_ESPFLUKE(behav);

  COMPONENT PGAND8_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A7 : IN std_logic;
        A6 : IN std_logic;
        A5 : IN std_logic;
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGAND8_ESPFLUKE use entity work.PGAND8_ESPFLUKE(behav);

  COMPONENT PGAND10_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A9 : IN std_logic;
        A8 : IN std_logic;
        A7 : IN std_logic;
        A6 : IN std_logic;
        A5 : IN std_logic;
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGAND10_ESPFLUKE use entity work.PGAND10_ESPFLUKE(behav);

  COMPONENT PGAND5_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A4 : IN std_logic;
        A3 : IN std_logic;
        A2 : IN std_logic;
        A1 : IN std_logic;
        A0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PGAND5_ESPFLUKE use entity work.PGAND5_ESPFLUKE(behav);

  COMPONENT PXIN_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        XI0 : IN std_logic;
        Z0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PXIN_ESPFLUKE use entity work.PXIN_ESPFLUKE(behav);

  COMPONENT PXTRI_ESPFLUKE
    GENERIC (TRISE, TFALL, HZ, ZH, 
        LZ, ZL : TIME);
    PORT (
        OE : IN std_logic;
        A0 : IN std_logic;
        XO0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PXTRI_ESPFLUKE use entity work.PXTRI_ESPFLUKE(behav);

  COMPONENT PXOUT_ESPFLUKE
    GENERIC (TRISE, TFALL : TIME);
    PORT (
        A0 : IN std_logic;
        XO0 : OUT std_logic
    );
  END COMPONENT;
  for all :  PXOUT_ESPFLUKE use entity work.PXOUT_ESPFLUKE(behav);

BEGIN

    UQNNONMCK_99 <=  OUT_IN(3);
    UQNNONMCK_100 <=  OUT_IN(2);
    UQNNONMCK_101 <=  OUT_IN(1);
    UQNNONMCK_102 <=  OUT_IN(0);
    UQNNONMCK_103 <=  AS_IN(6);
    UQNNONMCK_104 <=  AS_IN(5);
    UQNNONMCK_105 <=  AS_IN(4);
    UQNNONMCK_106 <=  AS_IN(3);
    UQNNONMCK_107 <=  AS_IN(2);
    UQNNONMCK_108 <=  AS_IN(1);
GLB_A1_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A1_P16, A1 => A1_IN1, A0 => A1_IN3);
GLB_A1_P15 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A1_P15, A1 => A1_IN3B, A0 => A1_IN4);
GLB_A1_P11 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A1_P11, A1 => A1_IN3, A0 => A1_IN9);
GLB_A1_P10 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A1_P10, A1 => A1_IN3B, A0 => A1_IN16);
GLB_A1_P7 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A1_P7, A1 => A1_IN3, A0 => A1_IN8);
GLB_A1_P6 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A1_P6, A1 => A1_IN3B, A0 => A1_IN17);
GLB_A1_P3 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A1_P3, A1 => A1_IN0, A0 => A1_IN3);
GLB_A1_P2 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A1_P2, A1 => A1_IN3B, A0 => A1_IN7);
GLB_A1_F3 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => A1_F3, A1 => A1_P15, A0 => A1_P16);
GLB_A1_F2 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => A1_F2, A1 => A1_P10, A0 => A1_P11);
GLB_A1_F1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => A1_F1, A1 => A1_P6, A0 => A1_P7);
GLB_A1_F0 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => A1_F0, A1 => A1_P2, A0 => A1_P3);
GLB_A1_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => A1_CLK, A0 => BUF_2403_ck2f);
GLB_A1_IN1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A1_IN1, A0 => OVFL_INX_grp);
GLB_A1_IN4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A1_IN4, A0 => OVFL_SIG_grpi);
GLB_A1_IN9 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A1_IN9, A0 => UQNNONMCK_177);
GLB_A1_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A1_IN16, A0 => UQNNONMCK_138);
GLB_A1_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A1_IN8, A0 => UQNNONMCK_179);
GLB_A1_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A1_IN17, A0 => UQNNONMCK_139);
GLB_A1_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A1_IN3, A0 => UPDATE_SIG_grpi);
GLB_A1_IN0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A1_IN0, A0 => UQNNONMCK_181);
GLB_A1_IN7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A1_IN7, A0 => UQNNONMCK_111);
UQBNONMCK_99 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_135, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A1_CLK, 
	D0 => A1_F0);
UQBNONMCK_100 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_136, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A1_CLK, 
	D0 => A1_F1);
UQBNONMCK_101 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_137, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A1_CLK, 
	D0 => A1_F2);
GLB_OVFL_SIG : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => OVFL_SIG, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A1_CLK, 
	D0 => A1_F3);
GLB_A1_IN3B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A1_IN3B, A0 => UPDATE_SIG_grpi);
GLB_A2_P13 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => A2_P13, A1 => A2_IN3, A0 => A2_IN6B);
GLB_A2_P8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => A2_P8, A0 => VCC);
GLB_A2_P7 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A2_P7, A1 => A2_IN1B, A0 => A2_IN5B);
GLB_A2_P4 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => A2_P4, A1 => A2_IN3B, A0 => A2_IN6);
GLB_A2_P3 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A2_P3, A1 => A2_IN0B, A0 => A2_IN17);
GLB_A2_P2 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A2_P2, A1 => A2_IN0B, A0 => A2_IN2);
GLB_A2_G3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => A2_G3, A0 => GND);
GLB_A2_G2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => A2_G2, A0 => A2_F1);
GLB_A2_G1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => A2_G1, A0 => GND);
GLB_A2_F1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => A2_F1, A0 => A2_P7);
GLB_A2_F0 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => A2_F0, A1 => A2_P2, A0 => A2_P3);
GLB_A2_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => A2_CLK, A0 => CLK_MASTERX_clk1);
GLB_A2_P4_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => A2_P4_xa, A0 => A2_P4);
GLB_A2_P8_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => A2_P8_xa, A0 => A2_P8);
GLB_A2_P13_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => A2_P13_xa, A0 => A2_P13);
GLB_A2_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A2_IN3, A0 => UQNN_N19_grpi);
GLB_A2_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A2_IN6, A0 => UQNN_N13_grpi);
GLB_A2_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A2_IN17, A0 => TRANSFER_SIG_ffb);
GLB_A2_IN2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A2_IN2, A0 => UQNN_N22_grpi);
GLB_A2_X2O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => A2_X2O, A1 => A2_P4_xa, A0 => A2_G1);
GLB_A2_X1O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => A2_X1O, A1 => A2_P8_xa, A0 => A2_G2);
GLB_A2_X0O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => A2_X0O, A1 => A2_P13_xa, A0 => A2_G3);
GLB_TRANSFER_SIG : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => TRANSFER_SIG, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A2_CLK, 
	D0 => A2_F0);
GLB_UQNN_N24 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N24, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A2_CLK, 
	D0 => A2_X2O);
GLB_UQNN_N26 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N26, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A2_CLK, 
	D0 => A2_X1O);
GLB_UQNN_N28 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N28, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A2_CLK, 
	D0 => A2_X0O);
GLB_A2_IN6B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A2_IN6B, A0 => UQNN_N13_grpi);
GLB_A2_IN5B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A2_IN5B, A0 => UQNN_N21_grpi);
GLB_A2_IN1B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A2_IN1B, A0 => UQNN_N32_grpi);
GLB_A2_IN3B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A2_IN3B, A0 => UQNN_N19_grpi);
GLB_A2_IN0B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A2_IN0B, A0 => STOP_SIG_grpi);
GLB_A4_P3 : PGAND3_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A4_P3, A2 => A4_IN1, A1 => A4_IN2B, A0 => A4_IN6);
GLB_A4_P2 : PGAND9_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A4_P2, A8 => A4_IN0, A7 => A4_IN3, A6 => A4_IN8, 
	A5 => A4_IN9, A4 => A4_IN10B, A3 => A4_IN11B, A2 => A4_IN13B, 
	A1 => A4_IN14B, A0 => A4_IN15B);
GLB_A4_G1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => A4_G1, A0 => A4_F0);
GLB_A4_G0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => A4_G0, A0 => A4_F0);
GLB_A4_F0 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => A4_F0, A1 => A4_P2, A0 => A4_P3);
GLB_A4_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => A4_CLK, A0 => CLK_MASTERX_clk1);
GLB_OR_1148 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => OR_1148, A0 => A4_X3O);
GLB_A4_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A4_IN6, A0 => UQNN_N23_grpi);
GLB_A4_IN1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A4_IN1, A0 => UQNN_N24_grpi);
GLB_A4_IN9 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A4_IN9, A0 => UQNN_N29_grpi);
GLB_A4_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A4_IN8, A0 => UQNN_N35_grpi);
GLB_A4_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A4_IN3, A0 => UQNN_N30_grpi);
GLB_A4_IN0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A4_IN0, A0 => UQNN_N166_grpi);
GLB_A4_X3O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => A4_X3O, A1 => GND, A0 => A4_G0);
GLB_A4_X2O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => A4_X2O, A1 => GND, A0 => A4_G1);
GLB_READ_REQ_SIG : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => READ_REQ_SIG, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A4_CLK, 
	D0 => A4_X2O);
GLB_A4_IN2B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A4_IN2B, A0 => SDA_BI_Z0_grp);
GLB_A4_IN15B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A4_IN15B, A0 => UQNN_N14_grpi);
GLB_A4_IN14B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A4_IN14B, A0 => UQNN_N15_grpi);
GLB_A4_IN13B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A4_IN13B, A0 => UQNN_N16_grpi);
GLB_A4_IN11B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A4_IN11B, A0 => UQNN_N17_grpi);
GLB_A4_IN10B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A4_IN10B, A0 => UQNN_N18_grpi);
GLB_A5_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A5_P16, A1 => A5_IN3, A0 => A5_IN4);
GLB_A5_P15 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A5_P15, A1 => A5_IN3B, A0 => A5_IN16);
GLB_A5_P12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => A5_P12, A0 => A5_IN6);
GLB_A5_F3 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => A5_F3, A1 => A5_P15, A0 => A5_P16);
GLB_A5_CLKP : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.400000 ns, TFALL => 1.400000 ns)
	PORT MAP (Z0 => A5_CLKP, A0 => A5_P12);
GLB_A5_IN4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A5_IN4, A0 => DS_INX_grp);
GLB_A5_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A5_IN3, A0 => UPDATE_SIG_grpi);
GLB_A5_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A5_IN16, A0 => N_ffb);
GLB_A5_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A5_IN6, A0 => UQNNONMCK_145);
GLB_N : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => N, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A5_CLK, 
	D0 => A5_F3);
GLB_A5_CLK : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (ZN0 => A5_CLK, A0 => A5_CLKP);
GLB_A5_IN3B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A5_IN3B, A0 => UPDATE_SIG_grpi);
GLB_A6_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A6_P16, A1 => A6_IN3, A0 => A6_IN10);
GLB_A6_P15 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A6_P15, A1 => A6_IN3B, A0 => A6_IN16);
GLB_A6_P12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => A6_P12, A0 => A6_IN6);
GLB_A6_P11 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A6_P11, A1 => A6_IN3, A0 => A6_IN9);
GLB_A6_P10 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A6_P10, A1 => A6_IN3B, A0 => A6_IN17);
GLB_A6_P7 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A6_P7, A1 => A6_IN3, A0 => A6_IN8);
GLB_A6_P6 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A6_P6, A1 => A6_IN1, A0 => A6_IN3B);
GLB_A6_P3 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A6_P3, A1 => A6_IN3, A0 => A6_IN11);
GLB_A6_P2 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A6_P2, A1 => A6_IN0, A0 => A6_IN3B);
GLB_A6_F3 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => A6_F3, A1 => A6_P15, A0 => A6_P16);
GLB_A6_F2 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => A6_F2, A1 => A6_P10, A0 => A6_P11);
GLB_A6_F1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => A6_F1, A1 => A6_P6, A0 => A6_P7);
GLB_A6_F0 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => A6_F0, A1 => A6_P2, A0 => A6_P3);
GLB_A6_CLKP : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.900000 ns, TFALL => 1.900000 ns)
	PORT MAP (Z0 => A6_CLKP, A0 => A6_P12);
GLB_A6_IN10 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A6_IN10, A0 => UQNNONMCK_175);
GLB_A6_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A6_IN16, A0 => UQNNONMCK_144);
GLB_A6_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A6_IN6, A0 => UQNNONMCK_145);
GLB_A6_IN9 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A6_IN9, A0 => UQNNONMCK_177);
GLB_A6_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A6_IN17, A0 => UQNNONMCK_146);
GLB_A6_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A6_IN8, A0 => UQNNONMCK_179);
GLB_A6_IN1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A6_IN1, A0 => UQNNONMCK_114);
GLB_A6_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A6_IN11, A0 => UQNNONMCK_181);
GLB_A6_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A6_IN3, A0 => UPDATE_SIG_grpi);
GLB_A6_IN0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A6_IN0, A0 => UQNNONMCK_115);
UQBNONMCK_102 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_140, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A6_CLKP, 
	D0 => A6_F0);
UQBNONMCK_103 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_141, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A6_CLKP, 
	D0 => A6_F1);
UQBNONMCK_104 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_142, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A6_CLKP, 
	D0 => A6_F2);
UQBNONMCK_105 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_143, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A6_CLKP, 
	D0 => A6_F3);
GLB_A6_IN3B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A6_IN3B, A0 => UPDATE_SIG_grpi);
GLB_A7_P16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A7_P16, A0 => A7_IN11);
GLB_A7_P15 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A7_P15, A5 => A7_IN1, A4 => A7_IN4B, A3 => A7_IN5, 
	A2 => A7_IN6B, A1 => A7_IN7, A0 => A7_IN15B);
GLB_A7_P13 : PGAND7_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => A7_P13, A6 => A7_IN1, A5 => A7_IN2B, A4 => A7_IN4, 
	A3 => A7_IN5, A2 => A7_IN6, A1 => A7_IN7, A0 => A7_IN15B);
GLB_A7_P12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => A7_P12, A0 => A7_IN10);
GLB_A7_P11 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A7_P11, A5 => A7_IN1, A4 => A7_IN4, A3 => A7_IN5B, 
	A2 => A7_IN6, A1 => A7_IN7, A0 => A7_IN15B);
GLB_A7_P8 : PGAND7_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => A7_P8, A6 => A7_IN1, A5 => A7_IN2B, A4 => A7_IN4B, 
	A3 => A7_IN5B, A2 => A7_IN6, A1 => A7_IN7, A0 => A7_IN15B);
GLB_A7_P7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A7_P7, A0 => A7_IN17);
GLB_A7_P6 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A7_P6, A5 => A7_IN1, A4 => A7_IN4B, A3 => A7_IN5B, 
	A2 => A7_IN6, A1 => A7_IN7, A0 => A7_IN15B);
GLB_A7_P4 : PGAND7_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => A7_P4, A6 => A7_IN1, A5 => A7_IN2B, A4 => A7_IN4, 
	A3 => A7_IN5B, A2 => A7_IN6, A1 => A7_IN7, A0 => A7_IN15B);
GLB_A7_P3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A7_P3, A0 => A7_IN16);
GLB_A7_P2 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => A7_P2, A5 => A7_IN1, A4 => A7_IN4, A3 => A7_IN5, 
	A2 => A7_IN6, A1 => A7_IN7, A0 => A7_IN15B);
GLB_A7_P0 : PGAND7_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => A7_P0, A6 => A7_IN1, A5 => A7_IN2B, A4 => A7_IN4B, 
	A3 => A7_IN5, A2 => A7_IN6B, A1 => A7_IN7, A0 => A7_IN15B);
GLB_A7_G3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => A7_G3, A0 => A7_F0);
GLB_A7_G2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => A7_G2, A0 => A7_F1);
GLB_A7_G1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => A7_G1, A0 => A7_F4);
GLB_A7_G0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => A7_G0, A0 => A7_F5);
GLB_A7_F5 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => A7_F5, A1 => A7_P15, A0 => A7_P16);
GLB_A7_F4 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => A7_F4, A1 => A7_P11, A0 => A7_P12);
GLB_A7_F1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => A7_F1, A1 => A7_P6, A0 => A7_P7);
GLB_A7_F0 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => A7_F0, A1 => A7_P2, A0 => A7_P3);
GLB_A7_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => A7_CLK, A0 => CLK_MASTERX_clk1);
GLB_A7_P0_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => A7_P0_xa, A0 => A7_P0);
GLB_A7_P4_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => A7_P4_xa, A0 => A7_P4);
GLB_A7_P8_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => A7_P8_xa, A0 => A7_P8);
GLB_A7_P13_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => A7_P13_xa, A0 => A7_P13);
GLB_A7_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A7_IN11, A0 => UQNN_N14_grpi);
GLB_A7_IN10 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A7_IN10, A0 => UQNN_N15_grpi);
GLB_A7_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A7_IN17, A0 => UQNN_N16_ffb);
GLB_A7_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A7_IN16, A0 => UQNN_N35_ffb);
GLB_A7_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A7_IN6, A0 => UQNN_N10_grpi);
GLB_A7_IN4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A7_IN4, A0 => UQNN_N9_grpi);
GLB_A7_IN7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A7_IN7, A0 => UQNN_N27_grpi);
GLB_A7_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A7_IN5, A0 => UQNN_N11_grpi);
GLB_A7_IN1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => A7_IN1, A0 => UQNN_N24_grpi);
GLB_A7_X3O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => A7_X3O, A1 => A7_P0_xa, A0 => A7_G0);
GLB_A7_X2O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => A7_X2O, A1 => A7_P4_xa, A0 => A7_G1);
GLB_A7_X1O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => A7_X1O, A1 => A7_P8_xa, A0 => A7_G2);
GLB_A7_X0O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => A7_X0O, A1 => A7_P13_xa, A0 => A7_G3);
GLB_UQNN_N14 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N14, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A7_CLK, 
	D0 => A7_X3O);
GLB_UQNN_N15 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N15, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A7_CLK, 
	D0 => A7_X2O);
GLB_UQNN_N16 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N16, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A7_CLK, 
	D0 => A7_X1O);
GLB_UQNN_N35 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N35, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => A7_CLK, 
	D0 => A7_X0O);
GLB_A7_IN5B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A7_IN5B, A0 => UQNN_N11_grpi);
GLB_A7_IN15B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A7_IN15B, A0 => UQNN_N12_grpi);
GLB_A7_IN6B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A7_IN6B, A0 => UQNN_N10_grpi);
GLB_A7_IN4B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A7_IN4B, A0 => UQNN_N9_grpi);
GLB_A7_IN2B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => A7_IN2B, A0 => SDA_BI_Z0_grp);
GLB_B0_P12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B0_P12, A0 => B0_IN4);
GLB_B0_P11 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B0_P11, A1 => B0_IN3, A0 => B0_IN15);
GLB_B0_P10 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B0_P10, A1 => B0_IN3B, A0 => B0_IN16);
GLB_B0_F2 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => B0_F2, A1 => B0_P10, A0 => B0_P11);
GLB_B0_CLKP : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.400000 ns, TFALL => 1.400000 ns)
	PORT MAP (Z0 => B0_CLKP, A0 => B0_P12);
GLB_B0_IN4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B0_IN4, A0 => UQNNONMCK_168);
GLB_B0_IN15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B0_IN15, A0 => DS_INX_grp);
GLB_B0_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B0_IN3, A0 => UPDATE_SIG_grpi);
GLB_B0_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B0_IN16, A0 => L_ffb);
GLB_L : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => L, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B0_CLK, 
	D0 => B0_F2);
GLB_B0_CLK : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (ZN0 => B0_CLK, A0 => B0_CLKP);
GLB_B0_IN3B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B0_IN3B, A0 => UPDATE_SIG_grpi);
GLB_B2_P16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B2_P16, A0 => B2_IN0);
GLB_B2_P15 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B2_P15, A5 => B2_IN1, A4 => B2_IN4, A3 => B2_IN5B, 
	A2 => B2_IN6B, A1 => B2_IN7, A0 => B2_IN15B);
GLB_B2_P13 : PGAND7_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B2_P13, A6 => B2_IN1, A5 => B2_IN2B, A4 => B2_IN4, 
	A3 => B2_IN5, A2 => B2_IN6B, A1 => B2_IN7, A0 => B2_IN15B);
GLB_B2_P12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B2_P12, A0 => B2_IN17);
GLB_B2_P11 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B2_P11, A5 => B2_IN1, A4 => B2_IN4B, A3 => B2_IN5B, 
	A2 => B2_IN6B, A1 => B2_IN7, A0 => B2_IN15B);
GLB_B2_P8 : PGAND7_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B2_P8, A6 => B2_IN1, A5 => B2_IN2B, A4 => B2_IN4B, 
	A3 => B2_IN5, A2 => B2_IN6, A1 => B2_IN7, A0 => B2_IN15B);
GLB_B2_P7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B2_P7, A0 => B2_IN16);
GLB_B2_P6 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B2_P6, A5 => B2_IN1, A4 => B2_IN4B, A3 => B2_IN5, 
	A2 => B2_IN6, A1 => B2_IN7, A0 => B2_IN15B);
GLB_B2_P4 : PGAND7_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B2_P4, A6 => B2_IN1, A5 => B2_IN2B, A4 => B2_IN4B, 
	A3 => B2_IN5B, A2 => B2_IN6B, A1 => B2_IN7, A0 => B2_IN15B);
GLB_B2_P3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B2_P3, A0 => B2_IN3);
GLB_B2_P2 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B2_P2, A5 => B2_IN1, A4 => B2_IN4, A3 => B2_IN5, 
	A2 => B2_IN6B, A1 => B2_IN7, A0 => B2_IN15B);
GLB_B2_P0 : PGAND7_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B2_P0, A6 => B2_IN1, A5 => B2_IN2B, A4 => B2_IN4, 
	A3 => B2_IN5B, A2 => B2_IN6B, A1 => B2_IN7, A0 => B2_IN15B);
GLB_B2_G3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => B2_G3, A0 => B2_F0);
GLB_B2_G2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => B2_G2, A0 => B2_F1);
GLB_B2_G1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => B2_G1, A0 => B2_F4);
GLB_B2_G0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => B2_G0, A0 => B2_F5);
GLB_B2_F5 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => B2_F5, A1 => B2_P15, A0 => B2_P16);
GLB_B2_F4 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => B2_F4, A1 => B2_P11, A0 => B2_P12);
GLB_B2_F1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => B2_F1, A1 => B2_P6, A0 => B2_P7);
GLB_B2_F0 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => B2_F0, A1 => B2_P2, A0 => B2_P3);
GLB_B2_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => B2_CLK, A0 => CLK_MASTERX_clk1);
GLB_B2_P0_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => B2_P0_xa, A0 => B2_P0);
GLB_B2_P4_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => B2_P4_xa, A0 => B2_P4);
GLB_B2_P8_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => B2_P8_xa, A0 => B2_P8);
GLB_B2_P13_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => B2_P13_xa, A0 => B2_P13);
GLB_B2_IN0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B2_IN0, A0 => UQNN_N17_grpi);
GLB_B2_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B2_IN17, A0 => UQNN_N18_ffb);
GLB_B2_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B2_IN16, A0 => UQNN_N29_ffb);
GLB_B2_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B2_IN6, A0 => UQNN_N10_grpi);
GLB_B2_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B2_IN3, A0 => UQNN_N30_grpi);
GLB_B2_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B2_IN5, A0 => UQNN_N11_grpi);
GLB_B2_IN7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B2_IN7, A0 => UQNN_N27_grpi);
GLB_B2_IN4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B2_IN4, A0 => UQNN_N9_grpi);
GLB_B2_IN1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B2_IN1, A0 => UQNN_N24_grpi);
GLB_B2_X3O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => B2_X3O, A1 => B2_P0_xa, A0 => B2_G0);
GLB_B2_X2O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => B2_X2O, A1 => B2_P4_xa, A0 => B2_G1);
GLB_B2_X1O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => B2_X1O, A1 => B2_P8_xa, A0 => B2_G2);
GLB_B2_X0O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => B2_X0O, A1 => B2_P13_xa, A0 => B2_G3);
GLB_UQNN_N17 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N17, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B2_CLK, 
	D0 => B2_X3O);
GLB_UQNN_N18 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N18, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B2_CLK, 
	D0 => B2_X2O);
GLB_UQNN_N29 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N29, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B2_CLK, 
	D0 => B2_X1O);
GLB_UQNN_N30 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N30, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B2_CLK, 
	D0 => B2_X0O);
GLB_B2_IN4B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B2_IN4B, A0 => UQNN_N9_grpi);
GLB_B2_IN15B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B2_IN15B, A0 => UQNN_N12_grpi);
GLB_B2_IN6B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B2_IN6B, A0 => UQNN_N10_grpi);
GLB_B2_IN5B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B2_IN5B, A0 => UQNN_N11_grpi);
GLB_B2_IN2B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B2_IN2B, A0 => SDA_BI_Z0_grp);
GLB_B3_P17 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B3_P17, A3 => B3_IN4, A2 => B3_IN7, A1 => B3_IN10, 
	A0 => B3_IN11);
GLB_B3_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B3_P16, A1 => B3_IN7B, A0 => B3_IN17);
GLB_B3_P15 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B3_P15, A3 => B3_IN7, A2 => B3_IN10, A1 => B3_IN11B, 
	A0 => B3_IN13);
GLB_B3_P14 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B3_P14, A3 => B3_IN0, A2 => B3_IN7, A1 => B3_IN10B, 
	A0 => B3_IN11);
GLB_B3_P13 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B3_P13, A3 => B3_IN3, A2 => B3_IN7, A1 => B3_IN10B, 
	A0 => B3_IN11B);
GLB_B3_P12 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B3_P12, A1 => B3_IN7B, A0 => B3_IN12);
GLB_B3_P11 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B3_P11, A3 => B3_IN6, A2 => B3_IN7, A1 => B3_IN10, 
	A0 => B3_IN11B);
GLB_B3_P10 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B3_P10, A3 => B3_IN7, A2 => B3_IN9, A1 => B3_IN10B, 
	A0 => B3_IN11);
GLB_B3_P9 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B3_P9, A3 => B3_IN5, A2 => B3_IN7, A1 => B3_IN10B, 
	A0 => B3_IN11B);
GLB_B3_P8 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B3_P8, A3 => B3_IN1, A2 => B3_IN7, A1 => B3_IN10, 
	A0 => B3_IN11);
GLB_B3_P7 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B3_P7, A3 => B3_IN7, A2 => B3_IN10, A1 => B3_IN11, 
	A0 => B3_IN15);
GLB_B3_P3 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B3_P3, A1 => B3_IN7B, A0 => B3_IN16);
GLB_B3_P2 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B3_P2, A3 => B3_IN7, A2 => B3_IN10, A1 => B3_IN11B, 
	A0 => B3_IN14);
GLB_B3_P1 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B3_P1, A3 => B3_IN7, A2 => B3_IN8, A1 => B3_IN10B, 
	A0 => B3_IN11);
GLB_B3_P0 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B3_P0, A3 => B3_IN2, A2 => B3_IN7, A1 => B3_IN10B, 
	A0 => B3_IN11B);
GLB_B3_G3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => B3_G3, A0 => B3_F4);
GLB_B3_G2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => B3_G2, A0 => B3_F5);
GLB_B3_G1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => B3_G1, A1 => B3_F0, A0 => B3_F1);
GLB_B3_F5 : PGORF75_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => B3_F5, A4 => B3_P13, A3 => B3_P14, A2 => B3_P15, 
	A1 => B3_P16, A0 => B3_P17);
GLB_B3_F4 : PGORF75_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => B3_F4, A4 => B3_P8, A3 => B3_P9, A2 => B3_P10, 
	A1 => B3_P11, A0 => B3_P12);
GLB_B3_F1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => B3_F1, A0 => B3_P7);
GLB_B3_F0 : PGORF74_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => B3_F0, A3 => B3_P0, A2 => B3_P1, A1 => B3_P2, 
	A0 => B3_P3);
GLB_B3_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => B3_CLK, A0 => CLK_MASTERX_clk1);
GLB_B3_IN4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN4, A0 => ML_SIG_grpi);
GLB_B3_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN17, A0 => UQNN_N39_ffb);
GLB_B3_IN13 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN13, A0 => UQNNONMCK_121);
GLB_B3_IN0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN0, A0 => UQNNONMCK_119);
GLB_B3_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN3, A0 => UQNNONMCK_112);
GLB_B3_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN12, A0 => UQNN_N42_grpi);
GLB_B3_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN6, A0 => UQNNONMCK_120);
GLB_B3_IN9 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN9, A0 => UQNNONMCK_117);
GLB_B3_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN5, A0 => UQNNONMCK_116);
GLB_B3_IN1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN1, A0 => TRIGGER_SIG_grpi);
GLB_B3_IN15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN15, A0 => N_grpi);
GLB_B3_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN16, A0 => UQNN_N38_ffb);
GLB_B3_IN14 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN14, A0 => UQNNONMCK_109);
GLB_B3_IN10 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN10, A0 => UQNNONMCK_123);
GLB_B3_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN11, A0 => UQNNONMCK_122);
GLB_B3_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN8, A0 => UQNNONMCK_118);
GLB_B3_IN7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN7, A0 => OR_1148_grpi);
GLB_B3_IN2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B3_IN2, A0 => UQNNONMCK_113);
GLB_B3_X2O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => B3_X2O, A1 => GND, A0 => B3_G1);
GLB_B3_X1O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => B3_X1O, A1 => GND, A0 => B3_G2);
GLB_B3_X0O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => B3_X0O, A1 => GND, A0 => B3_G3);
GLB_UQNN_N38 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N38, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B3_CLK, 
	D0 => B3_X2O);
GLB_UQNN_N39 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N39, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B3_CLK, 
	D0 => B3_X1O);
GLB_UQNN_N42 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N42, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B3_CLK, 
	D0 => B3_X0O);
GLB_B3_IN7B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B3_IN7B, A0 => OR_1148_grpi);
GLB_B3_IN11B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B3_IN11B, A0 => UQNNONMCK_122);
GLB_B3_IN10B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B3_IN10B, A0 => UQNNONMCK_123);
GLB_B5_P19 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B5_P19, A0 => B5_IN2);
GLB_B5_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B5_P16, A1 => B5_IN4, A0 => B5_IN8B);
GLB_B5_P15 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B5_P15, A1 => B5_IN3B, A0 => B5_IN8);
GLB_B5_P11 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B5_P11, A1 => B5_IN1, A0 => B5_IN8);
GLB_B5_P10 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B5_P10, A1 => B5_IN8B, A0 => B5_IN16);
GLB_B5_P7 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B5_P7, A1 => B5_IN8, A0 => B5_IN10);
GLB_B5_P6 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B5_P6, A1 => B5_IN8B, A0 => B5_IN17);
GLB_B5_F3 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => B5_F3, A1 => B5_P15, A0 => B5_P16);
GLB_B5_F2 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => B5_F2, A1 => B5_P10, A0 => B5_P11);
GLB_B5_F1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => B5_F1, A1 => B5_P6, A0 => B5_P7);
GLB_BUF_2402 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => BUF_2402, A0 => B5_P19);
GLB_B5_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => B5_CLK, A0 => BUF_2403_ck2f);
GLB_B5_IN2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B5_IN2, A0 => UQNN_N26_grpi);
GLB_B5_IN4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B5_IN4, A0 => ML_SIG_grpi);
GLB_B5_IN1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B5_IN1, A0 => RNG2_INX_grp);
GLB_B5_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B5_IN16, A0 => FREQ_SIG_ffb);
GLB_B5_IN10 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B5_IN10, A0 => UQNNONMCK_175);
GLB_B5_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B5_IN8, A0 => UPDATE_SIG_grpi);
GLB_B5_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B5_IN17, A0 => UQNNONMCK_148);
UQBNONMCK_106 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_147, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B5_CLK, 
	D0 => B5_F1);
GLB_FREQ_SIG : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => FREQ_SIG, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B5_CLK, 
	D0 => B5_F2);
GLB_ML_SIG : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => ML_SIG, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B5_CLK, 
	D0 => B5_F3);
GLB_B5_IN3B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B5_IN3B, A0 => ML_INX_grp);
GLB_B5_IN8B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B5_IN8B, A0 => UPDATE_SIG_grpi);
GLB_B6_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B6_P16, A1 => B6_IN7B, A0 => B6_IN16);
GLB_B6_P15 : PGAND3_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B6_P15, A2 => B6_IN3, A1 => B6_IN7B, A0 => B6_IN11B);
GLB_B6_P7 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B6_P7, A5 => B6_IN4, A4 => B6_IN5, A3 => B6_IN6, 
	A2 => B6_IN13, A1 => B6_IN14B, A0 => B6_IN15);
GLB_B6_P6 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B6_P6, A5 => B6_IN4, A4 => B6_IN5, A3 => B6_IN6, 
	A2 => B6_IN8, A1 => B6_IN14B, A0 => B6_IN15B);
GLB_B6_P5 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B6_P5, A5 => B6_IN4, A4 => B6_IN5, A3 => B6_IN6B, 
	A2 => B6_IN12, A1 => B6_IN14B, A0 => B6_IN15);
GLB_B6_P4 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B6_P4, A5 => B6_IN0, A4 => B6_IN4, A3 => B6_IN5, 
	A2 => B6_IN6B, A1 => B6_IN14B, A0 => B6_IN15B);
GLB_B6_P3 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B6_P3, A5 => B6_IN2, A4 => B6_IN4, A3 => B6_IN5, 
	A2 => B6_IN6, A1 => B6_IN14, A0 => B6_IN15);
GLB_B6_P2 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B6_P2, A5 => B6_IN1, A4 => B6_IN4, A3 => B6_IN5, 
	A2 => B6_IN6, A1 => B6_IN14, A0 => B6_IN15B);
GLB_B6_P1 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B6_P1, A5 => B6_IN4, A4 => B6_IN5, A3 => B6_IN6B, 
	A2 => B6_IN10, A1 => B6_IN14, A0 => B6_IN15);
GLB_B6_P0 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B6_P0, A5 => B6_IN4, A4 => B6_IN5, A3 => B6_IN6B, 
	A2 => B6_IN9, A1 => B6_IN14, A0 => B6_IN15B);
GLB_B6_G2 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => B6_G2, A1 => B6_F0, A0 => B6_F1);
GLB_B6_F3 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => B6_F3, A1 => B6_P15, A0 => B6_P16);
GLB_B6_F1 : PGORF74_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => B6_F1, A3 => B6_P4, A2 => B6_P5, A1 => B6_P6, 
	A0 => B6_P7);
GLB_B6_F0 : PGORF74_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => B6_F0, A3 => B6_P0, A2 => B6_P1, A1 => B6_P2, 
	A0 => B6_P3);
GLB_B6_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => B6_CLK, A0 => CLK_MASTERX_clk1);
GLB_B6_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN16, A0 => UPDATE_SIG_ffb);
GLB_B6_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN3, A0 => UQNNONMCK_155);
GLB_B6_IN13 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN13, A0 => UQNN_N40_grpi);
GLB_B6_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN8, A0 => UQNN_N41_grpi);
GLB_B6_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN12, A0 => UQNN_N42_grpi);
GLB_B6_IN0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN0, A0 => UQNN_N43_grpi);
GLB_B6_IN2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN2, A0 => UQNN_N36_grpi);
GLB_B6_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN6, A0 => UQNN_N10_grpi);
GLB_B6_IN1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN1, A0 => UQNN_N37_grpi);
GLB_B6_IN15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN15, A0 => UQNN_N9_grpi);
GLB_B6_IN10 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN10, A0 => UQNN_N38_grpi);
GLB_B6_IN14 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN14, A0 => UQNN_N11_grpi);
GLB_B6_IN9 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN9, A0 => UQNN_N39_grpi);
GLB_B6_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN5, A0 => UQNN_N21_grpi);
GLB_B6_IN4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B6_IN4, A0 => UQNN_N47_grpi);
GLB_B6_X1O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => B6_X1O, A1 => GND, A0 => B6_G2);
GLB_UQNN_N25 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N25, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B6_CLK, 
	D0 => B6_X1O);
GLB_UPDATE_SIG : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UPDATE_SIG, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B6_CLK, 
	D0 => B6_F3);
GLB_B6_IN11B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B6_IN11B, A0 => TRANSFER_SIG_grpi);
GLB_B6_IN7B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B6_IN7B, A0 => UQNNONMCK_176);
GLB_B6_IN14B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B6_IN14B, A0 => UQNN_N11_grpi);
GLB_B6_IN15B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B6_IN15B, A0 => UQNN_N9_grpi);
GLB_B6_IN6B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B6_IN6B, A0 => UQNN_N10_grpi);
GLB_B7_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B7_P16, A1 => B7_IN3, A0 => B7_IN14);
GLB_B7_P15 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B7_P15, A1 => B7_IN3B, A0 => B7_IN16);
GLB_B7_P12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => B7_P12, A0 => B7_IN5);
GLB_B7_P11 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B7_P11, A1 => B7_IN3, A0 => B7_IN9);
GLB_B7_P10 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B7_P10, A1 => B7_IN3B, A0 => B7_IN17);
GLB_B7_P7 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B7_P7, A1 => B7_IN3, A0 => B7_IN8);
GLB_B7_P6 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B7_P6, A1 => B7_IN3B, A0 => B7_IN10);
GLB_B7_P3 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B7_P3, A1 => B7_IN0, A0 => B7_IN3);
GLB_B7_P2 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => B7_P2, A1 => B7_IN3B, A0 => B7_IN11);
GLB_B7_F3 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => B7_F3, A1 => B7_P15, A0 => B7_P16);
GLB_B7_F2 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => B7_F2, A1 => B7_P10, A0 => B7_P11);
GLB_B7_F1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => B7_F1, A1 => B7_P6, A0 => B7_P7);
GLB_B7_F0 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => B7_F0, A1 => B7_P2, A0 => B7_P3);
GLB_B7_CLKP : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.900000 ns, TFALL => 1.900000 ns)
	PORT MAP (Z0 => B7_CLKP, A0 => B7_P12);
GLB_B7_IN14 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B7_IN14, A0 => UQNNONMCK_175);
GLB_B7_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B7_IN16, A0 => UQNNONMCK_153);
GLB_B7_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B7_IN5, A0 => UQNNONMCK_170);
GLB_B7_IN9 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B7_IN9, A0 => UQNNONMCK_177);
GLB_B7_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B7_IN17, A0 => UQNNONMCK_154);
GLB_B7_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B7_IN8, A0 => UQNNONMCK_179);
GLB_B7_IN10 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B7_IN10, A0 => UQNNONMCK_125);
GLB_B7_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B7_IN3, A0 => UPDATE_SIG_grpi);
GLB_B7_IN0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B7_IN0, A0 => UQNNONMCK_181);
GLB_B7_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => B7_IN11, A0 => UQNNONMCK_126);
UQBNONMCK_107 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_149, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B7_CLKP, 
	D0 => B7_F0);
UQBNONMCK_108 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_150, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B7_CLKP, 
	D0 => B7_F1);
UQBNONMCK_109 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_151, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B7_CLKP, 
	D0 => B7_F2);
UQBNONMCK_110 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_152, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => B7_CLKP, 
	D0 => B7_F3);
GLB_B7_IN3B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => B7_IN3B, A0 => UPDATE_SIG_grpi);
GLB_C0_P18 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C0_P18, A5 => C0_IN0, A4 => C0_IN1B, A3 => C0_IN7, 
	A2 => C0_IN8, A1 => C0_IN9B, A0 => C0_IN11B);
GLB_C0_P17 : PGAND3_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C0_P17, A2 => C0_IN0B, A1 => C0_IN5, A0 => C0_IN8);
GLB_C0_P16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C0_P16, A0 => C0_IN15);
GLB_C0_P15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C0_P15, A0 => C0_IN13);
GLB_C0_P14 : PGAND3_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C0_P14, A2 => C0_IN0B, A1 => C0_IN7, A0 => C0_IN10);
GLB_C0_P13 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C0_P13, A5 => C0_IN0, A4 => C0_IN1B, A3 => C0_IN7, 
	A2 => C0_IN8, A1 => C0_IN9B, A0 => C0_IN11B);
GLB_C0_P8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C0_P8, A0 => C0_IN12);
GLB_C0_P4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C0_P4, A0 => C0_IN14);
GLB_C0_G3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => C0_G3, A0 => GND);
GLB_C0_G2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => C0_G2, A0 => GND);
GLB_C0_G1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => C0_G1, A0 => GND);
GLB_C0_G0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => C0_G0, A0 => C0_F5);
GLB_C0_F5 : PGORF75_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => C0_F5, A4 => C0_P14, A3 => C0_P15, A2 => C0_P16, 
	A1 => C0_P17, A0 => C0_P18);
GLB_OR_1154 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => OR_1154, A0 => C0_X3O);
GLB_C0_P4_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => C0_P4_xa, A0 => C0_P4);
GLB_C0_P8_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => C0_P8_xa, A0 => C0_P8);
GLB_BUF_2403 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => BUF_2403, A0 => C0_X1O);
GLB_C0_P13_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => C0_P13_xa, A0 => C0_P13);
GLB_UQNN_N166 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => UQNN_N166, A0 => C0_X0O);
GLB_C0_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C0_IN5, A0 => UQNN_N24_grpi);
GLB_C0_IN15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C0_IN15, A0 => STOP_SIG_grpi);
GLB_C0_IN13 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C0_IN13, A0 => UQNN_N22_grpi);
GLB_C0_IN10 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C0_IN10, A0 => UQNN_N21_grpi);
GLB_C0_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C0_IN8, A0 => UQNN_N27_grpi);
GLB_C0_IN7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C0_IN7, A0 => UQNN_N28_grpi);
GLB_C0_IN0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C0_IN0, A0 => UQNN_N12_grpi);
GLB_C0_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C0_IN12, A0 => UQNNONMCK_155);
GLB_C0_IN14 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C0_IN14, A0 => SCL_INX_grp);
GLB_C0_X3O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => C0_X3O, A1 => GND, A0 => C0_G0);
GLB_C0_X2O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => C0_X2O, A1 => C0_P4_xa, A0 => C0_G1);
GLB_C0_X1O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => C0_X1O, A1 => C0_P8_xa, A0 => C0_G2);
GLB_C0_X0O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => C0_X0O, A1 => C0_P13_xa, A0 => C0_G3);
GLB_UQNN_N13 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N13, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C0_CLK, 
	D0 => C0_X2O);
GLB_C0_CLK : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (ZN0 => C0_CLK, A0 => CLK_MASTERX_clk1);
GLB_C0_IN0B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C0_IN0B, A0 => UQNN_N12_grpi);
GLB_C0_IN11B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C0_IN11B, A0 => UQNN_N9_grpi);
GLB_C0_IN9B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C0_IN9B, A0 => UQNN_N10_grpi);
GLB_C0_IN1B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C0_IN1B, A0 => UQNN_N11_grpi);
GLB_C1_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C1_P16, A1 => C1_IN5, A0 => C1_IN7);
GLB_C1_P15 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C1_P15, A1 => C1_IN7B, A0 => C1_IN11);
GLB_C1_P12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C1_P12, A0 => C1_IN12);
GLB_C1_P11 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C1_P11, A1 => C1_IN7, A0 => C1_IN15);
GLB_C1_P10 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C1_P10, A1 => C1_IN7B, A0 => C1_IN16);
GLB_C1_P7 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C1_P7, A1 => C1_IN6, A0 => C1_IN7);
GLB_C1_P6 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C1_P6, A1 => C1_IN7B, A0 => C1_IN17);
GLB_C1_P3 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C1_P3, A1 => C1_IN3, A0 => C1_IN7);
GLB_C1_P2 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C1_P2, A1 => C1_IN7B, A0 => C1_IN8);
GLB_C1_F3 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C1_F3, A1 => C1_P15, A0 => C1_P16);
GLB_C1_F2 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C1_F2, A1 => C1_P10, A0 => C1_P11);
GLB_C1_F1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C1_F1, A1 => C1_P6, A0 => C1_P7);
GLB_C1_F0 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C1_F0, A1 => C1_P2, A0 => C1_P3);
GLB_C1_CLKP : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.900000 ns, TFALL => 1.900000 ns)
	PORT MAP (Z0 => C1_CLKP, A0 => C1_P12);
GLB_C1_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C1_IN5, A0 => UQNNONMCK_175);
GLB_C1_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C1_IN11, A0 => UQNNONMCK_127);
GLB_C1_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C1_IN12, A0 => UQNNONMCK_160);
GLB_C1_IN15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C1_IN15, A0 => UQNNONMCK_181);
GLB_C1_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C1_IN16, A0 => UQNNONMCK_161);
GLB_C1_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C1_IN6, A0 => UQNNONMCK_177);
GLB_C1_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C1_IN17, A0 => UQNNONMCK_162);
GLB_C1_IN7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C1_IN7, A0 => UPDATE_SIG_grpi);
GLB_C1_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C1_IN3, A0 => UQNNONMCK_179);
GLB_C1_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C1_IN8, A0 => UQNNONMCK_128);
UQBNONMCK_111 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_156, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C1_CLKP, 
	D0 => C1_F0);
UQBNONMCK_112 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_157, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C1_CLKP, 
	D0 => C1_F1);
UQBNONMCK_113 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_158, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C1_CLKP, 
	D0 => C1_F2);
UQBNONMCK_114 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_159, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C1_CLKP, 
	D0 => C1_F3);
GLB_C1_IN7B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C1_IN7B, A0 => UPDATE_SIG_grpi);
GLB_C2_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C2_P16, A1 => C2_IN6, A0 => C2_IN12);
GLB_C2_P15 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C2_P15, A1 => C2_IN12B, A0 => C2_IN16);
GLB_C2_P12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C2_P12, A0 => C2_IN11);
GLB_C2_P11 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C2_P11, A1 => C2_IN4, A0 => C2_IN12);
GLB_C2_P10 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C2_P10, A1 => C2_IN12B, A0 => C2_IN17);
GLB_C2_P7 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C2_P7, A1 => C2_IN7, A0 => C2_IN12);
GLB_C2_P6 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C2_P6, A1 => C2_IN12B, A0 => C2_IN14);
GLB_C2_P3 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C2_P3, A1 => C2_IN5, A0 => C2_IN12);
GLB_C2_P2 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C2_P2, A1 => C2_IN12B, A0 => C2_IN15);
GLB_C2_F3 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C2_F3, A1 => C2_P15, A0 => C2_P16);
GLB_C2_F2 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C2_F2, A1 => C2_P10, A0 => C2_P11);
GLB_C2_F1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C2_F1, A1 => C2_P6, A0 => C2_P7);
GLB_C2_F0 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C2_F0, A1 => C2_P2, A0 => C2_P3);
GLB_C2_CLKP : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.900000 ns, TFALL => 1.900000 ns)
	PORT MAP (Z0 => C2_CLKP, A0 => C2_P12);
GLB_C2_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C2_IN6, A0 => UQNNONMCK_177);
GLB_C2_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C2_IN16, A0 => UQNNONMCK_167);
GLB_C2_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C2_IN11, A0 => UQNNONMCK_168);
GLB_C2_IN4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C2_IN4, A0 => UQNNONMCK_181);
GLB_C2_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C2_IN17, A0 => UQNNONMCK_169);
GLB_C2_IN7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C2_IN7, A0 => UQNNONMCK_179);
GLB_C2_IN14 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C2_IN14, A0 => UQNNONMCK_130);
GLB_C2_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C2_IN12, A0 => UPDATE_SIG_grpi);
GLB_C2_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C2_IN5, A0 => UQNNONMCK_175);
GLB_C2_IN15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C2_IN15, A0 => UQNNONMCK_119);
UQBNONMCK_115 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_163, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C2_CLKP, 
	D0 => C2_F0);
UQBNONMCK_116 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_164, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C2_CLKP, 
	D0 => C2_F1);
UQBNONMCK_117 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_165, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C2_CLKP, 
	D0 => C2_F2);
UQBNONMCK_118 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_166, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C2_CLKP, 
	D0 => C2_F3);
GLB_C2_IN12B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C2_IN12B, A0 => UPDATE_SIG_grpi);
GLB_C3_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C3_P16, A1 => C3_IN11, A0 => C3_IN12);
GLB_C3_P15 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C3_P15, A1 => C3_IN12B, A0 => C3_IN16);
GLB_C3_P12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C3_P12, A0 => C3_IN10);
GLB_C3_F3 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C3_F3, A1 => C3_P15, A0 => C3_P16);
GLB_C3_CLKP : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.400000 ns, TFALL => 1.400000 ns)
	PORT MAP (Z0 => C3_CLKP, A0 => C3_P12);
GLB_C3_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C3_IN12, A0 => UPDATE_SIG_grpi);
GLB_C3_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C3_IN11, A0 => DS_INX_grp);
GLB_C3_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C3_IN16, A0 => M_ffb);
GLB_C3_IN10 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C3_IN10, A0 => UQNNONMCK_170);
GLB_M : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => M, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C3_CLK, 
	D0 => C3_F3);
GLB_C3_CLK : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (ZN0 => C3_CLK, A0 => C3_CLKP);
GLB_C3_IN12B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C3_IN12B, A0 => UPDATE_SIG_grpi);
GLB_C4_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C4_P16, A1 => C4_IN12B, A0 => C4_IN16);
GLB_C4_P15 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C4_P15, A3 => C4_IN0, A2 => C4_IN1, A1 => C4_IN4B, 
	A0 => C4_IN12);
GLB_C4_P14 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C4_P14, A3 => C4_IN1B, A2 => C4_IN4, A1 => C4_IN7, 
	A0 => C4_IN12);
GLB_C4_P13 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C4_P13, A3 => C4_IN1B, A2 => C4_IN4B, A1 => C4_IN11, 
	A0 => C4_IN12);
GLB_C4_P12 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C4_P12, A1 => C4_IN12B, A0 => C4_IN17);
GLB_C4_P11 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C4_P11, A3 => C4_IN1, A2 => C4_IN2, A1 => C4_IN4B, 
	A0 => C4_IN12);
GLB_C4_P10 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C4_P10, A3 => C4_IN1B, A2 => C4_IN4, A1 => C4_IN5, 
	A0 => C4_IN12);
GLB_C4_P9 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C4_P9, A3 => C4_IN1B, A2 => C4_IN4B, A1 => C4_IN12, 
	A0 => C4_IN14);
GLB_C4_P8 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C4_P8, A3 => C4_IN1, A2 => C4_IN3, A1 => C4_IN4, 
	A0 => C4_IN12);
GLB_C4_P7 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C4_P7, A3 => C4_IN1B, A2 => C4_IN4B, A1 => C4_IN12, 
	A0 => C4_IN15);
GLB_C4_P6 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C4_P6, A3 => C4_IN1, A2 => C4_IN4, A1 => C4_IN10, 
	A0 => C4_IN12);
GLB_C4_P3 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C4_P3, A1 => C4_IN12B, A0 => C4_IN13);
GLB_C4_P2 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C4_P2, A3 => C4_IN1, A2 => C4_IN4B, A1 => C4_IN8, 
	A0 => C4_IN12);
GLB_C4_P1 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C4_P1, A3 => C4_IN1B, A2 => C4_IN4, A1 => C4_IN6, 
	A0 => C4_IN12);
GLB_C4_P0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C4_P0, A0 => C4_IN9);
GLB_C4_G2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => C4_G2, A0 => C4_F4);
GLB_C4_G1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => C4_G1, A1 => C4_F0, A0 => C4_F1);
GLB_C4_G0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => C4_G0, A0 => GND);
GLB_C4_F4 : PGORF75_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => C4_F4, A4 => C4_P8, A3 => C4_P9, A2 => C4_P10, 
	A1 => C4_P11, A0 => C4_P12);
GLB_C4_F3 : PGORF74_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C4_F3, A3 => C4_P13, A2 => C4_P14, A1 => C4_P15, 
	A0 => C4_P16);
GLB_C4_F1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => C4_F1, A1 => C4_P6, A0 => C4_P7);
GLB_C4_F0 : PGORF73_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => C4_F0, A2 => C4_P1, A1 => C4_P2, A0 => C4_P3);
GLB_C4_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => C4_CLK, A0 => CLK_MASTERX_clk1);
GLB_C4_P0_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => C4_P0_xa, A0 => C4_P0);
GLB_C4_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN16, A0 => UQNN_N43_ffb);
GLB_C4_IN0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN0, A0 => UQNNONMCK_127);
GLB_C4_IN7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN7, A0 => UQNNONMCK_124);
GLB_C4_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN11, A0 => UQNNONMCK_132);
GLB_C4_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN17, A0 => UQNN_N37_ffb);
GLB_C4_IN2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN2, A0 => UQNNONMCK_110);
GLB_C4_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN5, A0 => UQNNONMCK_130);
GLB_C4_IN14 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN14, A0 => UQNNONMCK_114);
GLB_C4_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN3, A0 => M_grpi);
GLB_C4_IN15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN15, A0 => UQNNONMCK_115);
GLB_C4_IN10 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN10, A0 => L_grpi);
GLB_C4_IN13 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN13, A0 => UQNN_N36_grpi);
GLB_C4_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN8, A0 => UQNNONMCK_111);
GLB_C4_IN1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN1, A0 => UQNNONMCK_123);
GLB_C4_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN12, A0 => OR_1148_grpi);
GLB_C4_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN6, A0 => UQNNONMCK_131);
GLB_C4_IN4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN4, A0 => UQNNONMCK_122);
GLB_C4_IN9 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C4_IN9, A0 => UQNN_N13_grpi);
GLB_C4_X3O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => C4_X3O, A1 => C4_P0_xa, A0 => C4_G0);
GLB_C4_X2O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => C4_X2O, A1 => GND, A0 => C4_G1);
GLB_C4_X1O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => C4_X1O, A1 => GND, A0 => C4_G2);
GLB_UQNN_N19 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N19, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C4_CLK, 
	D0 => C4_X3O);
GLB_UQNN_N36 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N36, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C4_CLK, 
	D0 => C4_X2O);
GLB_UQNN_N37 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N37, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C4_CLK, 
	D0 => C4_X1O);
GLB_UQNN_N43 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N43, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C4_CLK, 
	D0 => C4_F3);
GLB_C4_IN12B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C4_IN12B, A0 => OR_1148_grpi);
GLB_C4_IN4B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C4_IN4B, A0 => UQNNONMCK_122);
GLB_C4_IN1B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C4_IN1B, A0 => UQNNONMCK_123);
GLB_C5_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C5_P16, A1 => C5_IN8B, A0 => C5_IN16);
GLB_C5_P15 : PGAND8_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C5_P15, A7 => C5_IN0, A6 => C5_IN4B, A5 => C5_IN8, 
	A4 => C5_IN9, A3 => C5_IN10, A2 => C5_IN11B, A1 => C5_IN13B, 
	A0 => C5_IN15B);
GLB_C5_P13 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C5_P13, A5 => C5_IN4B, A4 => C5_IN8, A3 => C5_IN11B, 
	A2 => C5_IN13B, A1 => C5_IN15B, A0 => C5_IN16);
GLB_C5_P11 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C5_P11, A1 => C5_IN8B, A0 => C5_IN10);
GLB_C5_P10 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C5_P10, A5 => C5_IN0B, A4 => C5_IN4B, A3 => C5_IN10, 
	A2 => C5_IN11B, A1 => C5_IN13B, A0 => C5_IN15B);
GLB_C5_P9 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C5_P9, A5 => C5_IN4B, A4 => C5_IN9B, A3 => C5_IN10, 
	A2 => C5_IN11B, A1 => C5_IN13B, A0 => C5_IN15B);
GLB_C5_P8 : PGAND8_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C5_P8, A7 => C5_IN0, A6 => C5_IN4B, A5 => C5_IN8, 
	A4 => C5_IN9, A3 => C5_IN10B, A2 => C5_IN11B, A1 => C5_IN13B, 
	A0 => C5_IN15B);
GLB_C5_P7 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C5_P7, A1 => C5_IN8B, A0 => C5_IN9);
GLB_C5_P6 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C5_P6, A5 => C5_IN0, A4 => C5_IN4B, A3 => C5_IN9, 
	A2 => C5_IN11B, A1 => C5_IN13B, A0 => C5_IN15);
GLB_C5_P5 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C5_P5, A5 => C5_IN0B, A4 => C5_IN4B, A3 => C5_IN9, 
	A2 => C5_IN11B, A1 => C5_IN13B, A0 => C5_IN15B);
GLB_C5_P4 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C5_P4, A5 => C5_IN0, A4 => C5_IN4B, A3 => C5_IN8, 
	A2 => C5_IN9B, A1 => C5_IN11B, A0 => C5_IN13B);
GLB_C5_P3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C5_P3, A0 => C5_IN4);
GLB_C5_P2 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C5_P2, A1 => C5_IN13B, A0 => C5_IN17B);
GLB_C5_P1 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C5_P1, A5 => C5_IN0B, A4 => C5_IN9B, A3 => C5_IN10B, 
	A2 => C5_IN12, A1 => C5_IN13B, A0 => C5_IN16);
GLB_C5_P0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C5_P0, A0 => VCC);
GLB_C5_G3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => C5_G3, A0 => C5_F5);
GLB_C5_G0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => C5_G0, A0 => C5_F0);
GLB_C5_F5 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => C5_F5, A1 => C5_P15, A0 => C5_P16);
GLB_C5_F2 : PGORF74_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C5_F2, A3 => C5_P8, A2 => C5_P9, A1 => C5_P10, 
	A0 => C5_P11);
GLB_C5_F1 : PGORF74_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C5_F1, A3 => C5_P4, A2 => C5_P5, A1 => C5_P6, 
	A0 => C5_P7);
GLB_C5_F0 : PGORF73_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => C5_F0, A2 => C5_P1, A1 => C5_P2, A0 => C5_P3);
GLB_C5_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => C5_CLK, A0 => CLK_MASTERX_clk1);
GLB_C5_P0_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => C5_P0_xa, A0 => C5_P0);
GLB_C5_P13_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => C5_P13_xa, A0 => C5_P13);
GLB_C5_IN10 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C5_IN10, A0 => UQNN_N11_grpi);
GLB_C5_IN15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C5_IN15, A0 => UQNN_N166_grpi);
GLB_C5_IN9 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C5_IN9, A0 => UQNN_N10_grpi);
GLB_C5_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C5_IN8, A0 => OR_1154_grpi);
GLB_C5_IN0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C5_IN0, A0 => UQNN_N9_grpi);
GLB_C5_IN4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C5_IN4, A0 => STOP_SIG_grpi);
GLB_C5_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C5_IN16, A0 => UQNN_N12_ffb);
GLB_C5_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C5_IN12, A0 => UQNN_N28_grpi);
GLB_C5_X3O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => C5_X3O, A1 => C5_P0_xa, A0 => C5_G0);
GLB_C5_X0O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => C5_X0O, A1 => C5_P13_xa, A0 => C5_G3);
GLB_UQNN_N27 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N27, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C5_CLK, 
	D0 => C5_X3O);
GLB_UQNN_N10 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N10, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C5_CLK, 
	D0 => C5_F1);
GLB_UQNN_N11 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N11, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C5_CLK, 
	D0 => C5_F2);
GLB_UQNN_N12 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N12, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C5_CLK, 
	D0 => C5_X0O);
GLB_C5_IN8B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C5_IN8B, A0 => OR_1154_grpi);
GLB_C5_IN15B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C5_IN15B, A0 => UQNN_N166_grpi);
GLB_C5_IN11B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C5_IN11B, A0 => UQNN_N108_grpi);
GLB_C5_IN4B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C5_IN4B, A0 => STOP_SIG_grpi);
GLB_C5_IN17B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C5_IN17B, A0 => UQNN_N27_ffb);
GLB_C5_IN13B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C5_IN13B, A0 => UQNN_N22_grpi);
GLB_C5_IN10B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C5_IN10B, A0 => UQNN_N11_grpi);
GLB_C5_IN9B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C5_IN9B, A0 => UQNN_N10_grpi);
GLB_C5_IN0B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C5_IN0B, A0 => UQNN_N9_grpi);
GLB_C6_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C6_P16, A1 => C6_IN9B, A0 => C6_IN16);
GLB_C6_P15 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C6_P15, A1 => C6_IN5B, A0 => C6_IN16);
GLB_C6_P14 : PGAND3_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => C6_P14, A2 => C6_IN5, A1 => C6_IN9, A0 => C6_IN13B);
GLB_C6_P8 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C6_P8, A3 => C6_IN12, A2 => C6_IN13B, A1 => C6_IN14, 
	A0 => C6_IN17);
GLB_C6_P4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C6_P4, A0 => C6_IN13);
GLB_C6_P0 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => C6_P0, A3 => C6_IN12, A2 => C6_IN13, A1 => C6_IN14, 
	A0 => C6_IN17B);
GLB_C6_G2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => C6_G2, A0 => GND);
GLB_C6_G1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => C6_G1, A0 => GND);
GLB_C6_G0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => C6_G0, A0 => GND);
GLB_C6_F3 : PGORF73_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => C6_F3, A2 => C6_P14, A1 => C6_P15, A0 => C6_P16);
GLB_C6_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => C6_CLK, A0 => CLK_MASTERX_clk1);
GLB_C6_P0_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => C6_P0_xa, A0 => C6_P0);
GLB_C6_P4_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => C6_P4_xa, A0 => C6_P4);
GLB_C6_P8_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => C6_P8_xa, A0 => C6_P8);
GLB_C6_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C6_IN16, A0 => UQNN_N31_ffb);
GLB_C6_IN9 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C6_IN9, A0 => UQNN_N23_grpi);
GLB_C6_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C6_IN5, A0 => UQNN_N24_grpi);
GLB_C6_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C6_IN17, A0 => UQNN_N20_ffb);
GLB_C6_IN14 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C6_IN14, A0 => SCL_INX_grp);
GLB_C6_IN13 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C6_IN13, A0 => SDA_BI_Z0_grp);
GLB_C6_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => C6_IN12, A0 => UQNN_N19_grpi);
GLB_C6_X3O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => C6_X3O, A1 => C6_P0_xa, A0 => C6_G0);
GLB_C6_X2O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => C6_X2O, A1 => C6_P4_xa, A0 => C6_G1);
GLB_C6_X1O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => C6_X1O, A1 => C6_P8_xa, A0 => C6_G2);
GLB_STOP_SIG : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => STOP_SIG, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C6_CLK, 
	D0 => C6_X3O);
GLB_UQNN_N20 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N20, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C6_CLK, 
	D0 => C6_X2O);
GLB_UQNN_N22 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N22, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C6_CLK, 
	D0 => C6_X1O);
GLB_UQNN_N31 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N31, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => C6_CLK, 
	D0 => C6_F3);
GLB_C6_IN9B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C6_IN9B, A0 => UQNN_N23_grpi);
GLB_C6_IN5B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C6_IN5B, A0 => UQNN_N24_grpi);
GLB_C6_IN13B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C6_IN13B, A0 => SDA_BI_Z0_grp);
GLB_C6_IN17B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => C6_IN17B, A0 => UQNN_N20_ffb);
GLB_D0_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D0_P16, A1 => D0_IN6, A0 => D0_IN15B);
GLB_D0_P15 : PGAND3_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D0_P15, A2 => D0_IN11B, A1 => D0_IN15B, A0 => D0_IN16);
GLB_D0_P14 : PGAND9_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D0_P14, A8 => D0_IN0B, A7 => D0_IN2B, A6 => D0_IN4B, 
	A5 => D0_IN5B, A4 => D0_IN12, A3 => D0_IN13, A2 => D0_IN14B, 
	A1 => D0_IN15B, A0 => D0_IN16);
GLB_D0_P11 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D0_P11, A3 => D0_IN6B, A2 => D0_IN7B, A1 => D0_IN15B, 
	A0 => D0_IN17);
GLB_D0_P10 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D0_P10, A3 => D0_IN3B, A2 => D0_IN6B, A1 => D0_IN15B, 
	A0 => D0_IN17);
GLB_D0_P9 : PGAND10_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D0_P9, A9 => D0_IN0B, A8 => D0_IN2B, A7 => D0_IN4B, 
	A6 => D0_IN5B, A5 => D0_IN6B, A4 => D0_IN11, A3 => D0_IN12, 
	A2 => D0_IN13, A1 => D0_IN14B, A0 => D0_IN15B);
GLB_D0_F3 : PGORF73_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => D0_F3, A2 => D0_P14, A1 => D0_P15, A0 => D0_P16);
GLB_D0_F2 : PGORF73_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => D0_F2, A2 => D0_P9, A1 => D0_P10, A0 => D0_P11);
GLB_D0_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => D0_CLK, A0 => CLK_MASTERX_clk1);
GLB_D0_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D0_IN6, A0 => UQNN_N22_grpi);
GLB_D0_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D0_IN16, A0 => UQNN_N47_ffb);
GLB_D0_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D0_IN17, A0 => UQNN_N32_ffb);
GLB_D0_IN13 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D0_IN13, A0 => UQNN_N29_grpi);
GLB_D0_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D0_IN12, A0 => UQNN_N30_grpi);
GLB_D0_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D0_IN11, A0 => UQNN_N166_grpi);
GLB_UQNN_N32 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N32, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D0_CLK, 
	D0 => D0_F2);
GLB_UQNN_N47 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N47, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D0_CLK, 
	D0 => D0_F3);
GLB_D0_IN11B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D0_IN11B, A0 => UQNN_N166_grpi);
GLB_D0_IN7B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D0_IN7B, A0 => UQNN_N28_grpi);
GLB_D0_IN3B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D0_IN3B, A0 => UQNN_N35_grpi);
GLB_D0_IN15B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D0_IN15B, A0 => STOP_SIG_grpi);
GLB_D0_IN14B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D0_IN14B, A0 => UQNN_N18_grpi);
GLB_D0_IN6B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D0_IN6B, A0 => UQNN_N22_grpi);
GLB_D0_IN5B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D0_IN5B, A0 => UQNN_N15_grpi);
GLB_D0_IN4B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D0_IN4B, A0 => UQNN_N17_grpi);
GLB_D0_IN2B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D0_IN2B, A0 => UQNN_N16_grpi);
GLB_D0_IN0B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D0_IN0B, A0 => UQNN_N14_grpi);
GLB_D1_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D1_P16, A1 => D1_IN5, A0 => D1_IN12);
GLB_D1_P15 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D1_P15, A1 => D1_IN11, A0 => D1_IN12B);
GLB_D1_P12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => D1_P12, A0 => D1_IN8);
GLB_D1_P11 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D1_P11, A1 => D1_IN6, A0 => D1_IN12);
GLB_D1_P10 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D1_P10, A1 => D1_IN12B, A0 => D1_IN16);
GLB_D1_P7 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D1_P7, A1 => D1_IN7, A0 => D1_IN12);
GLB_D1_P6 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D1_P6, A1 => D1_IN12B, A0 => D1_IN17);
GLB_D1_P3 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D1_P3, A1 => D1_IN12, A0 => D1_IN15);
GLB_D1_P2 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D1_P2, A1 => D1_IN3, A0 => D1_IN12B);
GLB_D1_F3 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => D1_F3, A1 => D1_P15, A0 => D1_P16);
GLB_D1_F2 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => D1_F2, A1 => D1_P10, A0 => D1_P11);
GLB_D1_F1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => D1_F1, A1 => D1_P6, A0 => D1_P7);
GLB_D1_F0 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => D1_F0, A1 => D1_P2, A0 => D1_P3);
GLB_D1_CLKP : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.900000 ns, TFALL => 1.900000 ns)
	PORT MAP (Z0 => D1_CLKP, A0 => D1_P12);
GLB_D1_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D1_IN5, A0 => UQNNONMCK_175);
GLB_D1_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D1_IN11, A0 => UQNNONMCK_132);
GLB_D1_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D1_IN8, A0 => UQNNONMCK_176);
GLB_D1_IN6 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D1_IN6, A0 => UQNNONMCK_177);
GLB_D1_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D1_IN16, A0 => UQNNONMCK_178);
GLB_D1_IN7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D1_IN7, A0 => UQNNONMCK_179);
GLB_D1_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D1_IN17, A0 => UQNNONMCK_180);
GLB_D1_IN15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D1_IN15, A0 => UQNNONMCK_181);
GLB_D1_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D1_IN12, A0 => UPDATE_SIG_grpi);
GLB_D1_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D1_IN3, A0 => UQNNONMCK_134);
UQBNONMCK_119 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_171, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D1_CLKP, 
	D0 => D1_F0);
UQBNONMCK_120 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_172, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D1_CLKP, 
	D0 => D1_F1);
UQBNONMCK_121 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_173, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D1_CLKP, 
	D0 => D1_F2);
UQBNONMCK_122 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_174, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D1_CLKP, 
	D0 => D1_F3);
GLB_D1_IN12B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D1_IN12B, A0 => UPDATE_SIG_grpi);
GLB_D3_P17 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D3_P17, A3 => D3_IN0, A2 => D3_IN1, A1 => D3_IN12, 
	A0 => D3_IN17);
GLB_D3_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D3_P16, A1 => D3_IN12B, A0 => D3_IN16);
GLB_D3_P15 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D3_P15, A3 => D3_IN0B, A2 => D3_IN10, A1 => D3_IN12, 
	A0 => D3_IN17);
GLB_D3_P14 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D3_P14, A3 => D3_IN0, A2 => D3_IN4, A1 => D3_IN12, 
	A0 => D3_IN17B);
GLB_D3_P13 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => D3_P13, A3 => D3_IN0B, A2 => D3_IN8, A1 => D3_IN12, 
	A0 => D3_IN17B);
GLB_D3_P12 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => D3_P12, A1 => D3_IN7, A0 => D3_IN12B);
GLB_D3_P11 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D3_P11, A3 => D3_IN0B, A2 => D3_IN3, A1 => D3_IN12, 
	A0 => D3_IN17);
GLB_D3_P10 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D3_P10, A3 => D3_IN0, A2 => D3_IN5, A1 => D3_IN12, 
	A0 => D3_IN17B);
GLB_D3_P9 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D3_P9, A3 => D3_IN0B, A2 => D3_IN9, A1 => D3_IN12, 
	A0 => D3_IN17B);
GLB_D3_P8 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => D3_P8, A3 => D3_IN0, A2 => D3_IN11, A1 => D3_IN12, 
	A0 => D3_IN17);
GLB_D3_P7 : PGAND3_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D3_P7, A2 => D3_IN0B, A1 => D3_IN15, A0 => D3_IN17);
GLB_D3_P6 : PGAND3_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D3_P6, A2 => D3_IN13B, A1 => D3_IN15, A0 => D3_IN17);
GLB_D3_P5 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D3_P5, A3 => D3_IN0, A2 => D3_IN13, A1 => D3_IN15, 
	A0 => D3_IN17B);
GLB_D3_P3 : PGAND3_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D3_P3, A2 => D3_IN0B, A1 => D3_IN13, A0 => D3_IN15);
GLB_D3_P2 : PGAND3_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D3_P2, A2 => D3_IN0, A1 => D3_IN13B, A0 => D3_IN15);
GLB_D3_G3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => D3_G3, A0 => D3_F4);
GLB_D3_G2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => D3_G2, A0 => D3_F5);
GLB_D3_F5 : PGORF75_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => D3_F5, A4 => D3_P13, A3 => D3_P14, A2 => D3_P15, 
	A1 => D3_P16, A0 => D3_P17);
GLB_D3_F4 : PGORF75_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => D3_F4, A4 => D3_P8, A3 => D3_P9, A2 => D3_P10, 
	A1 => D3_P11, A0 => D3_P12);
GLB_D3_F1 : PGORF73_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => D3_F1, A2 => D3_P5, A1 => D3_P6, A0 => D3_P7);
GLB_D3_F0 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => D3_F0, A1 => D3_P2, A0 => D3_P3);
GLB_D3_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => D3_CLK, A0 => CLK_MASTERX_clk1);
GLB_D3_IN1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN1, A0 => FREQ_SIG_grpi);
GLB_D3_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN16, A0 => UQNN_N40_ffb);
GLB_D3_IN10 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN10, A0 => UQNNONMCK_129);
GLB_D3_IN4 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN4, A0 => UQNNONMCK_126);
GLB_D3_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN8, A0 => UQNNONMCK_134);
GLB_D3_IN7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN7, A0 => UQNN_N41_grpi);
GLB_D3_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN3, A0 => UQNNONMCK_128);
GLB_D3_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN5, A0 => UQNNONMCK_125);
GLB_D3_IN9 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN9, A0 => UQNNONMCK_133);
GLB_D3_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN12, A0 => OR_1148_grpi);
GLB_D3_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN11, A0 => OVFL_SIG_grpi);
GLB_D3_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN17, A0 => UQNNONMCK_184);
GLB_D3_IN13 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN13, A0 => READ_REQ_SIG_grpi);
GLB_D3_IN15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN15, A0 => TRANSFER_SIG_grpi);
GLB_D3_IN0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D3_IN0, A0 => UQNNONMCK_122);
GLB_D3_X1O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => D3_X1O, A1 => GND, A0 => D3_G2);
GLB_D3_X0O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => D3_X0O, A1 => GND, A0 => D3_G3);
UQBNONMCK_123 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_182, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D3_CLK, 
	D0 => D3_F0);
UQBNONMCK_124 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNNONMCK_183, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D3_CLK, 
	D0 => D3_F1);
GLB_UQNN_N40 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N40, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D3_CLK, 
	D0 => D3_X1O);
GLB_UQNN_N41 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N41, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D3_CLK, 
	D0 => D3_X0O);
GLB_D3_IN12B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D3_IN12B, A0 => OR_1148_grpi);
GLB_D3_IN17B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D3_IN17B, A0 => UQNNONMCK_184);
GLB_D3_IN0B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D3_IN0B, A0 => UQNNONMCK_122);
GLB_D3_IN13B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D3_IN13B, A0 => READ_REQ_SIG_grpi);
GLB_D4_P19 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => D4_P19, A0 => D4_IN15);
GLB_D4_P13 : PGAND8_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => D4_P13, A7 => D4_IN0B, A6 => D4_IN1, A5 => D4_IN6B, 
	A4 => D4_IN9, A3 => D4_IN10, A2 => D4_IN11, A1 => D4_IN12, 
	A0 => D4_IN15B);
GLB_D4_P12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => D4_P12, A0 => D4_IN13);
GLB_D4_P8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => D4_P8, A0 => VCC);
GLB_D4_G3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => D4_G3, A0 => GND);
GLB_D4_G2 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => D4_G2, A0 => GND);
GLB_D4_CD : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.000000 ns, TFALL => 1.000000 ns)
	PORT MAP (Z0 => D4_CD, A0 => D4_P19);
GLB_D4_CLKP : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.900000 ns, TFALL => 1.900000 ns)
	PORT MAP (Z0 => D4_CLKP, A0 => D4_P12);
GLB_D4_P8_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => D4_P8_xa, A0 => D4_P8);
GLB_D4_P13_xa : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => D4_P13_xa, A0 => D4_P13);
GLB_UQNN_N108 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.600000 ns, TFALL => 1.600000 ns)
	PORT MAP (Z0 => UQNN_N108, A0 => D4_X0O);
GLB_D4_IN15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D4_IN15, A0 => STOP_SIG_grpi);
GLB_D4_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D4_IN12, A0 => UQNN_N28_grpi);
GLB_D4_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D4_IN11, A0 => UQNN_N9_grpi);
GLB_D4_IN10 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D4_IN10, A0 => UQNN_N21_grpi);
GLB_D4_IN9 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D4_IN9, A0 => UQNN_N10_grpi);
GLB_D4_IN1 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D4_IN1, A0 => UQNN_N11_grpi);
GLB_D4_IN13 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D4_IN13, A0 => MUP_INX_grp);
GLB_D4_X1O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => D4_X1O, A1 => D4_P8_xa, A0 => D4_G2);
GLB_D4_X0O : PGXOR2_ESPFLUKE
    GENERIC MAP (TRISE => 0.800000 ns, TFALL => 0.800000 ns)
	PORT MAP (Z0 => D4_X0O, A1 => D4_P13_xa, A0 => D4_G3);
GLB_TRIGGER_SIG : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => TRIGGER_SIG, RNESET => L2L_KEYWD_RESET_glbb, CD => D4_CD, CLK => D4_CLKP, 
	D0 => D4_X1O);
GLB_D4_IN15B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D4_IN15B, A0 => STOP_SIG_grpi);
GLB_D4_IN6B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D4_IN6B, A0 => UQNN_N22_grpi);
GLB_D4_IN0B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D4_IN0B, A0 => UQNN_N12_grpi);
GLB_D5_P16 : PGAND2_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D5_P16, A1 => D5_IN0, A0 => D5_IN8B);
GLB_D5_P15 : PGAND5_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D5_P15, A4 => D5_IN0, A3 => D5_IN4B, A2 => D5_IN11B, 
	A1 => D5_IN13B, A0 => D5_IN15);
GLB_D5_P14 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D5_P14, A5 => D5_IN0B, A4 => D5_IN4B, A3 => D5_IN8, 
	A2 => D5_IN11B, A1 => D5_IN13B, A0 => D5_IN15B);
GLB_D5_P11 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D5_P11, A3 => D5_IN4B, A2 => D5_IN11B, A1 => D5_IN13B, 
	A0 => D5_IN16);
GLB_D5_P10 : PGAND6_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D5_P10, A5 => D5_IN3, A4 => D5_IN4B, A3 => D5_IN7, 
	A2 => D5_IN11B, A1 => D5_IN13B, A0 => D5_IN14);
GLB_D5_P9 : PGAND7_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D5_P9, A6 => D5_IN3, A5 => D5_IN4B, A4 => D5_IN7, 
	A3 => D5_IN11B, A2 => D5_IN12, A1 => D5_IN13B, A0 => D5_IN17);
GLB_D5_P7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D5_P7, A0 => D5_IN11);
GLB_D5_P6 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D5_P6, A3 => D5_IN4B, A2 => D5_IN5B, A1 => D5_IN9, 
	A0 => D5_IN13B);
GLB_D5_P3 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D5_P3, A3 => D5_IN4B, A2 => D5_IN5, A1 => D5_IN9, 
	A0 => D5_IN13B);
GLB_D5_P2 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D5_P2, A3 => D5_IN4B, A2 => D5_IN9, A1 => D5_IN13B, 
	A0 => D5_IN17);
GLB_D5_P1 : PGAND4_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => D5_P1, A3 => D5_IN4B, A2 => D5_IN7B, A1 => D5_IN13B, 
	A0 => D5_IN17);
GLB_D5_P0 : PGAND5_ESPFLUKE
    GENERIC MAP (TRISE => 3.700000 ns, TFALL => 3.700000 ns)
	PORT MAP (Z0 => D5_P0, A4 => D5_IN3B, A3 => D5_IN4B, A2 => D5_IN12, 
	A1 => D5_IN13B, A0 => D5_IN17);
GLB_D5_F3 : PGORF73_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => D5_F3, A2 => D5_P14, A1 => D5_P15, A0 => D5_P16);
GLB_D5_F2 : PGORF73_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => D5_F2, A2 => D5_P9, A1 => D5_P10, A0 => D5_P11);
GLB_D5_F1 : PGORF72_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => D5_F1, A1 => D5_P6, A0 => D5_P7);
GLB_D5_F0 : PGORF74_ESPFLUKE
    GENERIC MAP (TRISE => 2.400000 ns, TFALL => 2.400000 ns)
	PORT MAP (Z0 => D5_F0, A3 => D5_P0, A2 => D5_P1, A1 => D5_P2, 
	A0 => D5_P3);
GLB_D5_CLK : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.500000 ns, TFALL => 0.500000 ns)
	PORT MAP (Z0 => D5_CLK, A0 => CLK_MASTERX_clk1);
GLB_D5_IN15 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D5_IN15, A0 => UQNN_N166_grpi);
GLB_D5_IN0 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D5_IN0, A0 => UQNN_N9_grpi);
GLB_D5_IN8 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D5_IN8, A0 => OR_1154_grpi);
GLB_D5_IN16 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D5_IN16, A0 => UQNN_N21_ffb);
GLB_D5_IN14 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D5_IN14, A0 => UQNN_N32_grpi);
GLB_D5_IN7 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D5_IN7, A0 => UQNN_N28_grpi);
GLB_D5_IN3 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D5_IN3, A0 => UQNN_N35_grpi);
GLB_D5_IN11 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D5_IN11, A0 => UQNN_N108_grpi);
GLB_D5_IN5 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D5_IN5, A0 => UQNN_N24_grpi);
GLB_D5_IN9 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D5_IN9, A0 => UQNN_N23_grpi);
GLB_D5_IN17 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D5_IN17, A0 => UQNN_N33_ffb);
GLB_D5_IN12 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (Z0 => D5_IN12, A0 => UQNN_N31_grpi);
GLB_UQNN_N33 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N33, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D5_CLK, 
	D0 => D5_F0);
GLB_UQNN_N23 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N23, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D5_CLK, 
	D0 => D5_F1);
GLB_UQNN_N21 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N21, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D5_CLK, 
	D0 => D5_F2);
GLB_UQNN_N9 : PGDFFR_ESPFLUKE
    GENERIC MAP (HLCQ => 2.400000 ns, LHCQ => 2.400000 ns, HLRQ => 6.800000 ns, SUD0 => 1.000000 ns, 
        SUD1 => 1.000000 ns, HOLDD0 => 8.300000 ns, HOLDD1 => 8.300000 ns, POSC1 => 5.000000 ns, 
        POSC0 => 5.000000 ns, NEGC1 => 5.000000 ns, NEGC0 => 5.000000 ns, RECRC => 0.000000 ns, 
        HOLDRC => 0.000000 ns)
	PORT MAP (Q0 => UQNN_N9, RNESET => L2L_KEYWD_RESET_glbb, CD => GND, CLK => D5_CLK, 
	D0 => D5_F3);
GLB_D5_IN8B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D5_IN8B, A0 => OR_1154_grpi);
GLB_D5_IN15B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D5_IN15B, A0 => UQNN_N166_grpi);
GLB_D5_IN0B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D5_IN0B, A0 => UQNN_N9_grpi);
GLB_D5_IN11B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D5_IN11B, A0 => UQNN_N108_grpi);
GLB_D5_IN5B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D5_IN5B, A0 => UQNN_N24_grpi);
GLB_D5_IN7B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D5_IN7B, A0 => UQNN_N28_grpi);
GLB_D5_IN13B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D5_IN13B, A0 => UQNN_N22_grpi);
GLB_D5_IN4B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D5_IN4B, A0 => STOP_SIG_grpi);
GLB_D5_IN3B : PGINVI_ESPFLUKE
    GENERIC MAP (TRISE => 1.100000 ns, TFALL => 1.100000 ns)
	PORT MAP (ZN0 => D5_IN3B, A0 => UQNN_N35_grpi);
IOC_L2L_KEYWD_RESET : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 3.100000 ns, TFALL => 3.100000 ns)
	PORT MAP (Z0 => L2L_KEYWD_RESETb, XI0 => XRESET);
IOC_IO25_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO25_IBUFO, XI0 => SDA_BI);
IOC_IO25_OE : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 4.000000 ns, TFALL => 4.000000 ns)
	PORT MAP (Z0 => IO25_OE, A0 => BUF_2402_oe);
IOC_IO25_OBUFI : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.400000 ns, TFALL => 0.400000 ns)
	PORT MAP (Z0 => IO25_OBUFI, A0 => UQNN_N25_iomux);
IOC_SDA_BI : PXTRI_ESPFLUKE
    GENERIC MAP (TRISE => 12.200000 ns, TFALL => 12.200000 ns, HZ => 12.200000 ns, ZH => 12.200000 ns, 
        LZ => 12.200000 ns, ZL => 12.200000 ns)
	PORT MAP (XO0 => SDA_BI, OE => IO25_OE, A0 => IO25_OBUFI);
IOC_IO26_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO26_IBUFO, XI0 => SCL_IN);
IOC_IO17_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO17_IBUFO, XI0 => RNG2_IN);
IOC_IO33_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO33_IBUFO, XI0 => OVFL_IN);
IOC_IO30_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO30_IBUFO, XI0 => UQNNONMCK_99);
IOC_IO29_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO29_IBUFO, XI0 => UQNNONMCK_100);
IOC_IO28_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO28_IBUFO, XI0 => UQNNONMCK_101);
IOC_IO27_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO27_IBUFO, XI0 => UQNNONMCK_102);
IOC_IO34_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO34_IBUFO, XI0 => MUP_IN);
IOC_IO35_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO35_IBUFO, XI0 => ML_IN);
IOC_IO36_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO36_IBUFO, XI0 => DS_IN);
IOC_CLK_MASTERX : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.000000 ns, TFALL => 0.000000 ns)
	PORT MAP (Z0 => CLK_MASTERX, XI0 => CLK_MASTER);
IOC_IO24_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO24_IBUFO, XI0 => UQNNONMCK_103);
IOC_IO19_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO19_IBUFO, XI0 => UQNNONMCK_104);
IOC_IO20_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO20_IBUFO, XI0 => UQNNONMCK_105);
IOC_IO21_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO21_IBUFO, XI0 => UQNNONMCK_106);
IOC_IO22_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO22_IBUFO, XI0 => UQNNONMCK_107);
IOC_IO23_IBUFO : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 0.300000 ns, TFALL => 0.300000 ns)
	PORT MAP (Z0 => IO23_IBUFO, XI0 => UQNNONMCK_108);
IOC_LED : PXOUT_ESPFLUKE
    GENERIC MAP (TRISE => 12.200000 ns, TFALL => 12.200000 ns)
	PORT MAP (XO0 => LED, A0 => IO16_OBUFI);
IOC_IO16_OBUFI : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.400000 ns, TFALL => 0.400000 ns)
	PORT MAP (Z0 => IO16_OBUFI, A0 => UPDATE_SIG_iomux);
IOC_INT : PXOUT_ESPFLUKE
    GENERIC MAP (TRISE => 2.200000 ns, TFALL => 2.200000 ns)
	PORT MAP (XO0 => INT, A0 => IO49_OBUFI);
IOC_IO49_OBUFI : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 0.400000 ns, TFALL => 0.400000 ns)
	PORT MAP (Z0 => IO49_OBUFI, A0 => TRIGGER_SIG_iomux);
GRP_OVFL_SIG_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => OVFL_SIG_grpi, A0 => OVFL_SIG);
UQBNONMCK_125 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_138, A0 => UQNNONMCK_137);
UQBNONMCK_126 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_109, A0 => UQNNONMCK_137);
UQBNONMCK_127 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_139, A0 => UQNNONMCK_136);
UQBNONMCK_128 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_110, A0 => UQNNONMCK_136);
UQBNONMCK_129 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_111, A0 => UQNNONMCK_135);
UQBNONMCK_130 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.000000 ns, TFALL => 3.000000 ns)
	PORT MAP (Z0 => UQNNONMCK_181, A0 => IO27_IBUFO);
UQBNONMCK_131 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.000000 ns, TFALL => 3.000000 ns)
	PORT MAP (Z0 => UQNNONMCK_179, A0 => IO28_IBUFO);
UQBNONMCK_132 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.000000 ns, TFALL => 3.000000 ns)
	PORT MAP (Z0 => UQNNONMCK_177, A0 => IO29_IBUFO);
GRP_OVFL_INX_grp : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => OVFL_INX_grp, A0 => IO33_IBUFO);
GRP_UPDATE_SIG_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UPDATE_SIG_ffb, A0 => UPDATE_SIG);
GRP_UPDATE_SIG_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.400000 ns, TFALL => 3.400000 ns)
	PORT MAP (Z0 => UPDATE_SIG_grpi, A0 => UPDATE_SIG);
GRP_UPDATE_SIG_iomux : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.000000 ns, TFALL => 1.000000 ns)
	PORT MAP (Z0 => UPDATE_SIG_iomux, A0 => UPDATE_SIG);
GRP_BUF_2403_ck2f : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.800000 ns, TFALL => 1.800000 ns)
	PORT MAP (Z0 => BUF_2403_ck2f, A0 => BUF_2403);
GRP_UQNN_N28_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.900000 ns, TFALL => 2.900000 ns)
	PORT MAP (Z0 => UQNN_N28_grpi, A0 => UQNN_N28);
GRP_UQNN_N26_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNN_N26_grpi, A0 => UQNN_N26);
GRP_UQNN_N24_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.000000 ns, TFALL => 3.000000 ns)
	PORT MAP (Z0 => UQNN_N24_grpi, A0 => UQNN_N24);
GRP_TRANSFER_SIG_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => TRANSFER_SIG_ffb, A0 => TRANSFER_SIG);
GRP_TRANSFER_SIG_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => TRANSFER_SIG_grpi, A0 => TRANSFER_SIG);
GRP_UQNN_N21_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.800000 ns, TFALL => 2.800000 ns)
	PORT MAP (Z0 => UQNN_N21_grpi, A0 => UQNN_N21);
GRP_UQNN_N21_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N21_ffb, A0 => UQNN_N21);
GRP_UQNN_N32_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N32_ffb, A0 => UQNN_N32);
GRP_UQNN_N32_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNN_N32_grpi, A0 => UQNN_N32);
GRP_UQNN_N22_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.000000 ns, TFALL => 3.000000 ns)
	PORT MAP (Z0 => UQNN_N22_grpi, A0 => UQNN_N22);
GRP_STOP_SIG_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.000000 ns, TFALL => 3.000000 ns)
	PORT MAP (Z0 => STOP_SIG_grpi, A0 => STOP_SIG);
GRP_UQNN_N13_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNN_N13_grpi, A0 => UQNN_N13);
GRP_UQNN_N19_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNN_N19_grpi, A0 => UQNN_N19);
GRP_CLK_MASTERX_clk1 : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => CLK_MASTERX_clk1, XI0 => CLK_MASTERX);
GRP_READ_REQ_SIG_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => READ_REQ_SIG_grpi, A0 => READ_REQ_SIG);
GRP_OR_1148_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => OR_1148_grpi, A0 => OR_1148);
GRP_SDA_BI_Z0_grp : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.800000 ns, TFALL => 2.800000 ns)
	PORT MAP (Z0 => SDA_BI_Z0_grp, A0 => IO25_IBUFO);
GRP_UQNN_N23_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => UQNN_N23_grpi, A0 => UQNN_N23);
GRP_UQNN_N166_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.800000 ns, TFALL => 2.800000 ns)
	PORT MAP (Z0 => UQNN_N166_grpi, A0 => UQNN_N166);
GRP_UQNN_N29_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N29_ffb, A0 => UQNN_N29);
GRP_UQNN_N29_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNN_N29_grpi, A0 => UQNN_N29);
GRP_UQNN_N30_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => UQNN_N30_grpi, A0 => UQNN_N30);
GRP_UQNN_N35_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N35_ffb, A0 => UQNN_N35);
GRP_UQNN_N35_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => UQNN_N35_grpi, A0 => UQNN_N35);
GRP_UQNN_N14_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => UQNN_N14_grpi, A0 => UQNN_N14);
GRP_UQNN_N15_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => UQNN_N15_grpi, A0 => UQNN_N15);
GRP_UQNN_N16_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N16_ffb, A0 => UQNN_N16);
GRP_UQNN_N16_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNN_N16_grpi, A0 => UQNN_N16);
GRP_UQNN_N17_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => UQNN_N17_grpi, A0 => UQNN_N17);
GRP_UQNN_N18_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N18_ffb, A0 => UQNN_N18);
GRP_UQNN_N18_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNN_N18_grpi, A0 => UQNN_N18);
GRP_N_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => N_ffb, A0 => N);
GRP_N_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => N_grpi, A0 => N);
UQBNONMCK_133 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_145, A0 => IO22_IBUFO);
GRP_DS_INX_grp : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => DS_INX_grp, A0 => IO36_IBUFO);
UQBNONMCK_134 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_144, A0 => UQNNONMCK_143);
UQBNONMCK_135 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_112, A0 => UQNNONMCK_143);
UQBNONMCK_136 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_146, A0 => UQNNONMCK_142);
UQBNONMCK_137 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_113, A0 => UQNNONMCK_142);
UQBNONMCK_138 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_114, A0 => UQNNONMCK_141);
UQBNONMCK_139 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_115, A0 => UQNNONMCK_140);
UQBNONMCK_140 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.000000 ns, TFALL => 3.000000 ns)
	PORT MAP (Z0 => UQNNONMCK_175, A0 => IO30_IBUFO);
GRP_UQNN_N27_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => UQNN_N27_grpi, A0 => UQNN_N27);
GRP_UQNN_N27_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N27_ffb, A0 => UQNN_N27);
GRP_UQNN_N9_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.100000 ns, TFALL => 3.100000 ns)
	PORT MAP (Z0 => UQNN_N9_grpi, A0 => UQNN_N9);
GRP_UQNN_N10_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.000000 ns, TFALL => 3.000000 ns)
	PORT MAP (Z0 => UQNN_N10_grpi, A0 => UQNN_N10);
GRP_UQNN_N11_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 3.000000 ns, TFALL => 3.000000 ns)
	PORT MAP (Z0 => UQNN_N11_grpi, A0 => UQNN_N11);
GRP_UQNN_N12_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N12_ffb, A0 => UQNN_N12);
GRP_UQNN_N12_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.800000 ns, TFALL => 2.800000 ns)
	PORT MAP (Z0 => UQNN_N12_grpi, A0 => UQNN_N12);
GRP_L_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => L_ffb, A0 => L);
GRP_L_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => L_grpi, A0 => L);
UQBNONMCK_141 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_168, A0 => IO20_IBUFO);
GRP_UQNN_N42_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNN_N42_grpi, A0 => UQNN_N42);
GRP_UQNN_N39_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N39_ffb, A0 => UQNN_N39);
GRP_UQNN_N39_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNN_N39_grpi, A0 => UQNN_N39);
GRP_UQNN_N38_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N38_ffb, A0 => UQNN_N38);
GRP_UQNN_N38_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNN_N38_grpi, A0 => UQNN_N38);
UQBNONMCK_142 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_116, A0 => UQNNONMCK_173);
UQBNONMCK_143 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_178, A0 => UQNNONMCK_173);
UQBNONMCK_144 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_117, A0 => UQNNONMCK_151);
UQBNONMCK_145 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_154, A0 => UQNNONMCK_151);
UQBNONMCK_146 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_118, A0 => UQNNONMCK_166);
UQBNONMCK_147 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_167, A0 => UQNNONMCK_166);
UQBNONMCK_148 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_119, A0 => UQNNONMCK_163);
UQBNONMCK_149 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_120, A0 => UQNNONMCK_157);
UQBNONMCK_150 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_162, A0 => UQNNONMCK_157);
UQBNONMCK_151 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_121, A0 => UQNNONMCK_147);
UQBNONMCK_152 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_148, A0 => UQNNONMCK_147);
UQBNONMCK_153 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.700000 ns, TFALL => 2.700000 ns)
	PORT MAP (Z0 => UQNNONMCK_122, A0 => UQNNONMCK_182);
UQBNONMCK_154 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_123, A0 => UQNNONMCK_183);
UQBNONMCK_155 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_184, A0 => UQNNONMCK_183);
GRP_ML_SIG_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => ML_SIG_grpi, A0 => ML_SIG);
GRP_TRIGGER_SIG_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => TRIGGER_SIG_grpi, A0 => TRIGGER_SIG);
GRP_TRIGGER_SIG_iomux : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.000000 ns, TFALL => 1.000000 ns)
	PORT MAP (Z0 => TRIGGER_SIG_iomux, A0 => TRIGGER_SIG);
GRP_FREQ_SIG_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => FREQ_SIG_ffb, A0 => FREQ_SIG);
GRP_FREQ_SIG_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => FREQ_SIG_grpi, A0 => FREQ_SIG);
GRP_ML_INX_grp : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => ML_INX_grp, A0 => IO35_IBUFO);
GRP_RNG2_INX_grp : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => RNG2_INX_grp, A0 => IO17_IBUFO);
GRP_BUF_2402_oe : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.700000 ns, TFALL => 1.700000 ns)
	PORT MAP (Z0 => BUF_2402_oe, A0 => BUF_2402);
GRP_UQNN_N25_iomux : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.000000 ns, TFALL => 1.000000 ns)
	PORT MAP (Z0 => UQNN_N25_iomux, A0 => UQNN_N25);
UQBNONMCK_156 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_176, A0 => IO23_IBUFO);
UQBNONMCK_157 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_155, A0 => IO24_IBUFO);
GRP_UQNN_N36_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNN_N36_grpi, A0 => UQNN_N36);
GRP_UQNN_N37_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNN_N37_grpi, A0 => UQNN_N37);
GRP_UQNN_N37_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N37_ffb, A0 => UQNN_N37);
GRP_UQNN_N40_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNN_N40_grpi, A0 => UQNN_N40);
GRP_UQNN_N40_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N40_ffb, A0 => UQNN_N40);
GRP_UQNN_N41_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNN_N41_grpi, A0 => UQNN_N41);
GRP_UQNN_N43_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNN_N43_grpi, A0 => UQNN_N43);
GRP_UQNN_N43_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N43_ffb, A0 => UQNN_N43);
GRP_UQNN_N47_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNN_N47_grpi, A0 => UQNN_N47);
GRP_UQNN_N47_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N47_ffb, A0 => UQNN_N47);
UQBNONMCK_158 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_153, A0 => UQNNONMCK_152);
UQBNONMCK_159 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_124, A0 => UQNNONMCK_152);
UQBNONMCK_160 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_125, A0 => UQNNONMCK_150);
UQBNONMCK_161 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_126, A0 => UQNNONMCK_149);
UQBNONMCK_162 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_170, A0 => IO21_IBUFO);
GRP_OR_1154_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => OR_1154_grpi, A0 => OR_1154);
GRP_SCL_INX_grp : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => SCL_INX_grp, A0 => IO26_IBUFO);
UQBNONMCK_163 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_127, A0 => UQNNONMCK_159);
UQBNONMCK_164 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_128, A0 => UQNNONMCK_156);
UQBNONMCK_165 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_161, A0 => UQNNONMCK_158);
UQBNONMCK_166 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_129, A0 => UQNNONMCK_158);
UQBNONMCK_167 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_160, A0 => IO19_IBUFO);
UQBNONMCK_168 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_130, A0 => UQNNONMCK_164);
UQBNONMCK_169 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_169, A0 => UQNNONMCK_165);
UQBNONMCK_170 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_131, A0 => UQNNONMCK_165);
GRP_M_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => M_ffb, A0 => M);
GRP_M_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => M_grpi, A0 => M);
UQBNONMCK_171 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_132, A0 => UQNNONMCK_174);
GRP_UQNN_N108_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNN_N108_grpi, A0 => UQNN_N108);
GRP_UQNN_N31_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N31_ffb, A0 => UQNN_N31);
GRP_UQNN_N31_grpi : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNN_N31_grpi, A0 => UQNN_N31);
GRP_UQNN_N20_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N20_ffb, A0 => UQNN_N20);
UQBNONMCK_172 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNNONMCK_180, A0 => UQNNONMCK_172);
UQBNONMCK_173 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => UQNNONMCK_133, A0 => UQNNONMCK_172);
UQBNONMCK_174 : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.600000 ns, TFALL => 2.600000 ns)
	PORT MAP (Z0 => UQNNONMCK_134, A0 => UQNNONMCK_171);
GRP_MUP_INX_grp : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 2.500000 ns, TFALL => 2.500000 ns)
	PORT MAP (Z0 => MUP_INX_grp, A0 => IO34_IBUFO);
GRP_UQNN_N33_ffb : PGBUFI_ESPFLUKE
    GENERIC MAP (TRISE => 1.300000 ns, TFALL => 1.300000 ns)
	PORT MAP (Z0 => UQNN_N33_ffb, A0 => UQNN_N33);
GRP_L2L_KEYWD_RESET_glb : PXIN_ESPFLUKE
    GENERIC MAP (TRISE => 1.500000 ns, TFALL => 1.500000 ns)
	PORT MAP (Z0 => L2L_KEYWD_RESET_glbb, XI0 => L2L_KEYWD_RESETb);
END ESPFLUKE_STRUCTURE;
