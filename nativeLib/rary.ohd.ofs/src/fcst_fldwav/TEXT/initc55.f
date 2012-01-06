      SUBROUTINE INITC55(PO,CO,Z,QL,LTQL,ST1,LTST1,STT,LTSTT,T1,LTT1,
     . POLH,LTPOLH,ITWT,LTITWT,JNK,MIXF,NJUN,NB,NQCM,IFR,YDI,YDUMY,QDI,
     . QDUMY,X,DDX,HS,AS,BS,YN,YCR,KRCH,KU,KD,SLFI,NUMLAD,SQW,SQS1,SQS2,
     . SQO,QGH,MUD1,UW1,VIS1,SHR1,POWR1,IWF1,MRV,IORDR,MRU,NJUM,
     . K1,K2,K4,K6,K7,K8,K9,K10,K15,K16,K19,K20,K21)
      COMMON/VS55/MUD,IWF,SHR,VIS,UW,PB,SIMUD
      COMMON/METR55/METRIC
      COMMON/M155/NU,JN,JJ,KIT,G,DT,TT,TIMF,F1
      COMMON/M3055/EPSY,EPSQ,EPSQJ,THETA,XFACT
      COMMON/SS55/NCS,A,B,DB,R,DR,AT,BT,P,DP,ZH
      COMMON/MIXX55/MIXFLO,DFR,FRC
      COMMON/PRES55/KPRES
      COMMON/IONUM/IN,IPR,IPU
        COMMON/NETWK55/NET
      COMMON/FNOPR/NOPROT

      INCLUDE 'common/fdbug'
      INCLUDE 'common/ofs55'

      DIMENSION PO(*),CO(*),Z(*),QL(*),LTQL(*),ST1(*),LTST1(*),STT(*)
      DIMENSION LTSTT(*),T1(*),LTT1(*),POLH(*),LTPOLH(*),ITWT(*)
      DIMENSION LTITWT(*),MIXF(K1),NJUN(K1),NB(K1),NQCM(K1)
      DIMENSION IFR(K2,K1),YDI(K2,K1),YDUMY(K2,K1),QDI(K2,K1)
      DIMENSION QDUMY(K2,K1),X(K2,K1),DDX(K2,K1),HS(K9,K2,K1)
      DIMENSION AS(K9,K2,K1),YN(K2,K1),YCR(K2,K1),NUMLAD(K1)
      DIMENSION KRCH(K2,K1),KU(K1),KD(K1),SLFI(K2,K1),BS(K9,K2,K1)
      DIMENSION SQW(2,K16,K1),SQS1(2,K16,K1),SQS2(2,K16,K1)
      DIMENSION SQO(2,K16,K1),MRV(K1),IORDR(K1),MRU(K1),NJUM(K1)
      DIMENSION QGH(20,K16,K1)
      DIMENSION MUD1(K1),UW1(K1),VIS1(K1),SHR1(K1),POWR1(K1),IWF1(K1)
      CHARACTER*8 SNAME

C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_fldwav/RCS/initc55.f,v $
     . $',                                                             '
     .$Id: initc55.f,v 1.4 2004/02/02 21:51:56 jgofus Exp $
     . $' /
C    ===================================================================
C
C
      DATA SNAME/ 'INITC55 ' /

C  QDUMY SHARE SAME LOCATION AS QD TEMPORARILY
C  YDUMY SHARE SAME LOCATION AS YD TEMPORARILY

C
      CALL FPRBUG(SNAME,1,55,IBUG)

      DQDT=0.0
      IYI=0
      ITN=0
      DO 500 J=1,JN
      N=NB(J)
      DO 214 I=1,N
      KRA=IABS(KRCH(I,J))
      IF(KRA.EQ.25) THEN
        CALL IDDB55(I,J,NUMLAD,PO(LOLAD),KL,K1,K16)
        YDI(I,J)=QGH(1,KL,J)
      END IF
      YDUMY(I,J)=YDI(I,J)
  214 CONTINUE
      NUM=NUMLAD(J)
      IF(NUM.EQ.0) GO TO 500
      DO 494 LL=1,NUM
      DO 492 I1=1,2
      SQW(I1,LL,J)=1.0
      SQO(I1,LL,J)=1.0
      SQS1(I1,LL,J)=1.0
      SQS2(I1,LL,J)=1.0
  492 CONTINUE
  494 CONTINUE
  500 CONTINUE
