C MEMBER PM1226
C  (from old member FCPM1226)
C
      SUBROUTINE PM1226(WORK,IUSEW,LEFTW,NP12,SMALL,GATE,GATMAX,
     .                  LENDSU,JDEST,IERR)
C---------------------------------------------------------------------
C  SUBROUTINE TO READ AND INTERPRET PARAMETER INPUT FOR S/U #12
C   FLASHBOARDS SCHEME
C---------------------------------------------------------------------
C  K M KROUSE - HRL - JANUARY 1984
C----------------------------------------------------------------
C
      INCLUDE 'common/comn26'
C
C
      INCLUDE 'common/err26'
C
C
      INCLUDE 'common/fld26'
C
C
      INCLUDE 'common/mult26'
C
C
      INCLUDE 'common/rc26'
C
C
      INCLUDE 'common/read26'
C
C
      INCLUDE 'common/suid26'
C
C
      INCLUDE 'common/suin26'
C
C
      INCLUDE 'common/suky26'
C
C
      INCLUDE 'common/warn26'
C
      DIMENSION INPUT(2,13),LINPUT(13),IP(13),IPREQ(3),OK(13),
     . GENLL(5),GENLS(5),GENLG(3),HVAL(100),RATL(100),RATS(100),
     . RATG(100),WORK(1)
      LOGICAL ENDFND,OK,ALLOK,GETHDQ,SMALL,GATE
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_res/RCS/pm1226.f,v $
     . $',                                                             '
     .$Id: pm1226.f,v 1.1 1995/09/17 18:52:13 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA INPUT/
     .            4HNBOA,4HRDS ,4HGENL,4H-L  ,4HRATI,4HNG-L,
     .            4HGENL,4H-S  ,4HRATI,4HNG-S,4HGENL,4H-G  ,
     .            4HRATI,4HNG-G,4HREPL,4HQ   ,4HHEAD,4HVSQ ,
     .            4HTWCU,4HRVE ,4HCONV,4H    ,4HGENQ,4H    ,
     .            4HSLUI,4HCEQ /
      DATA LINPUT/10*2,1,1,2/
      DATA NINPUT/13/
      DATA NDINPU/2/
C
      DATA IPREQ/1,2,3/
C
      DATA QMCODE/1120.01/
C
C  INITIALIZE LOCAL VARIABLES AND COUNTERS
C
      NP12 = 0
      OK(1) = .FALSE.
      OK(2) = .FALSE.
      OK(3) = .FALSE.
      OK(4) = .TRUE.
      OK(5) = .TRUE.
      OK(6) = .TRUE.
      OK(7) = .TRUE.
      OK(8) = .TRUE.
      OK(9) = .TRUE.
      OK(10) = .TRUE.
      OK(11) = .TRUE.
      OK(12) = .TRUE.
      OK(13) = .TRUE.
      ALLOK = .TRUE.
      GETHDQ=.FALSE.
      SMALL = .FALSE.
      GATE  = .FALSE.
C
      NBS = 0
      RNBS = 0.
      REPLQ = 2E31
      GENQ = 0.0
      QSLU = 0.0
      CONVG = 0.02
C
C
      CODEMQ = QMCODE + SULEVL
C
      DO 3 I = 1,13
           IP(I) = 0
    3 CONTINUE
C
      IERR = 0
C
C  PARMS FOUND, LOOKING FOR ENDP
C
      LPOS = LSPEC + NCARD + 1
      LASTCD = LENDSU
      IBLOCK = 1
C
    5 IF (NCARD .LT. LASTCD) GO TO 8
           CALL STRN26(59,1,SUKYWD(1,7),3)
           IERR = 99
           GO TO 9
    8 NUMFLD = 0
      CALL UFLD26(NUMFLD,IERF)
      IF(IERF .GT. 0 ) GO TO 9000
      NUMWD = (LEN -1)/4 + 1
      IDEST = IKEY26(CHAR,NUMWD,SUKYWD,LSUKEY,NSUKEY,NDSUKY)
      IF (IDEST.EQ.0) GO TO 5
C
C  IDEST = 7 IS FOR ENDP
C
      IF (IDEST.EQ.7.OR.IDEST.EQ.8) GO TO 9
          CALL STRN26(59,1,SUKYWD(1,7),3)
          JDEST = IDEST
          IERR = 89
    9 LENDP = NCARD
C
C  ENDP CARD OR TS OR CO FOUND AT LENDP,
C  ALSO ERR RECOVERY IF NEITHER ONE OF THEM FOUND.
C
C
      IBLOCK = 2
      CALL POSN26(MUNI26,LPOS)
      NCARD = LPOS - LSPEC -1
C
   10 CONTINUE
      NUMFLD = 0
      CALL UFLD26(NUMFLD,IERF)
      IF(IERF .GT. 0) GO TO 9000
      NUMWD = (LEN -1)/4 + 1
      IDEST = IKEY26(CHAR,NUMWD,INPUT,LINPUT,NINPUT,NDINPU)
      IF(IDEST .GT. 0) GO TO 50
      IF(NCARD .GE. LENDP) GO TO 5000
C
C  NO VALID KEYWORD FOUND
C
      CALL STER26(1,1)
      ALLOK = .FALSE.
      GO TO 10
C
C  NOW SEND CONTROL TO PROPER LOCATION FOR PROCESSING EXPECTED INPUT
C
   50 CONTINUE
      GO TO (100,200,300,400,500,600,700,800,900,1000,1100,1200,1300),
     .    IDEST
