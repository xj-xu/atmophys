FUNCTION refl_thre, dbzthre, var

; Returns the altitude and time range for an user indicated threhold 
; of dBZ value. Plots the information.
; Oct 1/16
; label region?
;----------------------------------XJ------------------------------------

; extracts ncdf file
  fn   = file_search("/users/xj/desktop/mmcr/"+"*.cdf")
  ncdf_read_structure, fn, struct
  
  refl = struct.reflectivity ;[234, 54511]
  hght = struct.heights[*,3] ;[234]
  time = struct.time_offset ;[54511]
  sz   = size(refl)
  tsz  = sz[2]
  
;-----------------------------------------

; remove absurd filler values
  wrefl = where(refl ge 50000)
  whght = where(hght ge 50000)
  refl[wrefl] = !values.d_nan
  hght[whght] = !values.d_nan
  
;****parameterize function
; take in user input:
; 1) dBZ threshold: e.g.10 dBZ
  ;dbzthre = 10
; 2) variance: + or - 5 dBZ
  ;var = 5

; check for number of qualified points
  uppb     = dbzthre + var
  lowb     = dbzthre - var
  thre_ind = where(refl ge lowb and refl le uppb)
  nqual    = n_elements(thre_ind)

; produce out array of threholded points
; that contains: refl.index, dBZ, arb_alt, arb_time, act_alt, act_time.
  out = fltarr(6, nqual)

; fill that shit up
;1) refl.index
  out[0,*] = thre_ind
  for i = 1, nqual do begin
    ;2) dBZ values
	ind0 = out[0,i-1]
    out[1,i-1] = refl[ind0]
	;3) arb_alt
	arb_alt = ind0 / tsz
	out[2,i-1] = arb_alt
	;4) arb_time
	arb_time = ind0 mod tsz
	out[3,i-1] = arb_time
	;5) act_alt in km
	act_alt = hght[arb_alt]/1000
	out[4,i-1] = act_alt
	;6) act_time in hours
	act_time = time[arb_time]/3600
	out[5,i-1] = act_time	
  end

;plot act_alt and act_time
  p1  = plot(out[5,*], out[4,*], $
             title = 'dBZ over threhold', $;****add variables into title
             xtitle = 'Time(h)', ytitle = 'Altitude(km)', font_size = 20, $
             linestyle = 6, symbol = '*', color = 'black')

;******trouble with incorporating floating variable into title line 64, 76-79

;print ranges of alt and time
  altmax = max(out[4,*])
  altmin = min(out[4,*])
  timmax = max(out[5,*])
  timmin = min(out[5,*])
  print, 'The ranges of altitude & time for ', dbzthre, ' dBZ'
  print, 'with', var, ' dBZ are:'
  print, altmin, ' - ', altmax, ' km.'
  print, timmin, ' - ', timmax, ' h.'
;****trim string? gap in front
;--------------------------------------------

  RETURN, out

END
