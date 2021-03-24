c	Program RAW_GRBM_TOT 
c	by M.N.Cinti release January 1997
c
c	Setting the path of data
c
c	Input: orbit number
c	Output: File *.log (with general information)
c	        file *.out (ascii datafor each type data and for each
c                           slab)
c	        file *.tot.out (total light curve for each slab,
c                               bin= 7.8125 ms)
c
c	WARNING: Check the lenght of the path name 
*******************************************************************************
	
	character*100 logfile,file,outfile
	byte sequence,source_type
	character*1108 record
	integer*2 tempo(2),grb_counter_4,type,start_time(2),d(2)
	integer*2 data(512),dati(512),dati1(1024),grb_counter_5
	integer*4 time,grb_counter
        real*8 startime,stime
	character a*1,b*1,c*1,path*50,file1*50
	integer*2 flag, old_num
	parameter ftime=2.d0**-16


c  record definition

	equivalence(record(7:7),tempo(1))   
	equivalence(record(11:11),sequence)
	equivalence(record(12:12),source_type)
	equivalence(record(13:13),grb_counter)
	equivalence(record(17:17),data(1))


	equivalence(d(1),time)

	


c  WARNING: path definition
	write(*,*)'Path name (format ~/*:)'
	read(*,'(a)')path
	write(*,*)'Insert btbdump type (format btbdump.*_*):'
	read(*,'(a)')file1

c  Loop on the slabs

	do imi=1,4
	write(b,23)imi

c  Loop on type of counter

	do kkk=1,3
	write(c,23)kkk
23	format(i1)

c  Input file definition

	file=path(1:index(path,' ')-1)//'/'//
     1       file1(1:index(file1,' ')-1)//
     1       '.P'//b//'GRB00'//c

c  Log file definition 
	
	logfile=file(1:index(file,' ')-1)//'.log'
	open(10,name=file,status='old',form='unformatted',
     1	access='direct',recl=277,err=9998)

	open(20,name=logfile,status='unknown',form='formatted')

	write(*,*)
	write(*,98)logfile
98	format('Writing log-file: ',a60)
	
	time=0.

c
	
	flag = 0

c  Evaluation number of records

	irect=0
	nset=1
	do i=1,10000
	  flag = 0
	  irect=irect+1	
	  read(10,rec=irect,err=99)record
	  if (i.eq.1)type=(source_type.and.48)/16
c 99	  continue
	end do

99	continue

	nrecord=irect-1

c  Trigger number evaluation
	
	if(type.eq.1)isubset=2
	if(type.eq.2)isubset=20
	if(type.eq.3)isubset=22

	set=nrecord*1./isubset
	scarto=set-iint(set)
	if(scarto.eq.0)then
		nset=set
	else
		nset=set+1
	end if


	write(20,16)file1
	write(20,13)nrecord
13	format('Total number of records  -->',i3)	
	write(20,12)nset
12	format('Number of trigger        -->',i3)
	write(20,20)type
20	format('Type code                -->',i3)
	write(20,*)'     '


c Re-read input file and write log file and output file

	ilm=1
	do k=1,nset
	   write(a,24)k
24	   format(i1)
	   outfile=file(1:index(file,' ')-1)//'_'//a//'.out'
	
	   open(30,name=outfile,status='unknown',form='formatted')
	   old_num=0
       	   do i=ilm,k*isubset
               	if(i.gt.nrecord)goto 9999 

c       SALVA IL NUMERO DI SEQUENZA PRECEDENTE

		if(i.gt.1)then
		   read(10,rec=i-1)record
		   old_num = sequence
		endif



		read(10,rec=i)record

c       CONTROLLA SE CI SONO SALTI NELLA SEQUENZA
		
		write(*,*)(sequence - old_num)
		if(old_num.ne.(sequence-1))then
		   
c		   if ()
		   write(*,*)'sequence = '
		   write(*,*)sequence
		   write(*,*)'old_num = '
		   write(*,*)old_num 
		   write(*,*)
	        endif

	    	if(sequence.eq.1)then

		  start_time(1)=(tempo(1).and.255)*256+
     1                          (tempo(1).and.65280)/256


		  start_time(2)=(tempo(2).and.255)*256+
     1                          (tempo(2).and.65280)/256     	  
		

		  d(1)=start_time(1)
		  d(2)=start_time(2)
 
