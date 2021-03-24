
;--------------------------------------------------------------------------------
;1.Create the object
;--------------------------------------------------------------------------------

                      function Duration::Init
		        self.ds = [0.0, 0.0, 0.0, 0.0]
			self.ts = [0b,0b,0b,0b]
                        return, 1
                      end

;--------------------------------------------------------------------------------
;2.Create Cleanup method
;--------------------------------------------------------------------------------

                      pro Duration::Cleanup
                        ;self->Class2::cleanup
			obj_destroy, self
                      end

;--------------------------------------------------------------------------------
; SALVA LE DURATE E I FLAG DI SEGNALE RILEVATO
;--------------------------------------------------------------------------------

                      pro Duration::putDuration, ds, ts
			print, '*********************'
			print, 'Duration::putDuration'			
			print, 'durate'			
			print, ds			
			print, 'trigs'
			print, '*********************
			print, ts
                        self.ds = ds
			self.ts = ts			
                      end


;--------------------------------------------------------------------------------
;3.Create various methods for the object
;--------------------------------------------------------------------------------

                      pro Duration::write
			i = 0b
                        while (i LT 4) do begin
			  if (self.ts[i] EQ 1)then begin
			    print, 'durata sullo schermo ', i+1, ' = ', self.ds[i], ' sec'
		          endif
			  i = i+1b 		
			endwhile
			mean = self -> media()
			print, 'durata media =                  ', mean, ' sec'
                      end
;--------------------------------------------------------------------------------
;
;--------------------------------------------------------------------------------
                      pro Duration::Method2
;                     ....
                      end

;--------------------------------------------------------------------------------
;
;--------------------------------------------------------------------------------

                      function Duration::getduration
                        return, self.durmedia
                      end                      

;--------------------------------------------------------------------------------
;
;--------------------------------------------------------------------------------
                      function Duration::media
                        i = 0b
		        somma = 0.0
		        nt = 0b 	
		        while (i LT 4) do begin
		          if (self.ts[i] EQ 1) then begin 
			    somma = somma + self.ds[i]
			    nt = nt + 1b    
		          endif
			  i = i + 1 		
		        endwhile
			self.durmedia = somma/nt
                        return, somma/nt
                      end
                      
;--------------------------------------------------------------------------------
;4.Define the object
;--------------------------------------------------------------------------------

                      pro Duration__Define
                           struct={Duration,$
                           ;inherits Class2,$
			    ds:FLTARR(4), $ ; vettore delle durate sui 4 schermi
                            ts:BYTARR(4), $ ; vettore dei flag presenza segnale sui 4 schermi
				            ; 0b -> assenza di trigger | 1b -> presenza di trigger 	
                            durmedia:107.0 $  ; durata media dell'evento   	 
			    }
                       end