C
C--------------------------------------------------------------------
C  'NBOARDS' KEYWORD IS EXPECTED. ONE INTEGER VALUE MUST FOLLOW;
C  A SECOND VALUE IS OPTIONAL.
C
 100  CONTINUE
C
      IP(1) = IP(1) + 1
      IF(IP(1).GT.1)CALL STER26(39,1)
C
C  READ NEXT FIELD. LOOKING FOR AN INTEGER VALUE.
C
      NUMFLD = -2
      CALL UFLD26(NUMFLD,IERF)
      IF(IERF.GT.0)GO TO 9000
C
      IF(ITYPE.EQ.0)GO TO 110
      CALL STER26(5,1)
      GO TO 10
C
 110  CONTINUE
C
C  VALUE MUST BE GREATER THAN 0
C
      IF(INTEGR.GT.0)GO TO 130
      CALL STER26(95,1)
      GO TO 10
C
 130  CONTINUE
      RNBL = INTEGR + .01
C
C  CHECK FOR A SECOND INTEGER VALUE(NBS).  IF NOT FOUND, USE
C  DEFAULT VALUE OF O.
C
      NUMFLD = -2
      CALL UFLD26(NUMFLD,IERF)
      IF(IERF.GT.1)GO TO 9000
      IF(IERF.EQ.1)GO TO 150
C
C  VALUE FOUND. MUST BE INTEGER AND POSITIVE.
C
      IF(ITYPE.EQ.0)GO TO 135
      CALL STER26(5,1)
      GO TO 10
C
 135  IF(INTEGR.GE.0)GO TO 140
      CALL STER26(95,1)
      GO TO 10
C
 140  CONTINUE
      RNBS = INTEGR + .01
      NBS = INTEGR
      IF (NBS.GT.0) SMALL = .TRUE.
C
C  EVERYTHING OK
C
 150  CONTINUE
      OK(1)= .TRUE.
      GO TO 10
C
C-----------------------------------------------------------
C  'GENL-L' IS NEXT.  IT CONSISTS OF 5 REAL VALUES.  IF NOT
C   FOUND, CALL IT AN ERROR.
C
 200  CONTINUE
C
      IP(2)=IP(2) + 1
      IF(IP(2).GT.1)CALL STER26(39,1)
C
C  GET LIST OF VALUES. FIVE REAL VALUES MUST FOLLOW.
C
      NL=5
      CALL GLST26(1,1,X,GENLL,X,NL,OK(2))
      IF(.NOT.OK(2))GO TO 10
C
C  SEE IF 5 VALUES WERE READ
C
      IF(NL.EQ.5)GO TO 210
      CALL STER26(62,1)
      GO TO 10
C
 210  CONTINUE
C
C  SEE IF FIRST 4 VALUES ARE ASCENDING
C
      NG=4
      CALL ASCN26(GENLL,NG,0,IERA)
      IF(IERA.GT.0)GO TO 10
C
C  FIRST 4 VALUES MUST ALSO BE WITHIN THE BOUNDS OF THE
C  ELVSSTOR CURVE
C
      DO 220 I=1,5
      GENLL(I)=GENLL(I)/CONVL
 220  CONTINUE
C
      IF (GENLL(1).GT.ELSTOR(1)) GO TO 230
      CALL STER26(63,1)
      GO TO 10
  230 CALL ELST26(GENLL,NG,IERST)
      IF(IERST.GT.0)GO TO 10
C
C  FIFTH VALUE MUST BE REAL AND POSITIVE
C
      IF(GENLL(5).GE.0.0)GO TO 250
      CALL STER26(85,1)
      GO TO 10
C
C  EVERYTHING IS OK
C
 250  CONTINUE
      OK(2)=.TRUE.
      GO TO 10
C
C------------------------------------------------------------
C  'RATING-L' IS EXPECTED NEXT.
C
 300  CONTINUE
C
      IP(3)= IP(3) + 1
      IF(IP(3).GT.1)CALL STER26(39,1)
C
C  GET LIST OF VALUES FOR DEFINING SPILLWAY RATING CURVE
C
      NRATL=100
      CALL GLST26(1,1,X,RATL,X,NRATL,OK(3))
      IF(.NOT.OK(3))GO TO 10
C
C  THE FOLLOWING CHECKS MUST BE MADE ON THE CURVE:
C  1) THE TOTAL NO. OF VALUES INPUT MUST BE EVEN
C  2) THE ELEVATIONS MUST BE ASCENDING AND WITHIN THE BOUNDS
C     OF THE ELVSSTOR CURVE
C  3) THE FIRST ELEVATION MUST BE EQUAL TO GENLL(1) FROM PREVIOUS PARM
C  4) THE DISCHARGES MUST BE REAL POSITIVE AND ASCEDNING, AND
C  5) THE FIRST DISCHARGE MUST BE EQUAL TO 0.0
C
      IF(MOD(NRATL,2).EQ.0)GO TO 310
      CALL STER26(40,1)
      GO TO 10
C
 310  CONTINUE
      NHALF=NRATL/2
      NSEC=NHALF + 1
C
C  SEE IF ELEVATIONS ARE IN ASCENDING ORDER
C
      CALL ASCN26(RATL,NHALF,0,IERA)
      IF(IERA.GT.0)GO TO 10
C
C  SEE IF DISCHARGES ARE IN ASCENDING ORDER
C
      CALL ASCN26(RATL(NSEC),NHALF,0,IERA)
      IF(IERA.GT.0)GO TO 10
