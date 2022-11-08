c  Simple program to read FRESCO bound state wave functions
c  output when NFL<0.
c
c  If job.wf is the output file, use this program as
c	grwf < job.wf > job.plot
c	xmgr job.plot


      parameter(MAXN=10000)
      DIMENSION D(MAXN),VERT(MAXN)
      character*100 COMMENT
C
1        READ(5,'(a)',end=999)  COMMENT
         READ(5,*) NPOINTS,DR,RFIRST
         WRITE(0,71) COMMENT,NPOINTS,DR,RFIRST
71      FORMAT(/'  Input:',a80,/'  Reading ',I4,' data points at '
     X   ,F8.4,' intervals, starting from r =',F8.4)
        if(NPOINTS.gt.MAXN) then
          write(0,*) ' Only room to read in ',MAXN,' potential',
     x     ' points, not ',NPOINTS
          stop
          endif
        READ(5,*) (D(I),I=1,NPOINTS)
        READ(5,*) (VERT(I),I=1,NPOINTS)
C
      totd = 0.0
      rms = 0.0
      do 15 i=1,NPOINTS
        r = (i-1)*DR
	d(i) = d(i) * r
        de =d(i)**2  * dr
        totd = totd + de
15      rms = rms + de * r*r 
      rms = sqrt(rms/totd)
      write(0,16) totd,rms
16    format(' Wfntn volume integral =',F8.4,', rms radius =',F8.3)

      DO 200 I=1,NPOINTS
      R = (I-1)*DR

      WRITE(6,*) real(R),D(I),VERT(I)
200   CONTINUE
      write(6,*) '&'
	go to 1
C
999   STOP
      END
