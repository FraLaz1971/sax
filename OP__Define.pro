

;*******************************************************************************************

;op_id ................. numero identificativo dell' OP
;
;durh .................. durata : numero di ore
;
;durm .................. durata : numero di minuti
;
;durs .................. durata : numero di secondi
;
;dur  .................. durata totale in secondi
;
;grbm_on ............... memorizza lo stato dello strumento (SI = acceso; NO = spento)
;
;presente .............  memorizza se i dati dell'OP sono presenti in archivio locale 
;
;trigtimes ............  memorizza i tempi di trigger

;********************************************************************************************



;----------------------------------------------------------------------------
;1.Create the object
;----------------------------------------------------------------------------

;1.Create the object

                      function OP::Init, op_id
                      
		   ; **** inizializza l'oggetto ****
		      
		      print, 'oggetto OP inizializzato'
		      self.opid = 'null'
		      self.durh = 00	
		      self.durm = 00
		      self.durs = 00
		      self.grbm_on = 'no'
		      self.presente = 'no'		      
		      self.freeburst = 0b			
		      self.burstlist = OBJARR(30)
		      self.dur = 0
		      noldburst = 0b
		      ;self -> obsinit		    		    		     					      
		      return, 1
                      end


;-------------------------------------------------------------------------------
;	**** metodo inizializza il vettore di osservazioni **** 
;-------------------------------------------------------------------------------
	
		pro OP::obsinit
		  cur_obs = 0b
		  while (cur_obs LT 30b) do begin
		    self.observations[cur_obs] = '' 
		    cur_obs = cur_obs + 1
		  endwhile	  	
		end

;-------------------------------------------------------------------------------
;	**** metodo riempie il vettore di osservazioni **** 
;-------------------------------------------------------------------------------
	
		
;----------------------------------------------------------------------------
;2.Create Cleanup method
;----------------------------------------------------------------------------

                      pro OP::Cleanup
                      	;self->Class2::cleanup
		      	print, 'distruggo oggetto OP'
			burst_point = 0b
			while (burst_point LT 30) do begin
			  obj_destroy, self.burstlist[burst_point]
			  burst_point = burst_point + 1
			endwhile
			burts_point = 0b
		      	obj_destroy, self
                      end
;----------------------------------------------------------------------------
;3. salva l'istante di trigger per il burst di osservazione <obs> 
;----------------------------------------------------------------------------

		pro OP::saveopdata, obs ,trigstring
		  close, 30
		  path4 = './op_'		  
		  openw, 30, path4+self.opid+'/insert_times'+'_'+obs+'.log'	
		  printf, 30, 'stringa salvata : ', trigstring
		  printf, 30, 'nella lista burst n. ', self.freeburst + 1	      		      		      		      		      					
		  self.burstlist[self.freeburst] = OBJ_NEW('Burst', self.opid)		      		      						  		 
		  self.burstlist[self.freeburst] -> saveopdata, obs, trigstring		  
		  self.freeburst = self.freeburst + 1		  	
		end

;-------------------------------------------------------------------------------
;	**** metodo che seleziona una osservazione in un dato OP **** 
;-------------------------------------------------------------------------------

		pro OP::select, obs1
		  close, 20, 26
						
			; salva nella root l'OP corrente		
		
		  openw, 20, './ActualOP.txt'
		  printf, 20, self.opid
		  close, 20
								    		
			; salva nella root l'osservazione corrente
		    
		    openw, 26, './nobs.txt'
		    printf, 26, obs1
		    close, 26
					    
                    print
		    print, '-OP- selezionata osservazione '
		    print, '-OP- OP n. ', self.opid
		    print, '-OP- osservazione n. ', obs1
		    print

		    ;self -> creacurve
		   
		end




