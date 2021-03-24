;*** funzione che converte un intervallo di tempo  in secondi ***
;***               in ore minuti e secondi                    ***



FUNCTION converti, sec_tot
	
	durtotsec = 0
	sup1 = 0.0
	tempo  = ulonarr(3)
	
	i = 0
	while (i LE 2) do begin
		tempo [i] = 0
		i = i + 1
	end	

	durtotsec = sec_tot
	tempo[0]= ((durtotsec)/3600)
	sup1 = ((tempo[0])*3600.0)
	durtotsec = ulong(durtotsec - (sup1))
	tempo[1] = ((durtotsec)/60)
	durtotsec = ulong(durtotsec - (tempo[1])*60)
	tempo[2] = durtotsec  
	RETURN, tempo


END




