; -------------------------------------------------------------------------------

; ******************************************************************
; **** converte una stringa esadecimale in una stringa decimale ****
; **** 		con la precisione desiderata			****	
; ******************************************************************

function decimals, numb

nsteps = 0ul
nsteps = numb

if (nsteps GE 65536ul) then nsteps = nsteps - 65536ul

conversion_num = 1525878906ULL

ndecimals = 0d 




ndecimals = ROUND(nsteps*100000./65536.)


return, ndecimals
end 

;------------------------------------------------------------------------------
	; *************************************************
	; ****	accetta una stringa OBT in decimali e  ****
	; **** restituisce una stringa UTC 	       ****
	; *************************************************

function STRtoUTC, str

thisstr = ''
thisstr = str
thisnum = ULONG64(thisstr)

codiv = 65536 					; codiv e' lo step temporale
sec = ULONG64(thisnum / codiv) 	 		; sec contiene la quantita' intera di secondi   
print, 'sec = ', sec
frasec = decimals((thisnum MOD codiv))		; frasec = sec*10^-5

ore = (sec - (sec MOD 3600))/3600 
sec = (sec MOD 3600)
minuti = (sec - (sec MOD 60))/60  
sec = (sec MOD 60 )
secondi = sec 


  
hstring = STRCOMPRESS(STRING(ore), /REMOVE_ALL)
minstring = STRCOMPRESS(STRING(minuti), /REMOVE_ALL)
secstring = STRCOMPRESS(STRING(secondi), /REMOVE_ALL)
frasecstring = STRCOMPRESS(STRING(frasec), /REMOVE_ALL)

if (FIX(hstring)LE 9 ) then hstring = '0'+ hstring 
if (FIX(minstring)LE 9) then minstring = '0' + minstring
if (FIX(secstring)LE 9) then secstring = '0' + secstring

while (STRLEN(frasecstring)LT 5) do frasecstring = '0'+ frasecstring 

totstring = hstring + ':' + minstring + ':' + secstring+ ':' + frasecstring

	; ************************************************
	; **** calcola il tempo trascorso dall'ultimo ****
	; ****  azzeramento del cronometro espresso   **** 
	; **** in ore, minuti, secondi,  sec*10^(-5)  ****
	; ************************************************


	; ************************************************
	; **** restituisce una stringa contenente     **** 
	; ****		il tempo UTC   		      ****
	; ************************************************


return, totstring
end



;------------------------------------------------------------------------------
	; ************************************************
	; **** accetta un numero OBT in sec*(2^-16) e ****
	; **** restituisce una stringa UTC 	      ****
	; ************************************************

function NUMtoUTC, num

thisnum = 0ULL

thisnum = num
;print, 'num = ', num
;print, 'thisnum = ', thisnum

codiv = 65536 					; codiv e' lo step temporale
sec = ULONG64(thisnum / codiv) 	 		; sec contiene la quantita' intera di secondi
   
print, 'numero di secondi = ', sec

;if (sec GT 864000ull) then begin
 ; sec = sec - 864000ull ; caso in cui si passa da un giorno all'altro
;endif

print, 'numero di secondi = ', sec

frasec = decimals((thisnum MOD codiv))		; frasec = sec*10^-5

ore = (sec - (sec MOD 3600))/3600 
sec = (sec MOD 3600)
minuti = (sec - (sec MOD 60))/60  
sec = (sec MOD 60 )
secondi = sec 


  
hstring = STRCOMPRESS(STRING(ore), /REMOVE_ALL)
minstring = STRCOMPRESS(STRING(minuti), /REMOVE_ALL)
secstring = STRCOMPRESS(STRING(secondi), /REMOVE_ALL)
frasecstring = STRCOMPRESS(STRING(frasec), /REMOVE_ALL)

;print, 'hstring = ', hstring
;print, 'FIX(hstring) = ', FIX(hstring)

if (FIX(hstring)LE 9 ) then hstring = '0'+ hstring 
if (FIX(minstring)LE 9) then minstring = '0' + minstring
if (FIX(secstring)LE 9) then secstring = '0' + secstring

while (STRLEN(frasecstring)LT 5) do frasecstring = '0'+ frasecstring 

