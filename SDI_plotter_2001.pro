;   ***********************************************************************
;   **************************        SDI         *************************
;   **************************      (MANUAL)      *************************
;   ************************** SAX DATA INSPECTOR *************************
;   ***********************************************************************
;   ***********************************************************************
;   ******   PROGRAMMA CHE ANALIZZA CURVE DI LUCE RELATIVE AI GRBs   ******
;   ******             RILEVATI DAL SATELLITE BeppoSAX               ******
;   ***********************************************************************

;   ******             INIZIALIZZAZIONE FICCANASOSCOPIO              ******

LunghezzaFile=13568.0 ;Default=13568.0
Step2Massimo=128 ;Default=128
bMassimo=16.0; Default=16.0
bStep=2.0 ;Default=2.0
bSoglia1=4.0 ;Default=4.0
bSoglia2=8.0 ;Default=8.0
Step2Minimo=8 ;Default=8
StepMassimo=32 ;Default=32
bFinale=8.0 ;Default=8.0
StepMinimo=8 ;Default=8
StepBias=1.0 ;Default=1.0
Step2Bias=2.0 ;Default=2.0
BinInizioT90=16 ;Default=16
BinFineT90=8 ;Default=8

;   ******               DICHIARAZIONE DELLE VARIABILI               ******

k1=intarr(1)
imax=intarr(1)
ir1=intarr(1)
i2max=intarr(1)
orbit=strarr(1)
a=STRARR(1)
x=fltarr(LunghezzaFile,4)
media1=fltarr(4)
media2=fltarr(4)
sigma1=fltarr(4)
y=intarr(LunghezzaFile,4)
trig=intarr(4)
trig1=intarr(4)
filedaaprire=strarr(4)
media2s=fltarr(4)
sigma1s=fltarr(4)
dimensione=intarr(1)
minr=intarr(1)
tfine=fltarr(4)
durata=fltarr(4)
massimo=intarr(4)
tmassimo=fltarr(4)
tin=fltarr(4)
binin=intarr(4)
binout=intarr(4)
binin2=intarr(4)
binout2=intarr(4)
binout3=intarr(4)
binin3=intarr(4)
binin4=intarr(4)
binout4=intarr(4)
b=fltarr(4)
t90start=fltarr(4)
t90end=fltarr(4)
t90start1=fltarr(4)
t90end1=fltarr(4)
t90start2=fltarr(4)
t90end2=fltarr(4)
dur=fltarr(4)
correlatio=fltarr(257)
deltafi=fltarr(4,4)
correlM=fltarr(4,4)
correlP=fltarr(4,4)
correlD=fltarr(4,4)
teresa=intarr(4,4)
beatrice=intarr(4)
corrfit=fltarr(257)
stp2=intarr(4)
area=fltarr(4)
fester=intarr(4)

!P.MULTI=[0,2,2,0,0]
!P.PSYM=10
spawn, 'rm idl.ps'
; ******        SELEZIONE DEL TRIGGER DA ANALIZZARE       ******
; ******                    E PLOTTAGGIO                  ******
; ******        SELEZIONE DEL TRIGGER DA ANALIZZARE       ******
; ******                    E PLOTTAGGIO                  ******

print,'selezione OP '
close, 13
tempopid = ''
openr, 13, 'AcOP.txt'
readf, 13, tempopid
orbit = 'op_'+tempopid 
close, 13


close, 15
tempobs = ''
openr, 15, 'nobs.txt'
readf, 15, tempobs
close, 15

separatore = '-------------------------------------------------------------------------------------'


a(0)=orbit(0)+'/*tot.out'
files=FINDFILE(a(0))
n=N_ELEMENTS(files)


for i=0,n-1 do begin
   print,i,'  ',files(i)   
endfor


print,'selezione delle curve da analizzare'

tn = 0b
tn = FIX(n/4b); numero dei trigger

if (n EQ 1) then n = 0b

print,'files presenti : ', n

print,'trigger completi presenti : ', tn


  ;sp = tp ; scorre i files per i 4 schermi 

					



	temptrig = 0b
	close, 17 
	openr, 17, 'AcTrig.txt'
	readf, 17, temptrig
	close, 17 
	tp = temptrig ; punta il trigger
	print,'carico il trigger ', (tp + 1)
 	
	si = 0b ; scorre gli indici

	sp = tp

	if ((tp LE tn)AND(tn GT 0)) then begin
  	  while((sp LT n)AND(si LT 4))do begin
		filedaaprire(si)=files(sp)
		si = si + 1b
	      	sp = sp + tn	      	    
  	  endwhile
	endif else begin
	  print, 'curve totali non rilevate '
	  carica = 0b
	endelse

oldtp = 0b
oldtp = tp 

	if (tp LT (tn-1)) then begin		; SE NELL'OSS. CI SONO PIU' TRIGGER 
    		tp = tp + 1b			; SELEZIONA IL SUCCESSIVO		
	endif else begin			; ALTRIMENTI
    		tp = 0b				; IMPOSTA PER IL TRIGGER 0 DELLA PROSSIMA			
	endelse					; OSSERVAZIONE
 						

