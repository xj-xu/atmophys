FUNCTION mma, var

; Prints the max, min, median and average of an array
;Sept 5/16
;---------------------------------XJ----------------------------------


  a = max(var)
  b = min(var)
  m = median(var)
  
  s = total(var)
  n = n_elements(var)
  c = s/n
  
  arr = [a,b,m,c]
  
  RETURN, arr

END
