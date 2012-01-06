C$PRAGMA C (GET_APPS_DEFAULTS)
C MODULE TSDEF
C-----------------------------------------------------------------------
C
      SUBROUTINE TSDEF (TS,MTS,D,MD,NXD,NFOUND,LWMAX,
     *   TTS,MTTS,TSESP,MTSESP,IESPSG)
C
C  THIS ROUTINE DEFINES ALL OF THE TIME SERIES THAT WILL BE USED
C  FOR A SEGMENT IN THE FORECAST COMPONENT. IT STORES INFORMATION ABOUT
C  A TIME SERIES IN THE TS ARRAY AND ALLOCATES SPACE FOR THE TIME SERIES
C  DATA IN THE D ARRAY.
C
C  MD  = SIZE OF THE D ARRAY
C  NXD = NEXT OPEN POSITION IN THE D ARRAY
C
C  ROUTINE INITIALLY WRITTEN BY ERIC ANDERSON - HRL - JUNE 1979
C
      CHARACTER*4 DUMMY
      CHARACTER*4 DTYPE,FILETP,EFILETP
      CHARACTER*8 TSID,TSTYPE,ETSTYPE
      CHARACTER*8 RTNNAM/'TSDEF'/
      CHARACTER DEFREQ*32,DEFTYP*4
      CHARACTER*32 TSNAME
      CHARACTER*80 CARDIN
C
      DIMENSION TS(MTS),D(MD)
      DIMENSION TTS(MTTS),TSESP(MTSESP)
      DIMENSION EXTLOC(50)
C
      common /CMFCINIT/ PGMVRN,PGMVRD,PGMNAM,MPGMRG,PGMCMP,PGMSYS
      INCLUDE 'upvrsx_types'
      INCLUDE 'common/ionum'
      INCLUDE 'common/fdbug'
      INCLUDE 'common/fprog'
      INCLUDE 'common/where'
      INCLUDE 'common/fcsegn'
      COMMON /FLARYS/ NXTS,LP,LC,LT,LD
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_top/RCS/tsdef.f,v $
     . $',                                                             '
     .$Id: tsdef.f,v 1.7 2002/02/11 13:07:53 michaelo Exp $
     . $' /
C    ===================================================================
C
C

C     Setup the upvrsx common block
      call set_upvrsx(PGMVRN,PGMVRD,PGMNAM,MPGMRG,PGMCMP,PGMSYS)

      IOPNUM=0
      CALL UMEMOV (RTNNAM,OPNAME,2)
C
      IF (ITRACE.GE.1) WRITE (IODBUG,*) 'ENTER TSDEF'
C
      IBUG=IFBUG('SEGI')
C
      INDERR=0
C
C  NXTS IS THE NEXT OPEN POSITION IN THE TS ARRAY
      NXTS=1
C
      NFOUND=0
      LWMAX=0
      NUMTS=0
      LOCESP=0
C
C  PRINT HEADING
      CALL TSPRT_HEADER
C
C  READ CARD WITH TIME SERIES INFORMATION
40    READ (IN,'(A)') CARDIN
      IF (IBUG.EQ.1) WRITE (IODBUG,*) 'CARDIN=',CARDIN
C
C  CHECK FOR COMMENT
      IF (CARDIN(1:1).EQ.'#') GO TO 40
      IF (CARDIN(1:1).EQ.'$') GO TO 40
C
C  GET VALUES FROM CARD
      READ (CARDIN,50,IOSTAT=IOSTAT) TSID,DTYPE,ITIME,TSTYPE,FILETP,
     *   EFILETP,ETSTYPE
50    FORMAT (A,3X,A,3X,I2,12X,A,6X,A,5X,A,1X,A)
      IF (IOSTAT.NE.0) THEN
         WRITE (IPR,55) CARDIN
55    FORMAT ('0**ERROR** READ ERROR ENCOUNTERED GETTING VALUES FROM ',
     *    'THE FOLLOWING CARD:' /
     * ' ',A)
         CALL ERROR
         INDERR=1
57       READ (IN,'(A)') DUMMY
         IF (DUMMY.EQ.'END') GO TO 430
         GO TO 57
         ENDIF
C
      IF (TSID.EQ.'END') GO TO 430
      IF (TSID.EQ.'END-TS') GO TO 430
C
C  CHECK FILE TYPE
      IF (FILETP.EQ.' ') THEN
         IF (MAINUM.GT.2) THEN