close,1
close,2
close,3
close,4
print,' '
print,'Caricamento in corso. Attendere, prego ...'
print,' '
print,filedaaprire(0)
anna=0.0
openr,1,filedaaprire(0)
for i=0,(LunghezzaFile-1.0) do begin
    if EOF(1) EQ 1 then goto,FILENONVALIDO
    readf,1,a1,b1,c1
    x(i,0)=a1
    y(i,0)=b1
    if i EQ 0 then anna=a1
    x(i,0)=x(i,0)-anna
endfor
close,1
print,filedaaprire(1)
anna=0.0
openr,2,filedaaprire(1)
for i=0,(LunghezzaFile-1.0) do begin
    if EOF(2) EQ 1 then goto,FILENONVALIDO
    readf,2,a2,b2,c2
    x(i,1)=a2
    y(i,1)=b2
    if i EQ 0 then anna=a2
    x(i,1)=x(i,1)-anna
endfor
close,2
print,filedaaprire(2)
anna=0.0
openr,3,filedaaprire(2)
for i=0,(LunghezzaFile-1.0) do begin
    if EOF(3) EQ 1 then goto,FILENONVALIDO
    readf,3,a3,b3,c3
    x(i,2)=a3
    y(i,2)=b3
    if i EQ 0 then anna=a3
    x(i,2)=x(i,2)-anna
endfor
close,3
print,filedaaprire(3)
anna=0.0
openr,4,filedaaprire(3)
for i=0,(LunghezzaFile-1.0) do begin
    if EOF(4) EQ 1 then goto,FILENONVALIDO
    readf,4,a4,b4,c4
    x(i,3)=a4
    y(i,3)=b4
    if i EQ 0 then anna=a4
    x(i,3)=x(i,3)-anna
endfor
close,4

!X.RANGE=[x(0,0),x((LunghezzaFile-1.0),0)]

plot,[1.0,0,0,0]##x,[1.0,0,0,0]##y,XTITLE='Time (s)',YTITLE='# counts',TITLE=orbit+' osservazione '+tempobs+' (Trigger n.'+STRCOMPRESS(STRING(tp+1))+')',SUBTITLE='Shield n.1'
plot,[0,1.0,0,0]##x,[0,1.0,0,0]##y,XTITLE='Time (s)',YTITLE='# counts',SUBTITLE='Shield n.2'
plot,[0,0,1.0,0]##x,[0,0,1.0,0]##y,XTITLE='Time (s)',YTITLE='# counts',SUBTITLE='Shield n.3'
plot,[0,0,0,1.0]##x,[0,0,0,1.0]##y,XTITLE='Time (s)',YTITLE='# counts',SUBTITLE='Shield n.4'
close,1
close,2
close,3
close,4
goto,PRINCIPALE

FILENONVALIDO:
print,'File non valido'
goto,FINEFINALE

PRINCIPALE:print,' '
print,'Immetti 1 per accorpare, 2 zoomare, 0 per salvare il grafico o 3 terminare'
read,cosfai
if cosfai EQ 0 then goto,FINE
if cosfai EQ 1 then goto,REBIN
if cosfai EQ 2 then goto,RISCALA
if cosfai EQ 3 then goto,FINEFINALE
goto,PRINCIPALE

; ******     PROCEDURA CHE EFFETTUA UNO ZOOM DELLA CURVA     ******
; ******    RELATIVO AD UN INTERVALLO DI TEMPO SELEZIONATO   ******

RISCALA:print,'Immetti il valore minimo della X, oppure immetti -1 per tornare'
print,'all''intervallo completo'
read,minx
if minx EQ -1 then begin
   !X.RANGE=[x(0,0),x((LunghezzaFile-1.0),3)]
   GOTO,REBIN
endif
print,'Immetti il valore massimo della X'
read,maxx
if minx GT maxx then goto,RISCALA
!X.RANGE=[minx,maxx]

; ******           PROCEDURA CHE ACCORPA I DATI        ******
; ******      PER UN FATTORE d DEFINITO DALL'UTENTE    ******

REBIN:print,'Immetti il fattore per cui vuoi accorpare i dati,'
print,'oppure immetti 0 per uscire'
read,d
if d EQ 0 then goto,FINE
binstringa = STRCOMPRESS(string(7.8125*d))
print, 'intervallo di integrazione : '+binstringa+' ms' 
k1(0)=fix(LunghezzaFile/d)
xr=fltarr(k1(0),4)
yr=intarr(k1(0),4)
imax(0)=LunghezzaFile-d
i2max(0)=d-1
print,' '
print,'Accorpamento in corso. Attendere, prego ...'
for k=0,3 do begin
   for i1=0,imax(0),d do begin
      ir1(0)=i1/d
      xr(ir1(0),k)=x(i1,k)
      yr(ir1(0),k)=0
      for i2=0,i2max(0) do begin
         yr(ir1(0),k)=yr(ir1(0),k)+y(i1+i2,k)
      endfor
   endfor
