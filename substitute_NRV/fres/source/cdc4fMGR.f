 	program cdc4   ! Version 4f    including core deformation
      	implicit real*8(a-h,o-z)
	parameter (mp=2000)
	character*80 headng,line
	real*8 jbord(8),jtmin,jtmax,j,p(0:8),ips,begs,quasi,app(8),
     X		kstart,kend,kstep,mu,fmscal,bmid(mp),jpp(8),bepp(8)
	real*8 massn(8),chargen(8),spinn(8),be,bj(mp),bend(mp),xk
 	real*8 masst,massp,jp(mp),jt(mp),ep(mp),bstart(mp),bhat(mp),mass
        real*8 cspinn(mp),cenergyn(mp),jcoremax,jcore,jcom,qbj(mp),j1
        real*8 tspinn(mp),tenergyn(mp),et(mp)
        integer tparityn(mp),ntex
	real*8 sa(mp,mp),ampl(mp),qbjgs(mp),qbjb(mp,mp),expand(11)
     	complex qscale(0:5)
	integer parityn(8),bandp(mp),bl(mp),q,nnp(mp,mp),pset,
     x          lpp(8),nodpp(8,mp),pauli,trans,knex(mp),bia(mp),
     x          n(mp),ngs(mp)
	character*8 namep,namet,part,partn(8),name,namen(8)
	character cpwf,citt
	integer jump(6),cp,nlab(3),cpot,pade,pel,exl,reor,type,nchgs,
     x  shape,copyp,copyt,bandt(mp),ptyp,ptyt(mp),parity,parityl,pcon,
     x 	   nch,shapep,remnant,postprior,typedef,parity1,cparityn(mp)
	equivalence (bandp,ptyp),(bandt,ptyt)
        integer chans,listcc,treneg,cdetr,smats,xstabl,nlpl,waves,
     x      lampl,veff,kfus,wdisk,bpm,melfil,cdccc,bisc(mp),bkind(mp),
     x	    blmax(mp),bnch(mp),bipc(mp),qbl(mp),qbia(mp),
     x      qblgs(mp),qbiags(mp),qblb(mp,mp),qbiab(mp,mp),sumform,qc,
     x      maxcoup(3),static
	logical ppwf,pwf,trnl,energy,potbin,bener(mp),hat,nosol,pralpha,
     x		scaled,ldep(0:10),pdep(0:1),ccbins,dry,fail3,frac,
     x          nosub,itt
        integer nte !MGR
        character*40 text

c CDCC NAMELISTS FOR INPUT:
        namelist/cdcc/ hcm,rmatch,rintp, elab,quasi,rsp,iter,pset,llmax,
     X		rasym,accrcy,switch,ajswtch,sinjmax, cutl,cutr,cutc,
     X	        absend,jtmin,jump,jbord,nnu, ncoul,reor,q,ipc,iscgs,hat,
     X		listcc,smats,veff,chans,xstabl, nk, thmin,thmax,thinc,
     X		smallchan,smallcoup,melfil,nosol,cdetr,numnode,treneg,
     X		nlpl,trans,pel,exl,cdccc,qscale,pade,rmatr,kfus,
     x		nrbases,nrbmin,pralpha,pcon,meigs,hnl,rnl,centre,pauli,
     x 		lab,lin,lex,remnant,postprior,ipcgs,dry,
     x          sumform,qc,la,static,expand,maxcoup
        namelist/nucleus/ part,name,mass,charge,spin,parity,be,nte,
     X			n,l,j,ia,a,kind,lmax,nch,nce,ampl
        namelist/corestates/ spin,parity,ex
        namelist/targstates/ spin,parity,ex!target states MGR
        namelist/bin/ spin,parity,step,start,end,energy,n,l,j,isc,ipc,
     X			kind,lmax,nch,ia,il,ampl
        namelist/potential/ part,a1,a2,rc,ac,v,vr0,a,w,wr0,aw,
     X		wd,wdr0,awd,vso,rso0,aso,shape,freal,fimag,
     x          vsot,rsot0,asot,l,parity,nosub,itt,
     x          beta2,beta3,idef,beta2c,beta3c,beta2m,beta3m

c FRESCO NAMELISTS FOR OUTPUT:
	namelist/fresco/hcm,rmatch,rintp,rsp,hnl,rnl,centre
     X   rasym,accrcy,switch,ajswtch, sinjmax,
     X   jtmin,jtmax,absend,jump,jbord,pset,llmax,
     x   thmin,thmax,thinc,cutl,cutr,cutc,
     x   ips,it0,iter,iblock,nnu,numnode, 
     X   nrbases,nrbmin,pralpha,pcon,meigs,rmatr,beta,
     X   chans,listcc,treneg,cdetr,smats,xstabl,nlpl,waves,
     x        lampl,veff,kfus,wdisk,bpm,melfil,cdccc,
     X	 pel,exl,lab,lin,lex,elab,nosol,dry,sumform,expand
	namelist/partition/namep,massp,zp,nex,ppwf,namet,masst,zt,qval
	namelist/states/ jp,  copyp,ptyp,bandp,ep,tp, cpot,
     X		jt,copyt,ptyt,bandt,et
	namelist/pot/ kp,type,shape,p
	namelist/overlap/ kn1,kn2,ic1,ic2,in,kind,nn,l,sn,
     &         ia,j,kbpot,be,isc,ipc,nam,amp,
     & 	       dm,nk,er,e
	namelist/coupling/icto,icfrom,kind,ip1,ip2,ip3,ip4,ip5,p1,p2
	namelist/cfp/ in,ib,ia,kn,a

      frac(x) = abs(x-nint(x)).gt.1e-5
      fail3(x,y,z) = frac(x+y+z) .or. x.gt.y+z .or. x.lt.abs(y-z)

	trnl=.true.
	ki = 5
	ko1 = 1		! fully-formatted old-syle input
	ko3 = 6 	! new-style with customised namelist output
	kos = 10 	! new-style with customised namelist output, scratch
	koe = 0		! stderr
	nte = 0 !MGR
	open(ko1,recl=80,form='formatted',delim='apostrophe')
