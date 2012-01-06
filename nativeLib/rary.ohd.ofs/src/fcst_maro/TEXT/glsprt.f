C MEMBER GLSPRT
C  (from old member PPGLSPRT)
C
      SUBROUTINE GLSPRT(NUMST, IREC, IGRID, IPCPN, ISPTR)
C
C.....THIS SUBROUTINE PRODUCES A SORTED LIST PRINTOUT OF THE
C.....PRECIPITATION DATA.
C
C.....ARGUMENTS ARE:
C
C.....NUMST  - NUMBER OF STATIONS TO PRINT.
C.....IREC   - ARRAY OF RECORD NUMBERS IN 'GENL' PARAMETER ARRAY WHERE
C.....         STATION NAMES AND CALL LETTERS CAN BE OBTAINED.
C.....IGRID  - ARRAY OF GRID POINT ADDRESSES.
C.....IPCPN  - ARRAY OF PRECIPITATION DATA.
C.....ISPTR  - ARRAY OF SORT POINTERS THAT DEFINE THE PRECIPITATION LIST
C.....         SORTED IN DESCENDING NUMERICAL ORDER.
C
C
      INTEGER*2 IREC(1), IGRID(1), IPCPN(1), ISPTR(1)
C
      DIMENSION CLTR1(2), CLTR2(2), DESC1(5), DESC2(5), CLTR(2)
      DIMENSION DESC(5), PGENL(100), IBLNK(2), ISID(2), SNAME(2)
C
      INCLUDE 'common/where'
      INCLUDE 'gcommon/gversn'
      INCLUDE 'common/ionum'
      INCLUDE 'gcommon/gdispl'
      INCLUDE 'common/errdat'
      INCLUDE 'gcommon/gdate'
      INCLUDE 'common/pudbug'
      INCLUDE 'gcommon/gopt'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_maro/RCS/glsprt.f,v $
     . $',                                                             '
     .$Id: glsprt.f,v 1.1 1995/09/17 19:01:51 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA NBLNK, IBLNK, GENL /1h , 2*4h    , 4hGENL/
      DATA SNAME /4hGLSP, 4hRT  /