endfor

; ******     PLOTTAGGIO DELLA CURVA REBINNATA      ******

plot,[1.0,0,0,0]##xr,[1.0,0,0,0]##yr,XTITLE='Time (s)',YTITLE='# counts'+binstringa+' ms',TITLE=orbit+' osservazione '+tempobs+' (Trigger n.'+STRCOMPRESS(STRING(tp+1))+')',SUBTITLE='Shield n.1'
plot,[0,1.0,0,0]##xr,[0,1.0,0,0]##yr,XTITLE='Time (s)',YTITLE='# counts'+binstringa+' ms',SUBTITLE='Shield n.2'
plot,[0,0,1.0,0]##xr,[0,0,1.0,0]##yr,XTITLE='Time (s)',YTITLE='# counts'+binstringa+' ms',SUBTITLE='Shield n.3'
plot,[0,0,0,1.0]##xr,[0,0,0,1.0]##yr,XTITLE='Time (s)',YTITLE='# counts'+binstringa+' ms',SUBTITLE='Shield n.4'

goto,PRINCIPALE


; ****** PROCEDURA CHE CALCOLA LA MEDIA E LO SCARTO DEL SEGNALE ******
; ****** NEI 7 SECONDI PRECEDENTI  IL SECONDO IN CUI SCATTA     ******
; ******                      IL TRIGGER                        ******

FINE:
spawn, 'rm idl.ps'
set_plot,'ps'
plot,[1.0,0,0,0]##xr,[1.0,0,0,0]##yr,XTITLE='Time (s)',YTITLE='# counts'+binstringa+' ms',TITLE=orbit+' osservazione '+tempobs+' (Trigger n.'+STRCOMPRESS(STRING(tp+1))+')',SUBTITLE='Shield n.1'
plot,[0,1.0,0,0]##xr,[0,1.0,0,0]##yr,XTITLE='Time (s)',YTITLE='# counts'+binstringa+' ms',SUBTITLE='Shield n.2'
plot,[0,0,1.0,0]##xr,[0,0,1.0,0]##yr,XTITLE='Time (s)',YTITLE='# counts'+binstringa+' ms',SUBTITLE='Shield n.3'
plot,[0,0,0,1.0]##xr,[0,0,0,1.0]##yr,XTITLE='Time (s)',YTITLE='# counts'+binstringa+' ms',SUBTITLE='Shield n.4'
spawn, 'lpr -Php5 idl.ps'
for j=0,3 do begin
   media2(j)=0
   for k3=0,895 do begin
      media2(j)=media2(j)+y(k3,j)
   endfor
   media2(j)=media2(j)/896.0
   sigma1(j)=0
   for k3=0,895 do begin
      sigma1(j)=sigma1(j)+((y(k3,j)-media2(j))^2)
   endfor
   sigma1(j)=sqrt(sigma1(j)/(895.0*896.0))
   media2s(j)=media2(j)*128.0
   sigma1s(j)=sigma1(j)*128.0
endfor

npicchi=0

tfine=[0.0,0.0,0.0,0.0]
binout3=[1024,1024,1024,1024]
binin3=[896,896,896,896]
stp2=[Step2Massimo,Step2Massimo,Step2Massimo,Step2Massimo]
b=[bMassimo,bMassimo,bMassimo,bMassimo]
francesca=0

; **** PROCEDURA CHE TROVA L'INIZIO DEL SEGNALE SCANDAGLIANDO LA ****
; ****    CURVA DI LUCE A STEP VARIABILE E VERIFICANDO SE IL     ****
; ****  NUMERO DEI CONTEGGI ECCEDE IL CONTEGGIO MEDIO DEL FONDO  ****
; ****        DI b(j) VOLTE LA sigma CON b(j) VARIABILE          ****         

TROVAINIZIO:
ct=0
trig=[0,0,0,0]
francesca=0

for j=0,3 do begin
   for k3=binin3(j),binout3(j),stp2(j) do begin
      media1(j)=0
      for i=0,stp2(j)-1 do begin
         media1(j)=media1(j)+y(k3+i,j)
      endfor
      if media1(j) GT ((stp2(j)*media2(j))+(b(j)*stp2(j)*sigma1(j))) then begin
         tin(j)=x(k3,j)
         if tin(j) LE tfine(j) then goto,NONCEINIZIO
         ct=ct+1
         trig(j)=1
         binin(j)=k3
         binin4(j)=k3-(stp2(j)/Step2Bias)
         binout4(j)=k3+(stp2(j)/Step2Bias)
         goto,INTERROMPI
      endif
      NONCEINIZIO:
   endfor
