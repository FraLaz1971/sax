		;*******************************
		;**** interfaccia per l'uso ****
		;****    del GRBMhandler    ****
		;*******************************

function Ginterface::Init
  return, 1
end


pro Ginterface::Cleanup
  ;self->Class2::cleanup
  print, 'distruggo oggetto Ginterface'
  obj_destroy, self
end





pro Ginterface::Enable

  print, '***********************************'
  print, '**** programma per la gestione ****'
  print, '**** 	  archivio GRBM	       ****'
  print, '***********************************'
  print

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

  a = 7
  while (a NE 0) do  begin
 	read, a
	CASE (a) OF
		
		0: BEGIN 
                   print, 'elaborazione terminata'
        	END
		
		1: BEGIN 
                   print, 'sto aggiornando l''archivio'
        	END
        
		2: BEGIN 
                   print, 'sto analizzando i dati'
		   ;self -> OPdata
           	END
        	
		3: BEGIN 
               	   print, 'mostro la copertura'
	        END
	ENDCASE

  endwhile
  print, 'arrivederci'

end

;------------------------------------------------------------------------------
;************************************************************
;**** metodo che restituisce i dati per l'OP selezionato ****
;************************************************************

pro Ginterface::OPdata
  opstr1 = ''
  print, 'OP scelto ?'
  read, opstr1
  print, 'hai scelto l''OP ',opstr1
  
end

;4.Define the object
                      pro Ginterface__Define
                           struct={Ginterface,$
                           ;inherits Sinterface,$
;                            ...
;                            ...
			    field1:0b $
                            }
                      end