;-------------------------------------------------------------------------------
;	**** metodo che scorre le osservazioni di un dato OP **** 
;-------------------------------------------------------------------------------


		pro OP::runobs
		  close, 16, 20, 26
		  tempobs = ''
					; apre il file per lista osservazioni

		  openr, 16 , './op_'+self.opid+'/Observations.txt'
						
					; salva nella root l'OP corrente		
		
		  openw, 20, './AcOP.txt'
		  printf, 20, self.opid
		  close, 20
						
		  while(not EOF(16)) do begin
		    readf, 16, tempobs
					; salva nella root l'osservazione corrente
		    
		    openw, 26, './nobs.txt'
		    printf, 26, tempobs
		    close, 26
						; 

		    print, 'visitata osservazione ',tempobs
		    
		     self -> creacurve
		    ;self -> analizza, tempobs 
		  endwhile	
		  close, 16, 20
		end



;-------------------------------------------------------------------------------
;	**** metodo che crea le curve di un dato OP **** 
;-------------------------------------------------------------------------------

		pro OP::creacurve
		  spawn, './auto_fot_grbm_tot.exe'		  		  					  	
		end


;-------------------------------------------------------------------------------
;	**** metodo che analizza le curve di un dato OP **** 
;------------------------------------------------------------------------------

		pro OP::analizza, opstring
		 ; ... 	  	
		end

;-------------------------------------------------------------------------------
;	**** metodo ripone a zero il puntatore di burst appena aggiornato **** 
;------------------------------------------------------------------------------

		pro OP::reburstpoint
		  self.noldburst = 0b 	  	
		end
;-------------------------------------------------------------------------------
;	MOSTRA COORDINATE DEI BURST 
;------------------------------------------------------------------------------

		pro OP::writeburstcoords
		  i = 0b
		  while(i LT self.freeburst)do begin
		     self.burstlist[i] -> writecoords
		  i = i + 1
		  endwhile	  	
		end

;-------------------------------------------------------------------------------
;	**** metodo che salva la stringa numero di OP **** 
;-------------------------------------------------------------------------------

	
		pro OP::saveopid, opstring
		  self.opid = opstring		  	
		end