INTERROMPI:
;   print,j+1,binin3(j),binout3(j),stp2(j),b(j),trig(j)
;   read,dumb
endfor

if ct GE 2 THEN goto,TRIGGER
for j=0,3 do begin
   if (trig(j) EQ 0) then b(j)=b(j)-bStep
   if (b(j) LT bSoglia1) AND (npicchi LT 1) then goto,ESCI
   if (b(j) LT bSoglia2) AND (npicchi EQ 1) then goto,ESCI
endfor
goto,TROVAINIZIO
ESCI:
if npicchi LT 1 then begin
   binin3=[896,896,896,896]
   binout3=[(LunghezzaFile-1-Step2Massimo),(LunghezzaFile-1-Step2Massimo),(LunghezzaFile-1-Step2Massimo),(LunghezzaFile-1-Step2Massimo)]
   stp2=[Step2Massimo,Step2Massimo,Step2Massimo,Step2Massimo]
   b=[bMassimo,bMassimo,bMassimo,bMassimo]
   npicchi=1
   francesca=0
   goto,TROVAINIZIO
endif
print,' '
print,'Nessuna condizione di trigger'
goto,FINEFINALE


TRIGGER:
for j=0,3 do begin
   if trig(j) EQ 1 then j4=j
endfor
for j=0,3 do begin
   if trig(j) EQ 1 then begin
      if b(j) LT b(j4) then j4=j
   endif
endfor 
for j=0,3 do begin
   if trig(j) EQ 0 then begin
      binin4(j)=binin3(j)
      binout4(j)=binout3(j)
      if (b(j) GT bSoglia1) then b(j)=b(j)-bStep
   endif
endfor
binin3=binin4
binout3=binout4
for j=0,3 do begin
   if (trig(j) EQ 1) AND (stp2(j) GT ((Step2Minimo/2)+0.8)) then stp2(j)=stp2(j)/2
endfor
for j=0,3 do begin
   if (stp2(j) EQ (Step2Minimo/2)) AND (trig(j) EQ 1) then begin
      francesca=francesca+1
      stp2(j)=Step2Minimo
   endif
endfor
npicchi=0
if francesca LT ct then goto,TROVAINIZIO
for j=0,3 do begin
   if b(j) GT bSoglia1 and trig(j) EQ 0 then goto,TROVAINIZIO
endfor
binout=[(LunghezzaFile-1.0),(LunghezzaFile-1.0),(LunghezzaFile-1.0),(LunghezzaFile-1.0)]
stp=StepMassimo


; ****** ROUTINE CHE DETERMINA UN ISTANTE IN CUI IL SEGNALE ******
; ******         E' TORNATO AL LIVELLO DEL RUMORE           ******


TROVAFINE:

ct1=0
trig1=trig

for j=0,3 do begin
 if trig(j) EQ 1 then begin
   for k2=binin(j),binout(j)-stp,stp do begin
      media1(j)=0
      for i=0,stp-1 do begin
         media1(j)=media1(j)+y(k2+i,j)
      endfor
      if (media1(j) LT ((stp*media2(j))+(bFinale*stp*sigma1(j)))) AND (trig1(j) EQ 1) then begin
         tfine(j)=x(k2+stp-1,j)
         if tfine(j) LT tin(j) then goto,NONCEFINE
         ct1=ct1+1
         trig1(j)=0
         binin2(j)=k2-(stp/StepBias)
         binout2(j)=k2+(stp/StepBias)
         goto,INTERROMPI2
      endif
   NONCEFINE:
   endfor
   INTERROMPI2:
   if ct1 EQ ct then goto,FINITO
 endif
endfor

print,'Il burst non termina mai'
goto,FINEFINALE

;****   CONTROLLO DELLA COINCIDENZA TEMPORALE   ****
;****         DEGLI EVENTI INDIVIDUATI          ****

FINITO:
binin=binin2
binout=binout2
stp=stp/2.0
if stp GT ((StepMinimo/2.0)+1) then goto,TROVAFINE
for jj=3,1,-1 do begin
   for jjj=0,jj-1 do begin
      if (ABS((tin(jj)-tin(jjj))) LT 1.0) AND (trig(jj) EQ 1) AND (trig(jjj) EQ 1) then goto,FINE2
   endfor
endfor
for j=0,3 do begin
   if trig(j) EQ 1 then j3=j
endfor
for j=0,3 do begin
   if (binout(j) LT binout(j3)) AND (trig(j) EQ 1) then j3=j
endfor
binin3=[binout(j3),binout(j3),binout(j3),binout(j3)]
binout3=[(LunghezzaFile-1-Step2Massimo),(LunghezzaFile-1-Step2Massimo),(LunghezzaFile-1-Step2Massimo),(LunghezzaFile-1-Step2Massimo)]
tfine=[x(binout(j3),0),x(binout(j3),1),x(binout(j3),2),x(binout(j3),3)]
stp2=[Step2Massimo,Step2Massimo,Step2Massimo,Step2Massimo]
b=[bMassimo,bMassimo,bMassimo,bMassimo]
francesca=0
npicchi=1
;goto,TROVAINIZIO