C
  901 FORMAT(1H0, '*** GLSPRT ENTERED ***')
  902 FORMAT(1H0, '*** EXIT GLSPRT ***')
  903 FORMAT(1H1, 92X, 'TIME OF RUN ', 2A4, I2, ',', I5, ' - ', I2, ':',
     * I2, 'Z')
  904 FORMAT(1H0, 57X, 'NWSRFS VERSION 5.0', /, 52X, 'WGRFC FT. WORTH MA
     *RO FUNCTION', /, 54X, '(VERSION ', F4.2, ' - ', A4, I4, ')', //,
     * 29X, 'LISTING OF PRECIPITATION FROM DAILY PRECIPITATION FILE FOR
     *', 2A4, 1X, I2, ',', I5)
  905 FORMAT(48X, 'ONLY OBSERVED PRECIPITATION IS LISTED')
  906 FORMAT(36X, 'ESTIMATIONS ARE LISTED...AND ARE FLAGGED WITH AN ASTE
     *RISK (*)')
  907 FORMAT(15X, 'GRID  PRECIP    NWS ID    NAME', 27X, 'GRID  NWS ID
     *  PRECIP    NAME')
  908 FORMAT(15X, I4, 2X, F6.2, A1, 3X, 2A4, 2X, 5A4, 11X, I4, 2X,
     * 2A4, 2X, F6.2, A1, 3X, 5A4)
  909 FORMAT(1H0, 14X, 'END OF OUTPUT...', I4, ' STATIONS LISTED ON THIS
     * SUMMARY.')
  910 FORMAT(1H0, 14X, 'LIST SORTED BY PRECIPITATION AMOUNT', 22X,
     * 'LIST SORTED ALPHABETICALLY BY NAME')
  911 FORMAT(1H0, '*** ERROR ***  RPPREC ERROR IN GENERAL STATION PARAME
     *TER ARRAY. ERROR CODE = ', I4)
  912 FORMAT(46X, 'ZERO AMOUNTS ARE NOT INCLUDED IN THE LIST')
  913 FORMAT(48X, 'ZERO AMOUNTS ARE INCLUDED IN THE LIST')
  914 FORMAT(1X, 'FOR REC. # ', I4, ' OF PARAMETER ARRAY ', A4, ' ... ST
     *ATUS CODE = ', I4)
C
      INCLUDE 'gcommon/setwhere'
      IF(IPTRCE .GE. 3) WRITE(IOPDBG,901)
      IGBUG = IPBUG(GENL)
      LGENL = 100
C
C.....PRINT OUT THE HEADING.
C
      WRITE(IPR,903) NWKDAY, MONTH, NDATE, NYEAR, ICHRS, ICMINS
      WRITE(IPR,904) VERNUM, NVMON, NVYR, IHYDAY, IHYMON, IHYDAT, IHYYR
      IF(IPREST .EQ. 0) WRITE(IPR,905)
      IF(IPREST .EQ. 1) WRITE(IPR,906)
      IF(IPRZRO .EQ. 0) WRITE(IPR,912)
      IF(IPRZRO .EQ. 1) WRITE(IPR,913)
      WRITE(IPR,910)
      WRITE(IPR,907)
C
C.....BEFORE PRINTING OUT THE PRECIP LIST...INITIALIZE COUNTER
C.....VARIABLES.
C
      IP = 1
      NSTA = 0
      KP = 1
C
C.....NOW PRINT OUT THE PRECIPITATION LIST.
C
      DO 130 NP = 1, NUMST
C
      IPART = 1
C
C.....INITIALIZE THE PRINT LINE VARIABLES.
C
      CALL GPLVIT(IPGRD1, IPGRD2, RAIN1, RAIN2, IFLAG1, IFLAG2, CLTR1,
     * CLTR2, 2, DESC1, DESC2, 5)
C
C.....USE THE SORT POINTERS TO GET THE RECORD NUMBER TO READ FOR THOSE
C.....ENTRIES IN THE LIST SORTED BY PRECIPITATION AMOUNT.
C
   20 IF(KP .GT. NUMST) GOTO 80
      JP = ISPTR(KP)
      NREC = IREC(JP)
      JXRAIN = IPCPN(JP)
      IF(JXRAIN .GT. 0) GOTO 28
      IF(JXRAIN .EQ. 0) GOTO 25
      IF(IPREST .EQ. 1) GOTO 28
      GOTO 27
C
   25 IF(IPRZRO .EQ. 1) GOTO 28
   27 KP = KP + 1
      GOTO 20
C
   28 LP = KP
      KP = KP + 1
      ISID(1) = IBLNK(1)
      ISID(2) = IBLNK(2)
      GOTO 30
C
C.....READ THE GENERAL STATION PARAMETRIC ARRAY.
C
   30 CALL RPPREC(ISID, GENL, NREC, LGENL, PGENL, NUMGEN, IPTRNX,
     * ISTATC)
      IF(IGBUG .EQ. 1) WRITE(IOPDBG,914) NREC, GENL, ISTATC
C
      IF(ISTATC .EQ. 0) GOTO 32
      IF(ISTATC .EQ. 3) GOTO 32
      GOTO 40
C
C.....GET THE STATION DESCRIPTION AND ID...AND DUMP OUT THE PARAMETRIC
C.....DATA BEING?SEARCHED FOR IF SUCH IS DESIRED.
C
   32 CALL GGENLD(IGBUG, PGENL, CLTR, DESC, KGRID)
C
      IF(IPART .EQ. 1) GOTO 50
      IF(IPART .EQ. 2) GOTO 90
C
   40 CALL PSTRDC(ISTATC, GENL, ISID, NREC, LGENL, NUMGEN)
      WRITE(IPR,911) ISTATC
      IF(IPART .EQ. 2) GOTO 120
      GOTO 80
C
C.....NOW FILL OUT THE LEFT SIDE OF THE PRINT LINE.
C
   50 CALL GFPLDT(CLTR, CLTR1, 2, DESC, DESC1, 5, IPCPN(JP),
     * RAIN1, IFLAG1, IGRID(JP), IPGRD1)
C
C.....NOW USE THE CURRENT LOOP COUNTER TO RETRIEVE THE ENTRY FOR THE
C.....ALPHABETICALLY SORTED LIST.
C
   80 IPART = 2
C
   82 IF(IP .GT. NUMST) GOTO 130
      NREC = IREC(IP)
      KXRAIN = IPCPN(IP)
      IF(KXRAIN .GT. 0) GOTO 88
      IF(KXRAIN .EQ. 0) GOTO 85
      IF(IPREST .EQ. 1) GOTO 88
      GOTO 87
C
   85 IF(IPRZRO .EQ. 1) GOTO 88
   87 IP = IP + 1
      GOTO 82
C
   88 MP = IP
      IP = IP + 1
      ISID(1) = IBLNK(1)
      ISID(2) = IBLNK(2)
      GOTO 30
C
C.....FILL OUT RIGHT HALF OF PRINT LINE.
C
   90 CALL GFPLDT(CLTR, CLTR2, 2, DESC, DESC2, 5, IPCPN(MP),
     * RAIN2, IFLAG2, IGRID(MP), IPGRD2)
C
C
C.....WRITE OUT THE LINE...AND UPDATE THE COUNT OF STATIONS LISTED.
C
  120 WRITE(IPR,908) IPGRD1, RAIN1, IFLAG1, CLTR1, DESC1, IPGRD2,
     * CLTR2, RAIN2, IFLAG2, DESC2
C
      NSTA = NSTA + 1
C
  130 CONTINUE
C
      WRITE(IPR,909) NSTA
      IF(IPTRCE .GE. 3) WRITE(IOPDBG,902)
C
      RETURN
      END
