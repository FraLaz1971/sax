;-------------------------------------------------------------------------------
;Oggetto GRBMhandler
;Gestisce i dati del GRBM
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;1).Create the object
;-------------------------------------------------------------------------------	

		      function GRBMhandler::Init
		        spawn, 'rm GRBM_han.log'
			;spawn, 'script1'
		        self.lista = OBJ_NEW('OPlist', 100)
			self -> default
			;**** caricamento dati **** 
     		             	      
		        self -> loadAll
			self.lista -> CountOPs
			;self -> analyseAll
		        self.interface = OBJ_NEW('Ginterface', self)
		        print, 'oggetto GRBMhandler inizializzato'  

           ; **** STRUMENTO A REGIME : SI ENTRA NELLA ROUTINE PRINCIPALE ****

		        self -> main
		          return, 1  ;**** restituisce true se l'inizializzazione ha avuto successo		      
                      end
;-------------------------------------------------------------------------------
;2).Create Cleanup method
;-------------------------------------------------------------------------------	

                     pro GRBMhandler::Cleanup
                     	;self->Strumhandler::cleanup

		     	OBJ_DESTROY, self.lista
			OBJ_DESTROY, self.interface
		     	OBJ_DESTROY, self
		     	print, 'GRBMhandler distrutto' 	
                     end

;-------------------------------------------------------------------------------
		;**** metodo che sceglie gli OP da caricare   	  ****
		;**** e carica i dati di ogni singolo OP          ****
;-------------------------------------------------------------------------------

	pro GRBMhandler::loadAll
  	  close, 6
  	  openr, 6, './OP_ordinati.txt' ; si apre il file che contiene la lista di OP presenti
  	  op_index = ''
  	  while (NOT EOF(6)) do begin
	    readf, 6, op_index
            print, 'loading data OP_', op_index
	      print, 'salvo dati per OP '+op_index
	      self -> saveopdata, op_index	
          endwhile
  	  close, 6
	  self -> datiOP
	end		

;-------------------------------------------------------------------------------
		;**** metodo che salva il tempo di trigger 		****
		;**** per ogni burst contenuto in tutte le osservazioni ****
		;**** conntenute all'interno dell'OP      	        ****
;-------------------------------------------------------------------------------
		
		  pro GRBMhandler::saveopdata, opindex		  
		      close, 16
		      pntrgs = 1b
		      openw, 16, 'logburst.txt'
		      shell, opindex; **** estrae, fitta, converte e salva ****
		      path4 = './op_'+opindex+'/'
		       			   
		      obs = ''    ; stringa che identifica il n. dell'osservazione		       
		      close, 3
                      openr, 3, path4+'Observations.txt'
		     	 while (NOT EOF(3)) do begin
			   readf, 3, obs	; **** riferimento all'osservazione corrente
			   restore, path4+'TrigNum'+obs+'.dat'; recupera il n. di burst contenuti
						 ; nell'osservazione
			   printf, 16, 'numero di trigs in '+obs+' = ', pntrgs
			   count = 0b
			   while (count LT pntrgs) do begin
			     restore, path4+'TimeResult'+obs+'_'+'.dat' ; **** legge ****
			     self.lista -> saveopdata, opindex, obs, oldtimes[count]		      	   
			    ;self.lista -> saveopdata, opindex, obs, newtime_UTC
			     count = count + 1
			   endwhile 
		      	   
			   printf, 16, 'opindex = ', opindex 
			   endwhile
			   spawn, 'rm '+path4+'*.dat'
			   ;spawn, 'rm '+path4+'*.log'
			   ;spawn, 'rm '+path4+'*.txt'
			   spawn, 'rm ./*.dat'
		      close, 3, 16
		   end   
                   
;-------------------------------------------------------------------------------
		;**** metodo per aggiornare l'archivio ****
;------------------------------------------------------------------------------             
		      
		      pro GRBMhandler::Aggiorna
	                print, 'Aggiornamento archivio ...'			
                      end

;-------------------------------------------------------------------------------		
		;**** 	  metodo che restituisce 	****
		;**** informazioni sulla copertura	****
;-------------------------------------------------------------------------------		

                      pro GRBMhandler::coverage
			cover = self.lista -> coverage()
			print
                        print, 'copertura in archivio = ', cover, ' sec'
			print, 'ore/min/sec = ', converti(cover)
			print
                      end

