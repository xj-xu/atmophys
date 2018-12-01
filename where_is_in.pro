FUNCTION where_is_in,vec1,vec2,cnt,complement=complement
;
; RETURNS indices of all elements of vector 2, which occur in vector 1
;
;  e.g. 
;
;IDL> print, where_is_in([1,2],[0,1,2,3,4,5,1,2])
;           1           2           6           7
;  b/c the 1st,2nd,6th,7th element of the second vector are either 1 or 2
;

  ind = BYTARR(N_ELEMENTS(vec2))
  
  FOR i=0L,N_ELEMENTS(vec1)-1 DO ind = ind OR vec1[i] EQ vec2

  index=WHERE(ind GT 0,cnt)
  
  complement = WHERE(ind LE 0)
  
  RETURN,index
  

END