C
C  SEE IF ELEVATIONS ARE WITHIN THE BOUNDS OF
C  ELVSSTOR CURVE
C
      DO 320 I=1,NHALF
      RATL(I)=RATL(I)/CONVL
 320  CONTINUE
C
      CALL ELST26(RATL,NHALF,IERST)
      IF(IERST.GT.0)GO TO 10
C
C  SEE IF FIRST ELEVATION IS EQUAL TO GENLL(1)
C  FIRST SEE IF 'GENLL' KEYWORD HAS BEEN ENTERED  OK.
C
C
      IF(.NOT.OK(2))GO TO 10
      X=GENLL(1)
      IF((RATL(1).GT.X-.01) .AND. (RATL(1).LT.X+.01)) GO TO 325
      CALL STER26(72,1)
      GO TO 10
C
C  SEE IF ELEVATIONS AND DISCHARGES ARE POSITIVE
C
 325  DO 340 I=1,NRATL
      IF(RATL(I).GE.0.0)GO TO 330
      CALL STER26(95,1)
      GO TO 10
C
 330  IF(I.GE.NSEC)RATL(I)=RATL(I)/CONVLT
 340  CONTINUE
C
C  SEE IF FIRST DISCHARGE IS EQUAL TO 0.0
C
      IF(RATL(NSEC).GT.-.01 .AND. RATL(NSEC).LT..01) GO TO 350
      CALL STER26(72,1)
      GO TO 10
C
C  EVERYTHING IS OK
C
 350  CONTINUE
      OK(3)=.TRUE.
      GO TO 10
C
C-------------------------------------------------------------------
C-----------------------------------------------------------
C  'GENL-S' IS NEXT.  IT CONSISTS OF 5 REAL VALUES.
C  THIS KEYWORD IS NEEDED ONLY IF NUMBER OF SMALL BOARDS (NBS)
C  IS GREATER THAN ZERO.
C
 400  CONTINUE
C
      IP(4)=IP(4) + 1
      IF(IP(4).GT.1)CALL STER26(39,1)
C
      NL=5
      IF(NBS.GT.0)GO TO 405
      CALL STRN26(60,1,INPUT(1,IDEST),LINPUT(IDEST))
      GO TO 10
C
C  GET LIST OF VALUES. FIVE REAL VALUES MUST FOLLOW.
C
 405  CALL GLST26(1,1,X,GENLS,X,NL,OK(4))
      IF(.NOT.OK(4))GO TO 10
C
C  SEE IF 5 VALUES WERE READ
C
      IF(NL.EQ.5)GO TO 410
      CALL STER26(62,1)
      GO TO 10
C
 410  CONTINUE
C
C  SEE IF FIRST 4 VALUES ARE ASCENDING
C
      NG=4
      CALL ASCN26(GENLS,NG,0,IERA)
      IF(IERA.GT.0)GO TO 10
C
C  FIRST 4 VALUES MUST ALSO BE WITHIN THE BOUNDS OF THE
C  ELVSSTOR CURVE
C
      DO 420 I=1,5
      GENLS(I)=GENLS(I)/CONVL
 420  CONTINUE
C
      IF (GENLS(1).GT.ELSTOR(1)) GO TO 430
      CALL STER26(63,1)
      GO TO 10
  430 CALL ELST26(GENLS,NG,IERST)
      IF(IERST.GT.0)GO TO 10
C
C  FIFTH VALUE MUST BE REAL AND POSITIVE
C
      IF(GENLS(5).GE.0.0)GO TO 450
      CALL STER26(85,1)
      GO TO 10
C
C  EVERYTHING IS OK
C
 450  CONTINUE
      OK(4)=.TRUE.
      GO TO 10
C
C------------------------------------------------------------
C  'RATING-S' IS EXPECTED NEXT.  IT IS NEEDED ONLY IF NUMBER OF SMALL
C  BOARDS (NBS) IS GREATER THAN ZERO.
C
 500  CONTINUE
C
      IP(5)= IP(5) + 1
      IF(IP(5).GT.1)CALL STER26(39,1)
      NRATS=100
      IF(NBS.GT.0)GO TO 505
      CALL STRN26(60,1,INPUT(1,IDEST),LINPUT(IDEST))
      GO TO 10
C
C  GET LIST OF VALUES FOR DEFINING SPILLWAY RATING CURVE
C
 505  CALL GLST26(1,1,X,RATS,X,NRATS,OK(5))
      IF(.NOT.OK(5))GO TO 10
C
C  THE FOLLOWING CHECKS MUST BE MADE ON THE CURVE:
C  1) THE TOTAL NO. OF VALUES INPUT MUST BE EVEN
C  2) THE ELEVATIONS MUST BE ASCENDING AND WITHIN THE BOUNDS
C     OF THE ELVSSTOR CURVE
C  3) THE FIRST ELEVATION MUST BE EQUAL TO GENLS(1) FROM PREVIOUS PARM
C  4) THE DISCHARGES MUST BE REAL POSITIVE AND ASCEDNING, AND
C  5) THE FIRST DISCHARGE MUST BE EQUAL TO 0.0
C
      IF(MOD(NRATS,2).EQ.0)GO TO 510
      CALL STER26(40,1)
      GO TO 10
C
 510  CONTINUE
      NHALF=NRATS/2
      NSEC=NHALF + 1