;-------------------------------------------------------------------------------
; METODO CHE MOSTRA LA LISTA DI OP 
;-------------------------------------------------------------------------------

		      pro GRBMhandler::writelist
                    	 print, 'GRBMhandler : mostro la lista di OP '
		         self.lista -> writelist	
                      end

;-------------------------------------------------------------------------------
; METODO CHE MOSTRA IL CONTENUTO DI UN DETERMINATO OP DELLA LISTA
;-------------------------------------------------------------------------------

                      pro GRBMhandler::writeallOP
                         self.lista -> writeallOP
                      end

;-------------------------------------------------------------------------------
; METODO CHE MOSTRA IL CONTENUTO DI TUTTI GLI OP DELLA LISTA
;-------------------------------------------------------------------------------
		      
		      pro GRBMhandler::writeOP, op_id
                         self.lista -> WriteOP, op_id
                      end

;-------------------------------------------------------------------------------
;	metodo che seleziona OP e osservazione 
;-------------------------------------------------------------------------------

                      pro GRBMhandler::select, op_id, ob_s
                         self.lista -> op_id, ob_s
                      end
		
;-------------------------------------------------------------------------------
;	OPERAZIONI DI DEFAULT
;-------------------------------------------------------------------------------

                      pro GRBMhandler::default
                        close, 17 
	                openw, 17, 'AcTrig.txt'	              	
	                printf, 17, 0b
	                close, 17 
                      end
;-------------------------------------------------------------------------------
;	METODO CHE ANALIZZA TUTTI I BURST IN ARCHIVIO	
;-------------------------------------------------------------------------------		

	pro GRBMhandler::analyseAll
  	   close, 6
	  ;close, 33 
	  ;openw, 33, 'GRBM_han.log'	; FILE DI LOG GENERALE
	
  	  openr, 6, 'OP_ordinati.txt' ; si apre il file che contiene la lista di OP presenti
  	  op_index = ''
	  obs_num = ''
  	  while (NOT EOF(6)) do begin	 ; ciclo sugli OP in archivio
	    readf, 6, op_index
            print, 'Accesso alle osservazioni nell''OP ', op_index
	      close, 55
	      openr, 55, './op_'+op_index+'/Observations.txt'
	      while (NOT EOF(55)) do begin ; ciclo sulle osservazioni
	        readf, 55, obs_num  			
	        self -> select, op_index, obs_num    ; seleziona OP e obs.
		self -> cleanOP2		     ; pulisci il contenuto della directory
	        self -> analizza		     ; analizza i dati selezionati		
	      endwhile
	      close, 55		
          endwhile
  	  close, 6
	  close, 33
	end		

;-------------------------------------------------------------------------------
;	metodo che attiva lo strumento a regime
;-------------------------------------------------------------------------------

		pro GRBMhandler::main
   		  print, 'procedura main'
		  self -> countburst
		  ;self -> AnalyseAll
		  self -> risultati
   	  	  self.interface -> Enable; attiva l'interfaccia
        	end

;-------------------------------------------------------------------------------
;	metodo che carica dati relativi all'OP 
;	(durata, presenza, accensione strumento, ...)
;-------------------------------------------------------------------------------

pro GRBMhandler::datiop

		;****** procedura che calcola *****
		;******	 le durate degli OP   *****

close, 1       
close, 2
close, 3


; **** dichiarazione costanti e variabili ****

oldpos = 0
gi = 0			; giorno di inizio op
gf = 0		 	; giorno di fine op
tempi1  = ulonarr(3)
str_comp = ''    	; stringa per il confronto
leva = ''	 	; supporto per togliere la prima riga 	
mezzanotte = 0b  	; flag sul caso a cavallo della mezzanotte
off1 = 0ull      	; offset per il caso a cavallo della mezzanotte
off2 = 0ull		; offset per il caso maggiore di 24 ore
b = '     '      	; variabile supporto per l'op_id
c = 0
sup1 = 0ull             ; variabile di supporto
chi = 0                 ; variabile supporto per le ore    (inizio)
cmi = 0b       		; variabile supporto per i minuti  (inizio)
csi = 0b       		; variabile supporto per i secondi (inizio)
chf = 0        		; variabile supporto per le ore    (fine)
cmf = 0b       		; variabile supporto per i minuti  (fine)
csf = 0b       		; variabile supporto per i secondi (fine)
op_loc = ''    		; variabile supporto per gli op sull'archivio locale
ecc_loc = ''   		; gestisce una stringa eccezione nell'archivio locale 
totsf = 0ull   		; ora di fine in secondi	
totsi = 0ull   		; ora di inizio in secondi
durtotsec  = 0ull	; variabile supporto per la durata in secondi
durtotsec2  = 0.0	; variabile supporto per la durata in secondi
cur = 0l                ; cursore sull'archivio remoto
cur2 = 0l		; cursore sull'archivio locale
tot_loc = 0		; tempo copertura grbm in archivio locale			
tot_rem = 0		; tempo di copertura grbm
b = string(b)           ; variabile supporto per l'identificativo di op
c = long(c)             ;
totale = 0l		; variabile che contiene il totale in secondi di copertura
pos = 0l                ; variabile che contiene la posizione del puntatore 
			; alla posizione corrente nel file letto
