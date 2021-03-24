;**********************************
;****** programma che calcola *****
;******	 le durate degli OP   *****
;**********************************

close, 1       
close, 2
close, 3


; **** dichiarazione costanti e variabili ****


gi = 0			; giorno di inizio op
gf = 0		 	; giorno di fine op
tempi1  = ulonarr(3)
str_comp = ''    	; stringa per il confronto
leva = ''	 	; supporto per togliere ls prims riga 	
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

spawn, 'ls > archivio.txt'

				; *********************************				
				; *** si definisce una cartella ***
				; ***      dell'archivio        ***
	                        ; *********************************

op = create_struct('tempass', 0ul, 'op_id', '', 'durh', 0, 'durm', 0, 'durs', 0,'grbm_on', '', 'presente', '', 'copertura', 0ul)  
											

lun = 100                         ; *** numero di op da analizzare                                           
;lun = 9409
archivio = replicate (op, lun)     ; *** definisce la struttura archivio



;openr, 1, 'listaprova.txt'             ; *** si apre il primo   file di input: gli op in archivio remoto

openr, 1, 'nfilist2.txt'                 ; *** si apre il primo   file di input: gli op in archivio remoto

;openr, 3, 'archivioprova.txt'		; *** si apre il secondo file di input: gli op in archivio locale
openr, 3, 'archivio.txt'                ; *** si apre il secondo file di input: gli op in archivio locale
openw, 2, 'risultati1.txt'              ; *** si apre il file di output

printf, 2, '        tempo  op-id     ore   minuti   secondi   grbm_on     presente '
print,''
;print,     '       tempo  op-id     ore   minuti   secondi   grbm_on     presente '
;print,''
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
		
		readf, 1, $
		format = '((a5,T7,I2,T17,I2,T20,I2,T23,I2,T26,I2,T36,I2,T39,I2,T42,I2,T49,a1))',$
			 b, gi, chi, cmi, csi, gf, chf, cmf, csf, grbm_on
		
		readf, 3, $
		format = '((a7))', op_loc ; *** legge sul file di archivio locale
		
		op_loc = STRMID(op_loc, 3, 6)  ; *** estraggo l'identificatore di op dalla stringa letta
		                                               
		print, 'op in archivio locale', fix(op_loc)
		print, 'op in archivio remoto', fix(b)
		
		inf3 = fstat(3)
		pos = inf3.cur_ptr
		if (ulong(op_loc) NE ulong(b)) then begin 
			point_lun, 3, pos-8 ; *** resta a leggere sull'op corrente
			
			;if (ulong(op_loc) GT 4620) then begin
				;printf,2, 'ecco cosa leggo',  ulong(op_loc)
				;printf,2, ulong(b)
			;end
			  
			archivio[cur].presente = no		
		endif else begin
			;print, 'OP presente in archivio locale'	
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
		
		archivio[cur].durh = tempi1[0]
		archivio[cur].durm = tempi1[1]
		archivio[cur].durs = tempi1[2]

		
		
		; *** controllo sull'accensione strumento ***

		if (grbm_on EQ '0') then begin
 			archivio[cur].grbm_on = no 
		endif else begin
			archivio[cur].grbm_on = si
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
		print, archivio[cur]
		printf, 2, archivio[cur]
		print, ' tempo parziale copertura osservazione grbm ', converti(totale) 	                                         
		printf, 2, 'tempo parziale copertura osservazione grbm', converti(totale)


	cur = cur + 1                           ; incrementa il cursore all'indice dell' archivio remoto
	
	mezzanotte = 0b
				
	endwhile ;W1
	print, ''
	print, '*****                                *****'
	printf, 2, ''
	printf, 2, '*****                                *****'
	print, ' tempo totale copertura osservazione grbm ore/min/sec', converti(totale)      
	printf, 2, ' tempo totale copertura osservazione grbm ore/min/sec', converti(totale)	
		
read,'aspetta',  b

	 ;plot, 2, archivio.tempass,archivio.copertura