totstring = hstring + ':' + minstring + ':' + secstring+ ':' + frasecstring

	; ************************************************
	; **** calcola il tempo trascorso dall'ultimo ****
	; ****  azzeramento del cronometro espresso   **** 
	; **** in ore, minuti, secondi,  sec*10^(-5)  ****
	; ************************************************


	; ************************************************
	; **** restituisce una stringa contenente     **** 
	; ****		il tempo UTC   		      ****
	; ************************************************


return, totstring
end

;-------------------------------------------------------------------------------


; **************************************************************************************
; *** converte una stringa sessagesimale in un istante espresso in step (2^-16 sec)  ***
; **************************************************************************************


function setodec, sestring



STEP = 65536
sum = 0LL
hourtostep = 0LL
mintostep = 0LL
sectostep = 0LL

hourtosec = 0LL 
mintosec =  0LL	
sectosec =  0LL
sumsec = 0LL
		; **** extract fields ****

	hourtosec = ULONG(strmid(sestring, 0, 2))*3600
	mintosec =  FIX(strmid(sestring, 3, 2))*60
	sec =  FIX(strmid(sestring, 6, 2))
	sec_neg5 = strmid(sestring, 9, 5)
	
	totsec = hourtosec + mintosec + sec
	totstep = ULONG64(ULONG64(totsec)*STEP)		; contiene la parte h/m/s in step
	;print
	;print, 'totsec = ', totsec
	;print
	;print, 'totstep = ', totstep
	stepdigits = ROUND(sec_neg5*65536.0*0.00001)

	;stepdigits =  
	;print, 'ore in sec ...    ', hourtosec
	;print
	;print, 'minuti in sec ...', mintosec
	;print
	;print, 'secondi ...      ', sec
	;print
	;print, 'secondi*10(-5) ... ', sec_neg5
	;print
 	;print, 'stepdigits = ', stepdigits
	sum = ULONG64( totstep + stepdigits )
	;print, 'sumsec ...', sumsec
	return, sum
	

end





; -------------------------------------------------------------------------------
; ******************************************************************
; **** converte una stringa esadecimale in una stringa decimale ****
; ******************************************************************
; -------------------------------------------------------------------------------


function hextodec, hexstring
thishexstring = hexstring 
cur1 = 0b
len = 0b
esp = 0b
len = strlen(thishexstring)
;print, 'stringa passata lunga ', thishextring
;cur1 = (len - 1)
strpartial = ''
numpartial = 0l
sumpartial = 0l
bval = [0]
bvalb = 0b
	while(esp LE (len - 1) ) do begin
		strpartial = strmid(thishexstring, ((len - 1) - esp), 1)
		;print, 'strpartial = ', strpartial
		bval[0] = BYTE(strpartial)
		bvalb = bval[0]
		if (bval[0] GE 97) then begin 
			numpartial = (bval - 87) 
		endif else begin
			numpartial = (bval - 48)
		endelse
		
		addendo = ULONG64(numpartial * 16.0^esp)
		
		sumpartial = sumpartial+addendo
		 
		esp = esp + 1
		strpartial = ''
	endwhile

return, sumpartial
end

;-----------------------------------------------------------------------------
; programma che estrae il tempo di trigger calcolato dal programma calGRBMtime
;-----------------------------------------------------------------------------

pro strigger, directory, obs
  stringa = ''
  path4 = '/users/sax/lazza/objects2/objects/op_'
  close, 4
  openr, 4, path4+directory+'/iniTimes'+obs+'.txt'  ; **** file di input per i tempi di inizio	
  readf, 4, stringa ; legge la prima stringa : contiene il numero dei trigger
  print, stringa
  ntrgs = 0b ; variabile che contiene il numero dei trigger
  ciph1str = ''
  ciph2str = ''
  ciph1 = 0b
  ciph2 = 0b
  help, ntrgs
  pos1 = STRPOS(stringa, 'ins ') + 4
  print, 'il numero sta nella posizione', pos1
  ciph1str = STRMID(stringa, pos1, 1)
  print, 'ciph1str = ', ciph1str 
  ciph2str = STRMID(stringa, pos1+1, 1)
  print, 'ciph2str = ', ciph2str
  
  if (ciph2str EQ ' ') then begin  
    ciph1 = 0b
    ciph2 = BYTE(ciph1str) - 48b
  endif else begin
    ciph1 = BYTE(ciph1str[0]) - 48b
    ciph2 = BYTE(ciph2str[0]) - 48b
  endelse

  help, ciph2, ciph1
  ntrgs = (ciph1*10+ciph2)	; converte il n. da stringa a byte
  pntrgs = BYTE(ntrgs[0])       ; lo trasforma nel giusto tipo di dato

  print, 'nell''osservazione '+obs+'ci sono '+pntrgs+'burst'  