inf3 = 0                ; informazioni sul file 3							
si = '         si'      ; stringa vera
no = '         no'      ; stringa falsa
cond1 = 0b              ; condizione su op da contare
cond2 = 0b              ; condizione su op da contare

			; *********************************				
			; *** si definisce una cartella ***
			; ***      dell'archivio        ***
                        ; *********************************

op = create_struct('tempass', 0ul, 'op_id', '', 'durh', 0, 'durm', 0 , 'durs', 0,'grbm_on', '', 'presente', '', 'copertura', 0ul, 'duration', 0ul)  
											

;lun = 9409                         ; *** numero di op da analizzare                                           
lun = 50
archivio = replicate (op, lun)      ; *** definisce la struttura archivio
 


openr, 1, 'nfilist2.txt'                 ; *** si apre il primo   file di input: gli op in archivio remoto
openr, 3, 'OP_ordinati.txt'              ; *** si apre il secondo file di input: gli op in archivio locale
openw, 2, 'risultati1.txt'               ; *** si apre il file di output

printf, 2, '        tempo  op-id     ore   minuti   secondi  grbm_on    presente  copertura'

  	readf, 1, $
	format = '(a1)', leva	; togli la prima linea
	cur = 0l
	cur2 =0l
	while (cur LE (lun-1))AND(NOT EOF(3)) AND (NOT EOF(1)) do begin  ;W1 *** ciclo su gli archivi da confrontare
		off1 = 0
		sup1 = 0ull
		durtotsec = 0ull
		durtotsec2 = 0ull
		archivio[cur].durh = 0ull
		chi = 0ull        
		cmi = 0ull      
		csi = 0ull       
		chf = 0ull
		cmf = 0ull       
		csf = 0ull      
		cond1 = 0b ; *** inizializzato il controllo se il tempo e' da sommare
		grbm_on = ''
		inf3 = fstat(3)
		readf, 1, $
		format = '((a5,T7,I2,T17,I2,T20,I2,T23,I2,T26,I2,T36,I2,T39,I2,T42,I2,T49,a1))', b, gi, chi, cmi, csi, gf, chf, cmf, csf,grbm_on
		oldpos = inf3.cur_ptr
		readf, 3, op_loc ; *** legge sul file di archivio locale
		print, 'leggo la stringa ', op_loc		
		print, 'op in archivio locale ', op_loc 
		print, 'op in archivio remoto ', b 
		
		inf3 = fstat(3)
		pos = inf3.cur_ptr
		if (ulong(op_loc) NE ulong(b)) then begin 
			point_lun, 3, oldpos ; *** resta a leggere sull'op corrente			  
			archivio[cur].presente = no		
		endif else begin
			print, 'OP presente in archivio locale'	
			archivio[cur].presente = si
		endelse
						
		
		archivio[cur].op_id = b	; *** salva l'identificatore di op
		
		;print, ' giorno di inizio ', gi
		;print, ' giorno di fine ', gf
		

		;*** calcola la durata totale in secondi ***
		
		if (chf LT chi)OR((gf-gi) NE 0) then begin 		; *** gestisce il caso "a cavallo della mezzanotte"
			mezzanotte = 1b
			off1 = 86400 - ((chi*3600) + (cmi*60) + csi)
			
			if ((gf-gi) GT 1) then begin
					printf, 2, 'op che dura oltre le 24 ore'
					print, 'op che dura oltre le 24 ore'
					off1 = off1 + (((gf - gi) - 1)*86400)     ; nel caso in cui l'op duri piu' di un giorno 
			endif
		        
			          
			chi = 0
			cmi = 0 
			csi = 0
		endif	else	begin 
			off1 = 0
		endelse
		
				
		
		
		totsf = (chf*3600) + (cmf*60) + csf
	 	totsi = (chi*3600) + (cmi*60) + csi
		durtotsec = totsf - totsi + off1	
		durtotsec2 = durtotsec		
 		
		tempi1 = converti(durtotsec) ; **** converti in ore/min/sec

	; **** salva la durata dell'OP ****	

		archivio[cur].durh = tempi1[0]
		archivio[cur].durm = tempi1[1]
		archivio[cur].durs = tempi1[2]
		archivio[cur].duration = durtotsec2
		
		
		; *** controllo sull'accensione strumento ***

		if (grbm_on EQ '0') then begin
 			archivio[cur].grbm_on = '       no' 
		endif else begin
			if (grbm_on EQ 'G') then begin
				archivio[cur].grbm_on = '       si'
			endif else begin
			 	archivio[cur].grbm_on = '    boh'
			endelse
		endelse
		
		; *** salva il tempo assoluto ***
		
		if (cur EQ 0) then begin
			archivio[cur].tempass = durtotsec2
		endif else begin
			archivio[cur].tempass = archivio[cur-1].tempass + durtotsec2
		endelse
		
		
		; *******************************************************
		; *** controllo sugli op presenti in archivio locale  ***
		; ***   calcolo della copertura in archivio locale    ***
		; ***            e di quella mancante		      ***
		; *******************************************************
	
		cond1 = ((archivio[cur].presente EQ si)AND(archivio[cur].grbm_on EQ si)) 
		cond2 = (archivio[cur].presente EQ si)
		
		if (cond2)then begin
			totale = totale + durtotsec2   
		endif	

		; *** salva la copertura parziale ***
		
		archivio[cur].copertura = totale	
                
		; *** stampa l'output su file e su schermo ***
		
		printf, 2, 'op n. ', cur + 1 
		;print, archivio[cur]
		printf, 2, archivio[cur]
		;print, ' tempo parziale copertura osservazione grbm ', converti(totale) 	                                         
		;printf, 2, 'tempo parziale copertura osservazione grbm', converti(totale)


          self -> transfer, archivio[cur]

	  cur = cur + 1       ; incrementa il cursore all'indice dell' archivio remoto
	
	  mezzanotte = 0b
				
	endwhile ;W1

	print, ''
	print, '*****                                *****'
	printf, 2, ''
	printf, 2, '*****                                *****'
	print, ' tempo totale copertura osservazione grbm ore/min/sec', converti(totale)      
	printf, 2, ' tempo totale copertura osservazione grbm ore/min/sec', converti(totale)	
		
	
	close, 1 
	close, 2
	close, 3

	;read,'aspetta',  b
	print, 'arrivederci e grazie'