FINE2:
for cinzia=0,3 do begin
 for jjjj=0,3 do begin
   bandierina=0
   for jjjjj=0,3 do begin
      if (ABS(tin(jjjj)-tin(jjjjj)) LT 1.0) AND (jjjj NE jjjjj) AND (trig(jjjj) EQ 1) AND (trig(jjjjj) EQ 1) then begin
         bandierina=bandierina+1
      endif
   endfor
   if bandierina LT 1 then begin
      for j=0,3 do begin
         if (trig(j) EQ 1) AND (j NE jjjj) then jack=j
      endfor
      for j=0,3 do begin
         if (binin3(j) LT binin3(jack)) AND (j NE jjjj) AND (trig(j) EQ 1) then jack=j
      endfor
      if (binout(jjjj) LT binin3(jack)) AND (jack NE jjjj) AND (trig(jack) EQ 1) AND (trig(jjjj) EQ 1) then begin
         trig=[0,0,0,0]
         binin3=[binout(jjjj),binout(jjjj),binout(jjjj),binout(jjjj)]
         tfine=[x(binout(jjjj),0),x(binout(jjjj),1),x(binout(jjjj),2),x(binout(jjjj),3)]
         binout3=[(LunghezzaFile-1-Step2Massimo),(LunghezzaFile-1-Step2Massimo),(LunghezzaFile-1-Step2Massimo),(LunghezzaFile-1-Step2Massimo)]
         npicchi=1
         stp2=[Step2Massimo,Step2Massimo,Step2Massimo,Step2Massimo]
         b=[bMassimo,bMassimo,bMassimo,bMassimo]
         ;goto,TROVAINIZIO
      endif
      for j=0,3 do begin
         if (binout(j) GT binout(jack)) AND (j NE jjjj) AND (trig(j) EQ 1) then jack=j
      endfor
      if (binin3(jjjj) GT binout(jack)) then trig(jjjj)=0
   endif
 endfor
endfor
print,'Trigger scattato: schermi, tempi , sigma'
for j=0,3 do begin
   if trig(j) EQ 1 then print,j+1,tin(j),b(j)
endfor
print,' '
print,'Il burst termina nei seguenti schermi nel seguente istante'
for j=0,3 do begin
   if trig(j) EQ 1 then print,j+1,tfine(j),'1'
endfor
for j=0,3 do begin
   if trig(j) EQ 1 then begin
      j1=j
      j2=j
   endif
endfor

; ****** VIENE DETERMINATO UN INTERVALLO SULLE ASCISSE ******
; ****** CHE INQUADRI IL SEGNALE PER TUTTI GLI SCHERMI ******

for j=0,3 do begin
   if (binin3(j) LT binin3(j1)) AND (trig(j) EQ 1) then j1=j
   if (binout(j) GT binout(j2)) AND (trig(j) EQ 1) then j2=j
endfor
!X.RANGE=[x(binin3(j1)-64,j1),x(MIN([binout(j2)+64,LunghezzaFile-1.0]),j2)]

; ******           SI TORNA AD ACCORPARE I DATI        ******


dimensione(0)=fix((binout(j2)+2.0-binin3(j1))/d)

if dimensione(0) LE 0 then begin
   print,' '
   print,'Troppi pochi punti. Modificare il fattore di accorpamento e riprovare'
   print,' '
   goto,REBIN
endif

; ******   SELEZIONA DELLE PORZIONI DI CURVA  ******
; ******           ACCORPATE E ZOOMATE        ******

yr1=intarr(dimensione(0))
xr1=fltarr(dimensione(0))
yr2=yr1
xr2=xr1
yr3=yr1
xr3=xr1
yr4=yr1
xr4=xr1

minr(0)=fix((binin3(j1)-1.0)/d)


mafalda=FIX(MIN([(dimensione(0)-1),fix((LunghezzaFile-1.0)/d)-1-minr(0)]))


for i=0,mafalda do begin
   yr1(i)=yr(minr(0)+i,0)
   xr1(i)=xr(minr(0)+i,0)
   yr2(i)=yr(minr(0)+i,1)
   xr2(i)=xr(minr(0)+i,1)
   yr3(i)=yr(minr(0)+i,2)
   xr3(i)=xr(minr(0)+i,2)
   yr4(i)=yr(minr(0)+i,3)
   xr4(i)=xr(minr(0)+i,3)
endfor

; ****** INDIVIDUA L'ISTANTE CON MASSIMO NUMERO DI CONTEGGI ******

massimo(0)=MAX(yr1,k61)
massimo(1)=MAX(yr2,k62)
massimo(2)=MAX(yr3,k63)
massimo(3)=MAX(yr4,k64)
tmassimo(0)=xr1(k61)
tmassimo(1)=xr2(k62)
tmassimo(2)=xr3(k63)
tmassimo(3)=xr4(k64)