C        CALIBRATION PROGRAM - GET THE DEFAULT FILE TYPE FROM THE NWSRFS
C        APPLICATION DEFAULTS FILE
            DEFREQ='nwsrfs_calbfile_default'
            LDEFREQ=LENSTR(DEFREQ)
            CALL GET_APPS_DEFAULTS (DEFREQ,LDEFREQ,DEFTYP,LDEFTYP)
            IF (DEFTYP.EQ.'CARD') THEN
               FILETP='CARD'
               ELSE IF (DEFTYP.EQ.'HMDB') THEN
                  FILETP='HMDB'
               ELSE
                  FILETP='CALB'
               ENDIF
            ENDIF
         IF (MAINUM.EQ.1) THEN
            FILETP='FPDB'
            IF (EFILETP.NE.' ') FILETP='NONE'
            ENDIF
         ENDIF
C
C  PRINT GENERAL INFORMATION ABOUT THE TIME SERIES
      CALL TSPRT_GENERAL (NUMTS,TSID,DTYPE,ITIME,TSTYPE,FILETP,
     *   EFILETP,ETSTYPE)
C
C  CHECK TYPE OF TIME SERIES
      ITSTYP=0
      IF (TSTYPE.EQ.'INPUT') ITSTYP=1
      IF (TSTYPE.EQ.'UPDATE') ITSTYP=2
      IF (TSTYPE.EQ.'OUTPUT') ITSTYP=3
      IF (TSTYPE.EQ.'INTERNAL') ITSTYP=4
      IF (TSTYPE.EQ.' ') THEN
         ITSTYP=4
         TSTYPE='INTERNAL'
         ENDIF
      IF (ITSTYP.EQ.0) THEN
         WRITE (IPR,90) TSTYPE
90    FORMAT ('0**ERROR** TIME SERIES TYPE CODE ',A,'IS INVALID. ',
     * 'ONLY INPUT, OUTPUT, UPDATE AND INTERNAL ARE ALLOWED.')
         CALL ERROR
         GO TO 40
         ENDIF
C
      IF (ITSTYP.NE.2) GO TO 130
      IF (MAINUM.LE.2) GO TO 130
C
C  UPDATE TIME SERIES ARE NOT ALLOWED IN CALIBRATION PROGRAMS
      WRITE (IPR,110) TSID,DTYPE,ITIME
110   FORMAT ('0**ERROR** AN UPDATE TIME SERIES CANNOT BE USED ',
     * 'IN THE CALIBRATION PROGRAMS. ',
     * 'TSID=',A,2X,'TYPE=',A,2X,'ITIME=',I2)
      CALL ERROR
C  SKIP NEXT CARD BEFORE GOING TO THE NEXT TIME SERIES.
      READ (IN,'(A)') DUMMY
      IF (DUMMY.EQ.'END') GO TO 430
      GO TO 40
C
C  CHECK DATA TYPE CODE - GET UNITS, DIMENSION, IF MISSING DATA
C  ALLOWED, NUMBER OF VALUES PER TIME INTERVAL AND IF
C  ADDITIONAL INFORMATION IS NEEDED
130   CALL FDCODE (DTYPE,UNITS,DIM,MSG,NPDT,TSCALE,NADD,IERR)
      IF (IERR.NE.0) THEN
         WRITE (IPR,140) DTYPE,TSID
140   FORMAT ('0**ERROR** ',A,' IS NOT AN ALLOWABLE DATA TYPE ',
     * 'CODE FOR THE FORECAST COMPONENT. TSID=',A)
         CALL ERROR
         GO TO 150
         ENDIF
      GO TO 160
C
150   IF (ITSTYP.NE.4) THEN
C     SKIP NEXT CARD BEFORE GOING TO THE NEXT TIME SERIES.
         READ (IN,'(A)') DUMMY
         IF (DUMMY.EQ.'END') GO TO 430
         ENDIF
      GO TO 40
C
C  CHECK DATA TIME INTERVAL
160   IF (ITIME.EQ.0.OR.
     *    ITIME.GT.24.OR.
     *    ITIME*(24/ITIME).NE.24) THEN
         WRITE (IPR,180) ITIME,TSID
180   FORMAT ('O**ERROR** TIME INTERVAL OF ',I2,' ',
     * 'HOURS IS NOT ALLOWED. TSID=',A)
         CALL ERROR
         GO TO 150
         ENDIF
C
C  CHECK TIME SERIES IDENTIFIER
      LTSID=LEN(TSID)
      IPACKD=1
      IDCODE=4
      IPRERR=1
      CALL FCIDCK (TSID,LTSID,IPACKD,IDCODE,IPRERR,IERR)
      IF (IERR.NE.0) THEN
         WRITE (IPR,200) TSID,DTYPE,ITIME
200   FORMAT ('0**ERROR** THE IDENTIFIER FOR TIME SERIES ',A,
     * ' DTYPE=',A,' ITIME=',I2,') IS INVALID.')
         CALL ERROR
         GO TO 150
         ENDIF