end

;-------------------------------------------------------------------------------
; trasferisce i dati nei campi del relativo OP ;[]
;-------------------------------------------------------------------------------

	pro GRBMhandler::transfer, dati	  
	  ;print, 'sto trasferendo la durh = ', dati.durh
	  ;print, 'per l''OP ', dati.op_id
	  self.lista -> transfer, dati	   	     	  
        end

;-------------------------------------------------------------------------------
; METODO CHE SI SINCRONIZZA SU OSSERVAZIONE E OP CORRENTE
;-------------------------------------------------------------------------------

	function GRBMhandler::retrieve	 
	  close, 8, 9	
	  coord = STRARR(2)
	  tempstring1 = ''
	  tempstring2 = ''	
	  openr, 8,  'AcOP.txt'
	  readf, 8, tempstring1
	  close, 8	
	  openr, 9,  'nobs.txt'
	  readf, 9, tempstring2
	  close, 9			
	  print, 'OP corrente = ', tempstring1
	  print, 'osservazione corrente = ', tempstring2
          coord[0] = tempstring1
	  coord[1] = tempstring2
	  return, coord	   	     	  
        end

;-------------------------------------------------------------------------------
; legge le curve nel particolare OP
;-------------------------------------------------------------------------------

	pro GRBMhandler::analizza	  
	   actualobs = STRARR(2)
	   print, 'analizzo i dati ' 
	   actualobs = self -> retrieve() ; si sincronizza sui dati correnti
	   self -> unzip
	   self -> creacurve 		  ; crea le curve totali					   
	   tn = 0b		 	   
	   self -> SDI, 1b
	   close, 37 
	   openr, 37, 'Again.tem' ; legge il numero di trigger
	   readf, 37, tn
	   print, 'GRBMhandler' 
	   print, 'osservazione contenente ', tn, ' trigger'
	   at = 1b ; trigger analizzati 
	   while(at LT tn) do begin				  
	     self -> SDI, at + 1  		  ; lancia il programma di analisi 
	     at = at + 1    
	   endwhile	
	   print, 'terminati i trigger per l''oss ', actualobs[1]	 
	   self -> cleanOP	    	   	     	  
	   self -> zip
        end

