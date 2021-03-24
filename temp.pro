trigtimes = strarr(4,4)
t=0
s=0

while  (t LT 4) do begin 
	s = 0 	
	while (s LT 4) do begin		
		trigtimes[s, t] = '23:59:59:99999'
		print, 	trigtimes[s, t]
		print, 's = ', s, 't = ', t
		s = s+1
	endwhile
t = t+1
endwhile	

print, trigtimes

end
