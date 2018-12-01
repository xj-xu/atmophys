FUNCTION time_offset

  fn = file_search("/users/xj/desktop/mmcr/"+"*.cdf")
  ncdf_read_structure, fn, struct
  
  t = struct.time_offset
  n = n_elements(t)
  ;diff0 = t[1] - t[0]
  arrdiff = []
  
  for i = 2, n do begin
  
    diff = t[i] - t[i-1]
	
	
	;if diff gt diff0 then begin
	;  print, "Different increments."
	;  break
	;endif

  endfor
  
RETURN, diff

END


;Results:
;
;IDL> .comp time_offset
;% Compiled module: TIME_OFFSET.
;IDL> a = time_offset()
;Different increments.
;IDL> print, a
;       2.0310000
