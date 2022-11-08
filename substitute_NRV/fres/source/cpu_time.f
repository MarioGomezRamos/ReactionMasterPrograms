      FUNCTION SECOND()
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*4 TARRAY(2),ETIME

      call cpu_time(etime)
      second = etime

      RETURN
      END
