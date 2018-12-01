pro ees7110_HW6_procedure_event, ev
;  Xmanager, catch=0
  print, 'Event ID is: ', ev.id
  WIDGET_CONTROL, ev.ID, GET_UVALUE=uval        ;could get uname as well but just chose value   WHERE ID AND TOP FROM????
  print, 'Event TOP is: ', ev.top
  WIDGET_CONTROL, ev.TOP, GET_UVALUE=state    ;ev.TOP is the top parent that made this, looking for the previous part that made all of that structure
  

  img_orig = state.img_orig
  img_thrsh = state.img_thrsh
  img_bright=state.img_bright
  img_zoom=state.img_zoom
  img_last=state.img_last
  tlevel1 = state.tlevel1
  tlevel2 = state.tlevel2
  blevel1=state.blevel1
  blevel2 = state.blevel2
  sx = state.sx
  sy = state.sy
  ssx=state.ssx
  ssy=state.ssy
  tmin=state.tmin
  tmax=state.tmax
  file_in = state.file_in
  file_out = state.file_out
  label_file = widget_info(ev.top, find_by_uname='label_file')
  ;bright_slide_label = widget_info(ev.top, find_by_uname='bright_slide_label')
  bright_slide1=widget_info(ev.top, find_by_uname= 'bright_slide1')
  bright_slide2=widget_info(ev.top, find_by_uname= 'bright_slide2')
  thresh_slide1 = widget_info(ev.top, find_by_uname='thresh_slide1')
  thresh_slide2 = widget_info(ev.top, find_by_uname='thresh_slide2')
  ;thresh_slide_label = widget_info(ev.top, find_by_uname='thresh_slide_label')
  zoom_drop=widget_info(ev.top,find_by_uname='zoom_drop')
  kernel_drop=widget_info(ev.top,find_by_uname='kernel_drop')
  button_save = widget_info(ev.top, find_by_uname='button_save')
  

  photo = widget_info(ev.top, find_by_uname='photo')
  histo = widget_info(ev.top, find_by_uname='histo')
  combo = widget_info(ev.top, find_by_uname='combo')
  widget_control, photo, get_value=photo_ID     ;will help with wset to identify which window to do things to (e.g. histogram window or image window)
  widget_control, histo, get_value=histo_ID    ;need one for histogram as well


  case uval of
      'button_open': begin
       
        file = dialog_pickfile(title='Choose file to open', /read, /must_exist, get_path=path)
        if file eq '' then return
        cd, path
    
        img = read_image(file)
        text = ' File: ' + file
        widget_control, label_file, set_value=text
    
        s = size(img)
        sx=s[s[0]-1]
        sy=s[s[0]]
        ssx=sx
        ssy=sy
        widget_control, photo, draw_xsize=sx, draw_ysize=sy, /draw_viewport_events;/draw_expose_events
        widget_control, histo, draw_xsize=300, draw_ysize=300 
        
        case s[0] of
          2: begin
            tmin=min(img)
            tmax=max(img)
            wset, photo_ID
            tvscl, img, 0,/order     
            wset, histo_ID
            plot,histogram(img)
          end
          3: begin
            tmin=min(img)
            tmax=max(img)
            wset, photo_ID
            tvscl, img, 0,/true     ;displays image and /order orients the image in the correct direction
            wset, histo_ID
            plot,histogram(img)
            end
            endcase
     
        
        widget_control, bright_slide1, /sensitive, set_slider_max=tmax,set_slider_min=tmin
        widget_control,thresh_slide1,/sensitive, set_slider_max=tmax,set_slider_min=tmin
        widget_control, bright_slide2, /sensitive, set_slider_max=tmax,set_slider_min=tmin
        widget_control, thresh_slide2,/sensitive, set_slider_max=tmax,set_slider_min=tmin
        widget_control, button_save, /sensitive
        
        
        state = {img_orig:img, img_last:img, img_zoom: img, img_thrsh:img, img_bright:img,file_in:-1, tlevel1: -1, tlevel2:-1, blevel1: -1, blevel2:-1, sx:sx, sy:sy, ssx:ssx,ssy:ssy,tmin:tmin, tmax: tmax, file_out:''}   ;making a structure , can only update values in structure with the same type
    
    
      end
      'thresh_slide1': begin

        widget_control, thresh_slide1, get_value=tlevel1
        widget_control, thresh_slide2, get_value=tlevel2
        img_thrsh = (img_orig ge tlevel1)*tmin and (img_orig le tlevel2)

        wset, photo_ID
        tvscl, img_thrsh, /order
        wset, histo_ID
        plot, histogram(img_thrsh)

        state.img_thrsh = img_thrsh
        state.tlevel1=tlevel1
        state.tlevel2=tlevel2
        state.img_last=img_thrsh
        

       end
      'thresh_slide2':begin
        widget_control, thresh_slide1, get_value=tlevel1
        widget_control, thresh_slide2, get_value=tlevel2
        img_thrsh = (img_orig ge tlevel1)*tmin and (img_orig le tlevel2)

        wset, photo_ID
        tvscl, img_thrsh, /order
        wset, histo_ID
        plot, histogram(img_thrsh)

        state.img_thrsh = img_thrsh
        state.tlevel1=tlevel1
        state.tlevel2=tlevel2
        state.img_last=img_thrsh
       
       
       end 
      'bright_slide1': begin
        
      widget_control, bright_slide1, get_value=blevel1
      widget_control, bright_slide2, get_value=blevel2
