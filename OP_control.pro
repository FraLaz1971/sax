	      ;**************************************************************
	      ;**** programma che individua quali file devono essere     ****
	      ;**** scaricati per aggiornare l'archivio locale	         ****
	      ;**************************************************************
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------	

	      ;**** procedura che ordina gli OP ****
;-----------------------------------------------------------------------------------------
	      ;****   dichiarazione variabili   ****
b = 0
close, 1, 2, 3, 4, 5, 6
OP_sort = MAKE_ARRAY(100000, /STRING)    ; vettore di stringhe
cur = 0UL				; scorre il vettore di stringhe	
stringa = ''				; stringa di appoggio per le letture
;-----------------------------------------------------------------------------------------
		;**** corpo del programma ****

openr, 1, 'listato.txt'                    ; **** si apre il primo file di input: OP in archivio locale
openw, 3, 'voci_scartate.txt'		   ; **** si apre il file che raccoglie le voci scartate	
openw, 6, 'log.txt'			   ; **** si apre il file di log 		  
;------------------------------------------------------------------------------------------		
		; **** crea un vettore di OP ****
		; ****       ed ordina       ****

while (NOT EOF(1)) do begin
	;printf, 6, 'cur = ', cur
	readf,1,stringa
	OP_sort[cur] = stringa
	;printf, 6, 'sort[', cur, '] = ', OP_sort[cur]
	cur = cur+1
endwhile

taglia = 0UL
taglia = cur ; **** taglia = n. di voci memorizzate
print, 'taglia = ', taglia
onlyOP = MAKE_ARRAY((taglia), /UINT)
cur = 0
cur_onlyOP = 0 ; **** scorre il vettore di OP

;------------------------------------------------------------------------------------------
		;**** 	  ciclo che estrae le voci relative agli OP	       ****  
		;****     e salva i numeri di OP in un vettore di interi       **** 

OP_number = 0; **** variabile d'appoggio per l'intero numero di OP 

while (cur LE (taglia-1)) do begin
	!Error = 0
	stringa = OP_sort[cur]
	if (STRPOS(stringa,'op_') EQ 0) then begin
		nonins = 0b
		stringa = STRMID(stringa,3)
		OP_number = UINT(stringa)
		if (!Error EQ -89) then begin
			print, 'eccezione gestita: stringa = ', 'op_'+stringa
			printf, 6, 'voce ', 'op_'+stringa, ' non OP: eliminata dall''elenco'
                	printf, 3, 'op_'+stringa
			nonins = 1b
		endif 
		if (NOT nonins) then begin
			onlyOP[cur_onlyOP] = OP_number			
			cur_onlyOP = cur_onlyOP + 1
		endif
	endif else begin
		printf, 6, 'voce ', stringa, ' non OP: eliminata dall''elenco'
		printf, 3, stringa
	endelse

cur = cur + 1
endwhile

printf, 6, ''
printf, 6, 'n. di OP salvati = ', cur_onlyOP ; **** contiene il numero di OP in archivio locale
printf, 6, 'n. di voci scartate = ', (cur-cur_onlyOP)
printf, 6, ''

print, 'cur_onlyOP = ', cur_onlyOP
onlyOP = onlyOP(0:(cur_onlyOP-1)); **** viene ridimensionato il vettore
OP_sorted = MAKE_ARRAY((cur_onlyOP), /UINT); **** vettore per OP ordinati della giusta dimensione
lastOP = (cur_onlyOP-1) ; **** salva l'indice dell'ultimo OP in archivio locale

;------------------------------------------------------------------------------------------------
		; **** ordina il vettore di OP ****
cur = 0
;printf, 6, 'informazioni su onlyOP '
;printf, 6, SIZE(onlyOP) 
forSORT = SORT(onlyOP)	;**** vettore di indici per l'ordinamento crescente di onlyOP

while (cur LE lastOP) do begin
        ;printf, 6, ''
	;printf, 6, 'onlyOP(forSORT[', cur,'] = ', onlyOP(forSORT[cur])
	OP_sorted[cur] = onlyOP(forSORT[cur])
	cur = cur + 1
endwhile




;------------------------------------------------------------------------------------------
		; **** stampa e salva il vettore di OP ****

printf, 6, 'vettore ordinato'
printf, 6,''

openw, 2, 'OP_ordinati.txt'                ; *** si apre il file di output per la lista ordinata di OP
cur = 0
while (cur LE lastOP) do begin
; **** si elimina la sottostringa di spazi ****
	opstr = STRING(OP_sorted[cur]); **** n° di OP espresso in stringa
	opstr = STRTRIM(opstr,1)	
	printf, 2, opstr
	printf, 6, OP_sorted[cur]
	cur = cur + 1 
endwhile

printf, 6,''
close, 2
;read,'digitare un numero ', b

;-----------------------------------------------------------------------------------------
		;**** procedura che aquisisce gli OP del VAX ****
taglia = 100;
vaxOP = MAKE_ARRAY((taglia), /UINT) ;**** vettore che contiene i numeri di OP sul VAX
curVAX = 0	;**** scorre gli OP sul VAX 

