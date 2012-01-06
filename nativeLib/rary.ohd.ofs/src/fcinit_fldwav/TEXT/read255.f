      SUBROUTINE READ255(PO,IPO,IUSEP,LEFTP,NBT,NQL,NJUN,NPT,KU,KD,
     + NRCM1,NGAGE,MIXF,NQCM,NJFMT,NIFMT,NJTOT,NITOT,NGZ,NGZN,KFTR,
     + KLPI,MUD1,MRV,IORDR,KLOS,NSTR,MRU,NJUM,UW1,VIS1,SHR1,POWR,
     + IWF1,KALMAN,MPRV,MPLOC,DTMAP,SYSPTH,TWNPTH,NODESC,IERR,K1,K30)

C
C MR 1954 - 09/2004 FLDWAV Multi-Scenario Enhancement
C

      CHARACTER*80 DESC
C jgg changed to fix bug r26-16 3/05
C jgg      CHARACTER*4 SYSPTH(6,K30),TWNPTH(6,K30)
      CHARACTER*24 SYSPTH(K30),TWNPTH(K30)
C jgg      
      CHARACTER*8  SNAME

      COMMON/IDOS55/IDOS,IFCST
      COMMON/LEV55/NLEV,DHLV,NPOND,DTHLV,IDTHLV
      COMMON/M155/NU,JN,JJ,KIT,G,DT,TT,TIMF,F1
      COMMON/M655/KTIME,DTHYD,J1
      COMMON/M3055/EPSY,EPSQ,EPSQJ,THETA,XFACT
      COMMON/M3255/IOBS,KTERM,KPL,JNK,TEH
      COMMON/SS55/ NCS,A,B,DB,R,DR,AT,BT,P,DP,ZH
      COMMON/NPC55/NP,NPST,NPEND
      COMMON/NYQDC55/NYQD
      COMMON/MIXX55/MIXFLO,DFR,FRC
      COMMON/MXVAL55/MXNB,MXNGAG,MXNCM1,MXNCML,MXNQL,MXINBD,MXRCH,
     .               MXMGAT,MXNXLV,MXROUT,MXNBT,MXNSTR,MXSLC
      COMMON/NETWK55/NET

      INCLUDE 'common/fdbug'
      INCLUDE 'common/ionum'

      INCLUDE 'common/ofs55'
      INCLUDE 'common/opfil55'
      INCLUDE 'common/fldmap55'

      DIMENSION PO(*),IPO(*),NBT(K1),NQL(K1),NJUN(K1),NPT(2,K1),KU(K1)
      DIMENSION KD(K1),NRCM1(K1),NGAGE(K1),MIXF(K1),NQCM(K1),KFTR(K1)
      DIMENSION KLPI(K1),NJFMT(1),NIFMT(1),NJTOT(1),NITOT(1),MRV(K1)
      DIMENSION IORDR(K1),MUD1(K1),KLOS(K1),XLOS(2,K1),QLOS(K1),ALOS(K1)
      DIMENSION IFUT(10),NSTR(K1),UW1(K1),VIS1(K1),SHR1(K1),POWR1(K1)
      DIMENSION IWF1(K1),MRU(K1),NJUM(K1),MPRV(K30),MPLOC(2,K30)
      DIMENSION DTMAP(K30)

C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_fldwav/RCS/read255.f,v $
     . $',                                                             '
     .$Id: read255.f,v 1.8 2005/03/21 16:45:21 jgofus Exp $
     . $' /
