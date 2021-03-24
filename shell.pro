		; **************************************************
		; **** procedura che esegue istruzioni di shell ****
		; **** 	  scritte nel file istruzioni.txt	****
		; **************************************************


		; **************************************************
		; ****	      estrae il tempo di trigger	****
		; **************************************************

pro shell, directory

path1 = './op_'+directory+'/'

		  ;**** decomprime i file utilizzati da calGRBMtime ****  

spawn, 'gunzip '+path1+'saxfot.obt_utc'
spawn, 'gunzip '+path1+'pd.instdir'


		; **** copia i files nella directory radice  ****

spawn, 'cp '+path1+'saxfot.obt_utc .'
spawn, 'cp '+path1+'pd.instdir .'

                   ;**** determina la lista dei file delle osservazioni **** 
		   	  ;**** e la salva in un file ****         

spawn, 'ls '+path1+'npd*p1grb001.gz > '+path1+'trigfiles.txt'


		    			   
		       ; **** per ogni osservazione      	****
		       ; **** estrai  numero dei burst	 	****
		       ; **** ed  istanti di trigger	 	****
		       ; **** salva i numeri delle osservazioni ****

close, 9, 12
openr, 9, path1+'trigfiles.txt'
openw, 12,path1+'Observations.txt'; contiene l'elenco dei numeri di osservazione
file = ''
obs = ''
					;./opObservations.txt_10861/npd004.p1grb001.gz
while (not EOF(9)) do begin
  readf, 9, file
  			
  b = 0b
  			;a = STRPOS(file,'op_')
  b = STRPOS(file,'/', 5)	
  file = STRMID(file, b+1, 15)
  obs =  STRMID(file, 3, 3 )
  printf, 12, obs
  print, 'unzipping file ', file
  spawn, 'gunzip '+path1+file 
  spawn, 'calGRBMtime '+path1+file+' > '+path1+'iniTimes'+obs+'.txt'
  print, 'calGRBMtime '+file+' > '+path1+'iniTimes'+obs+'.txt'

  

  strigger, directory, obs ; **** calcola istante di trigger per l'osservazione ****
			  ; ****    <obs> contenuta nell'OP con <directory>    ****
  

  ;trigger, directory, obs ; **** calcola istante di trigger per l'osservazione ****
			  ; ****    <obs> contenuta nell'OP con <directory>    ****
  			  
  b = 0b	
  file = ''
  obs = ''	   
endwhile


close, 9, 12
			;*****************************************
			;**** per ogni osservazione           ****
			;**** salva i tempi di trigger        ****
			;**** relativi all'osservazione <xxx> ****
			;**** nei file iniTimes<xxx>.txt      ****
			;*****************************************


;-------------------------------------------------------------------------------

		;**** ristabilisce le condizioni iniziali ****

spawn, 'gzip '+path1+'saxfot.obt_utc'
spawn, 'gzip '+path1+'pd.instdir'
spawn, 'gzip '+path1+'*.p1grb001'
spawn, 'rm saxfot.obt_utc pd.instdir'

			    ;**** mostra il risultato ****

end
