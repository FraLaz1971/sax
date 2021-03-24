		;********************************************
		;**** prova per l'utilizzo degli oggetti ****
		;********************************************




;lista = OBJ_NEW('OPlist', 4)
;OBJ_DESTROY, lista
;print, obj_valid()



;op1 = OBJ_NEW('OP', 10855)
;op1 -> write
;OBJ_DESTROY, op1

;-----------------------------------------------------------------------------
			;**** istruzioni utilizzate ****
;-----------------------------------------------------------------------------

archivio = OBJ_NEW('GRBMhandler')

OBJ_DESTROY, archivio

print, obj_valid()

;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;
;help
;archivio -> Aggiorna
;var1 = archivio -> Analizza()
;archivio -> Copertura
;

end