C    ===================================================================
C
      DATA SNAME / 'READ255' /

      CALL FPRBUG(SNAME, 1, 55, IBUG)

      IERR=0

      KALMAN=0

      LOCOFW=IUSEP+1
      LOVWND=LOCOFW+JN
      LOWAGL=LOVWND+JN
      LOEPQJ=LOWAGL+JN
      IUSEP=LOEPQJ+JN-1

      CALL CHECKP(IUSEP,LEFTP,NERR)
      IF(NERR.EQ.1) THEN
        IUSEP=0
        GO TO 5000
      ENDIF

      PO(92)=LOCOFW+0.01
      PO(93)=LOVWND+0.01
      PO(94)=LOWAGL+0.01
      PO(95)=LOEPQJ+0.01

      IF(NLEV.EQ.0) GO TO 22
      IF(NODESC.EQ.0)THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,5)
    5 FORMAT (//
     .5X,'L      = LEVEE NUMBER'/
     .5X,'NJFM   = RIVER NO. FROM WHICH LEVEE FLOW IS PASSED'/
     .5X,'NIFM   = REACH NO. ON RIVER NJFM PASSING FLOW TO NITO'/
     .5X,'NJTO   = RIVER NO. TO WHICH LEVEE FLOW IS PASSED'/
     .5X,'NJTO   = REACH NO. ON RIVER NJFM RECEIVING FLOW FROM NIFM'/)
      ENDIF
      IF(IBUG.EQ.1) WRITE(IODBUG,7)
    7 FORMAT(/
     .5X,'  LEVEE NO   NJFM(L)   NIFM(L)   NJTO(L)   NITO(L)')
      DO 20 L=1,NLEV
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) NJFMT(L),NIFMT(L),NJTOT(L),NITOT(L)
      IF(IBUG.EQ.1)WRITE(IODBUG,10)L,NJFMT(L),NIFMT(L),NJTOT(L),NITOT(L)
   10 FORMAT(7X,I5,3X,4I10)
   20 CONTINUE
C.......................................................................
C   MPRV  --  RIVER NO FLOOD MAPPING REACH
C   MPLOC --  U/S & D/S SECTION NO. OF MAPPING REACH
C   DTMAP --  TIME STEP FOR ANIMATION
C   SYSPTH -  RIVER SYSTEM NAME USED IN FLDVIEW PATH
C   TWNPTH -  TOWN NAME USED IN FLDVIEW PATH (TOWN TO BE MAPPED)
C.......................................................................
   22 MPTIM=0
      IF(NMAP.EQ.0) GO TO 50
      IF(NODESC.EQ.0) THEN
        IF(IBUG.EQ.1) WRITE(IODBUG,25)
   25   FORMAT (//
     . 5X,'L      = SCENARIO NUMBER'/
     . 5X,'MPRV   = RIVER NO. OF MAPPING REACH'/
     . 5X,'MPLOC1 = SECTION NO. OF UPSTREAM END OF MAPPING REACH'/
     . 5X,'MPLOC2 = SECTION NO. OF DOWNSTREAM END OF MAPPING REACH'/
     . 5X,'DTMAP  = TIME STEP FOR ANIMATION'/
     . 5X,'SYSPTH = RIVER SYSTEM NAME USED IN FLDVIEW PATH'/
     . 5X,'TWNPTH = TOWN NAME USED IN FLDVIEW PATH (TOWN TO BE MAPPED'/)
      ENDIF
      IF(IBUG.EQ.1) WRITE(IODBUG,30)
   30 FORMAT(/
     .5X,'SCENARO NO   MPRV(L)  MPLOC(1,L)  MPLOC(2,L)    DTMAP(L)',
     .5X,'SYSPTH(L)',16X,'TWNPTH(L)')
      DO 35 L=1,NMAP
        READ(IN,'(A)',END=1000) DESC
C jgg only read DTMAP time step value for first scenario must be the same 
C   for all.    
      IF(L.EQ.1) THEN
C jgg changes to fix r26-16, by allowing free-format input  3/05      
C jgg          READ(IN,31) MPRV(L),MPLOC(1,L),MPLOC(2,L),DTMAP(L),
C jgg     .         (SYSPTH(LL,L),LL=1,6),(TWNPTH(LL,L),LL=1,6)
          READ(IN,*) MPRV(L),MPLOC(1,L),MPLOC(2,L),DTMAP(L),
     .         SYSPTH(L),TWNPTH(L)

C jgg        IF(IBUG.EQ.1) WRITE(IODBUG,32) L,MPRV(L),MPLOC(1,L),
C jgg     .         MPLOC(2,L),DTMAP(L),
C jgg     .         (SYSPTH(LL,L),LL=1,6),(TWNPTH(LL,L),LL=1,6)
        IF(IBUG.EQ.1) WRITE(IODBUG,32) L,MPRV(L),MPLOC(1,L),
     .         MPLOC(2,L),DTMAP(L),SYSPTH(L),TWNPTH(L)
      ELSE
C jgg          READ(IN,33) MPRV(L),MPLOC(1,L),MPLOC(2,L),
C jgg     .         (SYSPTH(LL,L),LL=1,6),(TWNPTH(LL,L),LL=1,6)
          READ(IN,*) MPRV(L),MPLOC(1,L),MPLOC(2,L),
     .         SYSPTH(L),TWNPTH(L)

        IF(IBUG.EQ.1) WRITE(IODBUG,34) L,MPRV(L),MPLOC(1,L),
     .         MPLOC(2,L),SYSPTH(L),TWNPTH(L)

        DTMAP(L)=DTMAP(1)
      
      ENDIF