C
C  SEE IF ELEVATIONS ARE IN ASCENDING ORDER
C
      CALL ASCN26(RATS,NHALF,0,IERA)
      IF(IERA.GT.0)GO TO 10
C
C  SEE IF DISCHARGES ARE IN ASCENDING ORDER
C
      CALL ASCN26(RATS(NSEC),NHALF,0,IERA)
      IF(IERA.GT.0)GO TO 10
C
C  SEE IF ELEVATIONS ARE WITHIN THE BOUNDS OF
C  ELVSSTOR CURVE
C
      DO 520 I=1,NHALF
      RATS(I)=RATS(I)/CONVL
 520  CONTINUE
C
      CALL ELST26(RATS,NHALF,IERST)
      IF(IERST.GT.0)GO TO 10
C
C  SEE IF FIRST ELEVATION IS EQUAL TO GENLS(1)
C  FIRST SEE IF 'GENLS' HAS BEEN ENTERED OK.
C
      IF(.NOT.OK(4))GO TO 10
      X=GENLS(1)
      IF((RATS(1).GT.X-.01) .AND. (RATS(1).LT.X+.01)) GO TO 525
      CALL STER26(72,1)
      GO TO 10
C
C  SEE IF ELEVATIONS AND DISCHARGES ARE POSITIVE
C
 525  DO 540 I=1,NRATS
      IF(RATS(I).GE.0.0)GO TO 530
      CALL STER26(95,1)
      GO TO 10
C
 530  IF(I.GE.NSEC)RATS(I)=RATS(I)/CONVLT
 540  CONTINUE
C
C  SEE IF FIRST DISCHARGE IS EQUAL TO 0.0
C
      IF(RATS(NSEC).GT.-.01 .AND. RATS(NSEC).LT..01) GO TO 550
      CALL STER26(72,1)
      GO TO 10
C
C  EVERYTHING IS OK
C
 550  CONTINUE
      OK(5)=.TRUE.
      GO TO 10
C
C-------------------------------------------------------------------
C
C  'GENL-G' IS NEXT. IF FOUND, FOLLOWED BY 3 REAL VALUES AND 1
C  INTEGER VALUE.
C
 600  CONTINUE
C
      IP(6) = IP(6) + 1
      IF(IP(6).GT.1)CALL STER26(39,1)
      GATE = .TRUE.
C
C  READ NEXT THREE FIELDS, ONE AT A TIME. SHOULD BE REAL POSITIVE NUMBER
C
      DO 620 I=1,3
      NUMFLD = -2
      CALL UFLD26(NUMFLD,IERF)
      IF(IERF.GT.0)GO TO 9000
C
C  LOOKING FOR REAL POSITIVE VALUE
C
      IF(ITYPE.EQ.1)GO TO 610
      CALL STER26(4,1)
      GO TO 10
C
 610  CONTINUE
      IF(REAL.GE.0.0)GO TO 615
      CALL STER26(68,1)
      GO TO 10
C
 615  GENLG(I)=REAL/CONVL
C
 620  CONTINUE
      GATMAX = GENLG(3)
C
C  READ NEXT FIELD (FOURTH VALUE) . SHOULD BE POSITIVE INTEGER VALUE.
C
      NUMFLD = -2
      CALL UFLD26(NUMFLD,IERF)
      IF(IERF.GT.0)GO TO 9000
C
      IF(ITYPE.EQ.0)GO TO 630
      CALL STER26(5,1)
      GO TO 10
C
 630  IF(INTEGR.GE.0)GO TO 635
      CALL STER26(68,1)
      GO TO 10
C
 635  PERIOD= INTEGR + .01
C
C
C  SEE IF FIRST VALUE (CREST) IS LESS THAN THE SECOND VALUE
C  (POOL ELEVATION).
C
      IF(GENLG(1).LT.GENLG(2))GO TO 640
      CALL STER26(109,1)
      GO TO 10
C
 640  CONTINUE
C
C  SEE IF BOTH 'CREST' AND 'POOL ELEVATION' ARE WITHIN BOUNDS
C  OF ELVSSTOR CURVE.
C
      IF (GENLG(1).GT.ELSTOR(1)) GO TO 645
      CALL STER26(63,1)
      GO TO 10
  645 CALL ELST26(GENLG,2,IERS)
      IF(IERS.EQ.0)GO TO 650
      GO TO 10
C
C  EVERYTHING IS OK
C
 650  CONTINUE
      OK(6)= .TRUE.
      GO TO 10
C
C------------------------------------------------------------
C  'RATING-G' IS EXPECTED NEXT.  NEEDED ONLY IF 'GENL-G' WAS ENTERED.
C
 700  CONTINUE
C
      IP(7)= IP(7) + 1
      IF(IP(7).GT.1)CALL STER26(39,1)
      IF(IP(6).GT.0)GO TO 710
      CALL STRN26(60,1,INPUT(1,7),LINPUT(7))
      GO TO 10
C
 710  CONTINUE
C
C  GET LIST OF VALUES FOR DEFINING SPILLWAY RATING CURVE
C
      NRATG=100
      CALL GLST26(1,1,X,RATG,X,NRATG,OK(7))
      IF(.NOT.OK(7))GO TO 10
