FUNCTION trial

; obtain user input
  userEntry = GUI_PROMPT('Enter 1, 2 or 3: ', $  ; the prompt text
       TITLE='Data Type', $   ; the prompt's title bar text
       VALIDATE_TYPE=size(0.0, /TYPE), $  ; validate that entry is a real
       XSIZE=30, $   ; make entry textbox 30 characters wide
       XOFFSET=100, YOFFSET=100)  ; position GUI at [100,100] screen coord
  userEntry = FLOAT(userEntry)
  
  print, userentry
  
END
