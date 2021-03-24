	;*******************************
	;**** interfaccia per l'uso ****
	;****    del GRBMhandler    ****
	;*******************************

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
           	END
        	
		3: BEGIN 
               	   print, 'mostro la copertura'
	        END
	ENDCASE

endwhile
print, 'arrivederci'
end
