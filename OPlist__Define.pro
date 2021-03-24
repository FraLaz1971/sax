;--------------------------------------------------------------------------------------------
;tempass ..............  durata in secondi del tempo totale di rilevazione OP gia' scanditi
;
;
;copertura ............  durata in secondi della copertura totale dati in archivio locale
;--------------------------------------------------------------------------------------------

;1.Create the object

;**** il costruttore di una OPlist accetta come parametro la lunghezza della lista  

                    function OPlist::Init, lun                     
		    
		      self.lun = lun		      
		      self.OPs = OBJARR(100)
		      self.tempass = 0ul
		      self.copertura = 0ul
		      self.OPIndice = 0b
		      self.lastopid = 'null'
		      a = 0b		      
		      while (a LT lun) do begin					
			self.OPs[a] = OBJ_NEW('OP', a)					
			a = a + 1 	
		      endwhile                     
		      return, 1
		      print, 'OPlist inizializzata'
                    end
;--------------------------------------------------------------------------------------------
;2.Create Cleanup method
;--------------------------------------------------------------------------------------------
                      pro OPlist::Cleanup
                      	;self->Class2::cleanup

			;**** distruggo gli oggetti OP **** 
		      
		        a = 0
		        while (a LT self.lun) do begin
                       	  obj_destroy, self.OPs[a]
			  a = a + 1
		        endwhile		        
		        obj_destroy, self.OPs ;**** distruggo l'array di OP			
			obj_destroy, self ;**** distrutt
	             	heap_gc, /verbose
			print, 'distrutto oggetto OPlist '
			end

;3.Create various methods for the object



;---------------------------------------------------------------------------------------------
			;******************************************
			;**** metodo che salva il numero di OP ****
			;******************************************


pro OPlist::saveopid, opindex1
    a = self.OPindice ;- 1
    print, 'salvo l''OP ', opindex1, ' su indice ', a
    self.OPs[a] -> saveopid, opindex1
end

;---------------------------------------------------------------------------------------------
; **** metodo che salva il tempo <trigtime> per l'OP <opindex> ****
;---------------------------------------------------------------------------------------------                     
		    
		     pro OPlist::saveopdata, opindex, obs, trigtime
		       		;print, 'devo salvare i tempi di trigger : ', trigtime
		       		;print, 'per l''OP n. ', opindex 
				;print, 'osservazione : ', obs
				;print, 'ultimo OP caricato = ', self.lastopid
				
			if (opindex NE self.lastopid)AND(self.lastopid NE 'null') then begin 
			  self.OPindice = self.OPindice + 1
			endif
			self.ops[self.OPindice] -> saveopid, opindex
                      	self.ops[self.OPindice] -> saveopdata, obs, trigtime
			;print, 'self.OPindice adesso e'' ', self.OPindice
			self.lastopid = opindex
                     end

			

;---------------------------------------------------------------------------------------------
; **** metodo che visualizza il contenuto di tutta la lista di OP
;---------------------------------------------------------------------------------------------
                      
		      pro OPlist::write
		      	a = 0b
                      	while (a LE self.OPindice) do begin
		          self.OPs[a] -> write
			  a = a + 1
		      	endwhile
		        a = 0b
                      end

;---------------------------------------------------------------------------------------------
; **** METODO CHE SALVA OSSERVAZIONI E INDICI PER TUTTO L'ARCHIVIO
;---------------------------------------------------------------------------------------------
                      
		      pro OPlist::CountOPs
		      	a = 0b
                      	while (a LE self.OPindice) do begin
		          self.OPs[a] -> countobs
			  a = a + 1
		      	endwhile
		        a = 0b
                      end

;---------------------------------------------------------------------------------------------
; **** metodo che salva le durate per un trigger di OP coord[0], OBS coord[1], ****
; **** DURATE ds e FLAG ts                                                     ****
;---------------------------------------------------------------------------------------------

		pro OPlist::putduration, coord, tn, ds, ts		  
		  print, 'OPlist : devo salvare le durate'
		  print, ds
		  print, 'sugli schermi'
		  print, ts
		  print, 'per l''OP '+coord[0]
		  print, 'osservazione '+coord[1]  
		  a = 0b
                  while (a LE self.OPindice) do begin
		    topid = self.OPs[a] -> op_id()
	            if (topid EQ coord[0]) then begin
		      print, 'OPlist::putduration'
		      print, 'devo salvare le durate per il burst OP ', topid
		      print, 'osservazione ', coord[1]
		      self.OPs[a] -> putduration, coord[1],  tn, ds, ts
		      ;
		    endif  	
                    a = a + 1
		  endwhile 
		  a = 0b  
		end

