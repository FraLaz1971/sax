;----------------------------------------------------------------------------
;1.Create the object
;----------------------------------------------------------------------------
                      function Burst::Init, opid
			;self.OPfather = OBJ_NEW('OP')
                      	self.trigtime = '23:59:59:99999'
			self.obs = '000'
			self.op_id = opid
			self.spectrum = 1.9999
			self.direzione = OBJ_NEW('direction')
			self.durata = OBJ_NEW('Duration')
			self.punteggio = OBJ_NEW('punteggio')
			self.indice = 0b
			self.point = 255.0
                      	return, 1
                      end
;----------------------------------------------------------------------------
;2.Create Cleanup method
;----------------------------------------------------------------------------

                      pro Burst::Cleanup
                      	;self->Class2::cleanup
			obj_destroy, self.direzione
			obj_destroy, self.durata
			obj_destroy, self.punteggio
		      	obj_destroy, self
                      end
;----------------------------------------------------------------------------
;metodo che scrive dati sull'OP
;----------------------------------------------------------------------------


                      pro Burst::write
			print
			print, 'dati burst'
			print, 'OP di provenienza : ', self.op_id
			print, 'osservazione n. ', self.obs
			print, 'indice nell''osservazione = ', self.indice
			print, 'tempo di trigger = ', self.trigtime
			print, 'spettro di energia = ', self.spectrum
			self.direzione -> write
			self.durata -> write
			print
			self.punteggio -> write
			print
                      end
;----------------------------------------------------------------------------
; metodo che scrive dati sull'OP
;----------------------------------------------------------------------------

                      pro Burst::saveopdata, obs, trigstring
			self.obs = obs
                        self.trigtime = trigstring
                      end
                    
;----------------------------------------------------------------------------
; SALVA L'INDICE DEL BURST ALL'INTERNO DELL'OSSERVAZIONE
;----------------------------------------------------------------------------

                      pro Burst::putindex, burst_count
			self.indice = burst_count
                      end

;----------------------------------------------------------------------------
; MOSTRA COORDINATE
;----------------------------------------------------------------------------

                      pro Burst::writecoords
			print, 'osservazione = ', self.obs, ' indice = ', self.indice 
                      end

;----------------------------------------------------------------------------
; 
;----------------------------------------------------------------------------

		      pro Burst::saveopid, opid
			print, 'salvo l''OP_ID per questo burst'
			print, 'op_id = ', self.op_id
			self.op_id = opid
                      end

;----------------------------------------------------------------------------
; 
;----------------------------------------------------------------------------

                      function Burst::Method3
;                      .....
                      return,0
                      end

;----------------------------------------------------------------------------
;  VERIFICA L'APPARTENENZA ALLA CLASSE SGR 
;  sia un evento astrofisico AND durata breve
;----------------------------------------------------------------------------

                      function Burst::isSGR
			Burstres = self -> isBurst()
			punti = self -> getpoint()
			dur = self.durata -> getduration ()			
		        if ((Burstres EQ 1b)AND(dur LT 0.5)AND(punti LT 2.5)) then begin
			  resSGR = 1b						        
		        endif else begin
			  resSGR = 0b
		        endelse
                        return, resSGR
                      end

;----------------------------------------------------------------------------
;  VERIFICA L'APPARTENENZA ALLA CLASSE BURST
;  sia riconosciuta la natura non locale dell'evento 
;----------------------------------------------------------------------------

                      function Burst::isBurst
			punti = self -> getpoint()			
		        if (punti LT 3.5) then begin
			  resBurst = 1b						        
		        endif else begin
			  resBurst = 0b
		        endelse
                        return, resBurst
                      end

;----------------------------------------------------------------------------
; RESTITUISCE IL NUMERO DI OSSERVAZIONE -STRINGA-
;----------------------------------------------------------------------------

                      function Burst::getobs
                        return, self.obs
                      end

;----------------------------------------------------------------------------
; RESTITUISCE L'INDICE DEL BURST -BYTE-
;----------------------------------------------------------------------------

                      function Burst::getindex
                        return, self.indice
                      end

;----------------------------------------------------------------------------
; RESTITUISCE LE COORDINATE IN ARCHIVIO DEL TRIGGER
;----------------------------------------------------------------------------

                      function Burst::getcoords			
			coordstringa = STRARR(3)
			coordstringa[0] = self.op_id
			coordstringa[1] = self.obs
			coordstringa[2] = self.indice 
                        return, coordstringa
                      end

;----------------------------------------------------------------------------
; RESTITUISCE IL PUNTEGGIO DEL BURST PER IL FILTRO DA SPIKE
;----------------------------------------------------------------------------

                      function Burst::getpoint
			self.point = self.punteggio -> getpoint ()
                        return, self.point
                      end

;----------------------------------------------------------------------------
; METODO CHE ACQUISISCE LE DURATE 
;----------------------------------------------------------------------------

                      pro Burst::putduration, ds, ts                      
			print, '******************************'
			print, 'salvo le durate'
			print, 'per il trigger ', self.indice
			print, 'dell''osservazione '+self.obs 
			print, '******************************'
			self.durata -> putduration, ds, ts
                      end
;----------------------------------------------------------------------------
; METODO CHE ACQUISISCE I PUNTEGGI 
;----------------------------------------------------------------------------

                      pro Burst::putpoints, p, ts                      
			print, '******************************'
			print, 'salvo i punteggi'
			print, 'per il trigger ', self.indice
			print, 'dell''osservazione '+self.obs 
			print, '******************************'
			self.punteggio -> putpoints, p, ts
                      end

;----------------------------------------------------------------------------
;4.Define the object
;----------------------------------------------------------------------------
                      pro Burst__Define
                           struct={Burst,$
                           ;inherits AstroEvent,$
			   indice:0b , $   ;n. indice del burst nell'osservazione
			   obs:'',  $ 	   ;n. di osservazione in cui e' contenuto
			   trigtime:'', $  ;tempo di trigger per il burst
                           op_id:'', $ 	   ;n. di OP in cui e' contenuto
			   punteggio:OBJ_NEW(), $; punteggio per filtro da spike
			   durata:OBJ_NEW(), $ ; durata dell'evento
			   spectrum:0.0 , $   ;caratteristiche dello spettro
			   point:0.0 , $ ; punteggio globale per il filtro da spike
			   direzione:OBJ_NEW() $   ;direzione di provenienza 	
                            }
                      end