C
C  THE FOLLOWING CHECKS MUST BE MADE ON THE CURVE:
C  1) THE TOTAL NO. OF VALUES INPUT MUST BE EVEN
C  2) THE ELEVATIONS MUST BE ASCENDING AND WITHIN THE BOUNDS
C     OF THE ELVSSTOR CURVE
C  7) THE FIRST ELEVATION MUST BE EQUAL TO GENLG(1) FROM PREVIOUS PARM
C  4) THE DISCHARGES MUST BE REAL POSITIVE AND ASCEDNING, AND
C  5) THE FIRST DISCHARGE MUST BE EQUAL TO 0.0
C
      IF(MOD(NRATG,2).EQ.0)GO TO 715
      CALL STER26(40,1)
      GO TO 10
C
 715  CONTINUE
      NHALF=NRATG/2
      NSEC=NHALF + 1
C
C  SEE IF ELEVATIONS ARE IN ASCENDING ORDER
C
      CALL ASCN26(RATG,NHALF,0,IERA)
      IF(IERA.GT.0)GO TO 10
C
C  SEE IF DISCHARGES ARE IN ASCENDING ORDER
C
      CALL ASCN26(RATG(NSEC),NHALF,0,IERA)
      IF(IERA.GT.0)GO TO 10
C
C  SEE IF ELEVATIONS ARE WITHIN THE BOUNDS OF
C  ELVSSTOR CURVE
C
      DO 720 I=1,NHALF
      RATG(I)=RATG(I)/CONVL
 720  CONTINUE
C
      CALL ELST26(RATG,NHALF,IERST)
      IF(IERST.GT.0)GO TO 10
C
C  SEE IF FIRST ELEVATION IS EQUAL TO GENLG(1)
C
      X=GENLG(1)
      IF((RATG(1).GT.X-.01) .AND. (RATG(1).LT.X+.01)) GO TO 725
      CALL STER26(72,1)
      GO TO 10
C
C  SEE IF ELEVATIONS AND DISCHARGES ARE POSITIVE
C
 725  DO 740 I=1,NRATG
      IF(RATG(I).GE.0.0)GO TO 730
      CALL STER26(95,1)
      GO TO 10
C
 730  IF(I.GE.NSEC)RATG(I)=RATG(I)/CONVLT
 740  CONTINUE
C
C  SEE IF FIRST DISCHARGE IS EQUAL TO 0.0
C
      IF(RATG(NSEC).GT.-.01 .AND. RATG(NSEC).LT..01) GO TO 750
      CALL STER26(72,1)
      GO TO 10
C
C  EVERYTHING IS OK
C
 750  CONTINUE
      OK(7)=.TRUE.
      GO TO 10
C
C-------------------------------------------------------------------
C  'REPLQ' IS NEXT. USE DEFAULT OF -999.0 IF NOT ENTERED.
C
  800 CONTINUE
      IP( 8) = IP(8) + 1
      IF (IP( 8).GT.1) CALL STER26(39,1)
C
C  NEXT FIELD MUST BE REAL POSITIVE VALUE, CONVERTED TO METRIC.
C
  810 CONTINUE
      OK( 8) = .FALSE.
      NUMFLD = -2
      CALL UFLD26(NUMFLD,IERF)
      IF (IERF.GT.1) GO TO 9000
      IF(IERF.EQ.1)GO TO 835
C
      IF (ITYPE.LE.1) GO TO  820
      CALL STER26(4,1)
      GO TO 10
C
  820 CONTINUE
      IF (REAL.GT.0.00) GO TO  830
      CALL STER26(61,1)
      GO TO 10
C
C EVERYTHING IS OK
C
  830 CONTINUE
      REPLQ = REAL/CONVLT
 835  OK(8) = .TRUE.
      GO TO 10
C
C--------------------------------------------------------------------
C  'HEADVSQ' IS NEXT IN LINE.
C
  900 CONTINUE
      IP(9) = IP(9) + 1
      IF (IP(9).GT.1) CALL STER26(39,1)
C
C  READ FIRST FIELD AFTER 'HEADVSQ'. IF IT'S NUMERIC, GET LIST OF NUMBER
C   FOR DEFINING CURVE
C  IF IT'S CHARACTER, ASSUME A MULTIPLE USE REFERENCE HAS BEEN ENTERED,
C   SEE IF SPEC IS VALID.
C
C  IN THE 1ST CASE, WE MUST REPOSITION READ POINTER BACK TO READ THE FIR
C  FIELD AFTER 'HEADVSQ'.
C
  910 CONTINUE
      GETHDQ = .TRUE.
      LPOSST = LSPEC + NCARD
      NUMFLD = -2
      CALL UFLD26(NUMFLD,IERF)
      IF (IERF.GT.0) GO TO 9000
C
      IHTYPE = ITYPE
      IF (IHTYPE.GT.1) GO TO  970
C
C  REPOSITION TO READ FIRST FIELD AFTER 'HEADVSQ'
C
      CALL POSN26(MUNI26,LPOSST)
      NCARD = LPOSST - LSPEC - 1
      NUMFLD = 0
      CALL UFLD26(NUMFLD,IERF)
C
C
C GET LIST OF VALUES FOR DEFINING THE HEAD VS. Q CURVE
C
      NHVAL=100
      CALL GLST26(1,1,X,HVAL,X,NHVAL,OK(9))
      IF (.NOT.OK(9)) GO TO 10
C
C  FIVE CHECKS MUST BE MADE ON THE CURVE:
C   1) THE TOTAL NO. OF VALUES INPUT MUST BE EVEN (PAIRS OF VALUES ARE
C      NEEDED,
C   2) THE HEAD VALUES MUST BE IN ASCENDING ORDER,
C   3) THE DISCHARGES MUST BE IN ASCENDING ORDER,
C   4) THE DISCHARGES AND HEAD VALUES MUST BE POSITIVE.
C
      IF (MOD(NHVAL,2).EQ.0) GO TO  930
