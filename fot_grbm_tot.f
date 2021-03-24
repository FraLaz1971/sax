c	Programma di lettura fot GRBM by M.N. Cinti
c	release   January 1997
c





	character path*50,on*3,nome*100,b*1,c*1




	write(*,*)'Path name (format~/*:'
	read(*,'(a)')path

	write(*,*)'Observation number (000):'
	read(*,'(a)')on

	do imi=1,4
		write(b,23)imi
		do kil=1,3
		  write(c,23)kil

		  nome=path(1:index(path,' ')-1)//'/npd'//
     1               on//'.p'//b//'grb00'//c 

		  call crea_log(nome)
		  call leggi (nome)
		end do

		call totale(b,path,on)
	end do



23	format(i1)
	end






	subroutine crea_log(file)


	integer*2 number_vect(1000)	
	character*2 id_vect(1000)    

	integer*2 number,nnum
	character file*100,logfile*100
	byte source,type,seq,reg,count
	character id*2  	
	character*1028 record,record1
     
	integer*2 start_time(2),d(2)
        integer*4 time
        parameter ftime=2.D0**-16
        real*8 startime




c	Definizione primo record


	equivalence(record(1:1),number)
	equivalence(record(3:3),id)

c	Definizione secondo record

	equivalence(record1(1:1),number)  
	equivalence(record1(3:3),id)
	equivalence(record1(5:5),start_time(1))   
	equivalence(record1(9:9),nnum)     
	equivalence(record1(11:11),source)   
	equivalence(record1(12:12),type)
	equivalence(record1(13:13),seq)
	equivalence(record1(14:14),reg)
	equivalence(record1(15:15),count)



	equivalence(d(1),time)

	inde=0

	logfile=file(1:index(file,' ')-1)//'.log'


10	format(a)

	open(10,name=file,status='old',form='unformatted',
     1	access='direct',err=4000,recl=257)
	open(20,name=logfile,status='unknown',form='formatted')

	time=0.0


	write(*,*)logfile

	irect=0
	do i=1,10000
		irect=irect+1	
		read(10,rec=irect,err=99)record
		number_vect(i)=number
		id_vect(i)=id


	end do
99	continue


	nrecord=irect-1

	nset=number_vect(nrecord)

	write(20,12)file
	write(20,13)nrecord
13	format('Numero  record Totali  -->',i3)	
	write(20,15)nset
15	format('Numero set da n record -->',i3)
	write(20,*)'     '

	idf=0

	do j=1,nset
		do i=1,nrecord
			if(number_vect(i).eq.j)then

         		 if (id_vect(i).eq.'SH') then
                              read(10,rec=i)record1
			      d(1)=start_time(1)
			      d(2)=start_time(2)
c			      time=start_time(1)+start_time(2)*65536.

                              if(time.ge.0.) then
                                     startime=time*ftime
                                    else
                                     startime=(time+2.**32)*ftime
                              end if


		              write(20,17)number_vect(i)
		   	      write(20,18)startime
			      write(20,22)type 
		              write(20,19)source
		              write(20,20)nnum
		              write(20,21)seq

			else if(id_vect(i).eq.'DF')then
 			     idf=idf+1
		
		 	end if
		      end if
		end do

                write(20,16)idf
                idf=0
		write(20,*)'            '
	end do

12	format('File name           ----->',a50)
16      format('Numero record dati (DF) ->',i3)
17	format('Packet Number       ----->',i3)	
18	format('Start_time ( sec.) ------>',f13.7)
19	format('Lateral shield     ------>',i3)
20	format('Number valid Counters --->',i5)
21	format('Sequential Identifier --->',i3)
22	format('Type Identifier       --->',i3)
	close(10)
	close(20)

4000	return
	
	end	





	subroutine leggi(file)


	integer*2 dati(512),type(20),ndf(20)    
	character*60 outfile,logfile,stringa
	character*1028 record1,record2
    	character a*1,id*2,file*100 
	byte dati1(1024)