c		  time= start_time(1)+(start_time(2)*65536)

                  if(time.ge.0) then
                      startime=time*ftime
                  else
                     startime=(time+2.**32)*ftime
                  end if
	          stime=startime
		  grb_counter_4=grb_counter.and.4096
		  grb_counter_5=grb_counter.and.8192


		  write(20,18)startime
		  write(20,21)grb_counter_4
		  write(20,22)grb_counter_5
		end if

		write(20,19)sequence
		write(20,*)'indice precedente -->', old_num

		If(type.eq.1.or.type.eq.3)then

		do j=1,512
			dati(j)=(data(j).and.65280)/2**8+
     1                          (data(j).and.255)*2**8
			dati(j)=dati(j).and.511

			write(30,*)dati(j)

		end do

		else if(type.eq.2)then
		kl=1
		do j=1,512
			dati1(kl)=(data(j).and.65280)/2**8
			dati1(kl)=dati1(kl).and.63

			write(30,*)dati1(kl)

			kl=kl+1
			dati1(kl)=(data(j).and.255)
			dati1(kl)=dati1(kl).and.63

			write(30,*)dati1(kl)

			kl=kl+1
		end do
		end if

	   end do

       	   ilm=ilm+isubset
	   write(20,*)'           '
	   close(30)

	end do
9999	continue        


16	format('File name          ------>',a50)  
18	format('Start_time         ------>',f13.7,' sec')
19	format('Sequence code      ------>',i3)
21	format('GRB_Counter (bit 4)------>',i3)
22	format('GRB_Counter (bit 5)------>',i3)

	close(10)
	close(20)

9998	continue
	end do
	
	write(*,*)'valore ultimo indice di sequenza letto V'
	write(*,*)sequence
	
	call totale(b,path,file1)
	end do
	end


	subroutine totale(b,path,file1)

	character*100 file,logfile,totfile,outfile
	character b*1,c*1,app*10,app1*13
	integer*4 itot
	real*8 stime1(20),stime2(20),stime3(20),stime0(20),stimet(200)
	integer*2 data2(20480),ntrigger(20),lollo
	real*4 tot_data(32768),data2_new(20000)
	real*8 tempi(200)
	character a1*1,a2*1,a3*1,stringa*50,path*50,file1*50


c  Read start_time and number of trigger from log file

	jlm1=0
	jlm2=0
	jlm3=0


	do i=1,3
	  write(c,23)i

	  file=path(1:index(path,' ')-1)//'/'//
     1         file1(1:index(file1,' ')-1)//'.P'//
     1         b//'GRB00'//c

          logfile=file(1:index(file,' ')-1)//'.log'
          open(30,name=logfile,status='old',form='formatted')
	  read(30,34)stringa
	  read(30,36)ntrigger(i)

          do lll=1,1000
               read(30,34,err=8000)stringa
               app=stringa(1:index(stringa,'-')-9)

               if(app.eq.'Start_time')then

		 if(i.eq.1)then
                     jlm1=jlm1+1
                     app1=stringa(27:index(stringa,'c')-4)
                     read(app1,35)stime1(jlm1)

		 else if(i.eq.2)then
		     jlm2=jlm2+1
		     app1=stringa(27:index(stringa,'c')-4)
		     read(app1,35)stime2(jlm2)

		 else if (i.eq.3)then
			
		      jlm3=jlm3+1
		      app1=stringa(27:index(stringa,'c')-4)
		      read(app1,35)stime3(jlm3)

		  end if

	       end if

	   end do
8000       continue
           close(30)

34         format(a)
35         format(f13.7)
36	   format(t29,i3)

	end do


c  Start_time array (stimet) creation

	jlmt=jlm1+jlm2+jlm3
	

	do i=1,jlm1
		stimet(i)=stime1(i)
	end do

	do i=1,jlm2
		stimet(i+jlm1)=stime2(i)
	end do
	
	do i=1,jlm3
		stimet(i+jlm2+jlm1)=stime3(i)
	end do


	call ordina(stimet,jlmt,0,tempi)


	if(jlm1.eq.jlm2.and.jlm2.eq.jlm3)then
		if(stime1(1).eq.tempi(1))then
			nset=jlm1
			lillo1=0
			lillo2=0
			lillo3=0
			goto 5000
		end if
	end if


	if(stime1(1).eq.tempi(1))then

		nset=min(jlm1,jlm2,jlm3)
		lillo1=0
		lillo2=0
		lillo3=0
		goto 5000
	else

		do i=1,jlmt
			if(stime1(1).eq.tempi(i))then
			inizio=i
			end if
		end do
	end if

	idiff=jlmt-inizio+1

	intero=idiff/3

	iscarto=inizio-1

	lillo2=0
	do j=1,jlm2
		do i=1,iscarto
			if(stime2(j).eq.tempi(i))then
				lillo2=lillo2+1
			end if
		end do
	end do



	lillo3=0
	do j=1,jlm3
		do i=1,iscarto
			if(stime3(j).eq.tempi(i))then
				lillo3=lillo3+1
			end if
		end do
	end do

c  Total file creation

	nset=intero
	lillo1=0
	
