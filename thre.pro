
;THRE
;ncdf threholding and extraction program
;Oct 4/16
;Edited:
;Oct 10: inserted GUI
;Oct 14: implemented blob tool

;----------------------------------XJ------------------------------------
FUNCTION thre

; Returns the altitude and time range for an user indicated threhold 
; of dBZ value. Plots the information.
; Created: Oct 4/16
;-> figure out more about the high altitude points (what's around it)
;   surrounding values are negative, thus these are likely to be anomalies.
;-> create a tool to find the values around a point
;-> colour code the values
;-> full GUI application
;----------------------------------XJ------------------------------------

; obtain user input
  userEntry = GUI_PROMPT('Enter 1 Refl, 2 Dop or 3 Spec: ', $ ;the prompt text
  	TITLE   = 'Data type', $   ;the prompt's title bar text
   	VALIDATE_TYPE=size(0.0, /TYPE), $ ;validate that entry is a real
    XSIZE   = 30, $  ;make entry textbox 30 characters wide
    XOFFSET = 100, $
	YOFFSET = 100)  ;position GUI at [100,100] screen coord
  userEntry = FLOAT(userEntry)
  
; userEntry = 1: Reflectivity
; userEntry = 2: Doppler Velocity
; userEntry = 3: Spectral Width

  uthre     = GUI_PROMPT('Enter value here: ', $
  	TITLE   = 'Threshold', $ 
    VALIDATE_TYPE = size(0.0, /TYPE), $ 
    XSIZE   = 30, $ 
    XOFFSET = 100, $
	YOFFSET = 100) 
  uthre     = FLOAT(uthre)
  
  var       = GUI_PROMPT('Enter value here: ', $  
  	TITLE   = 'Variance', $   
    VALIDATE_TYPE = size(0.0, /TYPE), $  
    XSIZE   = 30, $  
    XOFFSET = 100, $
	YOFFSET = 100) 
  var = FLOAT(var)
  
;--------------------------------------------

; extracts ncdf file
  fn   = file_search("/users/xj/desktop/mmcr/"+"*.cdf")
  ncdf_read_structure, fn, struct
  
  if (userEntry eq 1) then begin
    data   = struct.reflectivity
	gtitle = "Reflectivity for the threhold of "
	unit   = "dBZ"
  endif
  if (userEntry eq 2) then begin
    data   = struct.meandopplervelocity
	gtitle = "Doppler velocity for the threhold of "
	unit   = "m/s"
  endif
  if (userEntry eq 3) then begin
    data   = struct.spectralwidth
	gtitle = "Spectral width for the threhold of "
	unit   = "m/s"
  endif
  
  hght = struct.heights[*,3] ;[234]
  time = struct.time_offset ;[54511]
  sz   = size(data)
  tsz  = sz[2]
  
;--------------------------------------------

; remove absurd filler values
  wdata       = where(data ge 50000)
  whght       = where(hght ge 50000)
  data[wdata] = !values.d_nan
  hght[whght] = !values.d_nan
  ;Testing points above 50000
  ;hght[whght] = 13000.0
; check for number of qualified points
  uppb     = uthre + var
  lowb     = uthre - var
  thre_ind = where(data ge lowb and data le uppb)
  nqual    = n_elements(thre_ind)

; produce out array of threholded points
; that contains: index, value, arb_alt, arb_time, act_alt, act_time.
  out = fltarr(6, nqual)
  ;stop
; fill that shit up
  ;1) index
  out[0,*] = thre_ind
  for i = 1, nqual do begin
    ;2) values
	ind0 = out[0,i-1]
    out[1,i-1] = data[ind0]
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
  ;stop
;plot act_alt and act_time
  p1  = plot(out[5,*], out[4,*], $
             title = gtitle+strtrim(string(uthre), 1), $
             xtitle = 'Time(h)', ytitle = 'Altitude(km)', font_size = 20, $
             linestyle = 6, symbol = '*', color = 'black')

;print ranges of alt and time
  altmax = max(out[4,*])
  altmin = min(out[4,*])
  timmax = max(out[5,*])
  timmin = min(out[5,*])
  print, 'The ranges of altitude & time for ', strtrim(string(uthre),1), unit
  print, 'with ', strtrim(string(var),1), unit
  print, strtrim(string(altmin),1), ' - ', strtrim(string(altmax),1), ' km.'
  print, strtrim(string(timmin),1), ' - ', strtrim(string(timmax),1), ' h.'

;trial
  iplot, out[5,*], out[4,*]
  
;call blob
  blob, data

;--------------------------------------------

  RETURN, out

END



;----------------------------------XJ------------------------------------
PRO blob, data
;take in a (alt,time) point and print the four immediate surrounding points
;Created: Oct 14/2016

  h         = GUI_PROMPT('Enter value here (0-234): ', $
  	TITLE   = 'Altitude', $ 
    VALIDATE_TYPE = size(0.0, /TYPE), $ 
    XSIZE   = 30, $ 
    XOFFSET = 100, $
	YOFFSET = 100) 
  h         = FLOAT(h)

  t         = GUI_PROMPT('Enter value here (0-54511): ', $
  	TITLE   = 'Time', $ 
    VALIDATE_TYPE = size(0.0, /TYPE), $ 
    XSIZE   = 30, $ 
    XOFFSET = 100, $
	YOFFSET = 100) 
  t         = FLOAT(t)

  print, "Your requested point: ", data[h,t]
  print, "Surrounding points:"
  print, "Top: ", data[h+1,t-1], data[h+1,t], data[h+1,t+1]
  print, "Side: ", data[h,t-1], data[h,t+1]
  print, "Down: ", data[h-1,t-1], data[h-1,t], data[h-1,t+1]

END
;----------------------------------XJ------------------------------------










