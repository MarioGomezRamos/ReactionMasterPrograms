C  NON-F90 SUBROUTINES NEEDED ON SOME MACHINES
      FUNCTION SECOND()
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*4 TARRAY(2),ETIME
      SECOND = 0.0
C IBM-----------------
C     CALL CPTIME(I)
C     SECOND = I/100.0

C SUN/ALPHA---------
      SECOND = ETIME(TARRAY)

C F90 real-time clock (NOT cpu time!)
! 	call system_clock(ic,icr,icm)
!	if(icm*icr.ne.0) SECOND = real(ic)/real(icr)

      RETURN
      END