!	open(ko3,recl=80,form='formatted',delim='apostrophe')
	open(kos,recl=80,form='formatted',delim='apostrophe',   
     X			status='scratch')
	open(11,recl=80,form='formatted',delim='apostrophe')
	write(0,*) 'CDC: Fresco front end for CDCC, version cdc4f'
	write(0,*) 
	eps = 1d-8
      	read(ki,1005) headng
      	write(ko1,1005) headng
	write(ko3,1001) headng
 1001   format(a80,/,'NAMELIST')
 1005 	format(a80)
	call defaults
	 ios=0
         if(trnl) then
	 read(ki,nml=cdcc,IOSTAT=ios,end=2,err=2)
	 else
	 read(ki,nml=cdcc)
	 endif
   2     if ( ios .ne. 0 ) then
            write (koe,*) ' Input namelist CDCC read error: ',ios
            write (koe,cdcc)
            stop
         endif
	if(abs(rintp).le.1e-3) rintp=5*hcm
	if(abs(rnl)<1e-3) then
      	write(ko1,1010) hcm,rmatch,rintp,rsp
 1010 	format(3f8.3,48x,f8.3)
 	else
      	write(ko1,1011) hcm,rmatch,rintp,hnl,rnl,centre,rsp
 1011 	format(6f8.3,24x,f8.3)
  	endif
	pwf = rmatch<0.
      	if (pwf) write(ko1,1012) rasym,accrcy,switch,ajswtch
 1012 	format(f8.2,f8.6,f8.2,f8.2)

	jtmax = maxval(jbord(:))
	if(jbord(1)<0.) then
	  jtmin = jbord(1)
	  jbord(1) = abs(jbord(1))
	  endif
      	if(jtmax.lt.1000.) then
	  write(ko1,1030) jtmin,jtmax,absend,dry,
     x		(jump(i),nint(jbord(i)),i=1,6)
	  else
	  jtme = int(log10(jtmax))-1
	  jtma = int(jtmax/10.**jtme)
	  write(ko1,1031) jtmin,jtma,jtme,absend,dry,
     x		(jump(i),nint(jbord(i)),i=1,6)
	endif
 1030 	format(2f4.0,f8.4,1x,l1,6x,7(i4,i4))
 1031 	format(f4.0,i2,'e',i1,f8.4,1x,l1,6x,7(i4,i4))

!1055 format(6f8.3)
 1055 format(2x ,f6.2,f8.3,f6.3,2x,3f8.3)

      write(ko1,1055) thmin,thmax,thinc,cutl,cutr,cutc


!			READ IN NUCLEUS SPECIFICATIONS
!        namelist/nucleus/ part,name,mass,charge,spin,parity,be,n,l,j,a
	nin=4
	if(trans>0) nin= 6
	if(trans<0) nin= 5
	do in=1,nin
	 part=' '; name=' '; mass=0; charge=0; spin=0; parity=1
	 be=0; n=1; l=0; j=0; ia=1; a=0.; kind=0; nch=0; lmax=0
         ampl(:)=0.
	 ios=0
         if(trnl) then
	 read(ki,nml=nucleus,IOSTAT=ios,end=22,err=22)
	 else
	 read(ki,nml=nucleus)
	 endif
  22     if ( ios .ne. 0 ) then
            write (koe,*) ' Input namelist NUCLEUS read error: ',ios
            write (koe,nucleus)
            stop
         endif	
	if(part(1:1)==' ') go to 24
	nn = 0
	if(part(1:1)=='P'.or.part(1:1)=='p') nn=1
	if(part(1:1)=='C'.or.part(1:1)=='c') nn=2
	if(part(1:1)=='V'.or.part(1:1)=='v') nn=3
	if(part(1:1)=='T'.or.part(1:1)=='t') nn=4
	if(part(1:1)=='E'.or.part(1:1)=='e') nn=5
	if(part(1:1)=='R'.or.part(1:1)=='r') nn=6
	if(nn==0) then
	 write(0,*) ' Nucleus ',part,' NOT RECOGNISED! Stop'
	 stop
	endif
	namen(nn) = name
	massn(nn) = mass
	chargen(nn) = charge
	spinn(nn) = spin
	parityn(nn) = parity
	if(nn==1) then
	  begs = abs(be)
	  ngs(:) = n(:)
	  kindgs = kind
	  lmaxgs = lmax
          nchgs = nch
	  bl(1) = l
	  bj(1) = j
          bia(1)= ia
	else
	  bepp(nn) = abs(be)
	  nodpp(nn,1) = n(1)
	  lpp(nn) = l
	  jpp(nn) = j
	  app(nn) = a
	endif
	cspinn(1)=spinn(2)
         cparityn(1)=parityn(2)
         cenergyn(1)=bepp(2)
	 tspinn(1)=spinn(4)
	 tparityn(1)=parityn(4)
	 tenergyn(1)=0d0
         if (nn.eq.4 .and. nte.gt.0) then
	 ntex=1+nte
         do icore=1,nte ! include excited core states in partition 2 if nce>0
          if(trnl) then
	   read(ki,nml=targstates,IOSTAT=ios,end=40,err=40)
	  else
	   read(ki,nml=targstates)
	  endif
   40     if ( ios .ne. 0 ) then
           write (koe,*) ' Input namelist CORESTATES read error: ',ios
           write (koe,targstates)
           stop
          endif
          tspinn(icore+1)=spin
          tparityn(icore+1)=parity
          tenergyn(icore+1)=ex
         enddo
         endif 
        enddo