numt1 = 10B
oldtimes = STRARR(10)	; si presuppone che ci siano al massimo numt1 trigger 

; **** caso di osservazione contenente + trigger ****
 
curtrs = 0b 
print, 'sto per entrare'
help, pntrgs

; ciclo di estrazione dei tempi

  while (curtrs LT pntrgs) do begin
    print, 'sono entrato' 
    readf, 4, stringa
    readf, 4, stringa
    stringa = strmid(stringa, 34)
    oldtimes[curtrs] = stringa
    print, 'letto la stringa ', oldtimes[curtrs]
    curtrs = curtrs + 1
  endwhile

; adesso la variabile curtrs contiene il numero dei trigger

oldtime = ''
oldtime = (oldtimes[0]) ; contiene il valore del tempo estratto

trg = '001'
;path4+'TimeResult'+obs+'_'+trg+'.dat'

save, filename = 'CurrentObs.txt', obs
;save, filename = 'TimeResult'+obs+'.dat', oldtime
save, filename = 'TrigNum'+obs+'.dat', pntrgs ; salva il numero dei trigger

;save, filename = path4+directory+'/TimeResult'+obs+'_'+trg+'.dat', oldtime
save, filename = path4+directory+'/TimeResult'+obs+'_'+trg+'.dat', oldtimes ; salva i tempi di inizio

print
print, 'istante di trigger da calcGRBMtime = ', oldtime[0]
print

end 

;--------------------------------------------------------------------------

;***********************************************************
;**** procedura che determina l'istante di trigger      ****
;**** contenuto nell' OP <directory> osservazione <obs> ****
;****    di un evento con maggiore precisione           ****
;***********************************************************

;--------------------------------------------------------------------------

pro trigger, directory, obs 



		;******************************************************
		;****          operazioni preliminari              ****
		;******************************************************

close, 1, 2, 3, 4, 5

path3 = '/users/sax/lazza/objects/op_'
path4 = '/users/sax/lazza/objects2/objects/op_'

openr, 1, path4+directory+'/saxfot.obt_utc'    ; **** file di input per il fit lineare

openr, 4, path4+directory+'/iniTimes'+obs+'.txt'  ; **** file di input per i tempi di inizio	

openw, 2, '/users/sax/lazza/objects2/objects/uscita2.txt'      ; **** si apre il file di output per il fit

openw, 3, '/users/sax/lazza/objects2/objects/fit_times.txt'    ; **** si apre il file di output per i tempi

openw, 5, '/users/sax/lazza/objects2/objects/new_iniTimes.txt' ; **** si apre il file di output per i nuovi tempi



;--------------------------------------------------------------------------------------------------------
offtimer = 0ull		; **** offset per il tempo di bordo
offday = 0ull		; **** offset per l'UTC

tempi = MAKE_ARRAY(200, /STRING)	; **** vettore di stringhe
stringa = ''				; **** stringa temporanea
cur = 0b				; **** puntatore agli indici di tempi

		; **** vettore di tempi a bordo

OBT = INDGEN(200)
UTC = INDGEN(200)

		; **** vettore di tempi UTC

OBTstringa = ''			; **** tempo a bordo esadecimale in tipo stringa
UTCstringa = ''			; **** tempo universale in stringa
OBTx = '0'X			; **** tempo a bordo in esadecimale
OBTd = 0L			; **** tempo a bordo in decimale
UTC = 0.0
				
val1 = 0
val2 = 0
	
offtime = 0ULL			; **** valore temporale da sottrarre per ottenere l'UTC
		
			; **** struttura contenente i tempi

times = {rectype2, NAME: 'tempi1', OBT: ULON64ARR(200), UTC: ULON64ARR(200), NUTC: ULON64ARR(16)} 

