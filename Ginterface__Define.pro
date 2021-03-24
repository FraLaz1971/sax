		;*******************************
		;**** interfaccia per l'uso ****
		;****    del GRBMhandler    ****
		;*******************************

;------------------------------------------------------------------------------
;**** metodo che inizializza l'oggetto ****
;------------------------------------------------------------------------------



function Ginterface::Init, ghandler
  self.handler = ghandler
  return, 1
end

;------------------------------------------------------------------------------
;**** metodo che distrugge l'oggetto ****
;------------------------------------------------------------------------------

pro Ginterface::Cleanup
  ;self->Sinterface::cleanup
  print, 'distruggo oggetto Ginterface'
  obj_destroy, self
end


;------------------------------------------------------------------------------
;**** metodo che attiva l'interfaccia ****
;------------------------------------------------------------------------------

pro Ginterface::Enable

  print, '***********************************'
  print, '**** programma per la gestione ****'
  print, '**** 	  archivio GRBM	       ****'
  print, '***********************************'
  print

self -> legenda  

  a = 9
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
                   print, 'showing data '
		   ;self -> analyseAll	
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

		5: BEGIN 
               	   print, 'genera curve di luce'
		   self -> creacurve
		   self -> legenda
	        END
		
	
		6: BEGIN 
               	   print, 'analizza curve di luce'
		   self -> SDI
		  
		   self -> legenda
	        END
	
		7: BEGIN 
               	   print, 'comprimi i dati'
		   self -> zip
		   self -> legenda
	        END
	

		8: BEGIN 
               	   print, 'analizza tutto l''archivio'
		   self -> ini
		   self -> analyseAll
		   self -> legenda
	        END
		
		9: BEGIN 
		   print
               	   print, 'estrazione eventi in atto'		  
		   self -> risultati
		   self -> legenda
	        END
		
		
		10: BEGIN
		   print 
               	   print, 'stampa dei grafici in atto'		  
		   self -> plot
		   self -> legenda
	        END	
		
		ELSE: BEGIN
		   print
		   print, 'inserire un valore del menu'''
		   print			   
		END
		
	ENDCASE

  endwhile
  print, 'arrivederci'

end

pro Ginterface::legenda
  print
  print, 'selezionare la funzione' 
  print, 'e premere invio' 
  print 
  print, '0 = termina l''elaborazione'
  print 
  print, '1 = aggiorna l''archivio'
  print
  print, '2 = mostra i dati'
  print
  print, '3 = mostra la copertura'
  print
  print, '4 = mostra la lista'
  print
  print, '5 = crea le curve'
  print
  print, '6 = analizza le curve'
  print
  print, '7 = comprimi i dati'
  print	
  print, '8 = analizza archivio'
  print
  print, '9 = estrai gli eventi'
  print
  print, '10 = stampa i grafici'
  print	
end

;------------------------------------------------------------------------------
;**** metodo che restituisce i dati per l'OP selezionato ****
;------------------------------------------------------------------------------

pro Ginterface::OPdata  
  opstr1 = ''
  print, 'OP scelto ?'
  read, opstr1
  print, 'hai scelto l''OP ', opstr1
  self.handler -> writeop, opstr1
end

;------------------------------------------------------------------------------
;**** metodo che stampa la lista degli OP in archivio ****
;------------------------------------------------------------------------------

pro Ginterface::writelist
  self.handler -> writelist
end
;------------------------------------------------------------------------------
;**** metodo che stampa i grafici dell'evento salvato ****
;------------------------------------------------------------------------------

pro Ginterface::plot
  spawn, 'lpr -Php5 idl.ps' 
end
;------------------------------------------------------------------------------
;**** metodo che salva la durata di un burst ****
;------------------------------------------------------------------------------

pro Ginterface::saveduration
  self.handler -> saveduration
end
;------------------------------------------------------------------------------
;**** metodo che salva informazioni  ****
;------------------------------------------------------------------------------

pro Ginterface::writelog, gmessage
  self.handler -> writelog, gmessage
end

;------------------------------------------------------------------------------
;**** metodo che analizza le curve per  OP e osservazione selezionati ****
;------------------------------------------------------------------------------