;      widget_control, bright_slide_label1, set_value=strtrim(blevel1,2)
      img_brights=img_orig > blevel1 < blevel2
      wset,photo_ID
      tvscl, img_brights, /order
      wset, histo_ID
      plot, histogram(img_brights)
      state.img_bright = img_brights
      state.blevel1=blevel1
      state.blevel2 = blevel2
      state.img_last=img_brights
      
      

      end
      'bright_slide2': begin

      widget_control, bright_slide1, get_value=blevel1
      widget_control, bright_slide2, get_value=blevel2
;      widget_control, bright_slide_label1, set_value=strtrim(blevel1,2)
      img_brights=img_orig > blevel1 < blevel2
      wset,photo_ID
      tvscl, img_brights, /order
      wset, histo_ID
      plot, histogram(img_brights)
      state.img_bright = img_brights
      state.blevel1=blevel1
      state.blevel2 = blevel2
      state.img_last=img_brights


      end
      'zoom_drop': begin
        case ev.str of
          'original': begin
            print, ev.str
            widget_control, photo, draw_xsize=sx, draw_ysize=sy
            widget_control, histo, draw_xsize=300, draw_ysize=300
            img_zoom=img_orig
            wset, photo_ID
            tvscl, img_zoom, /order
            wset, histo_ID
            plot, histogram(img_zoom)
            
            
            
            end

          '2': begin
            z=2
            print, ev.str
            widget_control, photo, draw_xsize=sx*z, draw_ysize=sy*z
            widget_control, histo, draw_xsize=300, draw_ysize=300
            img_zoom=rebin(img_orig,z*sx,z*sy,/sample)
            wset, photo_ID
            tvscl, img_zoom, /order
            wset, histo_ID
            plot, histogram(img_zoom)
            
            
            end
          '3': begin
            z=3
            print, ev.str
            widget_control, photo, draw_xsize=sx*z, draw_ysize=sy*z
            widget_control, histo, draw_xsize=300, draw_ysize=300
            img_zoom=rebin(img_orig,z*sx,z*sy,/sample)
            wset, photo_ID
            tvscl, img_zoom, /order
            wset, histo_ID
            plot, histogram(img_zoom)
            
            
            end
           
        endcase   
      end
      'kernel_drop':begin 
        case ev.str of
          'boxcar': begin
            print,'boxcar'
            boxcar_array=(intarr(3,3)+1)
            boxcar=convol(img_orig,boxcar_array)
            wset,photo_ID
            tvscl, boxcar, /order
            wset, histo_ID
            plot, histogram(boxcar)
            state.img_last=boxcar
            
            end
          'median':begin
            print, 'median'
            wset, photo_ID
            img_median=median(img_orig, sx)
            tvscl,img_median, /order
            state.img_last=img_median
            end
         endcase
         end
         else:begin
          wset, photo_ID
          tvscl,img_last,/order
          end
    endcase
      WIDGET_CONTROL, ev.TOP, SET_UVALUE=state ;, /no_copy
   
   
   
    
   end