C jgg   31 FORMAT(3I5,F5.0,1X,6A4,1X,6A4)
C jgg   32 FORMAT(10X,I5,I10,2(2X,I10),2X,F10.0,2(2X,6A4))
   32 FORMAT(10X,I5,I10,2(2X,I10),2X,F10.0,2(2X,A24))
C jgg   33 FORMAT(3I5,6X,6A4,1X,6A4)
C jgg   34 FORMAT(10X,I5,I10,2(2X,I10),12X,2(2X,6A4))
   34 FORMAT(10X,I5,I10,2(2X,I10),12X,2(2X,A24))
C end of changes for r26-16 
      
   35 CONTINUE
C.......................................................................
C         NBT   --  NO. OF CROSS SECTIONS
C         NPT1  --  SECTION ID NO. ON HYDRAULIC INFO PRINTED
C         NPT2  --  FINAL SECTION ID NO. ON RIVER J
C         EPQJ  --  DISCHARGE TOLERANCE FOR TRIBUTARY ALGORITHM
C         COFW  --  WIND COEFFICIENT FOR J-TH RIVER
C         VWIND --  WIND VELOCITY
C         WINAGL--  WIND ANGLE
C         ATF   --  AZIMUTH ANGLE OF DYNAMIC TRIBUTARY
C         MRV   --  RIVER NO. OF THE RECEIVING RIVER
C         NJUN  --  REACH NO. WHERE DYNAMIC TRIBUTARY ENTERS MAIN
C                   RIVER.
C         MRU   --  RIVER NO. OF THE FEEDING RIVER
C         NJUM  --  REACH NO. OF THE FEEDING RIVER
C.......................................................................

   50 IF(NODESC.EQ.0)THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,60)
   60 FORMAT(//
     .15X,'NBT   = NO. OF CROSS SECTIONS'/
     .15X,'NPT1  = BEGINNING SECTION ID NO. ON RIVER J'/
     .15X,'NPT2  = FINAL SECTION ID NO. ON RIVER J'/
     .15X,'EPQJ  = DISCHARGE TOLERANCE FOR EACH RIVER'/
     .15X,'COFW  = WIND COEFFICIENT FOR J-TH RIVER'/
     .15X,'VWIND = WIND VELOCITY'/
     .15X,'WINAGL= WIND ANGLE'/
     .15X,'ATF   = AZIMUTH ANGLE OF DYNAMIC TRIBUTARY'/
     .15X,'NJUN  = REACH NO. WHERE DYNAMIC TRIB ENTERS MAIN RIVER'/)
      ENDIF

      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) NBT(1),(NPT(I,1),I=1,2),PO(LOEPQJ),PO(LOCOFW),
     .PO(LOVWND),PO(LOWAGL)
      IF(JN.EQ.1) THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,110)
  110 FORMAT(/' RIVER NO.  NBT NPT1 NPT2      EPQJ      COFW     VWIND
     .  WINAGL')
      IF(IBUG.EQ.1)
     .WRITE(IODBUG,2030) 1,NBT(1),NPT(1,1),NPT(2,1),PO(LOEPQJ),
     . PO(LOCOFW),PO(LOVWND),PO(LOWAGL)
 2030 FORMAT (I5,5X,3I5,4F10.2)
      ELSE IF (NET.EQ.0) THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,111)
  111 FORMAT(/' RIVER NO.  NBT NPT1 NPT2  MRV NJUN       ATF      EPQJ    
     .    COFW     VWIND    WINAGL')
      IF(IBUG.EQ.1)
     .WRITE(IODBUG,2040) 1,NBT(1),NPT(1,1),NPT(2,1),PO(LOEPQJ),
     . PO(LOCOFW),PO(LOVWND),PO(LOWAGL)
 2040 FORMAT (I5,5X,3I5,20X,4F10.2)
      ELSE
      IF(IBUG.EQ.1) WRITE(IODBUG,113)
  113 FORMAT(/'RIVER NO.  NBT NPT1 NPT2  MRV NJUN  MRU NJUM  ATF
     .   EPQJ      COFW     VWIND    WINAGL')
      IF(IBUG.EQ.1) WRITE(IODBUG,2041) 1,NBT(1),NPT(1,1),NPT(2,1),
     . PO(LOEPQJ),PO(LOCOFW),PO(LOVWND),PO(LOWAGL)
 2041 FORMAT(I5,4X,3I5,30X,4F10.2)
      ENDIF
      MXNBT=NBT(1)
      MRV(1)=0
      IORDR(1)=1
      EPSQ=PO(LOEPQJ)

      IF (JN-1) 150,150,120

  120 LOATF=IUSEP+1
      IUSEP=LOATF+JN-1
      PO(96)=LOATF+0.01
      IF(NET.EQ.0) THEN
      DO 140 J=2,JN
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) NBT(J),NPT(1,J),NPT(2,J),MRV(J),NJUN(J),PO(LOATF+J-1),
     . PO(LOEPQJ+J-1),PO(LOCOFW+J-1),PO(LOVWND+J-1),PO(LOWAGL+J-1)
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,2050) J,NBT(J),NPT(1,J),NPT(2,J),MRV(J),NJUN(J),
     .     PO(LOATF+J-1),PO(LOEPQJ+J-1),PO(LOCOFW+J-1),PO(LOVWND+J-1),
     .     PO(LOWAGL+J-1)
 2050 FORMAT (I5,5X,5I5,5F10.2)
      IF(MXNBT.LT.NBT(J)) MXNBT=NBT(J)
  140 CONTINUE
      ELSE
      DO 141 J=2,JN
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) NBT(J),NPT(1,J),NPT(2,J),MRV(J),NJUN(J),MRU(J),NJUM(J),
     . PO(LOATF+J-1),PO(LOEPQJ+J-1),PO(LOCOFW+J-1),PO(LOVWND+J-1),
     . PO(LOWAGL+J-1)
      IF(IBUG.EQ.1) WRITE(IODBUG,2051) J,NBT(J),NPT(1,J),NPT(2,J),
     . MRV(J),NJUN(J),MRU(J),NJUM(J),PO(LOATF+J-1),PO(LOEPQJ+J-1),
     . PO(LOCOFW+J-1),PO(LOVWND+J-1),PO(LOWAGL+J-1)
 2051 FORMAT (I5,4X,7I5,5F10.2)
      IF(MXNBT.LT.NBT(J)) MXNBT=NBT(J)
  141 CONTINUE
      ENDIF