pro Ginterface::SDI
  tempOP = ''
  tempobs = ''
  print
  print, 'OP selezionato ? '
  read, tempOP 
  print, 'osservazione selezionata ?'
  read, tempobs
  print
  print, 'analizzo curve di luce per OP : '+tempOP+' osservazione '+tempobs
  self.handler -> select, tempOP, tempobs
  index = 0b
  print
  print, 'indice nell''osservazione ?'
  read, index
  close, 17 
  openw, 17, 'AcTrig.txt'
  printf, 17, index - 1b
  close, 17 
  print, 'visualizza trigger n.', index
  self.handler -> SDIman, index - 1b

;self.handler -> cleanOP	

end

;------------------------------------------------------------------------------
;**** METODO CHE GENERA CURVE DI LUCE ****
;------------------------------------------------------------------------------

pro Ginterface::creacurve
  tempOP = ''
  tempobs = ''
  print
  print, 'OP selezionato ? '
  read, tempOP 
  print, 'osservazione selezionata ?'
  read, tempobs
  print
  print, 'genero curve di luce per OP : '+tempOP+' osservazione '+tempobs
  self.handler -> select, tempOP, tempobs
  self.handler -> unzip
  self.handler -> creacurve  
end

;------------------------------------------------------------------------------
;**** METODO CHE GENERA CURVE DI LUCE ****
;------------------------------------------------------------------------------

pro Ginterface::zip
  tempOP = ''
  tempobs = ''
  print
  print, 'OP selezionato ? '
  read, tempOP 
  print, 'osservazione selezionata ?'
  read, tempobs
  print
  print, 'genero curve di luce per OP : '+tempOP+' osservazione '+tempobs
  self.handler -> select, tempOP, tempobs
  self.handler -> zip  
end


;------------------------------------------------------------------------------
;**** metodo che legge e salva i dati di SDI ****
;------------------------------------------------------------------------------
pro Ginterface::savelogSDI
  tempstring = ''
  close, 44, 'SDIresult.txt'
  openr, 44, 'SDIresult.txt'
  while(NOT EOF(44)) do begin
    readf, 44, tempstring
    self -> writelog, tempstring    
  endwhile
  close, 44  
end
;------------------------------------------------------------------------------
;**** metodo che fornisce la copertura dei dati in archivio ****
;------------------------------------------------------------------------------

pro Ginterface::coverage
  self.handler -> coverage
end

;------------------------------------------------------------------------------
;  ESTRAI GLI EVENTI SGR
;------------------------------------------------------------------------------

pro Ginterface::findSGR
  self.handler -> findSGR
end

;------------------------------------------------------------------------------
;  ESTRAI GLI EVENTI SGR
;------------------------------------------------------------------------------

pro Ginterface::print
   print
   print, 'stampare il grafico sulla stampante hp5 ? (y/n)'
   print
   risp1 = ''
   while (risp1 NE 'n') do begin
 	read, risp1
	CASE (risp1) OF		
		n: BEGIN 
                   print, 'grafico non stampato'		   
        	END
		
		y: BEGIN 
                   print, 'stampa in corso ...'
		   spawn, 'lpr -Php5 idl.ps'
        	END 
	ENDCASE       
   endwhile 
end

;------------------------------------------------------------------------------
;**** metodo che inizializza alla lettura dell'archivio ****
;------------------------------------------------------------------------------

pro Ginterface::ini
  close, 17 
  openw, 17, 'AcTrig.txt'
  printf, 17, 0b
  close, 17 

  close, 37 
  openw, 37, 'Again.tem' 
  printf, 37, 1b
  close, 37
 
end

;------------------------------------------------------------------------------
;**** permette di analizzare le curve ****
;------------------------------------------------------------------------------

pro Ginterface::analyseAll
  self.handler -> analyseAll
end
;------------------------------------------------------------------------------
; ESTRAE I RISULTATI
;------------------------------------------------------------------------------

pro Ginterface::risultati
  self.handler -> writeallOP
  self.handler -> risultati
end

;------------------------------------------------------------------------------
;4.Define the object
;------------------------------------------------------------------------------

                      pro Ginterface__Define
                           struct={Ginterface,$
                           ;inherits Sinterface,$
;                            ...
;                            ...
			    handler:OBJ_NEW() $
                            }
                      end