pro ees7110_HW6_procedure

  sx = 300 & sy = 300
  ssx = 300 & ssy = 300

  big_base = WIDGET_BASE(title="Brandt's Program", /column, space=5)  ;can have base on base, inception, space is spacing between elements, column is having them go down columns instead of rows (looking at widgets when running program)
  Widget_Control, /REALIZE, big_base  ;means actually display the base
  ;;because using columns, things will be created in order
  button_open = widget_button(big_base, /align_left, uvalue='button_open', value='Open image')  ;(where you want to create, alignment location, unique values/names, value equals displayed text)
  label_file = widget_label(big_base, /align_left, scr_xsize=sx, uname='label_file', value='Press button to open image...')   ;something that cannot be edited but only displayed
  
  
  ;;;Thresh
  big_subbase1=widget_base(big_base, /row, /align_left, space=5, frame=0, sensitive=1)
    subbase1 = widget_base(big_subbase1, /row, /align_left, space=5, frame=0, sensitive=1)   ;base upon base,frame puts ouline, frame equals zero shows no outline
      threshbase=widget_base(subbase1,/column,/align_left,space=5,frame=1,sensitive=1)
      label_file = widget_label(threshbase, /align_left, scr_xsize=sx, uname='thresh_label', value='Thresholding Slider')   
     ; thresh_slide_label = widget_text(subbase1, /align_right, uname='thresh_slide_label', uvalue='thresh_slide_label',xsize=3)
      thresh_min = widget_label(threshbase, /align_left, scr_xsize=sx, uname='thresh_min', value='Minimum Thresholding Slider')
      thresh_slide1 = widget_slider(threshbase, minimum=0, maximum=255, xsize = 150, sensitive=0, value=127, uname='thresh_slide1', uvalue='thresh_slide1');, /suppress_value)  ;sensitive=0 means grayed out, shown but not used
      thresh_max = widget_label(threshbase, /align_left, scr_xsize=sx, uname='thresh_max', value='Maximum Thresholding Slider')
      thresh_slide2 = widget_slider(threshbase, minimum=0, maximum=255, xsize = 150, sensitive=0, value=127, uname='thresh_slide2', uvalue='thresh_slide2')
      
      ;;;;Zoom
      
        droplist1=widget_combobox(subbase1,/align_center, uname='zoom_drop',uvalue='zoom_drop',value=['Zoom','original','2','3'])
    
    ;;bright
      subbase3 = widget_base(big_subbase1, /row, /align_left, space=5, frame=0, sensitive=1)
      brightbase=widget_base(subbase3,/column,/align_left,space=5,frame=1,sensitive=1)
        label_file = widget_label(brightbase, /align_left, scr_xsize=sx, uname='bright_label', value='Brightness Slider')
        lower_bright = widget_label(brightbase, /align_left, scr_xsize=sx, uname='lower_label_bright', value='Minimum Brightness/Contrast')   
        bright_slide1 = widget_slider(brightbase, minimum=0, maximum=255, xsize = 150, sensitive=0, value=127, uname='bright_slide1', uvalue='bright_slide1');, /suppress_value)  ;sensitive=0 means grayed out, shown but not used
        upper_bright = widget_label(brightbase, /align_left, scr_xsize=sx, uname='bright_label_bright', value='Maximum Brightness/Contrast')
        bright_slide2 = widget_slider(brightbase, minimum=0, maximum=255, xsize = 150, sensitive=0, value=127, uname='bright_slide2', uvalue='bright_slide2')
        
        droplist2=widget_combobox(subbase3,/align_center,uname='kernel_drop',uvalue='kernel_drop',value=['Kernel','boxcar','median'])

  
  photo_subbase=widget_base(big_base,/row,/align_center,space=5,frame=1,sensitive=1)
  photo = widget_draw(photo_subbase, xsize=300, ysize=300, x_scroll_size=ssx,y_scroll_size=sy,uvalue='photo',uname='photo',/scroll);,/expose_events)
  histo=widget_draw(photo_subbase,xsize=300,ysize=300, uname='histo')

  subbase4 = widget_base(big_base, /row, /align_center, space=5, frame=1, sensitive=1)   ;base upon base,frame puts ouline, frame equals zero shows no outline
  button_save = widget_button(subbase4, /align_center, uvalue='button_save', uname='button_save', value='Save image', sensitive=0)
  button_other = widget_button(subbase4, /align_center, uvalue='button_other', uname='button_other', value='Do nothing', sensitive=1)

  state = {img_orig:-1, img_thrsh:-1, img_last:-1,img_zoom: -1, img_bright:-1, blevel1:127, blevel2:127, tlevel1:127, tlevel2:127, sx:300, sy:300, ssx:-1,ssy:-1,file_in:-1, file_out:'', tmin:-1,tmax:-1}   ;making a structure , can only update values in structure with the same type
  
  WIDGET_CONTROL, big_base, SET_UVALUE=state

  XManager, 'ees7110_HW6_procedure', big_base, /NO_BLOCK

end
;;
;event.str for dropdown box; case inside zoom case which houses zoom values