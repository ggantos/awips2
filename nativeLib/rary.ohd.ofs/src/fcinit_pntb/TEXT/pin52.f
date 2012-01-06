C MEMBER PIN52
C-----------------------------------------------------------------------
C
C@PROCESS LVL(77)
C
      SUBROUTINE PIN52 (P,LEFTP,IUSEP,C,LEFTC,IUSEC)

C     THIS IS THE INPUT ROUTINE FOR THE SSARR TIME SERIES SUMMING
C     POINT OPERATION.  THIS ROUTINE INPUTS ALL CARDS FOR THE 
C     OPERATION AND FILLS THE P ARRAY.

C     THIS ROUTINE ORIGINALLY WRITTEN BY 
C        RAY FUKUNAGA - NWRFC   MAY 1995         

C     DEFINITION OF VARIABLES
C     IVERSN = I4     VERSION NUMBER OF OPERATION
C     NTS    = I4     NUMBER OF UPSTREAM TIME SERIES TO SUM

C     CTITLE = C72    DESCRIPTION OF OPERATION

C     BEGIN INCREMENT OUTPUT TIME SERIES                                
C     CBOUTS = C8     BEGIN INCREMENT OUTPUT TIME SERIES IDENTIFIER
C     CBOUTC = C4     BEGIN INCREMENT OUTPUT TIME SERIES DATA TYPE CODE
C     IBOUTT = I4     BEGIN INCREMENT OUTPUT TIME SERIES TIME INTERVAL  

C     END INCREMENT OUTPUT TIME SERIES
C     CEOUTS = C8     END INCREMENT OUTPUT TIME SERIES IDENTIFIER
C     CEOUTC = C4     END INCREMENT OUTPUT TIME SERIES DATA TYPE CODE
C     IEOUTT = I4     END INCREMENT OUTPUT TIME SERIES TIME INTERVAL

C     INPUT TIME SERIES 
C     CINTS  = C8     INPUT TIME SERIES IDENTIFIER
C     CINCOD = C8     INPUT TIME SERIES DATA TYPE CODE
C     ININT  = I4     INPUT TIME SERIES TIME INTERVAL

C     POSITION     CONTENTS OF P ARRAY
C      1           VERSION NUMBER OF OPERATION
C      2-19        DESCRIPTION - TITLE
C     20           # OF INPUT TIME SERIES TO SUM

C     21-22        BEGIN INTERVAL OUTPUT TIME SERIES IDENTIFIER
C     23           BEGIN INTERVAL OUTPUT TIME SERIES DATA TYPE CODE
C     24           BEGIN INTERVAL OUTPUT TIME SERIES TIME INTEVAL
C     
C     25-26        END INTERVAL OUTPUT TIME SERIES IDENTIFIER
C     27           END INTERVAL OUTPUT TIME SERIES DATA TYPE CODE
C     28           END INTERVAL OUTPUT TIME SERIES TIME INTERVAL

C     FOR EACH INPUT TIME SERIES TO BE SUMMED
C     29-30        INPUT TIME SERIES IDENTIFIER
C     31           INPUT TIME SERIES DATA TYPE CODE
C     32           INPUT TIME SERIES TIME INTERVAL
C     33           CARRYOVER FLAG 
C                  = 'CARY', FROM CARRYOVER ARRAY              
C                  = 'FLAT', SET EQUAL TO SECOND ELEMENT
C                  = '    ', SET EQUAL TO ZERO
C                  = 'VALU', READ IN FROM INPUT

