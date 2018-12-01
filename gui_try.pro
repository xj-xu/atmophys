PRO gui_try

;***create base***
cont_base = WIDGET_BASE(TITLE='Click to Continue:', xsize = 300, $
                  xoffset = 100, yoffset = 100, /FRAME)

;***create button:***
continue_but= WIDGET_BUTTON(cont_base, /FRAME,$
VALUE=' CONTINUE ',UVALUE='CONT_CONT')

;***Realize the menu
WIDGET_CONTROL, cont_base, /REALIZE

;*** Wait for the first event: ***
event=WIDGET_EVENT(cont_base, uname = "print")

;*** Destroy the GUI, let caller program proceed: ***
WIDGET_CONTROL, cont_base, /DESTROY


END