;-------------------------------------------------------------------------------
; SALVA LE DURATE NEL DATABASE
;-------------------------------------------------------------------------------

	pro GRBMhandler::saveduration, tn	  	
	  restore, 'Dur_SDIres.dat'; recupera le durate e i flag
	  coord_9 = STRARR(2) ; conterra' OP_id e OBS_id
	  coord_9 = self -> retrieve()
	  path = 'op_'+coord_9[0]
	  obs = coord_9[1]
	  print, 'GRBMhandler :'
	  print, 'salvo le durate per OP '+coord_9[0]+' osservazione '+coord_9[1]
	  print, 'trigger n. ', tn
	  self.lista -> putduration, coord_9,tn , dur, trig	  	   
        end


;-------------------------------------------------------------------------------
; SALVA I PUNTEGGI DURATE NEL DATABASE
;-------------------------------------------------------------------------------

	pro GRBMhandler::savepoints, tn	  	
	  restore, 'Poi_SDIres.dat'; recupera le durate e i flag
	  coord_9 = STRARR(2) ; conterra' OP_id e OBS_id
	  coord_9 = self -> retrieve() ; SI SINCRONIZZA SU OP E OSSERVAZIONE
	  path = 'op_'+coord_9[0]
	  obs = coord_9[1]
	  print, 'GRBMhandler :'
	  print, 'salvo i punteggi per OP '+coord_9[0]+' osservazione '+coord_9[1]
	  print, 'trigger n. ', tn
	  self.lista -> putpoints, coord_9,tn , p, trig	  	   
        end
;-------------------------------------------------------------------------------
; richiama il programma SDI 
;-------------------------------------------------------------------------------

	pro GRBMhandler::SDI, tn	  	
	  print, 'programma SDI lanciato'	
	  spawn, 'idl SDIStartup'
	  self -> leggi
	  self -> saveduration, tn
	  self -> savepoints, tn	   
        end
;-------------------------------------------------------------------------------
; richiama il programma SDI manuale 
;-------------------------------------------------------------------------------

	pro GRBMhandler::SDIman, tn	  	
	  print, 'programma SDI manuale lanciato'	
	  spawn, 'idl SDImanStartup'	  	   
        end

;-------------------------------------------------------------------------------
; pulisci l'OP da i file di elaborazione 
;-------------------------------------------------------------------------------

	pro GRBMhandler::cleanOP	  	
	  ;print, 'cancello file di servizio'
          coord_9 = STRARR(2) ; conterra' OP_id e OBS_id
	  coord_9 = self -> retrieve()
	  path = 'op_'+coord_9[0]
	  obs = coord_9[1]	
	  spawn, 'rm  ./'+path+'/npd'+obs+'.p*grb*.log'
	  ;print, 'rm  ./'+path+'/npd'+obs+'.p*grb*.log'
	  spawn, 'rm  ./'+path+'/npd'+obs+'.p*.out'
	  ;print, 'rm  ./'+path+'/npd'+obs+'.p*.out'
	  spawn, 'rm  ./'+path+'/npd'+obs+'.p*.tot.out'
	  ;print, 'rm  ./'+path+'/npd'+obs+'.p*.tot.out'	   
        end
;-------------------------------------------------------------------------------
; pulisci l'OP anche da i file estranei 
;-------------------------------------------------------------------------------

	pro GRBMhandler::cleanOP2	  	
	  ;print, 'cancello file di servizio'
          coord_9 = STRARR(2) ; conterra' OP_id e OBS_id
	  coord_9 = self -> retrieve()
	  path = 'op_'+coord_9[0]
	  obs = coord_9[1]	
	  spawn, 'rm  ./'+path+'/npd*.p*grb*.log'	  
	  spawn, 'rm  ./'+path+'/npd*.p*.out'	  
	  spawn, 'rm  ./'+path+'/npd*.p*.tot.out'	  	   
        end