C
      CALL STER26(40,1)
      GO TO 10
C
  930 CONTINUE
      NHALF = NHVAL/2
      NSEC = NHALF + 1
C
C  SEE IF HEAD VALUES ARE IN ASCENDING ORDER
C
      CALL ASCN26(HVAL,NHALF,0,IERA)
      IF (IERA.GT.0) GO TO 10
C
C  SEE IF DISCHARGES ARE IN ASCENDING ORDER
C
      CALL ASCN26(HVAL(NSEC),NHALF,0,IERA)
      IF (IERA.GT.0) GO TO 10
C
C  SEE IF ALL VALUES ARE ALL POSITIVE
C
      DO  950 I=1,NHVAL
      CONV = CONVL
      IF (I.GT.NHALF) CONV = CONVLT
      HVAL(I) = HVAL(I)/CONV
      IF (HVAL(I).GT.0.00) GO TO  950
C
      CALL STER26(61,1)
      GO TO 10
C
  950 CONTINUE
C
C  STORE CODE FOR HEAD VS DISCHARGE CURVE IN /MULT26/
C
      NMDEF(3) = NMDEF(3) + 1
      DMCODE(NMDEF(3),3) = CODEMQ
C
      GO TO  995
C
C--------------------------------
C  FIRST FIELD AFTER 'HEADVSQ' IS CHARACTER. SEE IF IT'S A VALID S/U ID
C  WITH OR WITHOUT PARENTHESES
C
  970 CONTINUE
      CALL MREF26(3,REFCDH,LOCWK,LOCCDH,IERM)
      IF (IERM.GT.0) GO TO 10
C
C  CURVE IS DEFINED OK
C
  995 CONTINUE
      OK(9) = .TRUE.
      GO TO 10
C
C-----------------------------------------------------------------------
C  'TWCURVE' IS NEXT IN LINE.
C
 1000 CONTINUE
      IP(10) = IP(10) + 1
      IF (IP(10).GT.1) CALL STER26(39,1)
      IF(IP(9).EQ.0)CALL STRN26(60,1,INPUT(1,IDEST),LINPUT(IDEST))
C
C  LOOK FOR RATING CURVE NAME
C
 1010 CONTINUE
      NUMFLD = -2
      CALL UFLD26(NUMFLD,IERF)
      IF (IERF.GT.0) GO TO 9000
C
C  SEE IF RATING CURVE HAS BEEN DEFINED WITHIN THE FORECAST SEGMENT
C
      CALL CHEKRC(CHAR,IERR)
      IF (IERR.GT.0) GO TO 10
C
C  SEE IF WE'VE ALREADY DEFINED A TAIL WATER RATING CURVE
C
      CALL CKRC26(1,CHAR,IERR)
      IF (IERR.GT.0) GO TO 10
C
C  CURVE IS REFERRED TO PROPERLY.
C
 1095 CONTINUE
      OK(10) = .TRUE.
      GO TO 10
C
C-----------------------------------------------------------------------
C  'CONV' IS NEXT. IF IT IS NOT FOUND IN THE INPUT STREAM,
C  USE THE DEFAULT (2%).
C
 1100 CONTINUE
      IP(11) = IP(11) + 1
      IF (IP(11).GT.1) CALL STER26(39,1)
      IF(IP(9).EQ.0)CALL STRN26(60,1,INPUT(1,IDEST),LINPUT(IDEST))
C
C  GET NEXT FIELD. ALLOWED FIELDS ARE THE NULL FIELD, OR A REAL POSITIVE
C  VALUE BETWEEN 0.01 AND 1.00
C
      NUMFLD = -2
      CALL UFLD26(NUMFLD,IERF)
      IF (IERF.GT.1) GO TO 9000
      IF (IERF.EQ.1) GO TO 1190
C
C  LOOKING FOR REAL, POSITIVE VALUE BETWEEN 0.01 AND 1.00
C
      IF (ITYPE.EQ.1) GO TO 1120
      CALL STER26(4,1)
      GO TO 10
C
 1120 CONTINUE
      IF (REAL.GE.0.01.AND.REAL.LE.1.00) GO TO 1130
      CALL STER26(68,1)
      GO TO 10
C
C  SAVE THE VALUE AS ALL IS OK WITH 'CONV'
C
 1130 CONTINUE
      CONVG = REAL
C
 1190 CONTINUE
      OK(11) = .TRUE.
      GO TO 10
C
C-----------------------------------------------------------------------
C  'GENQ' IS NEXT KEYWORD.  IT IS NEEDED ONLY IF 'HEADVSQ' WAS
C   NOT ENTERED. IF NEEDED AND NOT FOUND, USE THE DEFAULT OF 0.0.
C
 1200 CONTINUE
      IP(12) = IP(12) + 1
      IF(IP(12).GT.1)CALL STER26(39,1)
      IF(IP(9).EQ.0)GO TO 1210
      CALL STRN26(60,1,INPUT(1,IDEST),LINPUT(IDEST))
      GO TO 10
C
C  GET NEXT FIELD. LOOKING FOR A REAL POSITIVE NUMBER OR NULL FIELD.
C
 1210 CONTINUE
      NUMFLD= -2
      CALL UFLD26(NUMFLD,IERF)
      IF(IERF.GT.1)GO TO 9000
      IF(IERF.EQ.1)GO TO 1250
