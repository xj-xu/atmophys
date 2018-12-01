;+
; <PRO gui_prompt_event>
; Event handler for the GUI_PROMPT CW_FIELD input text box. Reads the
; user input, stores it in a pointer and closes the GUI_PROMPT display.
;
; @Param
;   event {in} {required} {type=CW_FIELD event structure}
;     Routine anonymous event structure used by CW_FIELD
;
; @Author
;   James Jones (jjones\@ittvvis.com)
;
; @History
;   Written July 19, 2007
;   Recommented May 8, 2008
;-
PRO gui_prompt_event, event
widget_control, event.id, GET_VALUE=userEntry, GET_UVALUE=pReturnValue
*pReturnValue = userEntry
widget_control, event.top, /DESTROY
END

;+
; <FUNCTION gui_prompt>
; GUI_PROMPT provides a GUI dialog to replace IDL's READ procedure. The GUI
; displays, by default, in the center of the screen. Users of this function
; can set the GUI title bar text, the position of the GUI on the screen, and
; the size of the user entry field. They can also set it up to validate that
; user keyboard entries are correct for either integer or real/floating
; point types. GUI_PROMPT will also pass to the underlying CW_FIELD
; function any CW_FIELD keywords that you may want to set.
; This dialog box will block further IDL processing until the user
; presses the 'Enter' key or hits the dialog window close button.
;
; @Examples
; <PRE>  userEntry = GUI_PROMPT('Enter value here: ', $  ; the prompt text
;       TITLE='Input any real number', $   ; the prompt's title bar text
;       VALIDATE_TYPE=size(0.0, /TYPE), $  ; validate that entry is a real
;       XSIZE=30, $   ; make entry textbox 30 characters wide
;       XOFFSET=100, YOFFSET=100)  ; position GUI at [100,100] screen coord
;  userEntry = FLOAT(userEntry)</PRE>
;
; @Param
;   promptText {in} {required} {type=String} 
;     Text of the prompt inviting user entry
;
; @Keyword
;   TITLE {in} {optional} {type=String} {default='IDL'} 
;     An optional title for the dialog title bar
;
; @Keyword
;   VALIDATE_TYPE {in} {optional} {type=Integer} {default=No validation}
;     IDL datatype ID against which IDL should compare the user entry.
;     See Online Help for IDL's SIZE function for a list of valid values
;     for this keyword.
;     This kind of syntax "VALIDATE_TYPE=size(0.0, /TYPE)" is allowed.
;
; @Keyword
;   XSIZE {in} {optional} {type=Integer} {default=20} 
;     Width of user input textbox in number of characters
;
; @Keyword
;   XOFFSET {in} {optional} {type=Integer} {default=1/2 screen width} 
;     Location of GUI offset from left edge of screen
;
; @Keyword
;   YOFFSET  {in} {optional} {type=Integer} {default=1/2 screen height} 
;     Location of GUI offset from top edge of screen
;
; @Keyword
;   _EXTRA {in|out} {optional}
;     Any routine _EXTRA keywords allowed by CW_FIELD
;
; @Author
;   James Jones (jjones\@ittvvis.com)
;
; @History
;   Written April 8, 2006
;   Recommented May 8, 2008
;
; @Returns
;   The string value of the user entry. If numeric data is needed,
;   programmers must explicitly convert the return value after this
;   function returns. If this dialog box is closed with no entry,
;   then this function returns an '' empty string.
;-
FUNCTION gui_prompt, promptText, $
    TITLE=windowTitle, VALIDATE_TYPE=datatype, XSIZE=nCharacters, $
    XOFFSET=xoffset, YOFFSET=yoffset, _EXTRA=_extra
if n_elements(promptText) eq 0 then return, ''
; Optional keyword for validating user entries. The values are based
; on IDL type ID's as seen in table in Online Help for SIZE function.
if keyword_set(datatype) then begin
    switch datatype of
    1:    ; Integer types
    2:
    3:
    12:
    13:
    14:
    15: begin
        validateLong = 1
        break
    end
    4:    ; floating-point types
    5: begin
        validateReal = 1
        break
    end
    else: returnValue = ''    ; default type is /STRING
    endswitch
endif
if n_elements(windowTitle) eq 0 then winTitle = 'Entry Form'
device, GET_SCREEN_SIZE=displayDims
; By default, center the prompt (approximately) on the display
if n_elements(xoffset) eq 0 then xoffset = displayDims[0] / 2
if n_elements(yoffset) eq 0 then yoffset = displayDims[1] / 2
; By default, set the entry textbox width to 20
if n_elements(nCharacters) eq 0 then nCharacters = 20
tlb = widget_base(TITLE=windowTitle, XOFFSET=xoffset, YOFFSET=yoffset)
pReturnValue = ptr_new(/ALLOCATE_HEAP)
wPromptBox = cw_field(tlb, TITLE=promptText, FLOATING=validateReal, $
    LONG=validateLong, UVALUE=pReturnValue, $
    /RETURN_EVENTS, XSIZE=nCharacters, _EXTRA=_extra)
widget_control, tlb, /REALIZE
xmanager, 'gui_prompt', tlb
if n_elements(*pReturnValue) eq 0 $
    then returnValue='' $
else $
    returnValue = strtrim(*pReturnValue, 2)
ptr_free, pReturnValue
return, returnValue
END
