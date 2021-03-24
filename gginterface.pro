; **** oggetti per I/O ****

;pro Ginterface::legenda
 ; print, 'selezionare la funzione' 
 ; print, 'e premere invio' 
 ; print 
 ; print, '0 = termina l''elaborazione'
 ; print 
 ; print, '1 = aggiorna l''archivio'
 ; print
 ; print, '2 = analizza i dati'
 ; print
 ; print, '3 = mostra la copertura'
 ; print
 ; print, '4 = mostra la lista'
;end


PRO widget2_event, ev	;, tarchivio

;tarchivio = obj_new(GRBMhandGraf)
;tarchivio = archivio

WIDGET_CONTROL, ev.top, GET_UVALUE=controllo; salva il valore dell' ID del campo testo text in controllo
WIDGET_CONTROL, ev.id, GET_UVALUE=uval
WIDGET_CONTROL, ev.id, GET_VALUE=stringa1

;-----------------------------------------------------------------------------------------------------
; ROUTINE CHE DIRAMA FRA LE PROCEDURE 
;-----------------------------------------------------------------------------------------------------

CASE uval OF
  
'ONE' : BEGIN
	  ;WIDGET_CONTROL, controllo, SET_VALUE='invia'
	  stringa2 = 'inn'
	  stringa3 = 'out'
	  WIDGET_CONTROL, controllo, GET_VALUE=io

	   openw, 1, 'files.txt' ; **** si apre il file che raccoglie le voci scartate	
	   printf, 1, io
	   close, 1	
	   print, io
	   percorso='/users/sax/lazza/objects2/objects/' 
	   spawn , 'idl '+percorso+'go!'	  

	  ;spazzino, io
	  END

'TWO' : BEGIN
	  WIDGET_CONTROL, controllo, SET_VALUE=''
	  END
	  

'aggiorna' : BEGIN
	  WIDGET_CONTROL, controllo, SET_VALUE='aggiorno l''archivio'
	  spawn, 'script1' 
	  END

'analizza' : BEGIN
	  WIDGET_CONTROL, controllo, SET_VALUE='analizzo i dati'
	    archivio ->
	  END

'mostra_cop' : BEGIN
	  WIDGET_CONTROL, controllo, SET_VALUE='mostro la copertura'
	  END

'mostra_list' : BEGIN
	  WIDGET_CONTROL, controllo, SET_VALUE='mostro la lista'
	  END

  'IN'  : BEGIN	
	  WIDGET_CONTROL, controllo, SET_VALUE='inputfile = '+stringa1+' ', /APPEND 
	  gestinput, stringa1	   
	  END

  'OUT' : BEGIN
	  WIDGET_CONTROL, controllo, SET_VALUE='outputfile = '+stringa1+' ', /APPEND
	  gestoutput, stringa1
	  END

  'DONE': WIDGET_CONTROL, ev.top, /DESTROY

ENDCASE

END

PRO GRBMinterface
;spawn, 'idl GRBMcompile'

archivio = OBJ_NEW('GRBMhandGraf')
archivio -> loadall

Result = DIALOG_MESSAGE('selezionare le opzioni desiderate', information = 'true', title = 'istruzioni')
base = WIDGET_BASE(/COLUMN)
button1 = WIDGET_BUTTON(base, VALUE='invio',  UVALUE='ONE')
button2 = WIDGET_BUTTON(base, VALUE='cancella', UVALUE='TWO')
button3 = WIDGET_BUTTON(base, value='termina', UVALUE='DONE')
button4 = WIDGET_BUTTON(base, VALUE='aggiorna l''archivio', UVALUE='aggiorna')
button5 = WIDGET_BUTTON(base, VALUE='analizza i dati', UVALUE='analizza')
button6 = WIDGET_BUTTON(base, VALUE='mostra la copertura', UVALUE='mostra_cop')
button7 = WIDGET_BUTTON(base, VALUE='mostra la lista', UVALUE='mostra_list')

;button7 = WIDGET_BUTTON(base, VALUE='', UVALUE='SEVEN')
                              						
;EVENT_PRO='spazzino',
nomeinput = WIDGET_TEXT(base, EDITABLE=1,UVALUE='IN',  XSIZE=40); nomeinput = ID per il campo di testo

nomeoutput = WIDGET_TEXT(base, EDITABLE=1,UVALUE='OUT',XSIZE=40); nomeoutput = ID per il campo di testo

text = WIDGET_TEXT(base, XSIZE=60); text = ID per il campo di testo

WIDGET_CONTROL, base, SET_UVALUE=text; valore utente di base = text
WIDGET_CONTROL, base, /REALIZE
xmanager, 'Widget2', base
END