C     THEREFORE THE NUMBER OF ELEMENTS REQUIRED IN THE P ARRAY IS
C        28 + 
C         5 * NUMBER OF INPUT TIME SERIES TO BE SUMMED               


      CHARACTER *72 CTITLE
      CHARACTER * 8 CBOUTS,CEOUTS,CINTS        
      CHARACTER * 4 CBOUTC,CEOUTC,CINCOD,CBUNIT,CEUNIT,CUNIT
      CHARACTER * 4 CDIM,CBOUTD,CEOUTD,CTSCAL,CARY

      DIMENSION RBOUTS(2),REOUTS(2),RINTS(2),RTITLE(18)           
      DIMENSION P(*),C(*)

      EQUIVALENCE (CBOUTS,RBOUTS),(CEOUTS,REOUTS),(CINTS,RINTS)
      EQUIVALENCE (CBOUTC,RBOUTC),(CEOUTC,REOUTC)
      EQUIVALENCE (CINCOD,RINCOD)
      EQUIVALENCE (CTITLE,RTITLE)
      EQUIVALENCE (CARY,RARY)

C     COMMON BLOCKS

      COMMON/FDBUG/IODBUG,ITRACE,IDBALL,NDEBUG,IDEBUG(20)
      COMMON/IONUM/IN,IPR,IPU
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_pntb/RCS/pin52.f,v $
     . $',                                                             '
     .$Id: pin52.f,v 1.1 1996/03/21 14:28:51 page Exp $
     . $' /
C    ===================================================================
C
C
C     CHECK TRACE LEVEL
  
      CALL FPRBUG('PIN52   ',1,52,IBUG) 
      IF (IBUG.EQ.1) WRITE(IODBUG,500)
 500  FORMAT(1H0,10X,'DEBUG INPUT ROUTINE FOR SSARR SUMPT OPERATION')
C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C     READ IN CARDS IN FREE FORMAT
      IUSEP = 28
      IUSEC = 0
      IERROR = 0

C     CHECK FOR AVAILABLE SPACE IN THE P ARRAY
      CALL CHECKP (IUSEP,LEFTP,IERFLG)
      IF (IERFLG.EQ.1) IERROR = 1
 
C     READ IN DESCRIPTION
      READ(IN,FMT='(A)',ERR=9991) CTITLE
      IF (IBUG.GE.1) WRITE(IODBUG,801) CTITLE
 801  FORMAT('PIN52: CTITLE: ',A72)


C     READ IN NUMBER OF UPSTREAM TIME SERIES TO BE SUMMED AND
C     OUTPUT TIME SERIES INFORMATION AND TIME INTERVAL
      READ(IN,*,ERR=9992) CBOUTS,CBOUTC,CEOUTS,CEOUTC,IBOUTT,IEOUTT,NTS
      IF (IBUG.GE.1) WRITE(IODBUG,802)
     +                  NTS,CBOUTS,CBOUTC,IBOUTT,CEOUTS,CEOUTC,IEOUTT
 802  FORMAT('PIN52: NTS:    ',I6,/,             
     +       '         CBOUTS: ',A8,/,
     +       '         CBOUTC: ',A4,/,
     +       '         IBOUTT: ',I4,/, 
     +       '         CEOUTS: ',A8,/,
     +       '         CEOUTC: ',A4,/,
     +       '         IEOUTT: ',I4)  

C     CHECK OUTPUT TS INFORMATION
C     CHECK BEGIN INTERVAL OUTPUT TS INFORMATION
      CALL CHEKTS (RBOUTS,RBOUTC,IBOUTT,0,CBOUTD,0,1,IERFLG)
      IF (IERFLG.NE.0) THEN      
         IERROR = 1
         WRITE(IPR,601) CBOUTS,CBOUTC,IBOUTT
 601     FORMAT(//,10X,'*** ERROR *** ERROR WITH TIME SERIES ',
     +            'INFORMATION',/,
     +             10X,'TIME SERIES:  ',A8,2X,A4,2X,I6)
      ENDIF
      CALL FDCODE (CBOUTC,CBUNIT,CDIM,IMISS,NINVAL,CTSCAL,NELSE,IERFLG)
      IF (IERFLG.NE.0) IERROR = 1