;---------------------------------------------------------------------------------------------
; **** metodo che salva i punteggi per un trigger di OP coord[0], OBS coord[1], ****
; **** punteggi p e FLAG ts                                                     ****
;---------------------------------------------------------------------------------------------

		pro OPlist::putpoints, coord, tn, p, ts		  
		  print, 'OPlist : devo salvare i punteggi'
		  print, p
		  print, 'sugli schermi'
		  print, ts
		  print, 'per l''OP '+coord[0]
		  print, 'osservazione '+coord[1]  
		  a = 0b
                  while (a LE self.OPindice) do begin
		    topid = self.OPs[a] -> op_id()
	            if (topid EQ coord[0]) then begin
		      print, 'OPlist::putpoints'
		      print, 'devo salvare i punteggi per il burst OP ', topid
		      print, 'osservazione ', coord[1]		      
		      self.OPs[a] -> putpoints, coord[1], tn, p, ts
		    endif 	
                    a = a + 1
		  endwhile 
		  a = 0b  
		end




;---------------------------------------------------------------------------------------------
; **** metodo che calcola la copertura delle rilevazioni in archivio
;---------------------------------------------------------------------------------------------
                      
		      function OPlist::coverage
		      	a = 0b
			duration = 0ul
			self.tempass  = 0ul
                      	while (a LE self.OPindice) do begin
			  duration = self.OPs[a] -> getduration()
		          self.tempass = self.tempass + duration
			  a = a + 1
		      	endwhile
		        a = 0b
			self.copertura = self.tempass
			return, self.copertura
			self.tempass = 0
                      end


;---------------------------------------------------------------------------------------------
; **** metodo che visualizza la lista di OP
;---------------------------------------------------------------------------------------------
                      
		      pro OPlist::writelist
			print
			topid = ''
		      	a = 0b
                      	while (a LE self.OPindice) do begin
		          topid = self.OPs[a] -> op_id()
			  nburst = self.OPs[a] -> getnumburst()
			  print, 'op_'+ topid, ' contiene ', nburst, ' trigger'
			  a = a + 1
		      	endwhile
			print
		        a = 0b
                      end

;---------------------------------------------------------------------------------------------
; **** metodo che visualizza il contenuto di un unico  OP
;---------------------------------------------------------------------------------------------
	
		      pro OPlist::writeOP, opstr
		      	a = 0b			
                      	while (a LE self.OPindice ) do begin
			  topid = self.OPs[a] -> op_id()
			  if (topid EQ opstr) then begin
				print, 'indice nella lista = ', a
				self.OPs[a] -> write 				
			  endif
			  a = a + 1
		      	endwhile
		        a = 0b
		      end


;---------------------------------------------------------------------------------------------
; **** metodo che visualizza il contenuto di tutti gli OP
;---------------------------------------------------------------------------------------------
	
		      pro OPlist::writeallOP
		      	a = 0b			
                      	while (a LE self.OPindice ) do begin
			  print, 'indice nella lista = ', a
			  self.OPs[a] -> writeNOint 				
			  a = a + 1
		      	endwhile
		        a = 0b
		      end

;---------------------------------------------------------------------------------------------
; **** metodo crea curve
;---------------------------------------------------------------------------------------------
			pro OPlist::creacurve, opstr
		      	  a = 0b			
                      	  while (a LE self.OPindice ) do begin
			    topid = self.OPs[a] -> op_id()
			    if (topid EQ opstr) then begin
				print, 'indice nella lista = ', a
				self.OPs[a] -> creacurve 				
			    endif
			    a = a + 1
		      	  endwhile
		          a = 0b
			end
;---------------------------------------------------------------------------------------------
; **** metodo seleziona osservazione
;---------------------------------------------------------------------------------------------


		pro OPlist::select, opid1 , obs1
		  close, 20, 26
						
			; salva nella root l'OP corrente		
		
		  openw, 20, './ActualOP.txt'
		  printf, 20, opid1
		  close, 20
								    		
			; salva nella root l'osservazione corrente
		    
		    openw, 26, './nobs.txt'
		    printf, 26, obs1
		    close, 26
					    
                    print
		    print, '-OPlist- selezionata osservazione '
		    print, '-OPlist- OP n. ', self.opid
		    print, '-OPlist- osservazione n. ', obs1
		    print

		    ;self -> creacurve
		   
		end


;---------------------------------------------------------------------------------------------
; **** metodo analizza curve
;---------------------------------------------------------------------------------------------     
           	     pro OPlist::analizza, opstr
		      	a = 0b			
                      	while (a LE self.OPindice ) do begin
			  topid = self.OPs[a] -> op_id()
			  if (topid EQ opstr) then begin
				print, 'indice nella lista = ', a
				self.OPs[a] -> analizza				
			  endif
			  a = a + 1
		      	endwhile
		        a = 0b
		      end

;---------------------------------------------------------------------------------------------
; CERCA NELLA LISTA GLI EVENTI TIPO SGR 
;---------------------------------------------------------------------------------------------                      
 
		     pro OPlist::findSGR
                       	  a = 0b
			  SGRinOP = 0b			
                      	  while (a LE self.OPindice ) do begin
				self.OPs[a] -> findSGR
				SGRinOP = self.OPs[a] -> getSGRinOP()
				self.SGRinlist = self.SGRinlist + SGRinOP				
			    a = a + 1
		      	  endwhile
		          a = 0b
                      end

