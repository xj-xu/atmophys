@cw_bgroup_rb

PRO mascobs_container::wdisplay,i,w,xgam,init=init,done=done
     
     o = self->getelem(i)
     
     IF SIZE(o,/TYPE) EQ 2 THEN BEGIN
       done=1
       RETURN 
     ENDIF ELSE BEGIN
       done=0
     ENDELSE
     
     c = o->canvas(/hist)
     c = ((FLOAT(c)/255.0)^xgam)*255.0
     
     IF init EQ 0 THEN BEGIN
        ; this wmakes sure the image is dieplay in the right zoom etc...
        g     = w['canvas']
        g.setdata,c
     ENDIF ELSE BEGIN 
        w.erase
        g = image(c, current=w,name='canvas')
        g.scale, 2.0, 2.0, 1.0
        PRINT,'Flake No : ',i
     ENDELSE
END
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PRO mascobs_container__classify_event,event
   
   COMMON ccurrentflake,icurrentflake,w,wtop,result,xgam,calling_object,bgroup1,outfile,categories

   res = widget_info(event.id,/uname)
   
   IF icurrentflake EQ calling_object.count() THEN res = 'Exit'

   CASE res OF
      'Exit' :     BEGIN
                       WIDGET_CONTROL,wtop,/DESTROY
                   END
      'Back'     : BEGIN
                     xgam          = 1
                     icurrentflake = icurrentflake-1
                     calling_object->wdisplay,icurrentflake,w,xgam,init=1
                   END
      'Brighter' : BEGIN
                     xgam=xgam*0.9
                     calling_object->wdisplay,icurrentflake,w,xgam,init=0
                   END
      'Darker'   : BEGIN
                     xgam=xgam/0.9
                     calling_object->wdisplay,icurrentflake,w,xgam,init=0
                   END
      'Classify' : BEGIN
                     result[icurrentflake] = event.value
                     xgam                  = 1
                     icurrentflake         = icurrentflake+1
                     ; do a save every ten flakes (in case something crashes)....
                     IF icurrentflake MOD 10 EQ 0 THEN SAVE,result,categories,file=outfile
                     
                     calling_object->wdisplay,icurrentflake,w,xgam,init=1,done=done
                     xres=''
                     IF done EQ 1 THEN BEGIN
                         xres = DIALOG_MESSAGE('Last Flake in Object.... Quit',/CENTER,/CANCEL) 
                         IF xres NE 'OK' THEN BEGIN 
                            xgam          = 1
                            icurrentflake = icurrentflake-1
                            calling_object->wdisplay,icurrentflake,w,xgam,init=1
                         ENDIF ELSE BEGIN
                            WIDGET_CONTROL,wtop,/DESTROY
                         ENDELSE
                     ENDIF ELSE BEGIN 
                        ; this only works with cw_bgroup_rb.pro
                        ; allow to unselect exclusive button
                        WIDGET_CONTROL, bgroup1,set_value=-1
                     ENDELSE   
                   END         

   ENDCASE


   
END
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FUNCTION mascobs_container::classify,categories=categories,outfile=outfile,redo=redo


   COMMON ccurrentflake,icurrentflake,w,wtop,result,xgam,calling_object,bgroup1,outf,cat

   KEYWORD_DEFAULT,categories,['rimed','unrimed','unclear','not usable']
   KEYWORD_DEFAULT,outfile , 'dummy.sav'
   
   outf = outfile
   cat  = categories
   
   calling_object = self
   xgam           = 1

   loadct,0
  
   result=INTARR(self.count())-1

   ; restore old classification file if desired....(i.e. not keyword set redo)
   icurrentflake = 0
   IF NOT(KEYWORD_SET(redo)) THEN BEGIN
      ; if not redo and save file exists,, read in save file and start whereit ended last time
      f = FILE_SEARCH(outfile)
      IF f[0] NE '' THEN BEGIN 
        catnew= categories 
        RESTORE,outfile
        ; do a couple of very basic consistency check btw. container and classify-sav file...
        IF N_ELEMENTS(result) NE self.count() THEN BEGIN
          PRINT,'Your sav file is inconsistent with the MASCOBS_COBNTAINER. (Different No. of elements)'
          RETURN,-1
        ENDIF
        IF N_ELEMENTS(catnew) NE N_ELEMENTS(categories) THEN BEGIN
          PRINT,'Your sav file is inconsistent with the MASCOBS_CONTAINER....(Different number of categories)'
          RETURN,-1
        ENDIF
        IF TOTAL(catnew EQ categories) NE N_ELEMENTS(categories) THEN BEGIN
          PRINT,'Your sav file is inconsistent with the MASCOBS_CONTAINER....(Different categories)'
          RETURN,-1
        ENDIF
        icurrentflake = MIN(WHERE(result LT 0)) > 0
      ENDIF
   ENDIF
   
  
   ; crate top widget
   wtop  = widget_base(  column=2,  title='Classify Test')
   
   ; create all action widgets....
   wdraw   = widget_window(wtop, xsize=500,ysize=500)
   bExit   = WIDGET_BUTTON( wtop, VALUE = "Exit"    , XSIZE=50,YSIZE=50,  uname='Exit' )
   bBack   = WIDGET_BUTTON( wtop, VALUE = "Back"    , XSIZE=50,YSIZE=50 , uname='Back' )
   bdark   = WIDGET_BUTTON( wtop, VALUE = "Darker"  , XSIZE=50,YSIZE=50 , uname='Darker')
   bbright = WIDGET_BUTTON( wtop, VALUE = "Brighter", XSIZE=50,YSIZE=50 , uname='Brighter')
   bgroup1 = CW_BGROUP(wtop, categories, /COLUMN, /EXCLUSIVE, $
                       /NO_RELEASE, LABEL_TOP='Classify', /FRAME,uname='Classify')


   widget_control, wtop,  /realize
   widget_control, wdraw, /input_focus
   widget_control, wdraw, get_value=w 
   widget_control, wtop,  set_uvalue=w
   
   self->wdisplay,icurrentflake,w,xgam,init=1
  
   xmanager, 'mascobs_container__classify', wtop

   SAVE,result,categories,file=outfile

   RETURN,result

END
