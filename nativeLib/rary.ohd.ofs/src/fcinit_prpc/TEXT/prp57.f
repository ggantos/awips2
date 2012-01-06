C MEMBER PRP57
C-----------------------------------------------------------------------
C
C                             LAST UPDATE:
C
C @PROCESS LVL(77)
C
      SUBROUTINE PRP57 (P)

C     THIS IS THE PRINT PARAMETER ROUTINE FOR CONSUMPTIVE USE.

C     THIS ROUTINE ORIGINALLY WRITTEN BY
C        JOSEPH PICA  - NWRFC   MAY 1997

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C     POSITION     CONTENTS OF P ARRAY
C      1           VERSION NUMBER OF OPERATION
C      2-19        GENERAL NAME OR TITLE

C     TEMPERATURE INPUT FOR ESTIMATING ET
C     20-21       MEAN AREAL TEMPERATURE TIME SERIES IDENTIFIER
C     22          MEAN AREAL TEMPERATURE DATA TYPE CODE

C     POTENTIAL EVAPORATION INPUT FOR ESTIMATING ET
C     23-24       POTENTIAL EVAPORATION TIME SERIES IDENTIFIER
C     25          POTENTIAL EVAPORATION DATA TYPE CODE

C     NATURAL FLOW WHICH IS AVAILABLE FOR DIVERSIONS
C     26-27       NATURAL FLOW TIME SERIES IDENTIFIER
C     28          NATURAL FLOW DATA TYPE CODE

C     FLOW AFTER ACCOUNTING FOR DIVERSIONS AND RETURN FLOW OUT
C     29-30       ADJUSTED FLOW TIME SERIES IDENTIFIER
C     31          ADJUSTED FLOW DATA TYPE CODE

C     WATER DIVERTED BASED ON CROP DEMAND AND IRRIGATION EFFICIENCY
C     32-33       DIVERSION FLOW TIME SERIES IDENTIFIER
C     34          DIVERSION FLOW DATA TYPE CODE

C     RETURN FLOW STORAGE ACCUMULATION
C     RETURN FLOW IN IS A FRACTION OF THE DIVERSION FLOW
C     35-36       RETURN FLOW IN TIME SERIES IDENTIFIER
C     37          RETURN FLOW IN DATA TYPE CODE

C     RETURN FLOW STORAGE DECAY
C     RETURN FLOW OUT IS PART OF THE ADJUSTED FLOW
C     38-39       RETURN FLOW OUT TIME SERIES IDENTIFIER
C     40          RETURN FLOW OUT DATA TYPE CODE

C     OTHER LOSSES ARE TRANSPORTATION AND SUBSURFACE LOSSES
C     OTHER LOSSES ARE A FRACTION OF THE DIVERSION FLOW
C     41-42       OTHER LOSSES FLOW TIME SERIES IDENTIFIER
C     43          OTHER LOSSES FLOW DATA TYPE CODE

C     CROP DEMAND IS THE AMOUNT OF FLOW REQUIRED FOR THE CROPS
C     CROP DEMAND IS A FRACTION OF THE DIVERSION FLOW
C     44-45       CROP DEMAND FLOW TIME SERIES IDENTIFIER
C     46          CROP DEMAND FLOW DATA TYPE CODE

C     CROP EVAPOTRANSPIRATION
C     47-48       CROP EVAPOTRANSPIRATION TIME SERIES IDENTIFIER
C     49          CROP EVAPOTRANSPIRATION DATA TYPE CODE

C     50              OPTION FOR ET ESTIMATION METHOD
C     51              LATTITUDE OF IRRIGATED AREA
C     52              IRRIGATED AREA
C     53              IRRIGATION EFFICIENCY
C     54              MINIMUM FLOW
C     55              RETURN FLOW ACCUMULATION RATE
C     56              RETURN FLOW DECAY RATE
C     57              ANNUAL DAYLIGHT HOURS

C     58-422          DAILY EMPIRICAL CROP/METEOROLOGICAL
C                     COEFFICIENTS