C
C  VALUE FOUND.  SEE IF REAL AND POSITIVE.
C
      IF(ITYPE.EQ.1)GO TO 1220
      CALL STER26(4,1)
      GO TO 10
C
 1220 IF(REAL.GE.0.0)GO TO 1230
      CALL STER26(61,1)
      GO TO 10
C
C  EVERYTHING IS OK
C
 1230 CONTINUE
      GENQ= REAL/CONVLT
 1250 OK(12)= .TRUE.
      GO TO 10
C
C----------------------------------------------------------
C  'QSLUICE' IS LAST.  IF NOT FOUND, USE DEFAULT OF 0.0.
C
 1300 CONTINUE
C
      IP(13)= IP(13) + 1
      IF(IP(13).GT.1)CALL STER26(39,1)
C
C  GET NEXT VALUE. LOOKOING FOR A REAL POSITIVE NUMBER OR NULL FIELD.
C
      NUMFLD= -2
      CALL UFLD26(NUMFLD,IERF)
      IF(IERF.GT.1)GO TO 9000
      IF(IERF.EQ.1)GO TO 1350
C
C  VALUE FOUND.  SEE IF IT IS POSITIVE AND REAL.
C
      IF(ITYPE.EQ.1)GO TO 1320
      CALL STER26(4,1)
      GO TO 10
C
 1320 IF(REAL.GE.0.0)GO TO 1330
      CALL STER26(61,1)
      GO TO 10
C
C  EVERYTHING IS OK
C
 1330 CONTINUE
      QSLU= REAL/CONVLT
 1350 OK(13)= .TRUE.
      GO TO 10
C
C-----------------------------------------------------------
C  END OF INPUT. STORE VALUES IN WORK ARRAY IF EVERYTHING WAS ENTERED
C  WITHOUT ERROR.
C
 5000 CONTINUE
C
      DO 5005 I = 1,3
            NIP = IPREQ(I)
            IF (IP(NIP).EQ.0)
     .      CALL STRN26(59,1,INPUT(1,NIP),LINPUT(NIP))
 5005 CONTINUE
C
      DO 5007 I=1,13
      IF (.NOT.OK(I)) GO TO 9999
 5007 CONTINUE
      IF (ALLOK) GO TO 5010
      GO TO 9999
C--------------------------------------------------------------------
C  STORE NUMBER OF NBOARDS--LARGE AND SMALL, IF FOUND.
C
 5010 CONTINUE
      CALL FLWK26(WORK,IUSEW,LEFTW,RNBL,501)
      CALL FLWK26(WORK,IUSEW,LEFTW,RNBS,501)
      NP12 = NP12 + 2
C
C----------------------------------------------------------
C  STORE INFORMATION FOR LARGE BOARDS 'GENL-L'
C
      DO 5020 I=1,5
      CALL FLWK26(WORK,IUSEW,LEFTW,GENLL(I),501)
 5020 CONTINUE
      NP12 = NP12 + 5
C
C-----------------------------------------------------------
C  STORE SPILLWAY RATING FOR LARGE BOARDS
C
      PAIR=NRATL/2 + 0.01
CCC ** EV CHANGE ** CHECK THAT NUMBER OF SPILLWAY PTS LE 2*NSE
      IF (NRATL/4.GT.NSE) CALL STER26(121,1)
      IF (NRATL/4.GT.NSE) GO TO 9999
      CALL FLWK26(WORK,IUSEW,LEFTW,PAIR,501)
      DO 5030 I=1,NRATL
      CALL FLWK26(WORK,IUSEW,LEFTW,RATL(I),501)
 5030 CONTINUE
      NP12 = NP12 + NRATL + 1
C
C----------------------------------------------------------
C  STORE INFORMATION FOR SMALL BOARDS IF THERE ARE ANY (NBS.GT.0)
C
      IF(NBS.EQ.0)GO TO 5050
C
      DO 5040 I=1,5
      CALL FLWK26(WORK,IUSEW,LEFTW,GENLS(I),501)
 5040 CONTINUE
      NP12 = NP12 + 5
C
C-----------------------------------------------------------
C  STORE SPILLWAY RATING CURVE FOR SMALL BOARDS IF THERE ARE ANY
C
      PAIR=NRATS/2 + 0.01
CCC ** EV CHANGE ** CHECK THAT NUMBER OF SPILLWAY PTS LE 2*NSE
      IF (NRATS/4.GT.NSE) CALL STER26(121,1)
      IF (NRATS/4.GT.NSE) GO TO 9999
      CALL FLWK26(WORK,IUSEW,LEFTW,PAIR,501)
      DO 5045 I=1,NRATS
      CALL FLWK26(WORK,IUSEW,LEFTW,RATS(I),501)
 5045 CONTINUE
      NP12 = NP12 + NRATS + 1
C
C----------------------------------------------------------
C  STORE GATE INFORMATION IF REQUIRED
C
 5050 CONTINUE
C
C  FIRST STORE A FLAG TO INDICATE IF GATE INFORMATION FOLLOWS:
C    IF OPT = 0,  NO GATE INFORMATION
C    IF OPT = 1,  GATE INFORMATION REQUIRED
C
      OPT = 0 + .01
      IF(IP(6).EQ.1)OPT = 1 + .01
      CALL FLWK26(WORK,IUSEW,LEFTW,OPT,501)
      NP12 = NP12 + 1