C     CHECK END INTERVAL OUTPUT TS INFORMATION
      CALL CHEKTS (CEOUTS,CEOUTC,IEOUTT,0,CEOUTD,0,1,IERFLG)
      IF (IERFLG.NE.0) THEN
         IERROR = 1
         WRITE(IPR,601) CEOUTS,CEOUTC,IEOUTT
      ENDIF

C     CHECK END INTERVAL OUTPUT TIME SERIES
      CALL FDCODE (CEOUTC,CEUNIT,CDIM,IMISS,NINVAL,CTSCAL,NELSE,IERFLG)
      IF (IERFLG.NE.0) IERROR = 1

C     CHECK UNITS
      IF (IBUG.GE.1) WRITE(IODBUG,804) CEUNIT,CBUNIT
 804  FORMAT('PIN52: CEUNIT,CBUNIT: ',2A)
      IF (CEUNIT.NE.CBUNIT) THEN
         IERROR = 1
         WRITE(IPR,6017) CEUNIT,CBUNIT
 6017    FORMAT(//,10X,'*** ERROR *** END INTERVAL OUTPUT TIME SERIES ',
     +                 'UNITS ',A4,' NOT EQUAL TO ',/,
     +                 'BEGIN INTERVAL OUTPUT TIME SERIES UNITS ',A4)
      ENDIF

C     CHECK TIME INTERVALS
      IF (IBUG.GE.1) WRITE(IODBUG,805) IBOUTT,IEOUTT
 805  FORMAT('PIN52: IBOUTT,IEOUTT: ',2I6)
      IF (IBOUTT.NE.IEOUTT) THEN
         IERROR = 1
         WRITE(IPR,6019) IEOUTT,IBOUTT
 6019    FORMAT(//,10X,'*** ERROR *** END INTERVAL OUTPUT TIME SERIES ',
     +                 'TIME INTERVAL ',I4,' NOT EQUAL TO ',/,
     +                 '              BEGIN INTERVAL OUTPUT TIME ',
     +                 'SERIES TIME INTERVAL ',I4)
      ENDIF   

C     STORE OUTPUT TS INFORMATION IN P ARRAY
      P(1) = 1.
      DO 20 I=1,18
 20   P(I+1) = RTITLE(I)
      P(20) = REAL(NTS) + .01
      P(21) = RBOUTS(1)
      P(22) = RBOUTS(2)
      P(23) = RBOUTC
      P(24) = REAL(IBOUTT) + .01
      P(25) = REOUTS(1)
      P(26) = REOUTS(2)
      P(27) = REOUTC
      P(28) = REAL(IEOUTT) + .01

C     READ IN INPUT TIME SERIES 
      DO 100 I=1,NTS

         READ(IN,*,ERR=9993) CINTS,CINCOD,CARY,ININT,RINIT
         IF (IBUG.GE.1) WRITE(IODBUG,803)
     +                  CINTS,CINCOD,ININT,CARY,RINIT
 803     FORMAT('  PIN52: CINTS:   ',A,/,
     +          '         CINCOD:  ',A,/,
     +          '         ININT:   ',I4,/,
     +          '         CARY:    ',A,/,
     +          '         RINIT:   ',F10.2)

C        CHECK INPUT TS INFORMATION
         CALL CHEKTS (CINTS,CINCOD,ININT,1,'L3/T',0,1,IERFLG)
         IF (IERFLG.NE.0) IERROR = 1

C        CHECK DATA TYPE CODES
         CALL FDCODE (CINCOD,CUNIT,CDIM,IMISS,NINVAL,
     +                CTSCAL,NELSE,IERFLG)
         IF (IERFLG.NE.0) IERROR = 1
 
