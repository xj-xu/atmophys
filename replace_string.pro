function replace_string,in,was,womit
out=in
while 1 do begin
	res= STRPOS(out,was)
	if res eq -1 then return,out
	strput,out,womit,res
endwhile
end