C  RE-DEFINING NET WHEN NET=1, NEW NET IS THE NO. OF NETWORK RIVERS
      IF (NET.EQ.1) THEN
        NET=0
      DO 147 J=2,JN
      IF (MRU(J).GT.0 .AND. NJUM(J).GT.0) NET=NET+1
  147 CONTINUE
      ENDIF
C.......................................................................
C        DETERMINE THE ORDER IN WHICH THE TRIBS WILL BE SOLVED
C.......................................................................
      K=1
      I1=1
  142 I2=K
      IF(I2.GE.JN-NET) GO TO 150
      DO 146 L=I1,I2
        L1=IORDR(L)
        DO 144 M=1,JN-NET
          IF(MRV(M).EQ.L1) THEN
            K=K+1
            IORDR(K)=M
          ENDIF
  144   CONTINUE
  146 CONTINUE
      I1=I2+1
      GO TO 142

C.......................................................................
C         KU    --  UPSTREAM BOUNDARY SELECTION PARAMETER
C         KD    --  DOWNSTREAM BOUNDARY SELECTION PARAMETER
C         KD = 4 OR 7 FOR D/S LOOP, 7 IS A NEW METHOD
C         KD = -1 MEANS h(t) IS D/S B.C AND EXTRA FOR n(Q)
C         NQL     --  NO. OF LATERAL INFLOWS (OR OUTFLOWS)
C         NGAGE   --  NO. OF GAGING OR PLOTING STATIONS
C         NRCM1   --  NO. OF MANNING N REACHES
C         NQCM    --  >0, DATA POINTS FOR MANNING N VS. WATER ELEVATION
C                 --  <0, DATA POINTS FOR MANNING N VS. DISCHARGE CURVE
C                 --  =0, MANNING N VS. WATER ELEVATION CORRESPONDING TO
C         MIXF    --  MIXED FLOW INDICATOR; =0; SUB; =1;
C                       SUP; =>2, MIXED       =5  LPI USED
C         MUD1    --  MUD FLOW SWITCH  0/1 = WITHOUT/WITH
C         KFTR    --  KALMAN FILTER SWITCH
C         KLOS    --  CHANNEL FLOW LOSS SWITCH
C         XLOS, QLOS, ALOS  --  LOSS RELATED DATA
C         KLPI    --  BETA IN LPI
C         UW1     --  UNIT WEIGHT OF MUD/DEBRIS FLUID (MUD1=1)
C         UW1     --  FRICTION ANGLE OF DEBRIS FLOW BED (MUD1=2)
C         VIS1    --  DYNAMIC VISCOKSITY OF MUD/DEBRIS FLUID
C         SHR1    --  INITIAL YIELD STRESS OF MUD
C         POWR1   --  EXPONENT REPRESENT STRESS-RATE OF STRAIN RELATION
C         IWF1    --  WAVE-FRONT TRACKING INDEX (0/1=ON/OFF)
C.......................................................................
150   NLPI=0
      NMUD=0
      NLOS=0
      IF(NODESC.EQ.0)THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,152)
  152 FORMAT(//
     .15X,'KU    = UPSTREAM BOUNDARY SELECTION PARAMETER'/
     .15X,'KD    = DOWNSTREAM BOUNDARY SELECTION PARAMETER'/
     .15X,'NQL   = NO. OF LATERAL INFLOWS (OR OUTFLOWS)'/
     .15X,'NGAGE = NO. OF GAGING OR PLOTING STATIONS'/
     .15X,'NRCM1 = NO. OF MANNING N REACHES'/
     .15X,'NQCM  = >0, DATA POINTS FOR MANNING N VS. WATER ELEVATION'/
     .15X,'NSTR  = NO. OF OUTPUT TIME SERIES')
      END IF
      IF(IBUG.EQ.1) WRITE(IODBUG,18)
   18 FORMAT(/'RIVER NO.     KU    KD   NQL NGAGE NRCM1  NQCM  NSTR  FUT
     .URE DATA')
      DO 160 J=1,JN
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) KU(J),KD(J),NQL(J),NGAGE(J),NRCM1(J),NQCM(J),NSTR(J),
     . (IFUT(I),I=1,3)
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,154) J,KU(J),KD(J),NQL(J),NGAGE(J),NRCM1(J),NQCM(J),
     . NSTR(J),(IFUT(I),I=1,3)
  154 FORMAT(I5,5X,7I6,3X,3I2)
  160 CONTINUE

      IF(NODESC.EQ.0)THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,162)
  162 FORMAT(//
     .15X,'MIXF  = MIXED FLOW INDICATOR; =0; SUB; =1;'/
     .15X,'MUD1  = MUD FLOW SWITCH'/
     .15X,'KFTR  = KALMAN FILTER SWITCH'/
     .15X,'KLOS  = CHANNEL FLOW LOSS SWITCH'/
     .15X,'KLPI  = BETA IN LPI')
      END IF
      IF(IBUG.EQ.1) WRITE(IODBUG,19)
   19 FORMAT(/'RIVER NO.   MIXF   MUD  KFTR  KLOS    FUTURE DATA')
      DO 170 J=1,JN
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) MIXF(J),MUD1(J),KFTR(J),KLOS(J),(IFUT(K),K=1,6)
      IF(IBUG.EQ.1) WRITE(IODBUG,155) J,MIXF(J), MUD1(J),KFTR(J),
     . KLOS(J),(IFUT(K),K=1,6)
  155 FORMAT(I5,5X,4I6,3X,6I2)

      IF(MUD1(J).EQ.1) NMUD=1
      IF(MUD1(J).EQ.2) NMUD=2
      IF(KLOS(J).EQ.1) NLOS=1
      KLPI(J)=0
      MIXFLO=MIXF(J)
      IF(MIXF(J).EQ.5) NLPI=NLPI+1
      IF(KFTR(J).EQ.1) KALMAN=1
  170 CONTINUE

      PO(97)=NLPI+0.01

      IF (NLPI.EQ.0) GOTO 180
      IF(IBUG.EQ.1) WRITE(IODBUG,172)
  172 FORMAT(/1X, 'LPI COEFFICIENTS WHEN MIXF(J)=5:')
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) (KLPI(K),K=1,NLPI)
      IF(IBUG.EQ.1) WRITE(IODBUG,'(8I5)') (KLPI(K),K=1,NLPI)

      DO 174 J=JN,1,-1
      IF(MIXF(J).EQ.5) THEN
      KLPI(J)=KLPI(NLPI)
      IF (J.NE.NLPI) KLPI(NLPI)=0
      NLPI=NLPI-1
      MIXFLO=2
      ENDIF
  174 CONTINUE