C
C  CHECK TO MAKE SURE THAT THE IDENTIFIERS ARE UNIQUE
      IF (NXTS.LE.MTS) TS(NXTS)=0.01
      CALL FINDTS (TSID,DTYPE,ITIME,J,LOCTS,DUMMY)
      IF (LOCTS.NE.0) THEN
         WRITE (IPR,220) TSID,DTYPE,ITIME
220   FORMAT('0**ERROR** THE IDENTIFIERS (TSID=',A,' DTYPE=',A,
     * ' ITIME=',I2,') ARE USED FOR MORE THAN ONE TIME SERIES.')
         CALL ERROR
         GO TO 150
         ENDIF
C
      IF (ITSTYP.EQ.4) GO TO 340
C
      IF (FILETP.EQ.'NONE') GO TO 420
C
C  GET EXTERNAL LOCATION INFORMATION FOR INPUT, OUTPUT AND UPDATE TIME
C  SERIES
C
      IF (FILETP.EQ.'CALB') THEN
C     NWSRFS CALIBRATION DISK FILES
          CALL CALBIO (ITSTYP,NUMEXT,EXTLOC,DTYPE,UNITS,DIM,ITIME,
     *       NPDT,IERR)
         CALL UMEMOV (RTNNAM,OPNAME,2)
          IF (IERR.GE.0) GO TO 300
C         TIME SERIES WILL BE CHANGED TO INTERNAL
             ITSTYP=4
             GO TO 340
          ENDIF
C
      IF (FILETP.EQ.'CARD') THEN
C     NWSRFS DATACARD FORMAT FILES.
         CALL CARDIO (ITSTYP,NUMEXT,EXTLOC,DTYPE,UNITS,DIM,ITIME,
     *      NPDT,TSNAME,IERR)
         CALL UMEMOV (RTNNAM,OPNAME,2)
         IF (IERR.GE.0) GO TO 300
C        TIME SERIES WILL BE CHANGED TO INTERNAL
            ITSTYP=4
            GO TO 340
            ENDIF
C
      IF (FILETP.EQ.'HMDB') THEN
C     RTi HMData Database (HMDB) FORMAT FILES.
CCC         CALL HMDBIO (ITSTYP,NUMEXT,EXTLOC,DTYPE,UNITS,ITIME,
CCC     *      NPDT,TSNAME,IERR)
         CALL UMEMOV (RTNNAM,OPNAME,2)
         IF (IERR.GE.0) GO TO 300
C        TIME SERIES WILL BE CHANGED TO INTERNAL
            ITSTYP=4
            GO TO 340
         ENDIF
C
      IF (FILETP.EQ.'FPDB') THEN
C     OFS PROCESSED DATA BASE
         IF (MAINUM.LE.2) GO TO 260
            WRITE (IPR,250) FILETP
250   FORMAT('0**ERROR** FILE TYPE ',A,' CANNOT BE USED FOR ',
     * 'A CALIBRATION PROGRAM.')
            CALL ERROR
            GO TO 150
260      CALL FPDBIO (ITSTYP,NUMEXT,EXTLOC,DTYPE,ITIME,DIM,MSG,NPDT,
     *      TSCALE,NFD,D,MD,LWORK)
         CALL UMEMOV (RTNNAM,OPNAME,2)
         IF (NFD.EQ.1) GO TO 270
C        CHECK BUFFER SPACE.
            IF (LWORK.GT.LWMAX) LWMAX=LWORK
            GO TO 280
270      NFOUND=1
280      IF (NUMEXT.GT.0) GO TO 330
         GO TO 310
         ENDIF
C
C  INVALID FILE TYPE IDENTIFIER
      WRITE (IPR,290) FILETP
290   FORMAT ('0**ERROR** FILE TYPE (',A,') IS NOT VALID.')
      CALL ERROR
      GO TO 150
C
C  CHECK IF ERROR OCCURRED GETTING THE EXTERNAL LOCATION INFORMATION
300   IF (IERR.EQ.0) GO TO 330
C
310   WRITE (IPR,320)
320   FORMAT ('0**ERROR** EXTERNAL LOCATION VALUES COULD NOT BE ',
     * 'OBTAINED FOR THE PRECEDING TIME SERIES.')
      CALL ERROR
      GO TO 40
C
C  SET NUMBER OF LOCATIONS NEEDED TO STORE TIME SERIES INFORMATION
C  IN THE TS ARRAY
C
C  INPUT, OUTPUT AND UPDATE TIME SERIES
330   NLOC=13+NUMEXT+NADD
      GO TO 350
C
C  INTERNAL TIME SERIES
340   NLOC=10+NADD
C.
C  CHECK IF SPACE IS AVAILABLE IN TS ARRAY
350   NAVAIL=MTS-NXTS+1
      IF (NLOC.GT.NAVAIL) THEN
         WRITE (IPR,360)