;-------------------------------------------------------------------------------
;	 MOSTRA I DATI DI UNA SINGOLA OSSERVAZIONE
;-------------------------------------------------------------------------------

	
		pro OP::writeobs, id
		  				; **** controlla la presenza ****
		  i = 0b
		  done = 0b
		 
		  while	(i lt self.n_obs) do begin
		    if (self.observations[i] EQ id) then begin
	 	      print, 'dati per l''osservazione '+self.observations[i]
		      done = 1b		      
		    endif
		  i = i + 1 		  		    
		  endwhile
		  if (done EQ 0b) then begin
		    print, 'osservazione senza trigger in questo OP'
		  endif
						; **** cerca i burst giusti ****
		  burst_point = 0b
		  out = 0b 
		  			; while ((burst_point LT self.freeburst)OR(out EQ 1b) do begin
		  while (burst_point LT self.freeburst)do begin
		    obs = self.burstlist[burst_point] -> getobs ()
		    if (obs EQ id) then begin
		          self.burstlist[burst_point] -> write 
		    out = 1b
		    endif 
		    burst_point = burst_point + 1
		  endwhile			  	
		end

;-------------------------------------------------------------------------------
;	**** visualizza informazioni contenute nella lista di burst **** 
;-------------------------------------------------------------------------------

		pro OP::writebursts
		  burst_point = 0b	
		  while (burst_point LT self.freeburst) do begin
		    self.burstlist[burst_point] -> write
		    burst_point = burst_point + 1
		  endwhile
		  burst_point = 0b 	
		end

;-------------------------------------------------------------------------------
;	****   ASSEGNA AI BURST L'INDICE NELL'OSSERVAZIONE   ****
; 	**** E SALVA LE STRINGHE NEL VETTORE DI OSSERVAZIONI **** 
;-------------------------------------------------------------------------------

		pro OP::countobs
		  cur_obs = 0b
		  burst_point = 0b
		  obs = ''
		  obs_old = ''
		    burst_count = 1b	
		  while (burst_point+1 LT self.freeburst) do begin		    
		    obs_old = self.burstlist[burst_point] -> getobs()    
		    obs = self.burstlist[burst_point + 1] -> getobs()
		    if (obs_old EQ obs) then begin
			self.burstlist[burst_point] -> putindex, burst_count
			burst_count = burst_count + 1b
			self.burstlist[burst_point+1] -> putindex, burst_count
		    endif else begin
			print, 'presenti trigger (',burst_count,') nell''osservazione '+obs_old
			print,'observations[',cur_obs , '] = '+obs_old
			self.observations[cur_obs] = obs_old 
			self.burstlist[burst_point] -> putindex, burst_count
			cur_obs = cur_obs + 1b
			burst_count = 1b
		    endelse 		
		    burst_point = burst_point + 1
		  endwhile		  
		  ;print, 'burst_point = ', burst_point
		  if(burst_point GT 0) then begin
		    obs_old = self.burstlist[burst_point - 1] -> getobs()
		    obs = self.burstlist[burst_point] -> getobs()
		    if (obs_old EQ obs) then begin   
		       print, 'presenti trigger (',burst_count,') nell''osservazione '+obs
		       print,'observations[',cur_obs , '] = '+obs 
		       self.observations[cur_obs] = obs
		       self.burstlist[burst_point] -> putindex, burst_count 
		    endif else begin
		       print, 'presenti trigger (',burst_count,') nell''osservazione '+obs
		       print,'observations[',cur_obs , '] = '+obs
		       self.observations[cur_obs] = obs
		       self.burstlist[burst_point] -> putindex, burst_count
		    endelse
		   endif else begin ; *** 1 oss , 1 trigger
		    obs = self.burstlist[burst_point] -> getobs()
		    print,'observations[',cur_obs , '] = '+obs 
		    self.observations[cur_obs] = obs
		    print, '1 osservazione 1 trigger'
		    print, 'presenti trigger (',burst_count,') nell''osservazione '+obs
		    self.burstlist[burst_point] -> putindex, burst_count
		  endelse
		  self.n_obs = cur_obs + 1b ; salva il numero di osservazioni
		  burst_point = 0b 	
		end
;-------------------------------------------------------------------------------
; 	**** visualizza informazioni nell'OP e assegna punteggi ****
;	**** 		in modalita' non interattiva 		****
;-------------------------------------------------------------------------------

		pro OP::writeNOint
		  self -> writebursts  
		end

;-------------------------------------------------------------------------------
; 	**** visualizza informazioni contenute nell'OP **** 
;-------------------------------------------------------------------------------
                     pro OP::write
		      	print
		        print,'informazioni relative all''OP'
                      	print, 'op_id = ', self.opid
		      	print,'durata (ore) ', self.durh
		      	print,'durata (minuti)',self.durm
		      	print,'durata (secondi)',self.durs
			print,'durata in secondi',self.dur
		      	print,'grbm_on ',self.grbm_on
			print
		      	;print,'presente ',self.presente
			;self -> runobs
			self -> countobs 
			responce = ''
			print
			print, 'vuoi le informazioni relative ai burst ? (y/n)'
			if(responce NE 'n') then  begin
			  read, responce
			  CASE (responce) OF
		
  			   'n': BEGIN 
                	       print, 'elaborazione terminata'
        		    END
			
			   'y': BEGIN			     
                	       print,'n. burst contenuti = ', self.freeburst
			       print,'n. osservazioni contenute = ',self.n_obs  		   
		      	       print, 'contiene le osservazioni : ', self.observations
			       self -> writeburstcoords
			       self ->	handdata			       
        	  	    END 
	
	         	    ELSE: BEGIN
		  	       print
		   	       print, 'inserire un valore del menu'''
		               print			   
			    END

			 ENDCASE  
  		       endif				
		     end

;-------------------------------------------------------------------------------
;  GESTISCE ACCESSO AI DATI DI UN OSSERVAZIONE
;-------------------------------------------------------------------------------
 
                     pro OP::handdata
		       print
			       print, 'selezionare l''opzione '
			       print
			       print, 's = singola osservazione'
			       print, 't = tutti i burst'
			       print, 'n = nessuna operazione'
 			       responce2 = ''	
			       if(responce2 NE 'n') then  begin
			         read, responce2
			         CASE (responce2) OF
				
				   'n': BEGIN 
                	      	      print, 'elaborazione terminata'
        		    	    END
				    's': BEGIN 
                	      	      self -> handobsdata				   
        		    	    END
				    't': BEGIN 
                	      	     print, 'contiene i seguenti burst : '
		      	             self -> writebursts
        		    	    END

 	         	    	   ELSE: BEGIN
		  	           print
		   	           print, 'inserire un valore del menu'''
		                   print			   
			           END
			         ENDCASE
		      	       endif
		     end	



;-------------------------------------------------------------------------------
;**** restituisce la stringa numero di OP ****
;-------------------------------------------------------------------------------
 
                     pro OP::handobsdata
			 print
			 print, 'selezionare l''osservazione (formato 000)'
                      	 print
			 responce3 = ''				       
			 read, responce3
			 self -> writeobs, responce3 			         		      	     
                     end
;-------------------------------------------------------------------------------
; RESTITUISCE IL NUMERO DI BURST NELL'OP
;-------------------------------------------------------------------------------
 
                     function OP::countburst
                      	return, self.freeburst
                      end
                     
;-------------------------------------------------------------------------------
; RESTITUISCE IL NUMERO DI SGR NELL'OP
;-------------------------------------------------------------------------------
 
                     function OP::getSGRinOP
                      	return, self.SGRinOP
                      end
                    
;-------------------------------------------------------------------------------
; RESTITUISCE IL NUMERO DI EVENTI NON LOCALI NELL'OP
;-------------------------------------------------------------------------------
 
                     function OP::getNOspikeinOP
                      	return, self.NOspikeinOP
                      end

;-------------------------------------------------------------------------------
;**** restituisce la stringa numero di OP ****
;-------------------------------------------------------------------------------
 
                     function OP::op_id
                      	return, self.opid
                      end

;-------------------------------------------------------------------------------
; CERCA EVENTI DI TIPO SGR nell'OP 
;-------------------------------------------------------------------------------
 
                     pro OP::findSGR
                        burst_point = 0b
			SGR_count = 0b
		 	while(burst_point LT self.freeburst)do begin
		    	  resSGR = self.burstlist[burst_point] -> isSGR ()
			  if (resSGR EQ 1b) then begin
			    SGR_count  = SGR_count + 1
			    coordstringa = self.burstlist[burst_point] -> getcoords()
			    punti = self.burstlist[burst_point] -> getpoint()
			    print, SGR_count,' SGR burst rilevato coordinate in archivio : ', coordstringa, 'p = ', punti			 
			  endif	    
		    	  burst_point = burst_point + 1
		        endwhile
			self.SGRinOP = SGR_count	 
		     end
;-------------------------------------------------------------------------------
; CERCA EVENTI DI NON LOCALI NELL'OP
;-------------------------------------------------------------------------------
 
                     pro OP::findBURST
                        burst_point = 0b
			BURST_count = 0b
		 	while(burst_point LT self.freeburst)do begin
		    	  resBURST = self.burstlist[burst_point] -> isBURST ()
			  if (resBURST EQ 1b) then begin
			    BURST_count  = BURST_count + 1
			    coordstringa = self.burstlist[burst_point] -> getcoords()
			    punti = self.burstlist[burst_point] -> getpoint()
			    print, BURST_count,' burst non locale rilevato coordinate in archivio : ', coordstringa, 'p = ', punti			 
			  endif	    
		    	  burst_point = burst_point + 1
		        endwhile
			self.NOspikeinOP = BURST_count	 
		     end

;-------------------------------------------------------------------------------
;**** IL NUMERO DI BURST RILEVATI NELL'OP ****
;-------------------------------------------------------------------------------
 
                     function OP::getnumburst
                      	return, self.freeburst
                      end
;-------------------------------------------------------------------------------
;**** restituisce la durata dell'OP ****
;-------------------------------------------------------------------------------
 
                     function OP::getduration
                      	return, self.dur
                      end

;-------------------------------------------------------------------------------
; trasferisce i dati nei campi del relativo OP
;-------------------------------------------------------------------------------

	pro OP::transfer, dati
	  ; **** accetta un record di dati OP ****
	  self.durh = dati.durh 
	  self.durm = dati.durm 
          self.durs = dati.durs
	  self.grbm_on = dati.grbm_on
	  self.presente = dati.presente
	  self.dur = dati.duration 	     	  
        end



;-------------------------------------------------------------------------------
;	**** SALVA LE DURATE CALCOLATE DA SDI PER TUTTI I TRIGGER DELL'OP **** 
;-------------------------------------------------------------------------------
	
		pro OP::savedurations
		  burst_point = 0b
		  while(burst_point LT self.freeburst)do begin
		    self.burstlist[burst_point] -> putDuration, ds, ts		    
		    burst_point = burst_point + 1
		  endwhile		  	
		end

;-------------------------------------------------------------------------------
;	**** SALVA LE DURATE CALCOLATE DA SDI PER UN TRIGGER SELEZIONATO **** 
;-------------------------------------------------------------------------------
	
		pro OP::putduration, obs, tn, ds, ts
		  burst_point = self.noldburst
		  print, 'burst puntato ', burst_point		  
		      
		     self.noldburst = burst_point		      
		     print, '******************************'
		     print, 'OP::putduration'
		     print, 'trigger successivi'

		     ; *** acquisisco le coordinate del burst puntato ***
		     compobs = self.burstlist[burst_point] -> getobs()
		     index = self.burstlist[burst_point] -> getindex()
		     
		     ; *** CALCOLO LA CONDIZIONE ***
		            	
		 	
		     if ((compobs EQ obs)AND(index EQ tn )) then begin
			print, 'salvo nel posto giusto'
			print, '*****************************'
		        print, 'OP::putduration'
		        print, 'salvo durate per trigger n. ', tn
		        print, 'dell''osservazione ', obs
		        print, 'risulta salvato come trigger', index
		        print, 'dell''osservazione ', compobs
		        print, 'burst_point = ', burst_point
		        print, '*****************************'
  		       ;burst_point = burst_point + 1
		     print, 'prossimo burst su cui salvare = ',burst_point				
		     endif else begin 
			print, 'salverei nel posto sbagliato'
			kl = 0b
			while (NOT ((compobs EQ obs)AND(index EQ tn )AND(burst_point LT self.freeburst)) AND(kl LT 100b)) do begin
			   print, 'compobs = ',compobs , ' obs = ', obs 
		           print, 'index = ', index, ' n  = ',tn 
			   print, 'burst_point = ', burst_point
			   print, 'op ', self.opid		       
		           if (burst_point LT self.freeburst - 1) then begin
			      burst_point = burst_point + 1
		           endif else begin
			      burst_point = 0	  
		           endelse
			compobs = self.burstlist[burst_point] -> getobs()
		        index = self.burstlist[burst_point] -> getindex()
			kl = kl + 1b
			endwhile
		     endelse

	   
		     print, 'salvo durate nel burst di indice generale ', burst_point
		     print, 'dell''osservazione ', obs
		     print, 'risulta salvato come trigger', index
		     print, 'dell''osservazione ', compobs
		     print, 'burst_point = ', burst_point
		     self.burstlist[burst_point ] -> putduration, ds, ts  
		   print, '*****************************'
		   self.noldburst = burst_point		   
		   ;burst_point = burst_point + 1
		   print, 'prossimo burst su cui salvare = ',burst_point
		  if (burst_point EQ (self.freeburst)) then begin 
		    self -> reburstpoint
		  end    		  	
		end


;-------------------------------------------------------------------------------
;	**** SALVA I PUNTEGGI CALCOLATI DA SDI PER UN TRIGGER SELEZIONATO **** 
;-------------------------------------------------------------------------------
	
		pro OP::putpoints, obs, tn, p, ts		 
		  burst_point = self.noldburst
		  print, 'siamo arrivati al burst di indice ', burst_point		  
		  compobs = self.burstlist[burst_point] -> getobs()
		  index = self.burstlist[burst_point] -> getindex()
		  ; *** acquisisco le coordinate del burst puntato ***
		     compobs = self.burstlist[burst_point] -> getobs()
		     index = self.burstlist[burst_point] -> getindex()
		     
		     ; *** CALCOLO LA CONDIZIONE ***
		            	
		 	
		     if ((compobs EQ obs)AND(index EQ tn )) then begin
			print, 'salvo nel posto giusto'
			print, '*****************************'
		        print, 'OP::putpoints'
		        print, 'salvo punteggi per trigger n. ', tn
		        print, 'dell''osservazione ', obs
		        print, 'risulta salvato come trigger', index
		        print, 'dell''osservazione ', compobs
		        print, 'burst_point = ', burst_point
		        print, '*****************************'
  		       ;burst_point = burst_point + 1
		     print, 'prossimo burst su cui salvare = ',burst_point				
		     endif else begin 
			print, 'salverei nel posto sbagliato'
			kl = 0b
			while (NOT ((compobs EQ obs)AND(index EQ tn )AND(burst_point LT self.freeburst))AND(kl LT 100b)) do begin			  
			   print, 'compobs = ',compobs , ' obs = ', obs 
		           print, 'index = ', index, ' n  = ',tn 
			   print, 'burst_point = ', burst_point
			   print, 'op ', self.opid		       
		           if (burst_point LT self.freeburst - 1) then begin
			      burst_point = burst_point + 1
		           endif else begin
			      burst_point = 0	  
		           endelse
			compobs = self.burstlist[burst_point] -> getobs()
		        index = self.burstlist[burst_point] -> getindex()
			kl = kl + 1
			endwhile
		     endelse

		    		   
		   self.burstlist[burst_point ] -> putpoints, p, ts	   	   
		   burst_point = burst_point + 1		   
		   self.noldburst = burst_point
		
		 print, 'prossimo burst su cui salvare = ',burst_point
		  if (burst_point EQ (self.freeburst)) then begin 
		    self -> reburstpoint
		  end   		  	
		end

;-------------------------------------------------------------------------------
;4.Define the object
;----------------------------------------------------------------------------
 
                      
		      pro OP__Define
                           struct={OP, $
                       	   ;inherits Class2, $
			   opid:'',      $ ; contiene il numero identificativo di OP
			   durh:0b,      $ ; contiene la durata  (ore)
			   durm:0b,      $ ; contiene la durata (minuti)
                           durs:0b,      $ ; contiene la durata (secondi)
			   FreeBurst:0b, $ ; puntatore al primo Burst null in burstlist
			   FreeObs:0b,   $ ; puntatore alla prima obs null in observations	
			   grbm_on:'',   $ ; flag sull'accensione strumento
			   n_obs:0b,     $ ; numero di osservazioni
			   observations:STRARR(20), $
			   presente:'',  $ 
			   noldburst:0b, $
			   SGRinOP:0b, 	 $ ; numero di eventi SGR nell'OP
			   NOspikeinOP:0b, $ numero di eventi non spuri nell'OP
			   dur:0ul, $ ; contiene la durata in secondi
		  	   burstlist:OBJARR(30) $ ; lista dei burst contenuti nell'OP
                            }
                      end