C
C  STORE GATE INFORMATION NOW IF REQUIRED
C
      IF(IP(6).EQ.0)GO TO 5070
C
      DO 5060 I=1,3
      CALL FLWK26(WORK,IUSEW,LEFTW,GENLG(I),501)
 5060 CONTINUE
      CALL FLWK26(WORK,IUSEW,LEFTW,PERIOD,501)
      NP12 = NP12 + 4
C
 5070 CONTINUE
C
C-----------------------------------------------------------
C  STORE SPILLWAY RATING FOR GATE IF REQUIRED
C
      IF(IP(7).EQ.0)GO TO 5090
C
      PAIR=NRATG/2 + .01
CCC ** EV CHANGE ** CHECK THAT NUMBER OF SPILLWAY PTS LE 2*NSE
      IF (NRATG/4.GT.NSE) CALL STER26(121,1)
      IF (NRATG/4.GT.NSE) GO TO 9999
      CALL FLWK26(WORK,IUSEW,LEFTW,PAIR,501)
      DO 5080 I=1,NRATG
      CALL FLWK26(WORK,IUSEW,LEFTW,RATG(I),501)
 5080 CONTINUE
      NP12 = NP12 + NRATG + 1
C
C-----------------------------------------------------------
C  STORE PEAK REPLACING DISCHARGE
C
 5090 CALL FLWK26(WORK,IUSEW,LEFTW,REPLQ,501)
      NP12 = NP12 + 1
C
C-----------------------------------------------------------
C  STORE INFORMATION PERTAINING TO THE HEAD VS. DISCHARGE
C  CURVE IF USED.
C
      IF (GETHDQ) GO TO 5200
C
C  'HEADVSQ' IS NOT USED.  STORE A '0' TO INDICATE THIS AND
C  GO ON TO NEXT PARAMETER.
C
      OPT = 0 + .01
      CALL FLWK26(WORK,IUSEW,LEFTW,OPT,501)
      NP12 = NP12 + 1
      GO TO 5400
C
C  'HEADVSQ' IS REQUIRED.
C  IF THE CURVE WAS REFERENCED TO ANOTHER S/U, JUST STORE THAT REFERENCE
C  LOCATION.
C
 5200 CONTINUE
      IF (IHTYPE.GT.1) GO TO 5230
C
C  STORE DEFINITION OF THE HEAD VS. Q CURVE
C
      PAIR = NHVAL/2 + 0.01
      CALL FLWK26(WORK,IUSEW,LEFTW,PAIR,501)
C
C  STORE LOCATION FOR THIS CURVE DEFINITION
C
      IPOWD(NMDEF(3),3) = NPMENT + NP12 + 1
      IWKWD(NMDEF(3),3) = IUSEW
C
C  STORE CURVE
C
      DO 5220 I=1,NHVAL
      CALL FLWK26(WORK,IUSEW,LEFTW,HVAL(I),501)
 5220 CONTINUE
      NP12 = NP12 + NHVAL + 1
      GO TO 5300
C
C  STORE REFERENCE TO CURVE IN WORK ARRAY
C
 5230 CONTINUE
      CDHLOC = - (LOCCDH+0.01)
      CALL FLWK26(WORK,IUSEW,LEFTW,CDHLOC,501)
      NP12 = NP12 + 1
      GO TO 5300
C
C------------------------------------------------------------
C  STORE TAILWATER RATING CURVE NAME (IF 'HEADVSQ' WAS ENTERED)
C
 5300 CONTINUE
C
      CALL FLWK26(WORK,IUSEW,LEFTW,RCID26(1,1),501)
      CALL FLWK26(WORK,IUSEW,LEFTW,RCID26(2,1),501)
      NP12 = NP12 + 2
C---------------------------------------
C  STORE CONVERGENCE CRITERION (IF 'HEADVSQ' WAS ENTERED)
C
      CALL FLWK26(WORK,IUSEW,LEFTW,CONVG,501)
      NP12 = NP12 + 1
C--------------------------------
C  STORE CONSTANT GENERATION DISCHARGE ONLY IF 'HEADVSQ'
C  WAS NOT ENTERED.
C
 5400 CONTINUE
      IF(IP(9).EQ.0)GO TO 5410
C
C  'HEADVSQ' WAS ENTERED. THEREFORE DON'T NEED TO STORE 'GENQ'.
      GO TO 5450
C
C  'GENQ' IS NEEDED.
C
 5410 CALL FLWK26(WORK,IUSEW,LEFTW,GENQ,501)
      NP12 = NP12 + 1
C
C----------------------------------------------------------
C  STORE CONSTANT NON-SPILLWAY NON-GENERATION DISCHARGE
C
 5450 CONTINUE
      CALL FLWK26(WORK,IUSEW,LEFTW,QSLU,501)
      NP12 = NP12 + 1
      GO TO 9999
C
C-----------------------------------------------------------
C  ERROR IN UFLD26
C
 9000 CONTINUE
      IF (IERF.EQ.1) CALL STER26(19,1)
      IF (IERF.EQ.2) CALL STER26(20,1)
      IF (IERF.EQ.3) CALL STER26(21,1)
      IF (IERF.EQ.4) CALL STER26( 1,1)
C
      IF (NCARD.GE.LASTCD) GO TO 9100
      IF (IBLOCK.EQ.1)  GO TO 5
      IF (IBLOCK.EQ.2)  GO TO 10
C
 9100 USEDUP = .TRUE.
C
 9999 CONTINUE
      RETURN
      END