C     THE NUMBER OF ELEMENTS REQUIRED IN THE P ARRAY IS  422

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

      DIMENSION P(*)

      INTEGER IVERSN,OPTION
      REAL PREAL(30)
      CHARACTER*4  PCHAR(30)
      EQUIVALENCE (PREAL(1),PCHAR(1))

C     COMMON BLOCKS

      COMMON/FDBUG/IODBUG,ITRACE,IDBALL,NDEBUG,IDEBUG(20)
      COMMON/IONUM/IN,IPR,IPU
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_prpc/RCS/prp57.f,v $
     . $',                                                             '
     .$Id: prp57.f,v 1.2 1998/04/07 11:56:27 page Exp $
     . $' /
C    ===================================================================
C

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C        CONSUMPTIVE USE - VERSION XXXX
C        POCATELLO DIVERSIONS

C        OPTION  X  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

C        INPUT TIME SERIES                    ID     CODE
C           MEAN AREAL TEMPERATURE         XXXXXXXX  XXXX
C           POTENTIAL EVAPORATION          XXXXXXXX  XXXX
C           MEAN DAILY NATURAL FLOW        XXXXXXXX  XXXX

C        PRIMARY OUTPUT TIME SERIES
C           MEAN DAILY ADJUSTED FLOW       XXXXXXXX  XXXX
C           MEAN DAILY DIVERSION FLOW      XXXXXXXX  XXXX

C        SECONDARY OUTPUT TIME SERIES
C           MEAN DAILY RETURN FLOW IN      XXXXXXXX  XXXX
C           MEAN DAILY RETURN FLOW OUT     XXXXXXXX  XXXX
C           MEAN DAILY OTHER LOSSES        XXXXXXXX  XXXX
C           MEAN DAILY CROP DEMAND         XXXXXXXX  XXXX
C           CROP EVAPOTRANSPIRATION        XXXXXXXX  XXXX

C        GENERAL IRRIGATION BASIN PARAMETERS

C        LATTITUDE (+NORTH/-SOUTH, DEGREES)      XXX.XX
C        IRRIGATED AREA (KM^2)                XXXXXX.
C        IRRIGATION EFFICIENCY (0-1)               X.XX
C        MINIMUM STREAMFLOW (CMSD)               XXX.XX

C        MID-MONTH EMPIRICAL COEFFICIENTS

C         JAN     FEB     MAR     APR     MAY     JUN
C        ----    ----    ----    ----    ----    ----
C        XXXX    XXXX    XXXX    XXXX    XXXX    XXXX

C         JUL     AUG     SEP     OCT     NOV     DEC
C        ----    ----    ----    ----    ----    ----
C        XXXX    XXXX    XXXX    XXXX    XXXX    XXXX

C        RETURN FLOW PARAMETERS

C        RETURN FLOW ACCUMULATION RATE             X.XX
C        RETURN FLOW DECAY RATE (1/DAY)            X.XXXX

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C     CHECK TRACE LEVEL
      CALL FPRBUG ('PRP57   ',1,57,IBUG)

C     PRINT HEADING THEN TITLE INFORMATION FROM P ARRAY

      IVERSN = INT(P(1))
      DO 21 II=2,19
  21  PREAL(II) = P(II)
      WRITE(IPR,501) IVERSN,(PCHAR(II),II=2,19)
 501  FORMAT(//,10X,'CONSUMPTIVE USE - VERSION ',I4,/,
     +          10X,18A4,/)


C     PRINT OPTION INFORMATION FROM P ARRAY - ET ESTIMATION METHOD

      OPTION = INT(P(50))
      IF (OPTION.EQ.0) THEN
         WRITE(IPR,502) OPTION
 502     FORMAT(/,10X,'OPTION',2X,I1,5X,
     +            'ET ESTIMATION WITH TEMPERATURE',/)
      ELSE
         WRITE(IPR,503) OPTION
 503     FORMAT(/,10X,'OPTION',2X,I1,5X,
     +            'ET ESTIMATION WITH POTENTIAL ET',/)
      ENDIF


