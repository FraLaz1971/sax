;-------------------------------------------------------------------------------
;Oggetto GRBMhandler
;Gestisce i dati del GRBM
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;1).Create the object
;-------------------------------------------------------------------------------	
		;********************************************
		;**** metodo per inizializzare l'oggetto ****
		;********************************************

		      function GRBMhandGraf::Init
		      
		      self.lista = OBJ_NEW('OPlist', 10)

			;**** caricamento dati **** 
     		             	      
		      self -> loadAll
		      self.interface = OBJ_NEW('GGinterface', self)
		      print, 'oggetto GRBMhandGraf inizializzato'  

           ; **** STRUMENTO A REGIME : SI ENTRA NELLA ROUTINE PRINCIPALE ****

		      self -> main
		        return, 1  ;**** restituisce true se l'inizializzazione ha avuto successo		      
                      end
;-------------------------------------------------------------------------------
;2).Create Cleanup method
;-------------------------------------------------------------------------------	
		;****************************************
		;**** metodo per terminare l'oggetto ****
		;****************************************

                     pro GRBMhandGraf::Cleanup
                     	;self->Strumhandler::cleanup

		     	OBJ_DESTROY, self.lista
			OBJ_DESTROY, self.interface
		     	OBJ_DESTROY, self
		     	print, 'GRBMhandGraf distrutto' 	
                     end
;-------------------------------------------------------------------------------
;3).Create various methods for the object

;-------------------------------------------------------------------------------
		;*****************************************************
		;**** metodo che sceglie gli OP da caricare   	  ****
		;**** e carica i dati di ogni singolo OP          ****
		;*****************************************************
;-------------------------------------------------------------------------------
	pro GRBMhandGraf::loadAll
  	  close, 6
  	  openr, 6, 'OP_ordinati.txt' ; si apre il file che contiene la lista di OP presenti
  	  op_index = ''
  	  while (NOT EOF(6)) do begin
	    readf, 6, op_index
            print, 'loading data OP_', op_index
	    self -> saveopdata, op_index	
          endwhile
  	  close, 6
	  self -> datiOP
	end		
;-------------------------------------------------------------------------------


		;*******************************************
		;**** 	  metodo che carica i dati 	****
		;**** 	     relativi ad un OP		****
		;******************************************* 

		    ;  pro GRBMhandGraf::loadOP, op_id			
                    ;    self -> saveopdata, op_id			
                    ; end 

;-------------------------------------------------------------------------------
		;************************************************
		;**** metodo che salva il tempo di trigger   ****
		;************************************************
                   
		   pro GRBMhandGraf::saveopdata, opindex		  
		      shell, opindex; **** estrae, fitta, converte e salva ****
		      obs = ''
		      close, 3
                      openr, 3, 'Observations.txt'
		     	 while (NOT EOF(3)) do begin
			 readf, 3, obs	; **** riferimento all'osservazione corrente
			 restore, 'TimeResult'+obs+'.dat' ; **** legge **** 
			  self.lista -> saveopdata, opindex, obs, newtime_UTC 
		      	  print, 'opindex = ', opindex 
			  endwhile
			  ;spawn, 'rm *.dat'
		      close, 3
		   end   
                   
;-------------------------------------------------------------------------------


;------------------------------------------------------------------------------
                
		;******************************************
		;**** metodo per aggiornare l'archivio ****
		;******************************************     
		      
		      pro GRBMhandGraf::Aggiorna
	                print, 'Updating archive ...'			
                      end
;-------------------------------------------------------------------------------		
		;*******************************************
		;**** 	  metodo che restituisce 	****
		;**** informazioni sulla copertura	****
		;*******************************************

                      pro GRBMhandGraf::coverage
			cover = self.lista -> coverage()
			print
                        print, 'copertura in archivio = ', cover
			print, 'ore/min/sec = ', converti(cover)
			print
                      end

;-------------------------------------------------------------------------------
		pro GRBMhandGraf::writelist
                    print, 'GRBMhandGraf : showing OP list'
		    self.lista -> writelist	
                end
;-------------------------------------------------------------------------------
		;********************************************
		;**** 	  metodo che restituisce 	 ****
		;**** informazioni sull' OP in questione ****
		;********************************************

                      pro GRBMhandGraf::writeOP, op_id
                        self.lista -> WriteOP, op_id
                      end

		
;-------------------------------------------------------------------------------		
		;*******************************************
		;**** 	  metodo che restituisce 	****
		;**** informazioni sulla copertura	****
		;*******************************************

                      ;function GRBMhandGraf::Analizza
		      	;b = 0B
                      	;print, 'accetto richieste di analisi dati'
                      	;return, b
                      ;end
;-------------------------------------------------------------------------------
;metodo che attiva lo strumento a regime
;-------------------------------------------------------------------------------

	pro GRBMhandGraf::main
   	  print, 'procedura main'
   	  self.interface -> Enable; attiva l'interfaccia
	  self.interface -> GRBMinterface ;, self
        end
;-------------------------------------------------------------------------------
;metodo che carica dati relativi all'OP (durata, presenza, accensione, ...)
;-------------------------------------------------------------------------------

	pro GRBMhandGraf::datiop
   	;**********************************
	;****** procedura che calcola *****
	;******	 le durate degli OP   *****
	;**********************************

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
	while (cur LE (lun-1)) AND (NOT EOF(1)) do begin  ;W1 *** ciclo su gli archivi da confrontare
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


	  cur = cur + 1                           ; incrementa il cursore all'indice dell' archivio remoto
	
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
; trasferisce i dati nei campi del relativo OP
;-------------------------------------------------------------------------------

	pro GRBMhandGraf::transfer, dati	  
	  ;print, 'sto trasferendo la durh = ', dati.durh
	  ;print, 'per l''OP ', dati.op_id
	  self.lista -> transfer, dati	   	     	  
        end

;-------------------------------------------------------------------------------
;4.Define the object
;-------------------------------------------------------------------------------
                      pro GRBMhandGraf__Define
                           struct={GRBMhandGraf,$
                           ;inherits Strumhandler,$
			   interface:OBJ_NEW(),$
                           lista:OBJ_NEW() $
                           ;...
                            $
				 }
                      end