;	************************************************************************
;       **** routine che assegna il flag sulla condizione di  osservazione  ****
;       **** per ogni OP						    ****
;	************************************************************************

	indice = 0 		; *** indice che scorre le ascisse del grafico
	fattore = 86400		; *** fattore di precisione temporale
	limite = 3549168	; *** ultimo istante temporale in secondi
	
				; *** si scelgono l'istante iniziale e finale dell'analisi ***
	
	puntaop = 0
	istinizio = archivio[puntaop].tempass
	istfine = archivio[lun-1].tempass
	durgraf = istfine - istinizio
				; *** si dimensionano i vettori per il grafico ***	
	
	k = durgraf/fattore
	print, 'i giorni di copertura sono :'
	print, k
	X = ulonarr(k+2)
	Y1 = intarr(k+2)

sfalsamento = 1000; *** ; lo sfalsamento permette di scandire dall'OP 0+sfalsamento

puntasec = 0
valore = 0.0

controllo = 0


; *** all'OP 1199 corrisponde un valore in secondi di 3549168


print, 'puntaop ', puntaop
while (puntaop LT 99) do begin
	
	puntasec = archivio[puntaop].tempass
	print, 'puntaop ', puntaop
	;read,'aspetta',  b

			; *****************************************	
			; *** individua le diverse condizioni   ***
			; *** 	  per i diversi istanti         ***
			; *****************************************

	if ((archivio[puntaop].presente EQ si)AND(archivio[puntaop].grbm_on EQ si)) then valore = 4 ; *** OP presente, 	   GRBM acceso
	if ((archivio[puntaop].presente EQ si)AND(archivio[puntaop].grbm_on NE si)) then valore = 3 ; *** OP presente, 	   GRBM spento
	if ((archivio[puntaop].presente NE si)AND(archivio[puntaop].grbm_on EQ si)) then valore = 2 ; *** OP non presente, GRBM acceso
 	if ((archivio[puntaop].presente NE si)AND(archivio[puntaop].grbm_on NE si)) then valore = 1 ; *** OP non presente, GRBM spento
	
	
	print, 'valore = ', valore 
	
	if (puntaop EQ 0) then begin
		indice = ulong64(puntasec/fattore)
		print,'indice ', indice
		Y1[indice] = valore 
		X[indice] = indice
		print, 'X', X[indice]
		print, 'Y1',  Y1[indice]
		;read,'aspetta',  b
	endif

	if (puntaop GT 0) then begin 
		
		print, 'puntasec precedente = ', puntasec
		istprec = archivio[puntaop-1].tempass ; *** si salva l'istante precedente
		
		puntasec = istprec + 1

; ***************************************************************************************
; *** associo ad un istante temporale un valore che identifica una delle 4 condizioni *** 
; ***      questa operazione viene effettuata relativamente ad ogni singolo OP        *** 
; ***************************************************************************************

		while (puntasec LT archivio[puntaop].tempass) do begin
			print,'archivio[puntaop].tempass = ', archivio[puntaop].tempass  
			indice = ulong64(puntasec/fattore)
			x[indice]= indice
			Y1[indice] = valore 
			print, 'puntasec = ', puntasec
			print, 'X = ', X[indice]
			print, 'Y1 = ', Y1[indice]
			puntasec = puntasec + fattore
		endwhile	
	endif
	
	puntaop = puntaop + 1 		; *** si passa all'OP successivo
	print, 'puntaop =', puntaop
	print, 'puntasec =', puntasec
	;read,'aspetta',  b
endwhile


	;plot, X, Y1, title = 'copertura archivio', xtitle = 'giorni', ytitle = 'condizione', $
	;yrange = [0, 5], psym = 10
	;set_plot, 'ps'
	;plot, X, Y1, title = 'copertura archivio', xtitle = 'giorni', ytitle = 'condizione', $
	;yrange = [0, 5], psym = 10
        ;plot, X, Y1, title = 'copertura archivio', xtitle = 'giorni in archivio remoto', ytitle = 'condizione', $
	;xrange = [4950164 ,10232240],  yrange = [0, 2.5]  
	;set_plot, 'ps'
	;plot, X, Y1, title = 'copertura archivio', xtitle = 'giorni in archivio remoto', ytitle = 'condizione', $
	;xrange = [4950164 ,10232240]     

;---------------------------------------------------------------------------------------
; **** procedure di terminazione ****
;---------------------------------------------------------------------------------------

close, 1 
close, 2
close, 3




;read,'aspetta',  b
print, 'fine della elaborazione'


end