C     PRINT TIME SERIES INFORMATION FROM P ARRAY

      II=0
      DO 22 JJ=20,49
      II=II+1
  22  PREAL(II) = P(JJ)
      WRITE(IPR,504) (PCHAR(II),II=1,30)
 504  FORMAT(/,10X,'INPUT TIME SERIES',18X,'ID',7X,'CODE',/,
     +     13X,'MEAN AREAL TEMPERATURE',9X,2A4,2X,A4,/,
     +     13X,'POTENTIAL EVAPORATION',10X,2A4,2X,A4,/,
     +     13X,'MEAN DAILY NATURAL FLOW',8X,2A4,2X,A4,//,
     +     10X,'PRIMARY OUTPUT TIME SERIES',/,
     +     13X,'MEAN DAILY ADJUSTED FLOW',7X,2A4,2X,A4,/,
     +     13X,'MEAN DAILY DIVERSION FLOW',6X,2A4,2X,A4,//,
     +     10X,'SECONDARY OUTPUT TIME SERIES',/,
     +     13X,'MEAN DAILY RETURN FLOW IN',6X,2A4,2X,A4,/,
     +     13X,'MEAN DAILY RETURN FLOW OUT',5X,2A4,2X,A4,/,
     +     13X,'MEAN DAILY OTHER LOSSES',8X,2A4,2X,A4,/,
     +     13X,'MEAN DAILY CROP DEMAND',9X,2A4,2X,A4,/,
     +     13X,'CROP EVAPOTRANSPIRATION',8X,2A4,2X,A4,/)


C     WRITE GENERAL IRRIGATION BASIN PARAMETERS FROM P ARRAY

      WRITE(IPR,505) (P(II),II=51,54)
 505  FORMAT(/,10X,'GENERAL IRRIGATION BASIN PARAMETERS',//,
     +     10X,'LATTITUDE (+NORTH/-SOUTH, DEGREES)',5X,F6.2,/,
     +     10X,'IRRIGATED AREA (KM^2)',16X,F6.0,/,
     +     10X,'IRRIGATION EFFICIENCY (0-1)',14X,F4.2,/,
     +     10X,'MINIMUM STREAMFLOW (CMSD)',14X,F6.2,/)


C     WRITE MID-MONTH EMPIRICAL COEFFICIENTS FROM P ARRAY

      WRITE(IPR,506) P(73),P(103),P(132),P(163),P(193),P(224),P(254),
     +               P(285),P(316),P(346),P(377),P(407)
 506  FORMAT(/,10X,'MID-MONTH EMPIRICAL COEFFICIENTS',//,
     +     11X,'JAN',5X,'FEB',5X,'MAR',5X,'APR',5X,'MAY',5X,'JUN',/,
     +     10X,'----',4X,'----',4X,'----',4X,'----',4X,'----',4X,'----',
     +       /,10X,F4.2,4X,F4.2,4X,F4.2,4X,F4.2,4X,F4.2,4X,F4.2,//,
     +     11X,'JUL',5X,'AUG',5X,'SEP',5X,'OCT',5X,'NOV',5X,'DEC',/,
     +     10X,'----',4X,'----',4X,'----',4X,'----',4X,'----',4X,'----',
     +       /,10X,F4.2,4X,F4.2,4X,F4.2,4X,F4.2,4X,F4.2,4X,F4.2,/)


C     WRITE RETURN FLOW PARAMETERS FROM P ARRAY

      WRITE(IPR,507) P(55),P(56)
 507  FORMAT(/,10X,'RETURN FLOW PARAMETERS',//,
     +     10X,'RETURN FLOW ACCUMULATION RATE',11X,F4.2,/,
     +     10X,'RETURN FLOW DECAY RATE (1/DAY)',11X,F5.4)


      IF (ITRACE.GE.1) WRITE(IODBUG,199)
 199  FORMAT('PRP57:  EXITED:')

      RETURN
      END