;openr, 4, 'vaxprova.txt'
openr, 4,'vaxdir2.txt'   ; **** si apre il secondo file di input: OP nella memoria buffer dell'archivio remoto

while (NOT EOF(4)) do begin
	readf, 4, stringa
	printf, 6, 'ho letto : ', stringa
	
	if ((STRPOS(stringa,'OP_') EQ 0) OR(STRPOS(stringa,'op_') EQ 0)) then begin
		str = 3; **** scorre la stringa
		OPartial = ''; **** stringa parziale
		while (STRMID(stringa, str, 1) NE '.') do begin
			OPartial = OPartial+STRMID(stringa, str, 1)
			str = str+1
		endwhile
		printf, 6, 'stringa definitiva : ', OPartial
		OP_number = UINT(OPartial)	
		vaxOP[curVAX] = OP_number			
		curVAX = curVAX + 1
	endif else begin
		printf, 6,'voce ', stringa, ' non OP: estrazione non effettuata'
	endelse
endwhile

nvaxOP = curVAX ; **** nvaxOP salva il numero di OP nella memoria buffer del VAX
;in = 'l'
in = ''
printf, 6, ''
printf, 6, 'nel VAX sono presenti ',nvaxOP, ' OP'
printf, 6, ''
;print, 'digita l per leggere'
;print, 'quali OP sono presenti nel VAX'
;read, in

if (in EQ 'l') then begin
	cur=0
	while (cur LT curVAX) do begin 
		printf, 6, vaxOP[cur]
		cur = cur + 1
	endwhile
endif else begin
	;print, 'nessuna stampa'
	printf, 6, '' 
endelse
;-----------------------------------------------------------------------------------------
		; **** individuazione degli OP da richiedere ****


		
curIAS = 0 ;**** scorre gli OP in archivio locale
curVAX = 0 ;**** scorre gli OP nel VAX

; **** si assume che il vettore vaxOP sia ordinato in modo crescente
; **** si individua un range nei due vettori
; **** su cui effettuare il controllo

	iniOPV = vaxOP[curVAX]
	iniOPI = OP_sorted[curIAS]

;while (OP_sorted[curIAS] NE vaxOP[curVAX] AND (curIAS LT lastOP)) do begin
;	curIAS = curIAS + 1
;endwhile

iniOPI = OP_sorted[curIAS] 	  ;**** estremo inferiore dell'intervallo di OP individuato in archivio locale ovvero
				  ;**** l' OP di presente in ambedue gli archivi con numero piu' basso
	
finOPI = OP_sorted[cur_onlyOP-1]  ;**** estremo superiore intervallo di OP individuato in archivio locale ovvero
				  ;**** l'OP in archivio locale con numero piu' alto
 	

corOP = 0 		; **** OP remoto da aggiungere alla lista degli OP da richiedere
openw, 5, 'OPtoget.txt' ; **** si apre il file che salva i numeri degli OP da copiare
printf, 6, 'si parte dall''op ', OP_sorted[curIAS]
while  (curVAX LE (nvaxOP-1)) do begin
	fineloc = 0  
	while (OP_sorted[curIAS] EQ vaxOP[curVAX] AND NOT(fineloc)) do begin
		if ((curIAS LT (cur_onlyOP-1))AND(curVAX LT nvaXOP-1)) then begin ;
			printf, 6, OP_sorted[curIAS], ' ', vaxOP[curVAX], ' OP gia'' trasferito'  
			curIAS = curIAS+1
			curVAX = curVAX+1
		endif else begin
			printf, 6, 'curIAS = ',curIAS, '     cur_onlyOP-1', cur_onlyOP-1
			printf, 6, 'curVAX = ',curVAX, '     nvaxOP-1', nvaxOP-1
			;print, 'digita un numero'
			;read,'e premi RETURN ',  b
			fineloc = 1
		endelse
	endwhile


if (OP_sorted[curIAS] EQ vaxOP[curVAX]) then begin
	printf, 6, OP_sorted[curIAS], ' ', vaxOP[curVAX], ' OP gia'' trasferito'
endif else begin
	
	if (OP_sorted[curIAS] LT vaxOP[curVAX]) then begin
		;**** se hanno tolto nel VAX un OP intermedio
		;**** cerca se all'IAS c'è
		while ( (OP_sorted[curIAS] LT vaxOP [curVAX])AND(curIAS LT cur_onlyOP-1) ) do begin
			curIAS = curIAS + 1
		endwhile

	endif
	
	if (OP_sorted[curIAS] NE vaxOP[curVAX]) then begin
		printf, 6, 'OP puntato in archivio locale = ', OP_sorted[curIAS]
		printf, 6, 'OP puntato in archivio remoto = ', vaxOP[curVAX]
		printf, 5, vaxOP[curVAX]
		printf, 6, vaxOP[curVAX], ' manca e va richiesto'
	endif
endelse

curVAX = curVAX + 1
endwhile
close, 5

;------------------------------------------------------------------------------------------
		; **** procedure di terminazione ****

close, 1, 2, 3, 4
;print, 'digita un numero'
;read,'e premi RETURN ',  b

print, 'elaborazione terminata'
printf, 6, ''
printf, 6,'elaborazione terminata' 

close, 6
end
