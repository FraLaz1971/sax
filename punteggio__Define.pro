;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	CLASSE CHE SALVA I PUNTEGGI DI UN PICCO DA TRIGGER DEL GRBM
;	PER OGNI COPPIA DI SCHERMI IN UN VETTORE DI 6 ELEMENTI
;
;	p[0] ----> p4 - p3	
;	p[1] ----> p4 - p2
;	p[2] ----> p4 - p1
;	p[3] ----> p3 - p2
;	p[4] ----> p3 - p1
;	p[5] ----> p2 - p1
;
;--------------------------------------------------------------------------------
;1.Create the object
;--------------------------------------------------------------------------------

                      function punteggio::Init
		        self.p =  [ -0.01, -0.01, -0.01, -0.01, -0.01, -0.01 ]
			self.tp = [ 0b, 0b, 0b, 0b, 0b, 0b ]
			self.ps = [ 0.0, 0.0, 0.0, 0.0 ]
			self.ts = [ 0b, 0b, 0b, 0b ]
			self.meanpoint = 255b
                        return, 1
                      end

;--------------------------------------------------------------------------------
;2.Create Cleanup method
;--------------------------------------------------------------------------------

                      pro punteggio::Cleanup
                        ;self->Class2::cleanup
			obj_destroy, self
                      end

;--------------------------------------------------------------------------------
; SALVA IL PUNTEGGIO CALCOLATO DA SDI
;--------------------------------------------------------------------------------

                      pro punteggio::putpoints, points, ts1
			print, 'points = ', points
			i = 0b		        
		        while (i LT 6) do begin
		          self.p[i] = points[i]    
		          i = i + 1 		
		        endwhile
			self -> puttrigs, ts1
			self -> shieldpoints			
                      end


;--------------------------------------------------------------------------------
;  ASSEGNA IL FLAG ALLE COPPIE
;--------------------------------------------------------------------------------

			pro punteggio::flagassign
			  print		  
			  print, 	'p[0] ----> p4 - p3'	
			  print, 	'p[1] ----> p4 - p2'
			  print, 	'p[2] ----> p4 - p1'
			  print, 	'p[3] ----> p3 - p2'
			  print, 	'p[4] ----> p3 - p1'
			  print, 	'p[5] ----> p2 - p1'
			  print
			  i = 0b
			  count = 0b
                          while (i LT 6) do begin
			    if (self.p[i] NE -0.01)then begin
			      print, 'coppia ', i+1, ' punteggio = ', self.p[i]
			      count = count + 1b
			      self.tp[i] = 1b
		            endif
			  i = i+1b 		
			  endwhile
                      	end


;--------------------------------------------------------------------------------
; restituisce il punteggio globale
;--------------------------------------------------------------------------------

		      function punteggio::getpoint
			return, self.meanpoint			
                      end

;--------------------------------------------------------------------------------
; SALVA LE FLAG SUI TRIGGER
;--------------------------------------------------------------------------------

		      pro punteggio::puttrigs, ts
			i = 0b		        
		        while (i LT 4) do begin
		          self.ts[i] = ts[i]    
		          i = i + 1 		
		        endwhile			
                      end
;--------------------------------------------------------------------------------
; CONTA GLI SCHERMI CON SEGNALE
;--------------------------------------------------------------------------------

		      pro punteggio::countshields
			i = 0b
			temp = 0b		        
		        while (i LT 4) do begin
		          if (self.ts[i] EQ 1b) then temp = temp + 1    
		          i = i + 1 		
		        endwhile
			self.nshields = temp			
                      end

;--------------------------------------------------------------------------------
; CONTA IL n. DI COPPIE ESAMINATE PER SCHERMO
;--------------------------------------------------------------------------------

		      function punteggio::countcoup, sindex

			tot = 0b			
			if (sindex EQ 0) then begin			  
			  tot = self.tp[2] + self.tp[4] + self.tp[5]			
			endif
			if (sindex EQ 1) then begin
			 tot = self.tp[1] + self.tp[3] + self.tp[5]	
			endif
			if (sindex EQ 2) then begin
			  tot = self.tp[0] + self.tp[3] + self.tp[4]
			endif
			if (sindex EQ 3) then begin
			  tot = self.tp[0] + self.tp[1] + self.tp[2]	
			endif
			print, 'schermi per cui dividere = ',tot 
			return, tot			
                      end

;--------------------------------------------------------------------------------
; SALVA I PUNTEGGI PER I SINGOLI SCHERMI
;--------------------------------------------------------------------------------
                      pro punteggio::shieldpoints
			self -> flagassign
			quoz = self -> countcoup(0)
			self.ps[0] = (self.p[2] + self.p[4] + self.p[5])/quoz
			quoz = self -> countcoup(1)
			self.ps[1] = (self.p[1] + self.p[3] + self.p[5])/quoz
			quoz = self -> countcoup(2)
			self.ps[2] = (self.p[0] + self.p[3] + self.p[4])/quoz
			quoz = self -> countcoup(3)  
			self.ps[3] = (self.p[0] + self.p[1] + self.p[2])/quoz                   
		      end
                      
;--------------------------------------------------------------------------------
; CALCOLA UN PUNTEGGIO MEDIO PER IL TRIGGER	
;--------------------------------------------------------------------------------

                      function punteggio::media
			i = 0b
		        somma = 0.0
		        nt = 0b 	
		        while (i LT 4) do begin
		          if (self.ts[i] EQ 1) then begin 
			    somma = somma + self.ps[i]
			    nt = nt + 1b    
		          endif
			  i = i + 1 		
		        endwhile
			if (self.nshields GT 2) then begin
			  correzione = (0.15*self.nshields)*(somma/nt)
			endif else begin
			  correzione = 0.0
			endelse
                        return, (somma/nt)-correzione
                      end
                      
;--------------------------------------------------------------------------------
; MOSTRA I PUNTEGGI PER IL TRIGGER	
;--------------------------------------------------------------------------------                      

 		      pro punteggio::write
			i = 0b
                        while (i LT 4) do begin
			  if (self.ts[i] EQ 1)then begin
			    print, 'punteggio sullo schermo ', i+1, ' = ', self.ps[i]
		          endif
			  i = i+1b 		
			endwhile
			self -> countshields
			print, 'segnale su ', self.nshields, ' schermi'
			self.meanpoint = self -> media()
			print, 'punteggio medio =                  ', self.meanpoint
                      end

;--------------------------------------------------------------------------------
;	4.Define the object
;--------------------------------------------------------------------------------

                      pro punteggio__Define
                           struct={punteggio,$
                           ;inherits Class2, $
			     nshields:0b,    $ ; numero di schermi con segnale
			     p:FLTARR(6),    $ ; vettore dei punteggi per le coppie di schermi
			    tp:BYTARR(6),    $ ; vettore dei flag sulle coppie filtrate
					     ; 0b -> assenza di punteggio | 1b -> presenza di punteggio
                            ps:FLTARR(4), $ ; vettore dei punteggi per i singoli schermi  
			    ts:BYTARR(4),   $ ; 0b -> assenza di trigger | 1b -> presenza di trigger
						; vettore dei flag presenza segnale sui 4 schermi
			    meanpoint:0.0 $	; punteggio medio per l'evento
                            }		       
                      end