;-------------------------------------------------------------------------------------------------
; *****************************************************************
; **** routine che acquisisce i dati dal file saxfot.obt_utc   ****
; **** 		e li salva nelle apposite strutture 	       ****	
; *****************************************************************
;-------------------------------------------------------------------------------------------------

out = 0b


while (NOT EOF(1)) do begin
	out = 0b
	readf, 1, stringa
	tempi[cur] = stringa

		; **** acquisisce dal file e converte ****
	
	
	
	OBTstringa = STRCOMPRESS(strmid(tempi[cur], 3, 11), /REMOVE_ALL)
		
	OBTd = (hextodec(OBTstringa))
	UTCstringa = (strmid(tempi[cur], 27))
	UTC =  ULONG64(setodec(UTCstringa)) 

			; **** salva la stringa integrale ****

	printf, 2, 'tempi[', STRCOMPRESS(cur, /REMOVE_ALL), '] = ', tempi[cur]
	;print, 'tempi[', STRCOMPRESS(cur, /REMOVE_ALL), '] = ', tempi[cur]		
			
			
	
			; **** controlla se c'e' un riciclo del timer ****
	
	  times.OBT[cur] = OBTd 	  
	  printf, 2, 'OBT in decimale = ', times.OBT[cur]
	  print,  'OBT in decimale = ', times.OBT[cur]
	  offtimer = 4294967295ull

	if (cur GT 0) then begin
	  if times.OBT[cur-1] GT times.OBT[cur] then begin
	    out = 1b	  
	    times.OBT[cur] = times.OBT[cur] + offtimer   
	    printf, 2, 'riciclo del timer aggiungo 4294967295'
	    printf, 2, 'times.OBT[cur-1] = ',  times.OBT[cur-1]	
	    printf, 2, 'times.OBT[cur] = ',  times.OBT[cur]	
	  endif  
	endif		
       	  			; **** salva l'OBT ****
	  
	  
	  

	times.UTC[cur] = UTC
	printf, 2, 'UTC =             ', times.UTC[cur]
	print, 2, 'UTC =             ', times.UTC[cur]
	offday = 5662310399ull				
	if (cur GT 0) then begin
	  if times.UTC[cur-1] GT times.UTC[cur] then begin
	   out = 1b	  
	   times.UTC[cur] = times.UTC[cur] + offday
	  printf, 2, 'cambio giorno aggiungo 5662310399ull'
	  printf, 2, 'times.UTC[cur-1] = ',  times.UTC[cur-1]	
	  printf, 2, 'times.UTC[cur] = ',  times.UTC[cur]	
	  endif	  
	endif

			; **** salva L'UTC ****
			
	cur = cur + 1
	
	OBTd = 0
	UTC = 0
endwhile
cur = 0b
;---------------------------------------------------------------------------
	; *****************************************************************
	; **** routine che  effettua il fit lineare sui dati estratti  ****
	; *****************************************************************
;---------------------------------------------------------------------------

par = [0ULL, 0ULL]
par = LINFIT(times.OBT, times.UTC)
printf, 3, '**** valori dei tempi approssimati ****'
printf, 3, ''
printf, 3, 'A = ', par[0], '  ****  B = ', par[1]
printf, 3, ''

  

a = 0	
for a = 0, (cur-1) do begin
	times.NUTC[a] = (par[1]*times.OBT[a])+par[0]
	printf, 3, 'a = ', a
	printf, 3, 'NUTC = ', times.NUTC[a]
endfor

;---------------------------------------------------------------------------
		;*****************************************************
		;**** procedura che legge da file i vecchi tempi  ****
		;**** di inizio e scrive su un file i nuovi	  ****
		;*****************************************************
;---------------------------------------------------------------------------
	; *********************************************************************
	; **** si trova lo scarto che c'e' tra le ore passate dal riciclo  ****
	; ****                   dell'OBT e l'UTC			   ****
	; *********************************************************************								

offtime = (times.OBT[0] - times.NUTC[0])	; **** scarto fra ore OBT e UTC

;print, 'offtime = ', offtime

oldtime = 0ULL
scltime = 0ULL


;---------------------------------------------------------------------------------------------------
; routine che calcola quanti trigger ci sono in un'osservazione (n trigger)
; 			ed estrae gli n tempi di inizio
;---------------------------------------------------------------------------------------------------