print,'I massimi sono stati i seguenti:'
print,' '
print,'Schermo  ',' valore','       tempo'
for j=0,3 do begin
   if trig(j) EQ 1 then print,j+1,massimo(j),tmassimo(j)
endfor
print,' '
print,'Premi 0 per continuare, o premi 1 per riaccorpare'
read,cosavuoifareora
if cosavuoifareora EQ 1 then goto,PRINCIPALE 

durata=tfine-tin

; ******  PROCEDURA CHE CALCOLA INIZIO E FINE DEL SEGNALE  ******
; ******               CON IL METODO DEL "T90"             ******

t90start1=[0.0,0.0,0.0,0.0]
t90start=[0.0,0.0,0.0,0.0]
t90start2=[0.0,0.0,0.0,0.0]
t90end1=[0.0,0.0,0.0,0.0]
t90end=[0.0,0.0,0.0,0.0]
t90end2=[0.0,0.0,0.0,0.0]
area=[0.0,0.0,0.0,0.0]
fester=[0,0,0,0]

for j=0,3 do begin
   somma=0.0
   sigmaarea=0.0
   for i=binin3(j1)-BinInizioT90,binout(j2)+BinFineT90 do begin
      area(j)=area(j)+y(i,j)-media2(j)
   endfor
   sigmaarea=sqrt(area(j)+(((binout(j2)-binin3(j1)+(BinInizioT90+BinFineT90)))*media2(j))+(((binout(j2)-binin3(j1)+(BinInizioT90+BinFineT90))*sigma1(j))^2))
   bandierina2=0
   for i=binin3(j1)-BinInizioT90,binout(j2)+BinFineT90 do begin
      somma=somma+y(i,j)-media2(j)
      if (somma GE (0.05*(area(j)-sigmaarea))) AND (bandierina2 EQ 0) then begin
         t90start1(j)=x(i-1,j)
         bandierina2=1
      endif
      if (somma GE (0.05*area(j))) AND (bandierina2 EQ 1) then begin
         t90start(j)=x(i-1,j)
         bandierina2=2
      endif
      if (somma GE (0.05*(area(j)+sigmaarea))) AND (bandierina2 EQ 2) then begin
         t90start2(j)=x(i-1,j)
         bandierina2=3
      endif
      if (somma GE (0.95*(area(j)-sigmaarea))) AND (bandierina2 EQ 3) then begin
         t90end1(j)=x(i,j)
         bandierina2=4
      endif
      if (somma GE (0.95*area(j))) AND (bandierina2 EQ 4) then begin
         t90end(j)=x(i,j)
         bandierina2=5
      endif
      if (somma GE (0.95*(area(j)+sigmaarea))) AND (bandierina2 EQ 5) then begin
         t90end2(j)=x(i,j)
         goto,T90
      endif
   endfor
T90:
if t90end2(j) EQ 0.0 then begin
   t90end2(j)=x(binout(j2)+Step2Minimo,j)
   fester(j)=1
endif
endfor

durataT90=t90end-t90start

areamax=MAX(area,jarea)

durataeventoT90media=durataT90(jarea)
durataeventoT90max=t90end2(jarea)-t90start1(jarea)
durataeventoT90min=t90end1(jarea)-t90start2(jarea)

if durataeventoT90min EQ durataeventoT90media then durataeventoT90min=durataeventoT90media-0.0023
if durataeventoT90max EQ durataeventoT90media then durataeventoT90max=durataeventoT90media+0.0023

print,' '
print,'Durata evento:'
print,'Minima:',durataeventoT90min
print,'Media:',durataeventoT90media
if fester(jarea) EQ 0 then print,'Massima:',durataeventoT90max
if fester(jarea) EQ 1 then print,'Massima:',durataeventoT90max,'   (Warning:computed using T100)'

; ******       VIENE DETERMINATA LA DURATA DEL SEGNALE      ******
; ******     USANDO COME TEMPO DI INIZIO QUELLO TROVATO     ******
; ******     COL METODO DELLA sigma E COME TEMPO DI FINE    ******
; ******                   QUELLO DEL T90                   ******


dur=t90end-tin

for j=0,3 do begin
   if dur(j) LE 0.0 then trig(j)=0
endfor

; ******  ROUTINE CHE EFFETTUA LA CROSSCORRELAZIONE FRA  ******
; ******     PORZIONI DI CURVA PER VARI SFASAMENTI       ******
; ******  PER OGNI COPPIA DI SCHERMI SU CUI C'E' TRIGGER ******

lag=intarr(fix((257.0/d))+1)

for u=0,(256.0/d) do begin
   lag(u)=u-fix((128.0/d))
endfor

dimme=fix((-binin3(j1)+binout(j2)+512.0)/d)