23	format(i1)
5000	continue	

	if(nset.eq.0)goto 5001	

	do i=1,nset

		stime0(i)=stime1(i)
		write(a1,23)lillo1+i
		write(a2,23)lillo2+i
		write(a3,23)lillo3+i	

		itot=0

		do k=1,3

		  write(c,23)k

		  file=path(1:index(path,' ')-1)//'/'//
     1                 file1(1:index(file1,' ')-1)//'.P'
     1                 //b//'GRB00'//c

		  if(k.eq.1)then
		    outfile=file(1:index(file,' ')-1)//'_'//a1//'.out'
		    open(10,name=outfile,status='old',form='formatted')
		    
		    do jlm=1,21000
			itot=itot+1
			tot_data(itot)=0.
			cts=0
			read(10,*,err=2000)cts
			tot_data(itot)=cts
		    end do
		
2000		    continue 
		    close(10)
		    itot=itot-1
		    if(itot.ne.1024)then
		 	do jlm=itot+1,1024
				tot_data(jlm)=0.	
			end do	
		    	itot=1024
		    end if


	           end if


		  if(k.eq.2)then
		    outfile=file(1:index(file,' ')-1)//'_'//a2//'.out'
		    open(10,name=outfile,status='old',form='formatted')
		    itot1=0 
		    do jlm=1,21000
                        itot1=itot1+1
		        cts=0
			data2(itot1)=0
                        read(10,*,err=2001)cts
                        data2(itot1)=cts
                    end do
2001		    close(10)
                    itot1=itot1-1
		    call rican(itot1,data2,lollo,data2_new)
		    do jlm=1,lollo
			tot_data(itot+jlm)=0.
			tot_data(itot+jlm)=data2_new(jlm)
		    end do
		    itot=itot+lollo 
		    if(lollo.ne.1280)then
		    	do jlm=itot+lollo+1,1280
				tot_data(jlm)=0.
		    	end do
		        itot=1024+1280
		    end if
		  end if


		  if(k.eq.3)then
		   outfile=file(1:index(file,' ')-1)//'_'//a3//'.out'
		   open(10,name=outfile,status='old',form='formatted')
	
 		   do jlm=1,21000
			itot=itot+1
			tot_data(itot)=0.
			cts=0
			read(10,*,err=2002)cts
			tot_data(itot)=cts
		   end do
2002		   close(10)
		  end if

		end do

		itot=itot-1

		totfile=path(1:index(path,' ')-1)//'/'//
     1          file1(1:index(file1,' ')-1)//'.P'//
     1          b//'_'//a2//'.tot.out'

		open(99,name=totfile,status='unknown',form='formatted')

		do iii=1,itot
		 time_bin=stime0(i)+-8.+iii*0.0078125
                 write(99,400)time_bin,tot_data(iii),sqrt(tot_data(iii))
		end do

               close(99)
400    	       format(1x,f11.5,3x,f6.2,3x,f10.5)
	end do
5001	continue
	return
	end


c
	subroutine ordina(vect,n,intero,vect1)

c	Ordina il vettore vect :
c	1) se INTERO = 1 in modo decrescente
c	2) se INTERO e' diverso da 1 in modo crescente


	real*8 vect(n),vect1(n),a,b

	if(intero.eq.1)then

	do k=1,n
		ilm=k+1
		do i=n,ilm,-1
			if(vect(i).gt.vect(i-1))then
				a=vect(i)
				b=vect(i-1)
				vect(i)=b
				vect(i-1)=a
			end if
		end do
	end do

	else 


        do k=1,n
                ilm=k+1
                do i=n,ilm,-1
                        if(vect(i).lt.vect(i-1))then
                                a=vect(i)
                                b=vect(i-1)
                                vect(i)=b
                                vect(i-1)=a
                        end if
                end do
        end do

	end if

	do i=1,n
		vect1(i)=vect(i)
	end do

	return
	end

	subroutine rican(canali_old,count,hbin,new)

	integer*2 count(30000),hbin,canali_old
	real*4 new(3000),intervallo,intervallo_old

	parameter (intervallo=1/128.)
	


	intervallo_old=1/2048.

c	definizione numero di bin
	tbin=(intervallo_old*canali_old)/intervallo
	hbin=tbin

	if((tbin-hbin).ne.0.)hbin=hbin+1	
c	inizio ciclo di calcolo
	do j=1,hbin
		t1=(j-1)*intervallo
		t2=(j)*intervallo
	
		ch1=t1/intervallo_old
		ch2=t2/intervallo_old

		ich1=ch1+1
		ich2=ch2
			


		fraz1=ich1-ch1
		fraz2=ich2-ch2

		new(j)=fraz1*count(ich1)+fraz2*count(ich2+1)

		if (((ich2+1)-ich1).gt.1.)then
			do k=ich1+1,ich2
			   new(j)=new(j)+count(k)
			end do
		
		end if

	end do



	return
	end