C        CHECK UNITS
         IF (CEUNIT.NE.CUNIT) THEN
            IERROR = 1
            WRITE(IPR,602) CUNIT,CINTS,CINCOD,CEUNIT
 602        FORMAT(//,10X,'*** ERROR *** UNITS ',A,
     +                    ' FOR INPUT TIME SERIES (I.D.= ',A,', TYPE= ',
     +                    A,')',/,
     +                10X,'              DOES NOT MATCH UNITS ',A,
     +                    ' FOR THE OUTPUT TIME SERIES')
C ERROR - UNITS XXXX FOR INPUT TIME SERIES (I.D.= XXXXXXXX,  TYPE= XXXX)
C         DOES NOT MATCH UNITS XXXX FOR THE OUTPUT TIME SERIES
         ENDIF  

C        CHECK TIME INTERVAL
         IF (ININT.NE.IBOUTT) THEN          
            IERROR = 1
            WRITE(IPR,603) ININT,CINTS,CINCOD,IBOUTT
C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012
 603        FORMAT(//,10X,'*** ERROR *** TIME INTERVAL ',I3,
     +                    ' FOR INPUT TIME ',
     +                    'SERIES (I.D.= ',A,', TYPE= ',A,/,
     +                10X,'              DOES NOT MATCH TIME INTERVAL ',
     +                    I3,' FOR THE OUTPUT TIME SERIES')          
C  TIME INTERVAL XXX FOR INPUT TIME SERIES (I.D.= XXXXXXXX,  TYPE= XXXX)
C  DOES NOT MATCH TIME INTERVAL XXX FOR THE OUTPUT TIME SERIES
         ENDIF

C        CHECK IF SPACE IS AVAILABLE IN P ARRAY
         IUSEP = IUSEP + 5
         CALL CHECKP (IUSEP,LEFTP,IERROR)
         IF (IERROR.EQ.1) GO TO 990

C        STORE DATA IN P ARRAY
         P(IUSEP-4) = RINTS(1)
         P(IUSEP-3) = RINTS(2) 
         P(IUSEP-2) = RINCOD
         P(IUSEP-1) = REAL(ININT) + .01
         P(IUSEP) = RARY

C        CHECK IF SPACE IS AVAILABLE IN C ARRAY
         IUSEC = IUSEC + 1
         CALL CHECKC (IUSEC,LEFTC,IERROR)
         IF (IERROR.EQ.1) GO TO 990

C        STORE DATA IN C ARRAY
         IF (CARY.EQ.'VALU') THEN
            C(I) = RINIT
         ELSE
            C(I) = 0.
         ENDIF

 100  CONTINUE

      GO TO 990

 9991 IERROR = 1
      WRITE(IPR,9901)
 9901 FORMAT(//,10X,'*** SARSUMPT INPUT ERROR ***',/,
     +          10X,'CARD 1 READ: USER SUPPLIED INFORMATION')
C        *** SARSUMPT INPUT ERROR ***
C        CARD 1 READ: USER SUPPLIED INFORMATION
      GO TO 990

 9992 IERROR = 1
      WRITE(IPR,9902)
 9902 FORMAT(//,10X,'*** SARSUMPT INPUT ERROR ***',/,
     +          10X,'CARD 2 READ: OUTPUT TIME SERIES INFORMATION')
C        *** SARSUMPT INPUT ERROR ***
C        CARD 2 READ: OUTPUT TIME SERIES INFORMATION
      GO TO 990

 9993 IERROR = 1
      WRITE(IPR,9903)
 9903 FORMAT(//,10X,'*** SARSUMPT INPUT ERROR ***',/,
     +          10X,'CARD 3 READ: INPUT TIME SERIES INFORMATION')
C        *** SARSUMPT INPUT ERROR ***
C        CARD 3 READ: INPUT TIME SERIES INFORMATION 
 
 990  IF (IERROR.GE.1) THEN
         IUSEP = 0
         IUSEC = 0
      ENDIF

      IF (ITRACE.GE.1) WRITE(IODBUG,999) 
 999  FORMAT('PIN52 (SSARR SUMMING POINT) EXITED')

      RETURN
      END
