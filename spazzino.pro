; **** oggetti per I/O ****



PRO widget2_event, ev




WIDGET_CONTROL, ev.top, GET_UVALUE=controllo; salva il valore dell' ID del campo testo text in controllo
WIDGET_CONTROL, ev.id, GET_UVALUE=uval
WIDGET_CONTROL, ev.id, GET_VALUE=stringa1

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
	   percorso='/users/sax/lazza/spazzino/' 
	   spawn , 'idl '+percorso+'parti'	  


	  ;spazzino, io
	  END
  'TWO' : BEGIN
	  WIDGET_CONTROL, controllo, SET_VALUE=''
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

PRO widget2

Result = DIALOG_MESSAGE('selezionare i files di ingresso e uscita', information = 'true', title = 'istruzioni')
base = WIDGET_BASE(/COLUMN)
button1 = WIDGET_BUTTON(base, VALUE='invio',  UVALUE='ONE')
button2 = WIDGET_BUTTON(base, VALUE='cancella', UVALUE='TWO')
                              						;EVENT_PRO='spazzino',
nomeinput = WIDGET_TEXT(base, EDITABLE=1,UVALUE='IN',  XSIZE=40); nomeinput = ID per il campo di testo

nomeoutput = WIDGET_TEXT(base, EDITABLE=1,UVALUE='OUT',XSIZE=40); nomeoutput = ID per il campo di testo

text = WIDGET_TEXT(base, XSIZE=60); text = ID per il campo di testo
button3 = WIDGET_BUTTON(base, value='termina', UVALUE='DONE')
WIDGET_CONTROL, base, SET_UVALUE=text; valore utente di base = text
WIDGET_CONTROL, base, /REALIZE
xmanager, 'Widget2', base
END