24      mu = massn(3)*massn(2)/(massn(3)+massn(2))
        fmscal = 0.0478436
        c1 = fmscal*mu



!			READ IN CORESTATES SPECIFICATIONS
!        namelist/corestates/ spin,parity,ex
	  if(nchgs==0)nchgs=1

!			READ IN BIN SPECIFICATIONS
!        namelist/bin/ spin,parity,start,step,end,energy,n,l,j,isc,
!			kind,lmax
	ib = 1
	kn = 0
	spin=0; parity=0; step=0; end=0; energy=.false.; l=0; j=0; n=0
	spinl = -1.; parityl = 0; ia=1; ampl(:)=0.



30	  nex = ib
	  do 32 ib=2,nex
32 	  ep(ib) = begs + bhat(ib)
	  jp(1)=spinn(1) 
	  bandp(1)=parityn(1)
	  ep(1) = 0.

      iblock = 1
!      if(iter>=1.and.trans>=0.or.nosol) iblock = 0
      it0 = iter
      write(ko1,1070) ips,it0,iter,iblocko,pade,nnu,smallchan,
     x                smallcoup,numnode
 1070 format(f6.4,i2,i4,2i2,i4,36x,1p,2e8.1,i4)
	if(iblock<0) 
     X	write(ko1,1076) nrbases,nrbmin,pralpha,pcon,meigs,rmatr,beta
 1076    format(2i4,L2,I2,i2,f6.2,f8.4)

 1100 format(40i2)
      write(ko1,1100) chans,listcc,treneg,cdetr,smats,xstabl,nlpl,waves,
     x        lampl,veff,kfus,wdisk,bpm,melfil,cdccc
	icm = 1
	icp = icm
       do 61 ic=1,icm
   	  if(ic==1) then
	   namep=namen(1) ; massp=massn(1); zp=chargen(1)
   	   namet=namen(4) ; masst=massn(4); zt=chargen(4)
	   nexc=ntex
           do icore=1,ntex   ! excited core states
             jt(icore)=tspinn(icore)
             bandt(icore)=tparityn(icore)
             et(icore) = tenergyn(icore)
         enddo
      	 endif
	 qval = 0.0
	 if(ic==1) qval = begs
	 if(trans>0.and.ic>icp) qval = begs-bepp(5)+bepp(6)
	 if(trans<0.and.ic>icp) qval =             +bepp(6)
