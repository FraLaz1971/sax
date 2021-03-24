;1.Create the object
                      function direction::Init
;                      ....
		      self.RA = 'hh mm ss.s'
		      self.DEC = 'dd mm ss.s'
		      self.errore = '99 %'
                      return, 1
                      end

;2.Create Cleanup method
                      pro direction::Cleanup
                       ;self->Class2::cleanup
			obj_destroy, self	
                      end

;3.Create various methods for the object
;------------------------------------------------------------------------------------------
; **** METODO CHE VISUALIZZA IL CONTENUTO DEI CAMPI ****
;------------------------------------------------------------------------------------------

                      pro direction::WRITE
		        print
			print, 'ascensione retta = ', self.RA
			print, 'declinazione = ', self.DEC
			print, 'errore = ', self.errore
			print			 	
                      end

                      pro direction::Method2
;                      ....
                      end

                      function direction::Method3
;                      .....
                      return,0
                      end

;4.Define the object
                      pro direction__Define
                           struct={direction,$
                           ;inherits Class2,$
			    RA:'',  $   ;ascenzione retta
                            DEC:'',$    ;declinazione
                            errore:'' $ ;errore 
			    
                            }
                      end
