FUNCTION reflectivity

; Returns the radar reflectivity data from mmcr on August 3/2015
; Makes plots of data
; Sept 6/16
;----------------------------------XJ------------------------------------


  fn = file_search("/users/xj/desktop/mmcr/"+"*.cdf")
  ncdf_read_structure, fn, struct
 
  refl = struct.reflectivity
  ; REFLECTIVITY    FLOAT     Array[234, 54511]
  ; 234 columns, each with 54511 values
  
  wrefl = where(refl ge 50000) ;count)
 ; n     = count
  ;tlen  = 54511
  refl[wrefl] = !values.d_nan
  
  ;Replaced with line 19, more efficient method
  ;for i = 1, n do begin
    ;ind0      = i-1
	;ind       = wrefl[ind0]
	;xc        = ind/tlen
	;yc        = ind mod tlen
	;refl[xc,yc] = !values.d_nan
	; problem is that not all 9.9e+36 is replaced. E.g max(refl[*,16440 or 2271])	
  ;endfor
  
  ;o   = n_elements(refl[0,*])
  ;size funct is more elegant
  sz = size(refl)
  o  = sz[2]
  out = []
  
  for i = 1, o do begin
    
	tframe = refl[*,i-1]
	val    = mmm(tframe)
	t      = i*(24./tlen)
	; find if t increments are equal throughout the day (using struct.time_offset)
	result = [t, val]
	;result: [time(24hr), max, min, mean, median]
	out    = [[out], [result]]
  
  endfor
  
;Plots

  x   = out[0,*] ;time
  y1  = out[1,*] ;max
  y2  = out[2,*] ;min
  y3  = out[3,*] ;mean
  
  p1  = plot(x, y1, xtitle = 'Time(h)', ytitle = 'dBZ', font_size = 24, $
             linestyle = 6, symbol = 'dot', sym_transparency = 65, color = 'red')
  p2  = plot(x, y2, /overplot, $
             linestyle = 6, symbol = 'dot', sym_transparency = 65, color = 'blue')
  p3  = plot(x, y3, /overplot, $
             linestyle = 6, symbol = 'dot', sym_transparency = 65, color = 'black')

 ;Determine altitude for highest reflectivity
 ;find max dBZ
 alt = fltarr(3,o)
 alt[0:1,*] = out[0:1,*] ;time and max dbz [2,54511]
 
 hgtarr = struct.heights[*,3]
 
 ;aa = where(ref ge 5 and ref le 9)
 ;
 
 for m = 1, o do begin
   
   ind = where(refl[*,i-1] eq time_max[1,i-1])
   sca = ind mod o
   ;hgt = sca*(12/234)
   hgt = hgtarr[sca-1]
   alt[2,i-1] = hgt
 
 end

 ;find index of max dBZ value at every given time
 ;calculate altitude
 
 ;Query function: allows user to specific dBZ value and returns a time range
 ;and altitude
 


  RETURN, out

END