!	 ppwf = pwf.and.ic==1
	 ppwf = pwf
	 cpwf = 'F'; if(ppwf) cpwf='T'
      write(ko1,1130) namep,massp,zp,nexc,cpwf,namet,masst,zt,qval
      write(kos,1131) namep,massp,nint(zp),nexc,ppwf,
     X                namet,masst,nint(zt),qval
 1130 format(a8,2f8.4,i4,a1,1x,a8,2f8.4,f8.4)
 1131 format(' &Partition namep=''',a8,''' massp=',f8.4,' zp=',i3,
     X ' nex=',i3,' pwf=',L1,/
     X       '            namet=''',a8,''' masst=',f8.4,' zt=',i3,
     X       ' qval=',f8.4,'/')

      do 60 ia=1,abs(ntex)
!      read(ki,1150)  jp(ia),  copyp,bandp ,ep,   cpot,
!    X		jt,  copyt,bandt ,et
	copyt=0
	copyp=0
	if(ia==1) then
	else
	  copyp=1
	endif
	cpot=ic
       write(ko1,1150) jt(ia),copyt,bandt(ia),et(ia),  cpot,
     X		spinn(1),copyp,  parityn(1) ,0d0
       write(kos,11511) jt(ia),bandt(ia),et(ia),cpot
       if(copyp==0) write(kos,1153) spinn(1),  parityn(1) ,0d0
       if(copyp/=0) write(kos,1154) copyp
 1150 format(f4.1,2i2,f8.4,8x,i4,2x,f4.1,2i2,f8.4)
11511 format(' &States jt=',f4.1,' ptyt=',i2,' et=',f8.4,'  cpot=',i3)
 1153 format('         jp=',f4.1,' ptyp=',i2,' ep=',f8.4,'/')
 1154 format('         copyp=',i2,'/')
   60	continue
   61	continue
   62	write(ko1,*) 
   	write(kos,'('' &Partition /   ! END OF DEFINING PARTITIONS''/)')
	jp(1)=spinn(1); bandp(1)=parityn(1); ep(1) = 0. ! restore projectile info
	
!			READ IN POTENTIAL SPECIFICATIONS
!       namelist/potential/ part,a1,a2,rc,ac,v,vr0,a,w,wr0,aw,
!    X		wd,wdr0,awd,vso,rso0,aso,shape,vsot,rsot0,asot,beta2,beta3
	potbin=.false.
        kplast=-1
	do 80 in=1,80
	 part=' '; shape = 0; a1=massn(4); a2=0; nosub=.false.
	 rc=0; ac=0; v=0; vr0=0; a=0; w=0; wr0=0; aw=0; itt=.false.
	 wd=0; wdr0=0; awd=0; vso=0; rso0=0; aso=0; freal=0; fimag=0
	 vsot=0; rsot0=0; asot=0
         beta2=0; beta3=0; idef=0
         beta2c=0; beta3c=0; beta2m=0; beta3m=0
	 p(:) = 0
	 l = -1; parity=0
         itmin=0
	 ios=0
         if(trnl) then
	 read(ki,nml=potential,IOSTAT=ios,end=81,err=63)
	 else
	 read(ki,nml=potential,end=81)
	 endif
   63     if ( ios .ne. 0 ) then
            write (koe,*) ' Input namelist POTENTIAL read error: ',ios
            write (koe,potential)
            stop
         endif	
	kp = 0
	if(part(1:1)=='P'.or.part(1:1)=='p') kp=1  ! projectile - target
	if(part(1:1)=='C'.or.part(1:1)=='c') kp=2  ! core - target
	if(part(1:1)=='V'.or.part(1:1)=='v') kp=3  ! valence - target
	if(part(1:1)=='G'.or.part(1:1)=='g') kp=4  ! core-valence in gs
	if(part(1:1)=='B'.or.part(1:1)=='b') kp=5  ! core-valence in bins
	if(part(1:1)=='T'.or.part(1:1)=='t') kp=6  ! transfer channels
	if(part(1:1)=='E'.or.part(1:1)=='e') kp=7  ! projectile tr bs 
	if(part(1:1)=='R'.or.part(1:1)=='r') kp=8  ! target tr bs 
	if(part(1:1)==' '.or.part(1:1)==' ') go to 80
	potbin = potbin .or. kp==5
	if(kp==5.and.l>=0) then  ! l dependant potential
	    ldep(l) = .true.
	    kp=10+l
	    endif
        if(kp==5.and.parity/=0)then  ! parity dependent potential
            pdep(-(parity-1)/2) = .true.
            kp=10-(parity-1)/2
            endif
	if(kp==0) then
	 write(0,*) ' Potential ',part,' NOT RECOGNISED! Stop'
	 stop
	endif
	
	itmax=4
	if(shape==5) itmax=7	! RSC potential
	if(shape>=7.and.shape<=9) then
		v = freal
		vr0 = fimag
                if(kp==kplast)itmin=1
		endif
       do 79 type=itmin,itmax
       	  shapep = shape
	  p(:) = 0.
        if(type==0) then
	  p(1) = a1; p(2) = a2; p(3)=rc; p(4)=ac; shapep=0
	else if(type==1) then
	  p(1) = v; p(2) = vr0; p(3)=a; p(4)=w; p(5)=wr0; p(6)=aw
	else if(type==2) then
	  p(1) = 0; p(2) = 0  ; p(3)=0; p(4)=wd; p(5)=wdr0; p(6)=awd
	else if(type==3) then
	  p(1) = vso; p(2) = rso0; p(3)=aso; p(4)=0; p(5)=0; p(6)=0
	else if(type==4) then 	
	  if(shape==5) then      ! same as type=3 for RSC
	  p(1) = vso; p(2) = rso0; p(3)=aso; p(4)=0; p(5)=0; p(6)=0
	  else
	  p(1) = vsot; p(2) = rsot0; p(3)=asot; p(4)=0; p(5)=0; p(6)=0
	  endif
	else if(type==7) then 	! tensor force for RSC: same nos as vso
	  p(1) = vso; p(2) = rso0; p(3)=aso; p(4)=0; p(5)=0; p(6)=0
	endif

        if(.not.nosub) then
         citt = ' '
         if(itt) citt = '1'
        else
         citt = '2'
         if(itt) citt = '3'
        endif

        if(maxval(abs(p(1:7)))>eps) then
          write(ko1,72) kp,type,citt,shapep,p(1:7)
          write(kos,721) kp,type,shapep,nosub,itt
          if(maxval(abs(p(1:7)))>999.) then
            write(kos,724) (p(k),k=1,7)
          else if(sum(abs(p(4:7)))>eps) then
            write(kos,722) (p(k),k=1,7)
          else
            write(kos,723) (p(k),k=1,3)
          endif
        endif

        fourpi=16d0*atan(1d0)
        third=1d0/3d0
 
        if(type==0 .and. (idef==0.or.idef==2))then ! Coulomb deformation
        if(abs(beta2)>eps .or. abs(beta3)>eps 
     &      .or. abs(beta2c)>eps .or. abs(beta3c)>eps) then
          if(kp==1)then
            iz=4; typedef=11
          elseif(kp==2)then
            iz=2; typedef=10
          elseif(kp==4 .or. kp==5 .or. kp>=10)then
            iz=2; typedef=11
          endif
          if(typedef==11)a13=a1**third  ! target def
          if(typedef==10)a13=a2**third  ! projectile def
          if( abs(beta2c)<eps .and. abs(beta2)>eps ) beta2c=beta2
          if( abs(beta2c)<eps .and. abs(beta2)>eps ) beta3c=beta3
          amne2=3d0*chargen(iz)*beta2c*(rc*a13)**2/fourpi
          amne3=3d0*chargen(iz)*beta3c*(rc*a13)**3/fourpi
          p(1)=0 ; p(2)=amne2 ; p(3)=amne3; shapep=10
          do i=2,3   ! higher multipoles of deformed potential need 1e-8
           i2=2*i
           i3=3*i
           if(jcoremax*2>=i2)then
            p(i2)=1e-8
           endif
           if(jcoremax*2>=i3.and.i==2)then
            p(i3)=1e-8
           endif
          enddo
              write(ko1,725) kp,typedef,citt,shapep,p(2:7)
              write(kos,721) kp,typedef,shapep,nosub,itt
              write(kos,726) (p(k),k=1,7)
        endif
        endif
        
        if((type==1 .or. type==2) .and. (idef==0.or.idef==1))then  ! nuclear deformation
        if(maxval(abs(p(1:7)))>eps) then
         if(abs(beta2)>eps .or. abs(beta3)>eps
     &      .or. abs(beta2m)>eps .or. abs(beta3m)>eps) then
          if(kp==1)then
            typedef=11
          elseif(kp==2)then
            typedef=10
          elseif(kp==4 .or. kp==5 .or. kp>=10)then
            typedef=11
          endif
          if(typedef==11)a13=a1**third
          if(typedef==10)a13=a2**third
          if( abs(beta2m)<eps .and. abs(beta2)>eps ) beta2m=beta2
          if( abs(beta2m)<eps .and. abs(beta2)>eps ) beta3m=beta3
          p(1)=0 ; p(2)=beta2m*vr0*a13; p(3)=beta3m*vr0*a13; shapep=10
          p(4:7)=0
          do i=2,3
           i2=2*i
           i3=3*i
           if(jcoremax*2>=i2)then
            p(i2)=1e-8
           endif
           if(jcoremax*2>=i3.and.i==2)then
            p(i3)=1e-8
           endif
          enddo
              write(ko1,725) kp,typedef,citt,shapep,p(2:7)
              write(kos,721) kp,typedef,shapep,nosub,itt
              write(kos,726) (p(k),k=1,7)
          if(kp==4 .or. kp==5 .or. kp>=10)iscgs=typedef
         endif
        endif
        endif

72      format(i3,i2,a1,i2,7f8.4)
721     format(' &Pot kp=',i2,' type=',i2,' shape=',i2,
     x        ' nosub=',l1,' itt=',l1)
722     format('      p(1:7)=',f10.4,6f9.4,' /')
723     format('      p(1:3)=',f10.4,2f9.4,' /')
724     format('      p(1:7)=',3g12.4,/ '             ',4g12.4,' /')
725     format(i3,i2,a1,i2,8x,2f8.4,4e8.1)
726     format('      p(1:7)=',f10.4,2f9.4,4e8.1,' /')

79	enddo
        kplast=kp
80	enddo
81	write(ko1,*)
   	write(kos,'('' &Pot /   ! END OF DEFINING POTENTIALS''/)')
	
	ic1 = 1; ic2 = 2; ini=1; sn=spinn(3)
	er=0; dm=0; e=0
        nkin = nk

      kn2 = 0
      il=0
      do 90 ia=1,0
!     read(ki,852) kn1,kn2,ic1,ic2,ini,kind,nn,l,sn,ia,j,
!    &         kbpot,be,isc,ipc,nam,ampl
91    continue
      if(static>0.and.(ia==1.or.bmid(ia)<0.))then
       if(ia>1.and.il==nch)il=0
       il=il+1
      endif
      kind = bkind(ia)
      kn1 = kn2+1
      knex(ia) = kn1
      kbpot = 4
      nn= 0
      l = bl(ia)
      lmax = blmax(ia)
      nch = bnch(ia)
      ipc = bipc(ia)
      j = bj(ia)
      iai = bia(ia)
      if(potbin.and.ia>1.and.
     &   ((l.ne.bl(1).or.abs(j-bj(1))>.1.or.iai.ne.bia(1))
     &      .or.ccbins)) then
         kbpot=5
	 if(ldep(l)) kbpot=10+l
         if(pdep(mod(l,2))) kbpot=10+mod(l,2)
	 endif
      isc = bisc(ia)
      be = -bmid(ia)
      nk = nkin
      er = abs(bend(ia)-bstart(ia))
      nam=1
      amp = 1.0
      if(be>0.) then
	 nk=0
	 er=0
         nn = nnp(ia,1)
	endif
      if(ia==1) then
        nn = ngs(1)
        isc = iscgs
        ipc = ipcgs
        be = begs
	kind=kindgs
	lmax=lmaxgs
	nch = nchgs
	nk = 0
	er = 0
	endif
      if(static>0)then
       if(abs(sa(ia,il))>eps) amp = sa(ia,il)
       if(ia==1)then
        nn = ngs(il)
       else
        nn = nnp(ia,il)
       endif
       if(nn==0.and.be>0.)nn=1
      endif
      if(static>0.and.be>0.)then
          if(ia==1)then
           l = qblgs(il)
           j = qbjgs(il)
           iai = qbiags(il)
          else
           l = qblb(ia,il)
           j = qbjb(ia,il)
           iai = qbiab(ia,il)
          endif
        endif
      kn2 = kn1+nch-1
      if(static/=il.and.ia==1)goto 92

852   format(i3,3x,4i2,2x,2i2,f6.1,f6.1,i5,f11.4,2i3,3x,2(i3,f8.3))
8520  format(2i3,4i2,2x,3i2,f4.1,i2,f4.1,i2,i3,f11.4,2i3,3x,2(i3,f8.3))
      if(kind==0) then
      write(ko1,852) kn1,ic1,ic2,ini,kind,nn,l,sn,j,
     &         kbpot,be,isc,ipc,nam,amp,nk,-er
      write(kos,8521) kn1,0,ic1,ic2,ini
	else
      write(ko1,8520) kn1,kn2,ic1,ic2,ini,kind,nn,l,lmax,sn,iai,j,ia,
     &         kbpot,be,isc,ipc,nam,amp,nk,-er
      write(kos,8521) kn1,kn2,ic1,ic2,ini,iai,ia
	endif
      	  write(kos,8524) kind,nn,l,lmax,sn,j,nam,amp
	if(nk/=0.or.abs(er)>eps) then
          write(kos,8525) kbpot,be,isc,ipc,nk,-er
	 else
          write(kos,8526) kbpot,be,isc,ipc
	 endif
8521   format(' &Overlap kn1=',i4,' kn2=',i4,' ic1=',i1,' ic2=',i1,
     X   ' in=',i2,:,' ia=',i1,' ib=',i3)
8524   format('          kind=',i1,' nn=',i2,' l=',i1,' lmax=',i1,
     X   ' sn=',f3.1,' j=',f4.1,:,' nam=',i1,' ampl=',f8.4)
8525   format('          kbpot=',i2,' be=',f8.4,' isc=',i2,
     X   ' ipc=',i1,' nk=',i4,' er=',f8.4,' /')
8526   format('    kbpot=',i2,' be=',f8.4,' isc=',i2,' ipc=',i1,' /')
92    if(static>0.and.il<nch.and.be>0.)goto 91
90	continue
      lastbin  = kn2
      kn1 = lastbin

	do ic2=2,pauli+1
	kn1=kn1+1
	ic1 = 1; ini=2; kind=0; kbpot=5-ic2; isc=0; ipc=0
	nn=nodpp(ic2,1); l=lpp(ic2); j=jpp(ic2); be=bepp(ic2)
	write(ko1,852) kn1,ic1,ic2,ini,kind,nn,l,sn,j,
     &         kbpot,be,isc,ipc
          write(kos,8521) kn1,kn2,ic1,ic2,ini
      	  write(kos,8524) kind,nn,l,0,sn,j
          write(kos,8526) kbpot,be,isc,ipc
      	  enddo	

	inmin=1
	if(trans<0) inmin=2

	no=4
	if(trans<0) no=5
	do ic2=icp+1,icp+abs(trans)
	do ini=inmin,2
	kn1=kn1+1
	no=no+1
	ic1 = 1; kind=0; kbpot=6+ini; isc=1; ipc=0
	nn=nodpp(no,1); l=lpp(no); j=jpp(no); be=bepp(no)
	write(ko1,852) kn1,ic1,ic2,ini,kind,nn,l,sn,j,
     &         kbpot,be,isc,ipc
          write(kos,8521) kn1,kn2,ic1,ic2,ini
      	  write(kos,8524) kind,nn,l,0,sn,j
          write(kos,8526) kbpot,be,isc,ipc
      	  enddo	
      	  enddo	

	write(ko1,*)
   	write(kos,'('' &Overlap /   ! END OF DEFINING OVERLAPS''/)')
	
      icto = 1; icfrom=2; kind=3
      if(iter==1.and.trans>=0) then
         icto=-icto  !	up only
         if(reor==0)reor = 4	! to and from gs only + diagonal
         ! but if specified as reor/0 then leave as is
      endif
      scaled = .false.
      do i=0,5
       scaled = scaled .or. abs(qscale(i)-1d0)>eps
       enddo
       if(scaled) then
	 write(0,*) ' Scaled multipoles '
       	 reor = reor+10
         write(0,*) ' qscale =',qscale
	 endif
      irem = ncoul
      kpcore = reor
      betar = 3.0
      betai = 2.0
   
      write(ko1,'('' &coupling /   ! END OF Couplings''/)')
!      write(ko1,1220) icto,icfrom,kind,q,irem,kpcore,betar,betai
 1220 format(3i4,3i2,2f8.2)
      if(ccbins.and.(qc>=0.or.la>=0))then
!       write(kos,114) icto,icfrom,kind,q,irem,kpcore,qc,la,betar,betai
      else
!       write(kos,112) icto,icfrom,kind,q,irem,kpcore,betar,betai
       write(kos,'('' &coupling /   ! END OF Couplings''/)')
      endif
112   format(' &Coupling icto=',i2,' icfrom=',i2,' kind=',i1,' ip1=',i2,
     X	' ip2=',i2,' ip3=',i2,:,/,'   p1=',f10.4,' p2=',f8.4,' /')
113   format(' &Coupling icto=',i2,' icfrom=',i2,' kind=',i1,' ip1=',i2,
     X	' ip2=',i2,' ip3=',i2,' /')
114   format(' &Coupling icto=',i2,' icfrom=',i2,' kind=',i1,' ip1=',i2,
     X	' ip2=',i2,' ip3=',i2,' ip4=',i2,' ip5=',i2,:,/,
     X  '   p1=',f10.4,' p2=',f8.4,' /')

	ia = 1; in = 1; a=1.0
	if(ccbins)then
         write(ko1,*)
         write(kos,8741)
        else
         do 876 ib=1,nex
	 kn=knex(ib)
          if(ib==nex) in=-in
 !  	   write(ko1,8739) in,ib,ia,kn,a
 !  	   write(kos,8740) in,ib,ia,kn,a
           text='&cfp/'
           write(ko1,8741)
          write(kos,8741)
8739  	   format(4x,4i4,f8.4)
8740  	   format('   &Cfp/  in=',i2,' ib=',i3,' ia=',i3,' kn=',i3,
     X		  '  a=',g12.5,' /')
8741  	   format('   &Cfp  /')
876	   continue
	endif
        
        if(scaled) then
!	 write(ko1,879) (qscale(i),i=max(0,-q),abs(q))
879             format(6e12.4)
!	 write(kos,880)
880	 format('   &Scale ')
!	 do i=max(0,-q),abs(q)
!	 write(kos,881) i,qscale(i)
!	 enddo
881	 format('          qscale(',i1,') = (',g12.4,',',g12.4,') ')  
     	 write(kos,882) 
882	 format('   / ')
	endif

C				Transfer to PP blocked states
      	icfrom=1; kind=7
      	npp = 0
      	irem = 2
      	kpcore = 0
        kn = lastbin
        do icto=2,pauli+1
         kn = kn+1
!      	 write(ko1,1220) icto,icfrom,kind,npp,irem,kpcore
!      	 write(kos,113) icto,icfrom,kind,npp,irem,kpcore
		ia = 1; in = 1; a=1.0
		do ib=1,nex
!   	   	write(ko1,8739) in,ib,ia,knex(ib),a
!   	   	write(kos,8740) in,ib,ia,knex(ib),a
		enddo
	ia = 1; in = -2;ib=1; a=1.0   !  Occupied sp state
 !  	   write(ko1,8739) in,ib,ia,kn,a
 !  	   write(kos,8740) in,ib,ia,kn,a
   	 enddo
	
C				Transfer to allowed states
      	icfrom=1; kind=7
	no=3+inmin
      	npp = 1; if(postprior>-10) npp=postprior
      	irem = 2; if(remnant>-10) irem=remnant
      	kpcore = 2  !??
        do icto=icp+1,icp+abs(trans)
         if(pel==1) then
      	  write(ko1,1220) icto,icfrom,kind,npp,irem,kpcore
      	  write(kos,113)  icto,icfrom,kind,npp,irem,kpcore
	 else
      	  write(ko1,1220) icfrom,icto,kind,npp,irem,kpcore
      	  write(kos,113)  icfrom,icto,kind,npp,irem,kpcore
	 endif
	 do in=inmin,2
          kn = kn+1
	  no = no+1
	  ia = 1; ib=1 ;  a=app(no)  
	  ini=in; if(in==2) ini=-in
   !	  write(ko1,8739) ini,ib,ia,kn,a
          text='&cfp/'
          write(ko1,8741) 
          write(kos,8741) 
  ! 	  write(kos,8740) ini,ib,ia,kn,a
	  enddo
   	 enddo
	
	
 !     write(ko1,1220) 0,pel,exl,lab,lin,lex
 !     write(kos,113) 0,pel,exl,lab,lin,lex
!1121  format(' &Coupling icto=',i2,' icfrom=',i2,' kind=',i1,' /')

         write(kos,'('' ! *******  END OF CDCC INPUTS *******  '')')

      write(ko1,1255) elab
 1255 format(f8.2)


 	write(11,99) hcm,rmatch,rintp,rsp,elab,
     X   rasym,accrcy,switch,ajswtch, sinjmax,
     X   jtmin,jtmax,absend,jump,jbord,
     x   thmin,thmax,thinc,cutl,cutr,cutc,
     x   ips,it0,iter,iblock,pade,nnu,
     X   chans,listcc,treneg,cdetr,smats,xstabl,nlpl,waves,
     x        lampl,veff,kfus,wdisk,bpm,melfil,cdccc
99	format(6g12.4)
 

	write(ko3,100)hcm,rmatch,rintp,rsp
100	format(' &Fresco','  hcm=',f6.3,' rmatch=',f8.3,' rintp=',f6.2,
     x	       ' rsp=',f6.1)
	if(abs(rnl)>eps) 
     x	 write(ko3,102) hnl,rnl,centre
102     format('     hnl=',f9.3,' rnl=',f8.2,' centre=',f8.2)
	if(abs(rasym)>eps) 
     x	 write(ko3,103) rasym,accrcy,switch,ajswtch,sinjmax
103     format('     rasym=',f9.2,' accrcy=',f10.7,' switch=',f8.2,
     X		' ajswtch=',f6.0,' sinjmax=',f8.0)
	write(ko3,104) jtmin,jtmax,absend,pset
104     format('     jtmin=',f6.1,' jtmax=',f9.1,' absend=',f10.4,
     X		' pset=',i2)
	if(jump(1)/=0) 
     X		write(ko3,105) (jump(i),i=1,6),(jbord(i),i=1,6)
105	format('      jump =',6i8,/,'      jbord=',6f8.1)
	if(llmax>=0) write(ko3,106) llmax
106	format('     llmax =',i8)
    	write(ko3,200) thmin,thmax,thinc,cutl,cutr,cutc
200	format('     thmin=',f6.2,' thmax=',f7.2,' thinc=',f6.2,
     X            '  cutl=',f6.2,' cutr=',f6.2,' cutc=',f6.2)
	write(ko3,201) ips,it0,iter,iblock,pade,nnu
201	format('     ips=',f7.4,'  it0=',i2,' iter=',i3,
     X	   ' iblock=',i3,' pade=',i1,' nnu=',i3)
	if(nosol) write(ko3,'(''     nosol = '',l1)') nosol
	if(abs(smallchan)+abs(smallcoup)>0) 
     x		write(ko3,202) smallchan,smallcoup
202	format('     smallchan=',1p,e9.2,'  smallcoup=',e9.2)
     	if(numnode/=0) write(ko3,2025) numnode
2025	format('     numnode=',i4)
     	if(ccbins) write(ko3,2027) sumform
2027	format('     sumform=',i4)
        if(maxval(expand)>0.) write(ko3,2028) expand
2028	format('     expand=',10(f3.1,','),f3.1)
        if(maxval(abs(maxcoup))/=0) write(ko3,2029) maxcoup
2029	format('     maxcoup=',i10,',',i10,',',i10)
     	if(dry) write(ko3,2026) dry
2026	format('     dry=',l1)


     	if(nrbases>0) 
     x   write(ko3,203) nrbases,nrbmin,pralpha,pcon,meigs,rmatr
203	format('     nrbases=',i2,' nrbmin=',i2,' pralpha=',l1,
     x	  	' pcon=',i2,' meigs=',i4,' rmatr=',f8.3)
	write(ko3,204) chans,listcc,treneg,cdetr,smats,xstabl,
     x        waves,lampl,veff,kfus,wdisk,nlpl,melfil,cdccc
204	format('     chans=',i2,' listcc=',i2,' treneg=',i2,
     X	       ' cdetr=',i2,' smats=',i2,' xstabl=',i2,/,
     x         '     waves=',i2,' lampl=',i2,' veff=',i2,' kfus=',i2,
     X         ' wdisk=',i2,' nlpl=',i2,' melfil=',i2,' cdcc=',i2)
	write(ko3,209) elab,pel,exl,lab,lin,lex
209	format('     elab=',f11.4,'    pel=',i1,' exl=',i1,
     x	 ' lab=',i1,' lin=',i1,' lex=',i1,' /'/)


	rewind(kos)
	do 20 i=1,999999
	  read(kos,1005,end=21) line
	  write(ko3,1005) line
20	continue
21	continue

	write(ko3,1470) 
1470 	format(/' Please check that your input numbers have sufficient'
     X /' range and accuracy in the formats chosen for the namelists.'/)


	write(0,*) ' fort.1 has fully-formatted old-syle input'
	write(0,*) ' fort.6 (stdout) has namelist output'
	stop
	
	CONTAINS
	subroutine defaults
      	implicit real*8(a-h,o-z)
	 hcm=0.1; rmatch=20; rintp=0; rsp=0.
	 hnl=0.; rnl=0.; centre=0.; pauli=0; trans=0
         rasym=0; accrcy=0.001; switch=0; ajswtch=0; sinjmax=0 
         jtmin=0; jtmax=0; absend=-1; pset=0; llmax=-1
	 jump(:)=0; jbord(:)=0; 
         thmin=0; thmax=10; thinc=1;
         smallchan=1d-12; smallcoup=1d-12; numnode=0
	 cutl=0; cutr=0; cutc=0;  quasi=-1000.
         ips=0; it0=1; iter=1; iblock=90; pade=0; nnu=24
     	 nrbases=0;nrbmin=0;pralpha=.false.;pcon=0
	 meigs=0;rmatr=0.;beta=0.
         chans=1; listcc=0; treneg=1; cdetr=0; smats=2; xstabl=1; 
	 nlpl=0; waves=0; lampl=0; veff=0; kfus=0; wdisk=0
	 bpm=0; melfil=0; cdccc=0; nosol=.false.
	 ipc = 2; ipcgs=0; iscgs=1; nk=20; hat=.true.
	 remnant=-10; postprior=-10
     	 pel=1;exl=1;lab=1;lin=1;lex=1
	 elab=0; nlab=0
         nce=0; sumform=-1; qc=-1; la=-1
	  bepp(:) = 0.; nodpp(:,:) = 1; lpp(:) = 0; jpp(:) = 0.
	  qscale(:) = (1.0,0.0)
         sa(:,:)=0.
         ccbins=.false. ; static=0
         ldep(:)=.false.; pdep(:)=.false.
         dry=.false.
         expand(:)=0.
	 return
	 end subroutine defaults

	end
