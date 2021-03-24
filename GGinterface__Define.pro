		;*******************************
		;**** interfaccia per l'uso ****
		;****    del GRBMhandler    ****
		;*******************************

;------------------------------------------------------------------------------
;**** metodo che inizializza l'oggetto ****
;------------------------------------------------------------------------------



function GGinterface::Init, ghandler
  self.handler = ghandler
  return, 1
end

;------------------------------------------------------------------------------
;**** metodo che distrugge l'oggetto ****
;------------------------------------------------------------------------------

pro GGinterface::Cleanup
  ;self->Sinterface::cleanup
  print, 'distruggo oggetto GGinterface'
  obj_destroy, self
end


;------------------------------------------------------------------------------
;**** metodo che attiva l'interfaccia ****
;------------------------------------------------------------------------------

pro GGinterface::Enable

  print, '***********************************'
  print, '**** programma per la gestione ****'
  print, '**** 	  archivio GRBM	       ****'
  print, '***********************************'
  print

self -> legenda  

  a = 7
  while (a NE 0) do  begin
 	read, a
	CASE (a) OF
		
		0: BEGIN 
                   print, 'elaborazione terminata'
		   
        	END
		
		1: BEGIN 
                   print, 'updating archive ...'
		   spawn, 'script1'	
		   self -> legenda
        	END
        
		2: BEGIN 
                   print, 'data analysing'
		   self -> OPdata
		   self -> legenda
           	END
        	
		3: BEGIN 
		   self -> coverage
		   self -> legenda
	        END
		
		4: BEGIN 
               	   print, 'mostra la lista'
		   self -> writelist
		   self -> legenda
	        END
	
	ENDCASE

  endwhile
  print, 'arrivederci'

end

pro GGinterface::legenda
  print, 'selezionare la funzione' 
  print, 'e premere invio' 
  print 
  print, '0 = termina l''elaborazione'
  print 
  print, '1 = aggiorna l''archivio'
  print
  print, '2 = analizza i dati'
  print
  print, '3 = mostra la copertura'
  print
  print, '4 = mostra la lista'
end

;------------------------------------------------------------------------------
;**** metodo che restituisce i dati per l'OP selezionato ****
;------------------------------------------------------------------------------

pro GGinterface::OPdata
  
  opstr1 = ''
  print, 'OP scelto ?'
  read, opstr1
  print, 'hai scelto l''OP ', opstr1
  self.handler -> writeop, opstr1
end

;------------------------------------------------------------------------------
;**** metodo che stampa la lista degli OP in archivio ****
;------------------------------------------------------------------------------

pro GGinterface::writelist
  self.handler -> writelist
end

;------------------------------------------------------------------------------
;**** metodo che fornisce la copertura dei dati in archivio ****
;------------------------------------------------------------------------------

pro GGinterface::coverage
  self.handler -> coverage
end



;PRO GGinterface::widget2_event, ev , tarchivio

PRO widget2_event, ev
;tarchivio = obj_new('GRBMhandGraf')
print, obj_valid
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
	  self -> OPdata
	  self -> legenda
	  END

'mostra_cop' : BEGIN
	  WIDGET_CONTROL, controllo, SET_VALUE='mostro la copertura'
	  self -> coverage
	  self -> legenda
	  END

'mostra_list' : BEGIN
	  WIDGET_CONTROL, controllo, SET_VALUE='mostro la lista'
	  self -> writelist
	  self -> legenda
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

PRO GGinterface::GRBMinterface ;, archy
;spawn, 'idl GRBMcompile'

;tarchivio = OBJ_NEW('GRBMhandGraf')
;tarchivio = archy
;tarchivio -> loadall

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
xmanager, 'widget2', base	;, self.handler
END




;------------------------------------------------------------------------------
;4.Define the object
;------------------------------------------------------------------------------

                      pro GGinterface__Define
                           struct={GGinterface,$
                           ;inherits Sinterface,$
;                            ...
;                            ...
			    handler:OBJ_NEW() $
                            }
                      end
