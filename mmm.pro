FUNCTION mmm, var

; Stores the maxmin, mean and median of an array
; Sept 6/16
;---------------------------------XJ----------------------------------


  a = max(var, /nan)
  b = min(var, /nan)
  c = mean(var, /nan)
  d = median(var)
  
  
  arr = [a,b,c,d]
  
  RETURN, arr

END