C    READ MUD/DEBRIS DATA  (NMUD=1/2  VISCOPLASTIC/GRANULAR SLIDING MODELING)
  180 IF(NMUD.EQ.0) GOTO 183
cc      LOUW=IUSEP+1
cc      LOVIS=LOUW+JN
cc      LOSHR=LOVIS+JN
cc      LOPOWR=LOSHR+JN
cc      LOIWF=LOPOWR+JN
cc      IUSEP=LOIWF+JN-1

cc      CALL CHECKP(IUSEP,LEFTP,NERR)
cc      IF(NERR.EQ.1) THEN
cc        IUSEP=0
cc        GO TO 5000
cc      ENDIF

cc      PO(79)=LOUW+0.01
cc      PO(80)=LOVIS+0.01
cc      PO(81)=LOSHR+0.01
cc      PO(82)=LOPOWR+0.01
cc      PO(83)=LOIWF+0.01

      IF(IBUG.EQ.1) WRITE(IODBUG,*)
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,*) 'MUD/DEBRIS  DATA WHEN MUD(J)=1 OR 2:'
      IF(NMUD.EQ.1 .AND. NODESC.EQ.0)THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,181)
  181 FORMAT(//
     .10X,'UW1   = UNIT WEIGHT OF MUD/DEBRIS FLUID'/
     .10X,'VIS1  = DYNAMIC VISCOKSITY OF MUD/DEBRIS FLUID'/
     .10X,'SHR1  = INITIAL YIELD STRESS OF MUD'/
     .10X,'POWR1 = EXPONENT REPRESENT STRESS-RATE OF STRAIN RELATION'/
     .10X,'IWF1  = PARAMETER DENOTING DRY-BED ROUTING'//)
      END IF
      IF (NMUD.EQ.2 .AND. NODESC.EQ.0) THEN
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,'(//10X,42HUW1   = FRICTION ANGLE OF MUD/DEBRIS FLUI
     .D)')
      END IF
      WRITE(IODBUG,*)
      WRITE(IODBUG,*) 'MUD/DEBRIS DATA FOR MUD(J)=1 OR 2'
      IF (NMUD.EQ.1 .AND. IBUG.EQ.1) WRITE(IODBUG,*)
     .'RIVER NO.   UW         VIS       SHR      POWR    IWF'
      IF (NMUD.EQ.2 .AND. IBUG.EQ.1)
     . WRITE(IODBUG,*)'RIVER NO.   FRICTION ANGLE (DEGREE)'
      DO 182 J=1,JN
      IF (MUD1(J).NE.1) GOTO 785
      READ(IN,*) UW1(J),VIS1(J),SHR1(J),POWR1(J),
     . IWF1(J)
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,782) J,UW1(J),VIS1(J),SHR1(J),
     . POWR1(J),IWF1(J)