c	definizione record tipo 001 e 003

	equivalence(record2(1:1),number)  
	equivalence(record2(3:3),id)
	equivalence(record2(5:5),dati(1))

c	definizione record tipo 002	

        equivalence(record1(1:1),number)
        equivalence(record1(3:3),id)
        equivalence(record1(5:5),dati1(1))
	
	logfile=file(1:index(file,' ' )-1)//'.log'


	open(10,name=file,status='old',form='unformatted',
     1	access='direct',err=7500,recl=257)

	open(30,name=logfile,status='unknown')

        read(30,20)stringa
	read(30,20)stringa
	read(30,10)nsetrecord
10	format(t27,i3)

	do i=1,nsetrecord    
		read(30,20)stringa
                read(30,20)stringa
                read(30,20)stringa
       		read(30,10)type(i)
	        read(30,20)stringa
                read(30,20)stringa
                read(30,20)stringa
		read(30,10)ndf(i)
	end do

	close(30)

20	format(a35)

c	Salto i primi due record

	irect=2

c	Inizio lettura dati

	do i=1,nsetrecord

	      write(a,24)i
24            format(i1)


		if(type(i).eq.1)then



		  if(ndf(i).eq.0)goto 30		 
                  outfile=file(1:index(file,' ' )-1)//'_'//a//'.out'

              open(20,name=outfile,status='unknown',form='formatted')


		  do j=1,ndf(i)	
		      irect=irect+1
		      read(10,rec=irect,err=30)record2
	              do k=1,512

c	Maschera i dati a 9 bit

			dati(k)=dati(k).and.511
			write(20,*)dati(k)
		      end do		
	           end do
		end if

		if(type(i).eq.2)then
		   if(ndf(i).eq.0)goto 30
                   outfile=file(1:index(file,' ' )-1)//'_'//a//'.out'

              open(20,name=outfile,status='unknown',form='formatted')

                   do j=1,ndf(i)
                      irect=irect+1
                      read(10,rec=irect,err=30)record1
	              do k=1,1024

c	Maschera i dati a 6 bit

			dati1(k)=dati1(k).and.63
			write(20,*)dati1(k)
		      end do			
                   end do		
		end if

		if(type(i).eq.3)then
		   if(ndf(i).eq.0)goto30
		   outfile=file(1:index(file,' ' )-1)//'_'//a//'.out'
	     open(20,name=outfile,status='unknown',form='formatted')

		  do j=1,ndf(i)
		     irect=irect+1
		     read(10,rec=irect,err=30)record2
		     do k=1,512

c	Maschera i dati a 10 bit

			dati(k)=dati(k).and.1023
                        write(20,*)dati(k)
		     end do
		  end do
		end if

		irect=irect+2

		close(20)

	end do

30	continue
	close(10)

7500	return
	end	

	subroutine totale(b,path,on)

	character*100 file,logfile,totfile,outfile
	character b*1,c*1,app*10,app1*13
	integer*4 itot
	real*8 stime1(20),stime2(20),stime3(20),stime0(20),stimet(200)
	integer*2 data2(20480),ntrigger(20),lollo
	real*4 tot_data(32768),data2_new(20000)
	real*8 tempi(200)
	character a1*1,a2*1,a3*1,stringa*50,path*50,on*3


c  Read start_time and number of trigger from log file

	jlm1=0
	jlm2=0
	jlm3=0


	do i=1,3
	  write(c,23)i

	  file=path(1:index(path,' ')-1)//'/npd'//
     1         on//'.p'//
     1         b//'grb00'//c

          logfile=file(1:index(file,' ')-1)//'.log'
          open(30,name=logfile,status='old',form='formatted',err=6000)
	  read(30,34)stringa
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

		  file=path(1:index(path,' ')-1)//'/npd'//
     1                 on//'.p'
     1                 //b//'grb00'//c

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

		totfile=path(1:index(path,' ')-1)//'/npd'//
     1          on//'.p'//
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

6000	return
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