stringa = ''
  path4 = '/users/sax/lazza/objects2/objects/op_'
  close, 4
  openr, 4, path4+directory+'/iniTimes'+obs+'.txt'  ; **** file di input per i tempi di inizio	
  readf, 4, stringa ; legge la prima stringa : contiene il numero dei trigger
  print, stringa
  ntrgs = 0b ; variabile che contiene il numero dei trigger
  ciph1str = ''
  ciph2str = ''
  ciph1 = 0b
  ciph2 = 0b
  help, ntrgs
  pos1 = STRPOS(stringa, 'ins ') + 4
  print, 'il numero sta nella posizione', pos1
  ciph1str = STRMID(stringa, pos1, 1)
  print, 'ciph1str = ', ciph1str 
  ciph2str = STRMID(stringa, pos1+1, 1)
  print, 'ciph2str = ', ciph2str
  
  if (ciph2str EQ ' ') then begin  
    ciph1 = 0b
    ciph2 = BYTE(ciph1str) - 48b
  endif else begin
    ciph1 = BYTE(ciph1str[0]) - 48b
    ciph2 = BYTE(ciph2str[0]) - 48b
  endelse

  help, ciph2, ciph1
  ntrgs = (ciph1*10+ciph2)	; converte il n. da stringa a byte
  pntrgs = BYTE(ntrgs[0])       ; lo trasforma nel giusto tipo di dato

  print, 'nell''osservazione '+obs+'ci sono '+pntrgs+'burst'  

numt1 = 10B
oldtimes = STRARR(10)	; si presuppone che ci siano al massimo numt1 trigger 
oldtime2 = STRARR(10)
; **** caso di osservazione contenente + trigger ****
 
curtrs = 0b 
print, 'sto per entrare'
help, pntrgs

; ciclo di estrazione dei tempi

  while (curtrs LT pntrgs) do begin
    print, 'sono entrato' 
    readf, 4, stringa
    print, 'stringa letta = ', stringa
    oldtime2[curtrs] = strmid(stringa, 42, 8)
    readf, 4, stringa
    stringa = strmid(stringa, 34)
    oldtimes[curtrs] = stringa
    print, 'letto la stringa ', oldtimes[curtrs]
    curtrs = curtrs + 1
  endwhile

; adesso la variabile curtrs contiene il numero dei trigger

oldtime = ''
;oldtime = (oldtimes[0]) ; contiene il valore del tempo estratto
;print, 'il vecchio tempo e'' ', oldtime



oldtime = oldtime2[0]

				; **** FINE ROUTINE  ****

newtime = ULONG64((par[1]*oldtime2)+par[0])



scltime = oldtime - offtime 
oldnum = ULONG64(scltime)

openw, 10, 'appoggio.txt'
printf, 10, oldnum
printf, 10, newtime
close, 10

oldnum2 = 0ULL
newtime2 = 0ULL
 
openr, 11, 'appoggio.txt'
readf, 11,  oldnum2
readf, 11, newtime2
;numero = ULONG64(stringa2)
close, 11


;------------------------------------------------------------------------------------------------


oldtime_UTC = 0ULL
newtime_UTC = 0ULL

		; ****	calcolato il nuovo UTC ****

print, 'vecchio tempo = ', oldtime

;oldtime_UTC = NUMtoUTC(oldnum2)
;newtime_UTC = NUMtoUTC(newtime2)

oldtime_UTC = NUMtoUTC(oldtime)
newtime_UTC = NUMtoUTC(newtime2)

		; **** salva il nuovo istante di trigger ****
		; **** nel file parametri.dat		 ****

print, 'sono arrivato a salvare i tempi '
save, filename = 'CurrentObs.txt', obs
save, filename = 'TimeResult'+obs+'.dat', newtime_UTC
printf, 5
printf, 5, 'vecchio istante di inizio = ', oldtime_UTC
print, 'vecchio istante di trigger = ', oldtime_UTC
printf, 5
printf, 5, 'nuovo istante di inizio = ', newtime_UTC
print, 'nuovo istante di trigger   = ', newtime_UTC

;---------------------------------------------------------------------------
; **** procedure di terminazione
;---------------------------------------------------------------------------

print
print, '**** estratto tempo di trigger ****'
print
close, 1, 2, 3, 4, 5

end

;---------------------------------------------------------------------------