;---------------------------------------------------------------------------------------------
; CERCA NELLA LISTA GLI EVENTI NON LOCALI
;---------------------------------------------------------------------------------------------                      
 
		     pro OPlist::findNOspike
                       	  a = 0b
			  SGRinOP = 0b			
                      	  while (a LE self.OPindice ) do begin
				self.OPs[a] -> findBURST
				NOspikeinOP = self.OPs[a] -> getNOspikeinOP()
				self.NOspikeinlist = self.NOspikeinlist + NOspikeinOP				
			    a = a + 1
		      	  endwhile
		          a = 0b
                      end	
		     
;---------------------------------------------------------------------------------------------
; **** metodo 8
;---------------------------------------------------------------------------------------------                      
 
		      function OPlist::Method8
                       return, 0
                      end
;---------------------------------------------------------------------------------------------
; **** 
;---------------------------------------------------------------------------------------------                      
 
		      pro OPlist::resetStat
                       self.NOspikeinlist = 0b
		       self.SGRinlist = 0b
		       ;self.
                      end

;---------------------------------------------------------------------------------------------
; RESTITUISCE IL NUMERO DI BURST RILEVATI NELLA LISTA DI OP
;---------------------------------------------------------------------------------------------                      
 
		      function OPlist::getburstinlist
                       return, self.burstinlist
                      end

;---------------------------------------------------------------------------------------------
; RESTITUISCE IL NUMERO DI SGR RILEVATI NELLA LISTA DI OP
;---------------------------------------------------------------------------------------------                      
 
		      function OPlist::getSGRinlist
                       return, self.SGRinlist
                      end
;---------------------------------------------------------------------------------------------
; RESTITUISCE IL NUMERO DI EVENTI NON LOCALI RILEVATI NELLA LISTA DI OP
;---------------------------------------------------------------------------------------------                      
 
		      function OPlist::getNOspikeinlist
                       return, self.NOspikeinlist
                      end

;---------------------------------------------------------------------------------------------
; **** CONTA I BURST IN TUTTA LA LISTA
;---------------------------------------------------------------------------------------------                      
 
		      function OPlist::countburst
                          a = 0b			
                      	  while (a LE self.OPindice ) do begin
				burstinop = self.OPs[a] -> countburst()
				self.burstinlist = self.burstinlist + burstinop				
			    a = a + 1
		      	  endwhile
		          a = 0b
			  return, self.burstinlist
                      end

;---------------------------------------------------------------------------------------------
; **** metodo che restituisce l'indice dell'OP nella lista dato l'OP_ID
;---------------------------------------------------------------------------------------------                      
 
		      function OPlist::getindex, opstring
			a = 0b
			topid = self.OPs[a] -> op_id()
			if (topid EQ opstring) then a = 1b
                      	while ((topid NE opstring)AND(a LE self.OPindice)) do begin
			  topid = self.OPs[a] -> op_id()
			  print, 'OPID memorizzato = ',topid
			  print, 'a = ', a
			  a = a + 1
		      	endwhile
			if (a EQ  (self.OPindice + 1)) then a = a + 1; **** OP non presente
 		        if (a EQ 0) then a = 1 ;**** primo della lista
                        return, a - 1
			a = 0b
                      end


;--------------------------------------------------------------------------------------------
; trasferisce i dati nei campi del relativo OP
;--------------------------------------------------------------------------------------------

	pro OPlist::transfer, dati
	    ; **** accetta un record di dati OP ****
	    numero = dati.op_id	  
	    vnumero = STRCOMPRESS(numero, /REMOVE_ALL)
	    print, 'voglio sapere l''indice dell''OP ', vnumero
	    index = self -> getindex(vnumero)
	    if (index EQ 4) then begin
	      print, 'OP ', vnumero, 'non presente in archivio'
	    endif else begin
	      print, 'OP presente !!' 
	      print, 'l''indice di ', vnumero, ' e'' ', index	  
	      self.OPs[index] -> transfer, dati
	    endelse	    
	    numero = 0b	  	     	  
        end


;---------------------------------------------------------------------------------------------
;4.Define the object
;---------------------------------------------------------------------------------------------

                      pro OPlist__Define
                           struct={OPlist,$
			  ;inherits Class2,$
			   lun:0ul,$ 	        ; lunghezza lista di OP
			   tempass:0ul,$        ; tempo di osservazione parziale
			   copertura:0ul,$      ; copertura totale
			   OPindice:0b, $       ; indice per il caricamento 
			   lastopid:'', $       ; l'OP che si sta caricando attualmente
			   burstinlist: 0ul, $  ; salva il numero totale di trigger nella lista di OP
			   NOspikeinlist: 0ul, $; salva il numero totale di burst nella lista di OP
			   SGRinlist:0ul, $     ; salva il numero totale di SGR nella lista
			   OPs:OBJARR(100)$      ; array di 100 OP (DEFAULT DI PROVA)
                            }
                      end
