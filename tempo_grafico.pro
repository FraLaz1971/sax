pro disegna, X, Y

; **** crea un oggetto destinazione

oWindow = OBJ_NEW('IDLgrWindow')
oWindow -> setProperty, dimensions = [1000, 600]

; **** crea un visualizzatore che occupa la finestra ****
;oView = OBJ_NEW('IDLgrView')
oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[-50.0, -30.0, 1500, 1000])
oView-> setProperty, COLOR = [160, 200, 160]
oView-> setProperty, UNIT = 3

	; **** crea una scena

;oScene = OBJ_NEW('IDLgrScene')
;oScene->Add, oView

	; **** crea un grafico **** 


; **** crea un model e l'aggiunge al view ****

oModel = OBJ_NEW('IDLgrModel')


; **** crea un plot e l'aggiunge al modello ****

thisX=DOUBLE(X*0.000001)-2000
thisY=DOUBLE(Y*0.000001)-2000
print, 'thisX = ', thisX, 'thisY = ', thisY
disegna = OBJ_NEW('IDLgrPlot', thisX, thisY)

; **** crea gli assi e aggiungili 

;disegna->SetProperty, xrange = [0, 1000], yrange = [0, 1000]
disegna->SetProperty, symbol = 5

xr = 0
yr = 0

disegna -> GetProperty, XRANGE = xr, YRANGE = yr

xaxis = OBJ_NEW('IDLgrAxis', 0)
yaxis = OBJ_NEW('IDLgrAxis', 1)
xtl = 0.01 * (xr[1] - xr[0])
ytl = 0.01 * (yr[1]- yr[0])
xaxis -> SetProperty, RANGE = xr
yaxis -> SetProperty, RANGE = yr
xaxis -> SetProperty, TICKLEN = xtl
yaxis -> SetProperty, TICKLEN = ytl
; **** crea una casella di testo e la aggiunge al modello

otext = OBJ_NEW('IDLgrTExt', 'grafico 1', ALIGNMENT=0.5, location = [60, 60])
oModel->Add, oText


; **** aggiungi il il modello al visore

oView->Add, oModel

; **** aggiungi il plot al modelllo

oModel->Add, disegna
oModel->Add, xaxis
oMOdel->Add, yaxis

; **** disegna il visore ****


Owindow->Draw, oView





;-----------------------------------------------



;read, b
;OBJ_DESTROY, oWindow
;OBJ_DESTROY, oView

end





;''
;******************************************************
;**** programma che determina l'istante di inizio  ****
;****    di un evento con maggiore precisione      ****
;******************************************************

;--------------------------------------------------------------------------

;******************************************************
;****          operazioni preliminari              ****
;******************************************************

close, 1, 2, 3
openr, 1,'/users/sax/lazza/tempo/saxfot.obt_utc'  ; **** file di input
openw, 2, '/users/sax/lazza/tempo/uscita2.txt'	  ; **** si apre il file di output
;tempi = MAKE_ARRAY(100, /STRING)    ; vettore di stringhe
cur = 0b			; **** puntatore agli indici di tempi
stringa = ''			; **** stringa temporanea
		; **** si estraggono i dati dal file ****

;**** si crea un array di stringhe in memoria contenente i dati del file
		; **** si salvano i dati in due vettori

tempi = MAKE_ARRAY(100, /STRING); **** vettore di stringhe
stringa = ''			; **** stringa temporanea
cur = 0b 			; **** puntatore agli indici di tempi

		; **** vettore di tempi a bordo

OBT = INDGEN(100)
UTC = INDGEN(100)

		; **** vettore di tempi UTC

OBTstringa = ''			; **** tempo a bordo esadecimale in tipo stringa
UTCstringa = ''			; **** tempo universale in stringa
OBTx = '0'X			; **** tempo a bordo in esadecimale
OBTd = 0L
UTC = 0.0
				; **** tempo a bordo in decimale
val1 = 0
val2 = 0
		; **** struttura contenente i tempi

times = {rectype2, NAME: 'tempi1', OBT: ULON64ARR(16), UTC: ULON64ARR(16), NUTC: ULON64ARR(16)} 

;-------------------------------------------------------------------------------------------------
; *****************************************************************
; **** routine che acquisisce i dati dal file e li salva nelle ****
; **** apposite strutture 				       ****	
; *****************************************************************

while (NOT EOF(1)) do begin
	readf, 1, stringa
	tempi[cur] = stringa

		; **** acquisisce dal file e converte ****

	OBTstringa = STRCOMPRESS(strmid(tempi[cur], 3, 11), /REMOVE_ALL)
	;OBTd = 	
	OBTd = (hextodec(OBTstringa))
	UTCstringa = (strmid(tempi[cur], 27))
	UTC =  ULONG64(setodec(UTCstringa)) 


			; **** salva la stringa integrale ****

	printf, 2, 'tempi[', STRCOMPRESS(cur, /REMOVE_ALL), '] = ', tempi[cur]
			; **** salva l'OBT ****
	times.OBT[cur] = OBTd
	printf, 2, 'OBT in decimale = ', times.OBT[cur]
	
			; **** salva L'UTC ****
	times.UTC[cur] = UTC
	printf, 2, 'UTC =             ', times.UTC[cur]
	 


	cur = cur + 1
	OBTd = 0
	UTC = 0
endwhile

;---------------------------------------------------------------------------

; *****************************************************************
; **** routine che  effettua il fit lineare sui dati estratti  ****
; *****************************************************************

openw, 3, 'nuovi.txt'
par = [0.0, 0.0]
par = LINFIT(times.OBT, times.UTC)

printf, 3, '**** valori dei tempi approssimati ****'
printf, 3, ''
printf, 3, 'A = ', par[0], '  ****  B = ', par[1]
printf, 3, ''

;trigtime =  

a = 0	
for a = 0, (cur-1) do begin
	times.NUTC[a] = (par[1]*times.OBT[a])+par[0]
	printf, 3, 'a = ', a
	printf, 3, 'NUTC = ', times.NUTC[a]
endfor

;---------------------------------------------------------------------------

disegna, times.OBT, times.UTC

;---------------------------------------------------------------------------
; **** procedure di terminazione

print, 'esecuzione terminata'
close, 1, 2, 3

end

;---------------------------------------------------------------------------
	  	