;-------------------------------------------------------------------------------
; CREA LE CURVE TOTALI 
;-------------------------------------------------------------------------------

	pro GRBMhandler::creacurve	  	
	  print, 'genera le curve totali'	
	  spawn, 'auto_fot_grbm_tot.exe'	   
        end

;-------------------------------------------------------------------------------
; CONTA GLI EVENTI DELLA CLASSE SGR
;-------------------------------------------------------------------------------

	pro GRBMhandler::findSGR	  	
	  self.lista -> findSGR   	   
        end

;-------------------------------------------------------------------------------
; ESTRAI GLI EVENTI ED EFFETTUA STATISTICHE
;-------------------------------------------------------------------------------

	pro GRBMhandler::risultati
	  self.lista -> resetStat
	  self.lista -> findNOspike
	  self.lista -> findSGR
	  numburst = self.lista -> getburstinlist()
	  numNOspike = self.lista -> getNOspikeinlist()
	  numSGR = self.lista -> getSGRinlist()
	  print
	  print, 'numero totale di trigger rilevati = ', numburst
	  print
	  print, 'numero totale di burst   rilevati = ', numNOspike
	  print
	  print, 'numero totale di SGR     rilevati = ', numSGR  
	  print   	   
        end

;-------------------------------------------------------------------------------
; CONTA I BURST PRESENTI NEL DATABASE A REGIME
;-------------------------------------------------------------------------------

	pro GRBMhandler::countburst	  		
	  numburst = self.lista -> countburst()
	  print
	  print, ' rilevati ',STRCOMPRESS(STRING(numburst)), ' burst nel database'
	  print	   
        end

;-------------------------------------------------------------------------------
; SELEZIONA OP E OSSERVAZIONE 
;-------------------------------------------------------------------------------

	pro GRBMhandler::select, opid, obs
	  ;print, 'mi sincronizzo su'	  
	  close, 8, 9	
	  coord = STRARR(2)
	  tempstring1 = ''
	  tempstring2 = ''	
	  openw, 8,  'AcOP.txt'
	  printf, 8, opid
	  close, 8	
	  openw, 9,  'nobs.txt'
	  printf, 9, obs
	  close, 9			
	  ;print, 'salvato OP corrente = ', opid
	  ;print, 'salvata osservazione selezionata = ', obs       	  	
        end


;-------------------------------------------------------------------------------
; LEGGI I DATI RELATIVI AD OSSERVAZIONE E OP SELEZIONATI
;-------------------------------------------------------------------------------

	pro GRBMhandler::leggi	  
	  close, 3
	  print, 'acquisisco risultati generati da SDI'
	  tempstring = ''	
	  openr, 3, 'SDIresult.txt'
	  while(NOT EOF(3)) do begin
	    readf, 3, tempstring
	    openu,1,'GRBM_han.log',APPEND=1
		printf,1,' '
		printf,1,tempstring
	    close,1
	    endwhile		  		
	  close, 3	  
        end


;-------------------------------------------------------------------------------
; METODO PER DECOMPRIMERE DATI NELL'OP CORRENTE
;-------------------------------------------------------------------------------

	pro GRBMhandler::unzip
	  coord_9 = STRARR(2)
	  coord_9 = self -> retrieve()	  	
	  print, 'decomprime dati nell''OP '+coord_9[0]+' osservazione '+coord_9[1]
	  spawn, 'gzip -d op_'+coord_9[0]+'/npd'+coord_9[1]+'.p*grb*.gz'	   
        end


;-------------------------------------------------------------------------------
; METODO PER COMPRIMERE DATI NELL'OP CORRENTE
;-------------------------------------------------------------------------------

	pro GRBMhandler::zip	  	
	  coord_9 = STRARR(2)
	  coord_9 = self -> retrieve()	  	
	  print, 'comprime dati nell''OP '+coord_9[0]+' osservazione '+coord_9[1]
	  spawn, 'gzip  op_'+coord_9[0]+'/npd'+coord_9[1]+'.p*grb*'	   
        end

	
;-------------------------------------------------------------------------------
;4.Define the object
;-------------------------------------------------------------------------------
                      pro GRBMhandler__Define
                           struct={GRBMhandler,	  $
                           ;inherits Strumhandler,$
			   interface:OBJ_NEW(),	  $
                           lista:OBJ_NEW() 	  $
                           ;...
                           			  $
				 }
                      end