782   FORMAT(1X,I6,4F10.2,I6)
785   IF (MUD1(J).NE.2) GOTO 182
      READ(IN,*) PO(LOUW+J)
      IF(IBUG.EQ.1) WRITE(IODBUG,'(1X,I6,F10.1)') J,PO(LOUW+J)
182   CONTINUE

C  FLOW LOSS RELATED DATA
  183 PO(98)=NLOS+0.01
      IF(NLOS.EQ.0) GO TO 187
      LOXLOS=IUSEP+1
      LOQLOS=LOXLOS+JN*2
      LOALOS=LOQLOS+JN
      IUSEP=LOALOS+JN-1

      CALL CHECKP(IUSEP,LEFTP,NERR)
      IF(NERR.EQ.1) THEN
        IUSEP=0
        GO TO 5000
      ENDIF

      PO(86)=LOXLOS+0.01
      PO(87)=LOQLOS+0.01
      PO(88)=LOALOS+0.01

      IF(NODESC.EQ.0) THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,184)
  184 FORMAT(/
     .20X,'XLOS1 = BEGINNING LOCATION FOR FLOW LOSS'/
     .20X,'XLOS2 = ENDING LOCATION FOR FLOW LOSS'/
     .20X,'QLOS  = PERCENTAGE OF FLOW LOSS'/
     .20X,'ALOS  = LOSS DISTRIBUTION COEFFICIENT'/)
      ENDIF
      IF(IBUG.EQ.1) WRITE(IODBUG,15)
   15 FORMAT(/
     .'RIVER    XLOS(1,J)  XLOS(2,J)   QLOS(J) (%)   ALOS(J)')
      DO 185 J=1,JN
        IF(KLOS(J).EQ.0) GOTO 185
        READ(IN,'(A)',END=1000) DESC
        READ(IN,*) PO(LOXLOS+J),PO(LOXLOS+J+1),PO(LOQLOS+J),PO(LOALOS+J)
        IF(IBUG.EQ.1)
     .  WRITE(IODBUG,783) J,PO(LOXLOS+J),PO(LOXLOS+J+1),PO(LOQLOS+J),
     .    PO(LOALOS+J)
  783   FORMAT(1X,I6,4F12.2)
  185 CONTINUE