C--------  START INITIAL CONDITION COMPUTATION ---------------
      DO 300 M=1,JN
      J=IORDR(M)
      J1=MRV(J)
      JJ=J
      MUD=MUD1(J)
      UW=UW1(J)
      VIS=VIS1(J)
      SHR=SHR1(J)
      POWR=POWR1(J)
      IWF=IWF1(J)
      IF (POWR.GE.0.01) PB=1.0/POWR
      N=NB(J)
      NM=N-1
      NCML=ABS(NQCM(J))
      IF(NCML.EQ.0) NCML=NCS
      ITRBW=0
    4 ITQ=0
C
C  ITQ=0, FLOW IS CORRECT, NO CORRECTION NECESSARY
C  ITQ=1, ESTIMATED FLOW OR SUBMERGED FLOW, ITERATE TO OBTAIN CORRECT FL
C  COMPUTE INITIAL FLOWS ASSUMING FREE FLOW,
C  THEN CORRECT SUBMERGENCE AT DAM FOR ITRBW TIMES IF NECESSARY
      ITRBW=ITRBW+1
      DO 215 I=1,N
      QDUMY(I,J)=QDI(I,J)
  215 CONTINUE
      CALL QMAIN55(PO,CO,Z,ST1,LTST1,T1,LTT1,POLH,LTPOLH,ITWT,
     . LTITWT,ITRBW,ITQ,NB,QDI,Z(LZQOTR),QGH,Z(LZYU),YDUMY,NJUN,
     1 PO(LONQL),PO(LOLQ1),PO(LCLQN),QL,LTQL,CO(LXQLI),KU,KRCH,HS,
     2 DDX,PO(LOYQI),SLFI,NQCM,NCS,IORDR,MRV,MRU,NJUM,
     3 K1,K2,K7,K8,K9,K10,K15,K16,K19,K20,K21)
      IF(JNK.GT.4.AND.NOPROT.EQ.0) THEN
      WRITE(IPR,1314) J
 1314 FORMAT(/' ** COMPUTE INITIAL FLOW, NORMAL AND INITIAL DEPTH FOR ',
     &'RIVER NO ',I2,'  **')
        IF(J.EQ.1) WRITE(IPR,1315)
 1315   FORMAT(//2X,'INITIAL DISCHARGES:')
        WRITE(IPR,1316) J
 1316   FORMAT(/10X,'(QDI FOR RIVER NO.',I3,')')
        CALL WYQMET55(METRIC,1,N,QDI(1,J),0,N)
      ENDIF
      DYC=0.02
      IF (JNK.GT.4.AND.NOPROT.EQ.0) WRITE(IPR,10002)
10002 FORMAT(/1X,'** COMPUTE NORMAL/CRITICAL DEPTH **')
      DO 10 I=1,N
      IF(AS(1,I,J).GE.0.1) THEN
        ASM=AS(1,I,J)
        IF(METRIC.EQ.1) ASM=ASM/10.765
        IF(JNK.GT.4.AND.NOPROT.EQ.0) WRITE(IPR,1317) I,J,ASM
 1317   FORMAT(5X,'AS(1,',I3,I2,')=',F10.0,
     1  ' > 0.0; SUB-CRITICAL FLOW ASSUMED!')
        YCR(I,J)=HS(1,I,J)
        YN(I,J)=YDUMY(I,J)
        IF(ABS(YDUMY(I,J)).LE.0.01) YN(I,J)=YCR(I,J)+DYC+0.01
        IFR(I,J)=0
        GO TO 10
      END IF
      QO=QDI(I,J)
      CALL INITY55(IYI,I,J,YDUMY,PO(LONGAG),PO(LONGS),STT,LTSTT,
     . K1,K2,K4)
      YNN=YDUMY(I,J)
      IF(IYI.EQ.1) GO TO 7
      YDUM=0.0
      IF(BS(1,I,J).GT.0.0) YDUM=AS(1,I,J)/BS(1,I,J)
      YMN=HS(1,I,J)-YDUM
      DO 105 LL=1,NCS
      LST=NCS-LL+1
      IF(ABS(HS(LST,I,J)).GT.0.0001) GO TO 106
  105 CONTINUE
  106 YMX=HS(LST,I,J)
CC      IF(MIXF(J).EQ.1) GO TO 5
      IF(MIXF(J).EQ.1.AND.KRCH(1,J).EQ.0) GO TO 5
      IDUM=I
      IF(IDUM.GE.NM) IDUM=NM
      IDUM1=IDUM+1
      IRCH=IDUM
      DYNX=0.5*(HS(1,IDUM,J)-HS(1,IDUM1,J))
      IF(I.GE.N) DYNX=-DYNX
      SO=SLFI(IRCH,J)
      GO TO 6
    5 IDUM=I
      IF(IDUM.LE.2) IDUM=2
      IDUMM=IDUM-1
      IRCH=IDUMM
      DYNX=-0.5*(HS(1,IDUMM,J)-HS(1,IDUM,J))
      SO=SLFI(IRCH,J)
    6 YNN=-999.0
      CALL HNORM55(PO,JNK,NCML,NQCM,J,I,IRCH,YNN,QO,SO,YMN,YMX,DYNX,
     1 ITN,K1,K2,K7,K8,K9)
    7 DEPN=YNN-HS(1,I,J)
      YN(I,J)=YNN
      YDUM=0.0
      IF(BS(1,I,J).GT.0.0) YDUM=AS(1,I,J)/BS(1,I,J)
      YMN=HS(1,I,J)-YDUM
      DO 2 LL=1,NCS
      LST=NCS-LL+1
      IF(HS(LST,I,J).GT.0.0001) GO TO 3
    2 CONTINUE
    3 YMX=HS(LST,I,J)
      YC=-999.0
      CALL HCRIT55(PO,JNK,J,I,YC,QO,YMN,YMX,ITC,K1,K2,K9)
      DEPC=YC-HS(1,I,J)
      YCR(I,J)=YC
      IF(YN(I,J).GT.YC+DYC) IFR(I,J)=0
      IF(YN(I,J).LE.YC+DYC) IFR(I,J)=1
      PYN=YNN
      PYC=YC
      XI=X(I,J)
      IF(METRIC.EQ.0) GO TO 207
      XI=XI*1.6093
      PYN=YNN/3.281
      PYC=YC/3.281
      DEPN=DEPN/3.281
      DEPC=DEPC/3.281
  207 IF(MIXF(J).EQ.0) IFR(I,J)=0
      IF(MIXF(J).EQ.1) IFR(I,J)=1
      IF(JNK.GT.4.AND.NOPROT.EQ.0) WRITE(IPR,9) I,XI,PYN,DEPN,PYC,DEPC,
     .   IFR(I,J),ITN,ITC
    9 FORMAT(3X,2HI=,I5,3X,2HX=,F8.3,3X,3HYN=,F10.2,3X,5HDEPN=,F10.2,3X,
     * 3HYC=,F10.2,3X,5HDEPC=,F10.2,3X,4HIFR=,I2,2X,4HITN=,I5,2X,
     *  4HITC=,I5)
      IF(SLFI(I,J).LE.0.000001) IFR(I,J)=0
   10 CONTINUE
      IF(JNK.GT.4.AND.NOPROT.EQ.0) THEN
        WRITE(IPR,111)
        WRITE(IPR,11) (IFR(I,J),I=1,N)
      ENDIF
   11 FORMAT(10I5)
  111 FORMAT(//10X,'(IFR(I,J),I=1,N)')
C  CHECK TO SEE IF DAMS AT MAIN RIVER CAN DROWN-OUT
C  UPSTREAM SUPERCRITICAL ELEV. AT TRIBUTARY RIVER J
      IF(J.LE.1) GO TO 1110
      IF(KU(J).EQ.0) GO TO 1110
      I1=NJUN(J)
      YT=0.5*(YDI(I1,J1)+YDI(I1+1,J1))
      DO 1100 I=1,N
      II=N-1+1
      IF(YT.LE.YN(II,J)) GO TO 1110
      IFR(II,J)=0
 1100 CONTINUE
C  CHECK TO SEE IF DAM CAN DROWN-OUT UPSTREAM SUPERCRITICAL ELEV.
 1110 IPIFR=0
      DO 13 I=1,N
      QQ=QDI(I,J)
      YRS=YN(I+1,J)
      YLS=YDUMY(I,J)
      IF(YLS .LT. -100.0) YLS=0.0
      KRA=IABS(KRCH(I,J))
      IF(KRA.LT.10 .OR. KRA.GT.30) GO TO 13
      IF(I.EQ.1) THEN
        IFR(I,J)=0
        GO TO 13
      ENDIF
      YDUMA=ABS(YDUMY(I,J))
      IF(YDUMA.LE.0.004) CALL INTBI55(PO,CO,Z,ST1,LTST1,T1,LTT1,POLH,
     . LTPOLH,ITWT,LTITWT,NCML,ITQ,2,I,J,QQ,YLS,YRS,KRCH,
     * Z(LZYU),HS,YCR,K1,K2,K7,K8,K9,K15,K16,K19,K20,K21)
      YT=YLS
      INTB=I
      DO 12 L=1,INTB
      IL=INTB-L+1
      IF(YT.LT.YN(IL,J)) GO TO 13
      IFR(IL,J)=0
      IPIFR=1
   12 CONTINUE
   13 CONTINUE
   14 DO 1114 I=2,NM
      IM1=I-1
      IP1=I+1
      IF(IFR(IM1,J).EQ.0.AND.IFR(I,J).EQ.1.AND.IFR(IP1,J).EQ.0)
     * GO TO 1112
      IF(IFR(IM1,J).EQ.1.AND.IFR(I,J).EQ.0.AND.IFR(IP1,J).EQ.1)
     * GO TO 1113
      GO TO 1114
 1112 IFR(I,J)=0
      IPIFR=1
      GO TO 1114
 1113 IFR(I,J)=1
      IPIFR=1
 1114 CONTINUE
      IF(IFR(NM,J).NE.IFR(N,J)) IFR(N,J)=IFR(NM,J)
C  IPIFR=1, MIXED FLOW REACH CHANGED DUE TO DROWN OUT
      IF(JNK.GT.4.AND.IPIFR.EQ.1.AND.NOPROT.EQ.0)
     .    WRITE(IPR,11) (IFR(I,J),I=1,N)
      INN=N
      IS=N
  100 IF(IFR(INN,J).EQ.1) GO TO 160
  110 IS=IS-1
      IF(IS.EQ.1) GO TO 112
      IF(IFR(IS,J).EQ.0) GO TO 110
C      COMPUTE BACKWATER
      IS=IS+1
  112 IF(INN.EQ.N) GO TO 113
      YNN=YCR(INN,J)
      INM=INN-1
      KRA=ABS(KRCH(INM,J))
      IF(KRA.LT.10 .OR. KRA.GT.30) GO TO 117
      YNN=YN(INN,J)
      GO TO 117
  113 IF(KD(J).NE.0) GO TO 115
      II=NJUN(J)
      YNN=0.5*(YDI(II,J1)+YDI(II+1,J1))
      GO TO 117
C      SELECT STARTING ELEVATION AT END OF REACH
  115 QN=QDI(N,J)
      YNN=YN(N,J)
      QNM=QDI(NM,J)
      CALL INITY55(IYI,N,J,YDUMY,PO(LONGAG),PO(LONGS),STT,LTSTT,
     . K1,K2,K4)
      IF(IYI.EQ.1) GO TO 130
      KDD=KD(J)
      IF(KDD.NE.4) GO TO 116
      IL=NM
      IR=N
      QIL=QDI(IL,J)
      QIR=QDI(IR,J)
      YIR=YN(IR,J)
      DX=DDX(IL,J)
      YMN=YCR(IL,J)
      YIL=YMN
      YILL=HS(1,IL,J)+0.1
      DO 2222 LL=1,NCS
      LST=NCS-LL+1
      IF(HS(LST,IL,J).GT.0.0001) GO TO 2224
 2222 CONTINUE
 2224 YMX=HS(LST,IL,J)+0.5*(HS(LST,IL,J)-HS(1,IL,J))
      Y1=-999.0
      CALL BWATR55(PO,JNK,NCML,NQCM,J,IR,IL,QIR,QIL,YIR,YIL,DX,Y1,
     1 YMX,DQDT,ITB,K1,K2,K7,K8,K9)
  116 S0A=SLFI(N,J)
      IFRN=IFR(N,J)
      IF (MUD.EQ.0)
     * CALL YEND55(PO,JNK,J,NCML,NQCM,NB,HS,KD,STN,LTSTN,PO(LOYQD),
     * PO(LOQYQD),QNM,QN,YNN,IFRN,YCR,DX,QIL,QIR,YIL,YIR,S0A,K1,K2,
     * K6,K7,K8,K9)
      IF(KDD.NE.4) GO TO 117
      DHL=YIL-HS(1,IL,J)
      DHR=YIR-HS(1,IR,J)
      DHA=ABS(DHL-DHR)
      IF(DHA.LE.2.*EPSY) GO TO 117
      INN=NM
      YDI(N,J)=YIR
      YNN=YIL
  117 DEP=YNN-HS(1,INN,J)
      IF(YDI(INN,J).LE.0.00001) YDI(INN,J)=YNN
  130 PYN=YDI(INN,J)
      PDEP=PYN-HS(1,INN,J)
      IF(METRIC.EQ.1) THEN
        PYN=PYN/3.281
        PDEP=PDEP/3.281
      ENDIF
      IF(JNK.GT.4.AND.NOPROT.EQ.0) WRITE(IPR,133) INN,PYN,PDEP
  133 FORMAT(//5X,'BACKWATER',5X,4HINN=,I3,5X,4HYNN=,F10.2,5X,4HDEP=,
     * F10.2)
      IE=INN
      IT=INN-IS
      DO 120 I=1,IT
      IR=INN-I+1
      IL=IR-1
      IF(IL.EQ.0) GO TO 120
      QIL=QDI(IL,J)
      QIR=QDI(IR,J)
      YIR=YDI(IR,J)
      CALL INITY55(IYI,IR,J,YDUMY,PO(LONGAG),PO(LONGS),STT,LTSTT,
     . K1,K2,K4)
      IF(IYI.EQ.0) GO TO 285
      YIR=YDUMY(IR,J)
      IB=IR
      IEB=IE-IB
      IF(IEB.LE.1) GO TO 287
      ERY=(YDUMY(IB,J)-YDI(IB,J))/(IE-IB)
      IF(ABS(ERY).LE.0.01) GO TO 287
      IB1=IB+1
      IEM=IE-1
      DO 286 II=IB1,IEM
      YDI(II,J)=YDI(II,J)+ERY*(IE-II)
  286 CONTINUE
  287 YDI(IB,J)=YDUMY(IB,J)
      IE=IB
  285 DX=DDX(IL,J)
      YMN=YCR(IL,J)
      YIL=YMN
      DO 2226 LL=1,NCS
      LST=NCS-LL+1
      IF(HS(LST,IL,J).GT.0.0001) GO TO 2228
 2226 CONTINUE
 2228 YMX=HS(LST,IL,J)+0.5*(HS(LST,IL,J)-HS(1,IL,J))
      DYX=0.
      IF(I.GE.2) GO TO 512
      KRAA=0
      IF(KRCH(1,J).GE.10.AND.KRCH(1,J).LE.30) KRAA=1
      IF(KRAA.EQ.1) GO TO 512
      Y1=YN(IL,J)+2.
      GO TO 516
C  IF IL OR IR IS A DAM, CANNOT EXTRAPOLATE
C  USE RESERVOIR ELEV AS INITIAL GUESS
  512 KRA=IABS(KRCH(IL,J))
      IF(KRA.LT.10 .OR. KRA.GT.30) GO TO 513
        Y1=YDUMY(IL,J)
        GO TO 516
  513 KRA=IABS(KRCH(IR,J))
      IF(KRA.LT.10 .OR. KRA.GT.30) GO TO 514
        Y1=YDUMY(IR,J)
        GO TO 516
  514 IF(DDX(IL,J) .GE. 0.0001)
     1 DYX=(YDI(IL,J)-YDI(IL+1,J))/DDX(IL,J)
      Y1=YDI(IR,J)+DYX*DDX(IL,J)+2.
      IF(Y1.LE.YCR(IL,J)) Y1=YCR(IL,J)+2.
C  CHECK FOR DAM OR BRIDGE
  516 YLS=Y1
      YRS=YIR
      KRA=IABS(KRCH(IL,J))
      IF(KRA.LT.10) GO TO 518
      YDUMA=ABS(YDUMY(IL,J))
      IF(YDUMA.LT.0.004) CALL INTBI55(PO,CO,Z,ST1,LTST1,T1,LTT1,POLH,
     . LTPOLH,ITWT,LTITWT,NCML,ITQ,2,IL,J,QIR,YLS,YRS,
     * KRCH,Z(LZYU),HS,YCR,K1,K2,K7,K8,K9,K15,K16,K19,K20,K21)

C  DAM OR BRIDGE
      YIL=YLS
      IF(YDI(IL,J).LE.0.00001) YDI(IL,J)=YIL
      GO TO 526
  518 IF(KRCH(IR,J).GE.10.AND.KRCH(IR,J).LE.30) THEN
C  LEVEL POOL ROUTING DAM
        IF(IL.GT.1.AND.KRCH(IL,J).NE.4) GO TO 525
        YIL=YDI(IR,J)
        IF (YIL.LT.YN(IL,J)) YIL=YN(IL,J)
        YDI(IL,J)=YIL
        GO TO 526
      END IF
  525 CALL BWATR55(PO,JNK,NCML,NQCM,J,IR,IL,QIR,QIL,YIR,YIL,DX,Y1,
     1 YMX,DQDT,ITB,K1,K2,K7,K8,K9)
  526 IF(YDI(IL,J).LE.0.00001) YDI(IL,J)=YIL
      DEP=YDI(IL,J)-HS(1,IL,J)
      IF(JNK.LE.4) GO TO 120
      PQIL=QIL
      PYIL=YDI(IL,J)
      PDEP=DEP
      IF(METRIC.EQ.1) THEN
        PQIL=PQIL/35.32
        PYIL=PYIL/3.281
        PDEP=PDEP/3.281
      ENDIF
      IF(JNK.GT.4.AND.NOPROT.EQ.0) WRITE(IPR,216) IL,PQIL,PYIL,PDEP,ITB
  216 FORMAT(10X,2HI=,I3,5X,4HQIL=,F12.3,5X,4HYIL=,F10.4,5X,4HDEP=,
     *  F10.4,5X,4HITB=,I3)
  120 CONTINUE
      INN=INN-IT-1
      IS=INN
      IF(IS.GT.1) GO TO 100
      GO TO 200
C      COMPUTE DOWNWATER
  160 IS=IS-1
      IF(IS.EQ.0) GO TO 162
      IF(IFR(IS,J).EQ.1) GO TO 160
  162 IS=IS+1
      IF(IS.EQ.1) THEN
        YDI(1,J)=YN(1,J)
        GO TO 164
      END IF
      YDI(IS,J)=YCR(IS,J)
      ISM=IS-1
      KRA=ABS(KRCH(ISM,J))
      IF(KRA.GE.10 .AND. KRA.LE.30) YDI(IS,J)=YN(IS,J)
  164 PYN=YDI(IS,J)
      PDEP=PYN-HS(1,IS,J)
      IF(METRIC.EQ.1) THEN
        PYN=PYN/3.281
        PDEP=PDEP/3.281
      ENDIF
      IF(JNK.GE.4.AND.NOPROT.EQ.0) WRITE(IPR,143) IS,PYN,PDEP
  143 FORMAT(//5X,'DOWNWATER',5X,4HINN=,I3,5X,4HYNN=,F10.2,5X,4HDEP=,
     * F10.2)
      IB=IS
      IS=IS+1
      DO 170 I=IS,INN
      IR=I
      IL=I-1
      QIL=QDI(IL,J)
      QIR=QDI(IR,J)
      YIL=YDI(IL,J)
      CALL INITY55(IYI,IL,J,YDUMY,PO(LONGAG),PO(LONGS),STT,LTSTT,
     . K1,K2,K4)
      IF(IYI.EQ.0) GO TO 295
      YIL=YDUMY(IL,J)
      IE=IL
      IEB=IE-IB
      IF(IEB.LE.1) GO TO 297
      ERY=(YDUMY(IB,J)-YDI(IB,J))/(IE-IB)
      IF(ABS(ERY).LE.0.01) GO TO 297
      IB1=IB+1
      IEM=IE-1
      DO 296 II=IB1,IEM
      YDI(II,J)=YDI(II,J)+ERY*(IE-II)
  296 CONTINUE
  297 YDI(IB,J)=YDUMY(IB,J)
      IB=IE
  295 DX=DDX(IL,J)
      IF(IYI.GE.2) GO TO 168
C  CHECK FOR DAM OR BRIDGE
      YRS=0.5*(HS(1,IR,J)+YIL)
      YLS=YIL
      KRA=IABS(KRCH(IL,J))
      IF(KRA.LT.10) GO TO 165
      CALL INTBI55(PO,CO,Z,ST1,LTST1,T1,LTT1,POLH,LTPOLH,ITWT,LTITWT,
     . NCML,ITQ,3,IL,J,QIR,YLS,YRS,KRCH,Z(LZYU),HS,YCR,K1,K2,K7,K8,
     * K9,K15,K16,K19,K20,K21)

C  DAM OR BRIDGE
      YDI(IR,J)=YRS
      GO TO 170
  165 IF(KRCH(IL,J).GE.10.AND.KRCH(IL,J).LE.30) THEN
        IF(IL.GT.1.AND.KRCH(IL-1,J).NE.4) GO TO 168
C  LEVEL POOL ROUTING DAM
        YDI(IR,J)=YDI(IL,J)
        GO TO 170
      END IF
  168 YDUM=0.0
      IF(BS(1,I,J).GT.0.0) YDUM=AS(1,I,J)/BS(1,I,J)
      YMN=HS(1,I,J)-YDUM
      YMX=YCR(I,J)
      YIR=YMN
      Y1=YN(IR,J)
      CALL DWATR55(PO,JNK,NCML,NQCM,J,IL,IR,QIL,QIR,YIL,YIR,DX,Y1,YMX,
     1 DQDT,ITD,K1,K2,K7,K8,K9)
      DEP=YIR-HS(1,IR,J)
      YDI(IR,J)=YIR
      IF(JNK.LE.4) GO TO 170
      PQIR=QIR
      PYIR=YIR
      PDEP=DEP
      IF(METRIC.EQ.1) THEN
        PQIR=PQIR/35.32
        PYIR=PYIR/3.281
        PDEP=PDEP/3.281
      ENDIF
      IF(JNK.GT.4.AND.NOPROT.EQ.0) WRITE(IPR,217) IR,PQIR,PYIR,PDEP,ITD
  217 FORMAT(10X,2HI=,I3,5X,4HQIR=,F12.3,5X,4HYIR=,F10.4,5X,4HDEP=,
     *  F10.4,5X,4HITD=,I3)
  170 CONTINUE
      IF(IS.EQ.2) GO TO 200
      INN=IS-1
      IS=INN
      GO TO 110
C     CHECK FOR SUBMERGENCE OF UPSTREM YI DUE TO D/S YI
C
  200 ISUB=0
      DO 205 II=1,NM
      I=N-II
      IP=I+1
      IF(YDI(IP,J).LT.YDI(I,J)) GO TO 205
      IF(IFR(I,J).EQ.0) GO TO 205
      YSUP=YDI(I,J)
      QSUP=QDI(I,J)
      YDUM=0.0
      IF(BS(1,I,J).GT.0.0) YDUM=AS(1,I,J)/BS(1,I,J)
      YMN=HS(1,I,J)-YDUM
      DO 2227 LL=1,NCS
      LST=NCS-LL+1
      IF(HS(LST,I,J).GT.0.0001) GO TO 2229
 2227 CONTINUE
 2229 YMX=HS(LST,I,J)
      CALL HSEQ55(PO,JNK,J,I,QSUP,YSUP,YSUB,YMN,YMX,ITS,K1,K2,K9)
      IF(YDI(IP,J).LT.YSUB) GO TO 205
      ISUB=1
      IFR(I,J)=0
      YDI(I,J)=YDI(IP,J)
  205 CONTINUE
      IF(ISUB.EQ.1) GO TO 14
      IF(ITQ.EQ.0.OR.ITRBW.GE.20) GO TO 300
C  IF FLOW IS INCORRECT, THEN RECOMPUTE FLOW, BACK/DOWN WATER!
      DQMX=0.0
      DO 210 I=1,N
      DQ=ABS(QDUMY(I,J)-QDI(I,J))
      IF(DQ.GE.DQMX) DQMX=DQ
  210 CONTINUE
      IF(DQMX.GE.EPSQ) GO TO 4
  300 CONTINUE
C-------  END OF INITIAL CONDITION COMPUTATION  -----------------
C INTERPOLATE YDI FOR NETWORK-RIVER
      IF (NET.LE.0) GOTO 419
        DO 414 J=JN+1,JN+NET
      JIN=MRU(J)
      IIN=NJUM(J)
        JOUT=MRV(J)
      IOUT=NJUN(J)
        H1=0.5*(YDI(IIN,JIN)+YDI(IIN+1,JIN))
      H2=0.5*(YDI(IOUT,JOUT)+YDI(IOUT+1,JOUT))
      DH=(H1-H2)/(NB(J)-1.0)
      YDI(1,J)=H1
      DO 412 I=2,NB(J)
      YDI(I,J)=YDI(I-1,J)-DH
  412 CONTINUE
  414 CONTINUE
  419 IF (JNK.LE.4.OR.NOPROT.EQ.1) GOTO 997
      WRITE(IPR,499)
  499 FORMAT(//1X,'INITIAL WATER ELEVATION:')
  997 DO 420 J=1,JN+NET
      NUM=NUMLAD(J)
      DO 421 LL=1,NUM
      SQW(2,LL,J)=SQW(1,LL,J)
      SQO(2,LL,J)=SQO(1,LL,J)
      SQS1(2,LL,J)=SQS1(1,LL,J)
      SQS2(2,LL,J)=SQS2(1,LL,J)
  421 CONTINUE
      IF (JNK.LE.4.OR.NOPROT.EQ.1) GOTO 420
      WRITE(IPR,490) J
  490 FORMAT(/5X,'YDI FOR RIVER NO.',I3)
      N=NB(J)
       CALL WYQMET55(METRIC,1,N,YDI(1,J),1,N)
  491 FORMAT(5X,8F10.2)
  420 CONTINUE
C  MUD/DEBRIS FLOW INITIAL CONDITIONS
      DO 620 J=1,JN
      IF(MUD1(J).EQ.1.AND.IWF1(J).GE.1) THEN
      N=NB(J)
      IMUD=3
      YDI(2,J)=YN(2,J)+0.5
      YDI(3,J)=YN(3,J)+0.5
      IF (KRCH(1,J).LT.10) YDI(1,J)=YN(1,J)+0.5
      IF (KRCH(1,J).GE.10) IMUD=4
      IWF1(J)=IMUD-1
      IF (N.LE.IMUD) GOTO 620
      DO 600 I1=IMUD,N
      YDI(I1,J)=HS(1,I1,J)
      QDI(I1,J)=0.01
600   CONTINUE
      ENDIF
620   CONTINUE
C NETWORK-RIVER INITIAL CONDITIONS (YDI INTERPOLATED)
11111 FORMAT(1X,'** EXIT INITC **')
999   RETURN
      END