yc1=intarr(dimme)
yc2=intarr(dimme)
yc3=intarr(dimme)
yc4=intarr(dimme)

marisa=FIX(MIN([(dimme-1),FIX((LunghezzaFile-1.0)/d)-1-FIX(((binin3(j1)-256.0)/d))]))

for i=0,marisa do begin
   yc1(i)=yr(fix(((binin3(j1)-256.0)/d))+i,0)
   yc2(i)=yr(fix(((binin3(j1)-256.0)/d))+i,1)
   yc3(i)=yr(fix(((binin3(j1)-256.0)/d))+i,2)
   yc4(i)=yr(fix(((binin3(j1)-256.0)/d))+i,3)
endfor

for jennifer=0,3 do begin
   for juliette=0,3 do begin
      teresa(jennifer,juliette)=0
   endfor
endfor
print,' '
print,'    Schermi,     crosscorr,  sfasamento'
for jennifer=1,3 do begin
   if trig(jennifer) EQ 1 then begin
      for juliette=0,(jennifer-1) do begin
         if trig(juliette) EQ 1 then begin
             bandierina3=0
             if jennifer EQ 1 then begin
               if juliette EQ 0 then begin
                  correlatio=C_CORRELATE(yc2,yc1,lag)
                  bandierina3=1
               endif
            endif  
            if jennifer EQ 2 then begin
               if juliette EQ 0 then begin
                  correlatio=C_CORRELATE(yc3,yc1,lag)
                  bandierina3=1
               endif
               if juliette EQ 1 then begin
                  correlatio=C_CORRELATE(yc3,yc2,lag)
                  bandierina3=1
               endif
            endif
            if jennifer EQ 3 then begin
               if juliette EQ 0 then begin
                  correlatio=C_CORRELATE(yc4,yc1,lag)
                  bandierina3=1
               endif
               if juliette EQ 1 then begin
                  correlatio=C_CORRELATE(yc4,yc2,lag)
                  bandierina3=1
               endif
               if juliette EQ 2 then begin
                  correlatio=C_CORRELATE(yc4,yc3,lag)
                  bandierina3=1
               endif
            endif

; ******   PER OGNI COPPIA DI SCHERMI CROSSCORRELATI SALVA      ******
; ******   IL VALORE DELLO SFASAMENTO PER CUI LA CROSS E'       ******
; ******   MASSIMA ED I VALORI DELLA CROSSS PER SFASAMENTO      ******
; ******   APPENA MINORE (correlP) ED APPENA MAGGIORE (correlD) ******

            if bandierina3 EQ 1 then begin
               NTERMS=6
               corrfit=correlatio
               correlatioM=MAX(corrfit,k99)
               print,jennifer+1,juliette+1,correlatioM,lag(k99)
               teresa(jennifer,juliette)=1
               deltafi(jennifer,juliette)=lag(k99)
               correlM(jennifer,juliette)=corrfit(k99)
               if k99 GT 0 then begin
                  correlP(jennifer,juliette)=corrfit(k99-1)
               endif else begin
                  correlP(jennifer,juliette)=0.0
               endelse
               if k99 LT (N_ELEMENTS(corrfit)-1) then begin
                  correlD(jennifer,juliette)=corrfit(k99+1)
               endif else begin
                  correlD(jennifer,juliette)=0.0
               endelse

            endif
         endif
      endfor
   endif
endfor

;****   CALCOLO DELLA LARGHEZZA A MEZZA ALTEZZA (fwhm)   ****

fwhmsx=FLTARR(4)
fwhmdx=FLTARR(4)
fwhmsx=[0.0,0.0,0.0,0.0]
fwhmdx=[0.0,0.0,0.0,0.0]
for jap=0,3 do begin
     alien=0
     alien2=0
     if trig(jap) EQ 1 THEN begin
       for alien=binin3(j1),binout(j2),d do begin
         if(yr(fix(alien/d),jap)-(media2(jap)*d)) GT ((massimo(jap)-(d*media2(jap)))/2.0) THEN begin
              fwhmsx(jap)=alien
              alien=binout(j2)
         endif
       endfor
       for alien2=binout(j2),binin3(j1),-d do begin
         if(yr(fix(alien2/d),jap)-(media2(jap)*d)) GT ((massimo(jap)-(d*media2(jap)))/2.0) THEN begin
              fwhmdx(jap)=alien2+d
              alien2=binin3(j1)
         endif
       endfor
     endif
endfor
fwhm=(fwhmdx-fwhmsx)/128.0
for jaz=0,3 do begin
   if fwhm(jaz) LT 0 then fwhm(jaz)=0
endfor
print,' '
print,'FWHM=',fwhm









beatrice=[0,0,0,0]; ** VETTORE CHE PUNTA GLI SCHERMI CON SEGNALE BUONO