360   FORMAT ('0**ERROR** THERE IS NOT ENOUGH SPACE AVAILABLE ',
     2 'IN THE TS ARRAY TO STORE THE INFORMATION FOR THE PRECEDING ',
     3 'TIME SERIES.')
         CALL ERROR
         GO TO 40
         ENDIF
C
C  COMPUTE AMOUNT OF SPACE NEEDED IN THE D ARRAY
      I=(24/ITIME)*NPDT
      LENGTH=I*NDD
C
C  STORE THE INFORMATION FOR THE TIME SERIES IN THE TS ARRAY
      L=NXTS-1
      TS(L+1)=ITSTYP+0.01
      NAVAIL=NXTS+NLOC
      TS(L+2)=NAVAIL+0.01
      CALL UMEMOV (TSID,TS(L+3),2)
      CALL UMEMOV (DTYPE,TS(L+5),1)
      TS(L+6)=ITIME+0.01
      TS(L+7)=NPDT+0.01
      TS(L+8)=NXD+0.01
      NXD=NXD+LENGTH
      IF (ITSTYP.GT.2) GO TO 370
         TS(L+9)=1.01
         GO TO 380
370   TS(L+9)=0.01
380   IF (ITSTYP.EQ.4) GO TO 400
         CALL UMEMOV (FILETP,TS(L+10),1)
         TS(L+11)=0.01
         TS(L+12)=NUMEXT+0.01
         DO 390 I=1,NUMEXT
            J=L+12+I
            TS(J)=EXTLOC(I)
390         CONTINUE
C     IADD IS LOCATION OF NUMBER OF PIECES OF ADDITIONAL INFORMATION
         IADD=L+13+NUMEXT
         GO TO 410
400   IADD=L+10
410   TS(IADD)=NADD+0.01
      IF (IBUG.EQ.1) THEN
         WRITE (IODBUG,*) ' L=',L,' ITSTYP=',ITSTYP,' TSID=',TSID,
     *      ' DTYPE=',DTYPE,' ITIME=',ITIME,' NLOC=',NLOC
         ENDIF
C
C  CHECK IF NEED TO READ ADDITIONAL INFORMATION
      IF (NADD.NE.0) THEN
C     CURRENTLY NO TIME SERIES NEED ADDITIONAL INFORMATION
         ENDIF
C
420   IF (MAINUM.LE.2) THEN
         IF (ITSTYP.EQ.4.OR.EFILETP.NE.' ') THEN
            IF (EFILETP.NE.'NONE') THEN
C           PROCESS ESP FILE TYPE
               NWORK=MD-IWKLOC+1
               IREADC=0
               CALL ETSDEF (TTS,MTTS,TS,MTS,NWORK,
     *            IREADC,TSID,DTYPE,UNITS,ITIME,TSTYPE,EFILETP,ETSTYPE,
     *            LOCESP,IERR)
               IF (EFILETP.NE.' ') IESPSG=1
               ENDIF
            ENDIF
         ENDIF
C
      IF (IBUG.EQ.1) THEN
         WRITE (IODBUG,*) 'TSID=',TSID,' FILETP=',FILETP,
     *      ' DTYPE=',DTYPE,' ITSTYP=',ITSTYP
         ENDIF
C
C  ALL INFORMATION NOW STORED IN THE TS ARRAY - PROCESS THE NEXT
C  TIME SERIES AFTER INCREMENTING NXTS
      IF (IBUG.EQ.1) THEN
         WRITE (IODBUG,*) 'NXTS=',NXTS,' NLOC=',NLOC
         ENDIF
      NXTS=NXTS+NLOC
      GO TO 40
C
C  ALL TIME SERIES NOW ENTERED INTO TS ARRAY - COMPUTE LENGTH AND
C  PRINT SPACE ALLOCATED
430   IF (NXTS.GT.MTS) THEN
         NXTS=MTS
         ELSE
            TS(NXTS)=0.01
         ENDIF
      LD=NXD-1
      CALL TSPRT_ARRAY_SPACE (NXTS,MTS,LD)
      IF (LWMAX.GT.0) THEN
         WRITE (IPR,490) LWMAX
490   FORMAT ('0',I5,' SPACES HAVE BEEN ALLOCATED FOR THE PROCESSED ',
     * 'PROCESSED DATA READ/WRITE WORK ARRAY.')
        ENDIF
C
      IF (IBUG.EQ.1) THEN
C     PRINT TS ARRAY
         CALL FDMPA ('TS  ',TS,MTS)
         ENDIF
C
      IF (INDERR.EQ.0.AND.IESPSG.EQ.1) THEN
         CALL ESPTS (TS,MTS,TTS,MTTS,TSESP,MTSESP,IER)
         ENDIF
C
      IF (ITRACE.GE.1) WRITE (IODBUG,*) 'EXIT TSDEF'
C
      RETURN
C
      END