CCC   READ IN NSTR(J) FOR NWSRFS: NUM OF OUTPUT T.S.
CC  187 IF (IDOS.LT.3) GOTO 188
CCC  187 NTOUT=0
CC      READ(IN,'(A)',END=1000) DESC
CC      READ(IN,*) (NSTR(KK),KK=1,JN)
CC	IF(IBUG.EQ.1) WRITE(IODBUG,2070) (NSTR(KK),KK=1,JN)
CC 2070 FORMAT(/,22H  NSTR(J)    (J=1,NJ):,10I4)

C   NTOUT=TOTAL NUM OF OUTPUT T.S. (FOR NWSRFS ONLY)
C   MXNSTR=MAX. NUM IN ANY RIVER
  187 NTOUT=0
      MXNSTR=0
      DO 2072 J=1,JN
        NTOUT=NTOUT+NSTR(J)
        IF(MXNSTR.LT.NSTR(J)) MXNSTR=NSTR(J)
 2072 CONTINUE
      PO(331)=NTOUT+0.01

C    NTQL   --  TOTAL NUM. OF LATERAL FLOW (FOR NWSRFS USE)
C    MXNQL  --  MAX. NUM IN ANY RIVER
  188 MXNQL=0
      NTQL=0
      DO 189 J=1,JN
      NTQL=NTQL+NQL(J)
      IF(MXNQL.LT.NQL(J)) MXNQL=NQL(J)
  189 CONTINUE
      MXNQL=MXNQL+JN
      PO(313)=NTQL+0.01

      NGZ=0
      DO 190 J=1,JN
      IF(KU(J).EQ.1) NGZ=NGZ+1
  190 CONTINUE

      LOOPKD=0
      IF (KD(1).EQ.7) THEN
      LOOPKD=1
      KD(1)=4
      ENDIF
      PO(320)=LOOPKD+0.01

      NGZN=0
      NTGAG=0
      IF(KD(1).EQ.0) NGZN=NGZN+1
      DO 200 J=1,JN
      NTGAG=NTGAG+NGAGE(J)
      IF(KD(J).EQ.1.OR.KD(J).EQ.3) NGZN=NGZN+1
      IF(MXNGAG.LT.NGAGE(J)) MXNGAG=NGAGE(J)
      NQCMJ=IABS(NQCM(J))
      IF(NQCM(J).EQ.0) NQCMJ=NCS
      IF(MXNCML.LT.NQCMJ) MXNCML=NQCMJ
  200 CONTINUE
      PO(323)=NTGAG+0.01

      IF(IDOS.GE.3.AND.KD(1).LE.2) THEN
        LOSTNN=IUSEP+1
        IUSEP=LOSTNN+3*JN-1

        CALL CHECKP(IUSEP,LEFTP,NERR)
        IF(NERR.EQ.1) THEN
          IUSEP=0
          GO TO 5000
        ENDIF
      ENDIF
      PO(362)=LOSTNN+0.01

      GO TO 9000
 1000 WRITE(IPR,1010)
 1010 FORMAT(/5X,'**ERROR** END OF FILE ENCOUNTERED WHILE READING INPUT
     *RIVER INFO.'/)
      CALL ERROR
 5000 IERR=1
 9000 CONTINUE
cc      print ('6a4'),(syspth(l),l=1,6), "in read255: "
cc      print ('6a4'),(po(lospth+l-1),l=1,6), "in read255: po "
      RETURN
      END
