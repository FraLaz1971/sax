function setodec, sestring

; **** converte una stringa sessagesimale in un istante espresso in decimali

sum = 0LL
MAXSTEP = (86400*10^5)
hourtostep = 0LL
mintostep = 0LL
sectostep = 0LL

	
		; **** extract fields

		hourtostep = ULONG64(UINT(strmid(sestring, 0, 2))*MAXSTEP)
		mintostep =  ULONG64(UINT(strmid(sestring, 3, 2))*MAXSTEP)
		sectostep =  ULONG64(UINT(strmid(sestring, 6, 4))*MAXSTEP)
		sumpartial = ULONG64(strmid(sestring, 9, 4))
	
		sum = (hourtostep + mintostep + sectostep + sumpartial)

	return, sum
	

end


















function hextodec, hexstring
thishexstring = hexstring 
cur1 = 0b
len = 0b
esp = 0b
len = strlen(thishexstring)
;print, 'stringa passata lunga ', thishextring
;cur1 = (len - 1)
strpartial = ''
numpartial = 0l
sumpartial = 0l
bval = [0]
bvalb = 0b
	while(esp LE (len - 1) ) do begin
		strpartial = strmid(thishexstring, ((len - 1) - esp), 1)
		print, 'strpartial = ', strpartial
		bval[0] = BYTE(strpartial)
		bvalb = bval[0]
		if (bval[0] GE 97) then begin 
			numpartial = (bval - 87) 
		endif else begin
			numpartial = (bval - 48)
		endelse
		print, 'numpartial = ', numpartial
		;print, 'indice = ',((len - 1) - esp)
		print, 'esp = ', esp
		print, '16^esp = ', (16^esp)
		addendo = ULONG64(numpartial * 16.0^esp)
		print, 'addendo = ', addendo
		sumpartial = sumpartial+addendo
		print, 'sumpartial = ', sumpartial  
		esp = esp + 1
		strpartial = ''
	endwhile

return, sumpartial
end