; ****** PER OGNI COPPIA DI SCHERMI ASSEGNA UN VALORE
; ****** DA SOMMARE ALLA VARIABILE punteggio 
; ****** CON I SEGUENTI CRITERI:
; ****** 1) SE LA DIFFERENZA FRA I TEMPI DI SALITA
; ******    E' MAGGIORE DEL 20% DELLA MASSIMA FRA LE
; ******    DUE ASSEGNA UN PUNTO
; ****** 2) SE LA DIFFERENZA FRA LE DURATE E' n VOLTE 
; ******    10% DELLA DURATA MAX IN BIN AGGIUNGI n PUNTI
; ****** 3) SE LO SFASAMENTO RELATIVO AL MAX VALORE DELLA
; ******    CROSS (IN BIN) E' MAGGIORE DI n VOLTE IL 10% 
; ******    DELLA DURATA MAX IN BIN AGGIUNGI n PUNTI
; ****** 4a) AGGIUNGI n PUNTI SE LA CORRELAZIONE NEL VALORE 
; ******    PRECEDENTE IL MAX E' MINORE DI n VOLTE IL 10%
; ******    DELLA CORRELAZIONE MASSIMA
; ****** 4b) AGGIUNGI n PUNTI SE LA CORRELAZIONE NEL VALORE 
; ******    SUCCESSIVO IL MAX E' MINORE DI n VOLTE IL 10%
; ******    DELLA CORRELAZIONE MASSIMA
; ****** 5) AGGIUNGE PUNTI PER DIFFERENTI FWHM

print,' '
print,'Coppie    Punti'
for jennifer=3,0,-1 do begin
   for juliette=3,0,-1 do begin
      punteggio=0.0
      if teresa(jennifer,juliette) EQ 1 then begin 
         durmax=MAX([dur(jennifer),dur(juliette)])
         dtmax=MAX([(tmassimo(jennifer)-tin(jennifer)),(tmassimo(juliette)-tin(juliette))])
         if ABS((tmassimo(jennifer)-tin(jennifer))-(tmassimo(juliette)-tin(juliette)) GE 0.2*dtmax) then punteggio=punteggio+1
         for n=4,2,-1 do begin
            if (ABS(dur(jennifer)-dur(juliette)) GE 0.1*n*durmax) then begin
               punteggio=punteggio+n
               n=-100
            endif
         endfor
         for n=4,2,-1 do begin
            if ABS(deltafi(jennifer,juliette)*d) GE ABS(durmax*12.8*n) then begin
               punteggio=punteggio+n
               n=-100
            endif
         endfor
         for n1=0.1,0.4,0.1 do begin
            if (correlP(jennifer,juliette)/correlM(jennifer,juliette)) LE n1 then begin
               punteggio=punteggio+(0.1/n1)
               n1=200.1
            endif
         endfor
         for n2=0.1,0.4,0.1 do begin
            if (correlD(jennifer,juliette)/correlM(jennifer,juliette)) LE n2 then begin
               ;incremento = (0.1/n2)
	       punteggio=punteggio+(0.1/n2)
               n2=200.1
            endif
         endfor
         h=0
         fwhmmax=MAX([fwhm(jennifer),fwhm(juliette)])
         if ABS(fwhm(jennifer)-fwhm(juliette)) GE (0.5*fwhmmax) THEN begin
                   punteggio=punteggio+4 
                   h=1
         endif
         if (ABS(fwhm(jennifer)-fwhm(juliette)) GE (0.4*fwhmmax)) AND (h EQ 0) THEN begin
                   punteggio=punteggio+2
                   h=1
         endif
         if (ABS(fwhm(jennifer)-fwhm(juliette)) GE (0.3*fwhmmax)) AND (h EQ 0) THEN punteggio=punteggio+1
         h=0
         print,jennifer+1,juliette+1,punteggio
         if punteggio GE 4 then begin
            print,'Spike!!'
         endif else begin
            beatrice(jennifer)=1
            beatrice(juliette)=1
         endelse
      endif
   endfor
endfor


; ******  SCRIVI I DATI RELATIVI AL SEGNALE  *****

print,'Burst sui seguenti schermi:'

print,' '
print,'   Schermo   ','inizio       ','fine         ','durata       ','massimo      ','tmassimo'
for j=0,3 do begin
   if dur(j) LE 0 then beatrice(j)=0
   if beatrice(j) EQ 1 then print,j+1,tin(j),t90end(j),dur(j),massimo(j),tmassimo(j)
endfor

binin3=[binout(j2),binout(j2),binout(j2),binout(j2)]
binout3=[(LunghezzaFile-1-Step2Massimo),(LunghezzaFile-1-Step2Massimo),(LunghezzaFile-1-Step2Massimo),(LunghezzaFile-1-Step2Massimo)]
stp2=[Step2Massimo,Step2Massimo,Step2Massimo,Step2Massimo]
b=[bMassimo,bMassimo,bMassimo,bMassimo]
npicchi=1
francesca=0
;goto,TROVAINIZIO


FINEFINALE:


print, 'esecuzione terminata'
end
