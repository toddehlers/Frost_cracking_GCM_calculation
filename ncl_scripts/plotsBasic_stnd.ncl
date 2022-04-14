; ***************************************************************************************
; STANDARD PLOTS                                                                        *
;                                                                                       *
; About this script:                                                                    *
; 0. Loads necessary NCL libraries                                                      *
; 1. Gets environmental variables passed by a bash control script (incl. experiment     * 
;    names, climate variables, time periods)                                            *           
; 2. If necessary calculates annual means from monthly input                            *
; 3. Generates 6-panel plots (for the 6 month interval and climate variable passed by   *
;    the control script) or single plots for annual means                               *
; ***************************************************************************************

; Load NCL libraries
; ------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin



;************************************************
; SCRIPT SETUP AND DECLARATIONS
;************************************************
; get passed options, generate file names, titles, set up script for passed options


; Get environmental variables passed by control script
; ----------------------------------------------------
  inpath1  = getenv("iPATH1")    ; path to input file
  inpath1w = getenv("wiPATH1")   ; path to wiso input file
  inpath2  = getenv("iPATH2")    ; path to reference simulation input file
  inpath2w = getenv("wiPATH2")   ; path to reference simulation wiso input file  
  outpath  = getenv("oPATH")     ; path to directory to save plots in
  infile1  = getenv("iFILE1")    ; input file
  exp1     = getenv("EXP")       ; experiment ID
  exp1Nm   = getenv("simNm")     ; experiment name
  climVar  = getenv("climVar")   ; climate variable to be investigated
  months   = getenv("monthsNm")  ; names of months to be plotted
  domain   = getenv("plotRegion"); region to be plotted 
  time     = getenv("plotTime")  ; time to be plotted (monthly or annual)
 
 
; Construct strings from passed options 
; -------------------------------------
; construct strings for output name, titles and labels

  ; ---- Annual mean
  if (time .eq. "an") then   
     outfile = "stnd_e5_"+domain+"_"+exp1+"_"+climVar                             ; create name of output file (plot)
     common_title = climVar+" ["+exp1Nm+"] annual mean"                           ; create plot title 
     if (climVar .eq. "Precipitation") then                                       ; colour bar label (variable specific)
        cbLabel="Precipitation (mm)"
     else if (climVar .eq. "Temperature") then
        cbLabel="Temperature (deg C)"
     else if (climVar .eq. "d18o") then
        cbLabel="d18O (per mil)"               
     else
        print ("ERROR: invalid climate variable passed in options")
     end if
     end if  
     end if    
  
  ; ---- Monthly means  
  else if (time .eq. "mo") then      
     outfile = "stnd_e5_"+domain+"_"+exp1+"_"+climVar+"_"+months                  ; create name of output file (plot)
     common_title = climVar+" ["+exp1Nm+"] "+months                               ; create plot title 
     if (climVar .eq. "Precipitation") then                                       ; colour bar label (variable specific)
        cbLabel="Precipitation (mm)"
     else if (climVar .eq. "Temperature") then
        cbLabel="Temperature (deg C)"
     else if (climVar .eq. "d18o") then
        cbLabel="d18O (per mil)"                  
     else
        print ("ERROR: invalid climate variable passed in options")
     end if
     end if
     end if  
  
  ; ---- Error handling
  else
     print ("ERROR: invalid time passed in options")
  end if
  end if  
  
  
  
; Month names and numbers 
; -----------------------
  if (months .eq. "January-June") then                          
     month_str = (/"Januray","Feburary","March","April","May","June"/)
     month_num = (/0,1,2,3,4,5/)
  else  
     month_str = (/"July","August","September","October","November","December"/)
     month_num = (/6,7,8,9,10,11/)
  end if

 
; Set climate variable specifics
; ------------------------------
  if (climVar .eq. "Precipitation") then  
     if (time .eq. "an") then
        lbmin=0                                ; minimum plotted
        lbmax=2500                             ; maximum plotted
        space=100                              ; spacing for colour bar        
     else if (time .eq. "mo") then         
        lbmin=0                                ; minimum plotted
        lbmax=200                              ; maximum plotted
        space=10                               ; spacing for colour bar
     end if
     end if    
     colI=50                                   ; colour start (for colour table)
     colF=300                                  ; colour end (for colour table)       
  else if (climVar .eq. "Temperature") then
     lbmin=-30                                 ; minimum plotted
     lbmax=30                                  ; maximum plotted
     space=2                                   ; spacing for colour bar  
     colI=-30                                  ; colour start (for colour table)
     colF=30                                   ; colour end (for colour table)        
  else if (climVar .eq. "d18o") then
     lbmin=-20                                 ; minimum plotted
     lbmax=5                                   ; maximum plotted
     space=2                                   ; spacing for colour bar  
     colI=-20                                  ; colour start (for colour table)
     colF=10                                   ; colour end (for colour table)        
  end if
  end if
  end if
 
 
; Set domain size 
; ---------------
; set minimum and maximum latitude and longitude
  if (domain .eq. "glo") then          ; global
     minLon = -180
     maxLon = 180
     minLat = -90
     maxLat = 90
  else if (domain .eq. "als") then     ; Alaska
     minLon = -165
     maxLon = -125
     minLat = 52
     maxLat = 68    
  else if (domain .eq. "sam") then     ; South America (Andes)     
     minLon = -80
     maxLon = -60
     minLat = -50
     maxLat = -5    
;     minLon = -76
;     maxLon = -65
;     minLat = -20
;     maxLat = -10    
  else if (domain .eq. "nam") then     ; Olympic Mnt's
     minLon = -126
     maxLon = -118
     minLat = 43
     maxLat = 52        
  else if (domain .eq. "tbt") then     ; Tibetan Plateau / Himalayas
     minLon = 40
     maxLon = 120
     minLat = 0
     maxLat = 60
  else if (domain .eq. "eur") then     ; Europe
     minLon = -15
     maxLon = 40
     minLat = 35
     maxLat = 65     
  else if (domain .eq. "eas") then     ; Eurasia
     minLon = -18
     maxLon = 164
     minLat = 20
     maxLat = 77         
  else if (domain .eq. "cas") then     ; Cascades
     minLon = -129
     maxLon = -120
     minLat = 45
     maxLat = 52        
  else if (domain .eq. "nzl") then     ; New Zealand
     minLon = 165
     maxLon =180
     minLat = -47
     maxLat = -34       
  else
     print ("ERROR: invalid geographical domain passed in options")   
  end if
  end if
  end if
  end if
  end if 
  end if 
  end if 
  end if
  end if 
 
 
 
 
;************************************************
; READ INPUT FILES 
;************************************************
  
  if (climVar .eq. "d18o") then   
     f1 = addfile(inpath1w+infile1,"r")   ; simulation  
  else
     f1 = addfile(inpath1+infile1,"r")    ; simulation
 end if
 

; Reading and processing precipitation (total)
; -------------------------------------------- 
 
  if (climVar .eq. "Precipitation") then 
     var1 = f1->aprl       ; read large scale precipitation 
     var2 = f1->aprc       ; read convective precipitation
     lat  = f1->lat        
     lon  = f1->lon
     rec  = f1->time

     var3=var1              ; pass dimensions to new variable
     var3=var1+var2         ; total precipitation = var1 + var2
     var3=var3*60*60*24*30  ; convert from mm/h to mm/month

     var=var3               ; pass variable attributes to difference variable
     var@units = "mm"       ; attribute new units

     ; ---- calculate annual mean if to be plotted
     if (time .eq. "an") then        
        var((0),:,:,:)=dim_sum_n(var3,0)             ; precip as mean annual sum        
     end if

             
; Reading and processing temperature (surface)
; --------------------------------------------    
    
  else if (climVar .eq. "Temperature") then
    
     var3 = f1->temp2       ; read surface temperature
     lat  = f1->lat   
     lon  = f1->lon
     rec  = f1->time    
    
     var3 = var3-273.15     ; convert to degrees Celsius 
    
     var3@rec   = rec
     var3@lat   = lat
     var3@lon   = lon
     var3&lat@units = "degrees_north"
     var3&lon@units = "degrees_east"
     var3@units = "deg C"

     var=var3               ; pass variable attributes to difference variable            
     var@units = "deg C"    ; attribute new units
 
     ; ---- calculate annual mean if to be plotted
     if (time .eq. "an") then        
         var((0),:,:)=dim_avg_n(var3,0)              ; arithmetic mean (annual mean)
     end if

     
; Reading and processing d18o (total)
; -------------------------------------------- 
 
  else if (climVar .eq. "d18o") then 
     var1 = f1->wisoaprl    ; read large scale precipitation 
     var2 = f1->wisoaprc    ; read convective precipitation
     lat  = f1->lat        
     lon  = f1->lon
     rec  = f1->time

     var3=var1              ; pass dimensions to new variable
     var3=var1+var2         ; total precipitation = var1 + var2
;     var3=var3*60*60*24*30  ; convert from mm/h to mm/month

     var=var3               ; pass variable attributes to difference variable
     var@units = "per mil"  ; attribute new units

     ; ---- calculate annual mean if to be plotted
     if (time .eq. "an") then        
        var((0),:,:,:)=dim_sum_n(var3,0)             ; precip d18O as mean annual sum
     end if     
     
  end if     
  end if
  end if 
 


 
;************************************************
; CREATE PLOT
;************************************************

  wks = gsn_open_wks("pdf",outpath+outfile)   ; file type (=PDF) and output file  
  
  ;--- Determine variable specific colour table
  if (climVar .eq. "Precipitation") then
     gsn_define_colormap(wks,"BlAqGrYeOrReVi200")      ; choose colormap      
  else if (climVar .eq. "Temperature") then
     gsn_define_colormap(wks,"BlAqGrYeOrReVi200")      ; choose colormap   
  else if (climVar .eq. "d18o") then
     gsn_define_colormap(wks,"BlAqGrYeOrReVi200")      ; choose colormap   
  end if     
  end if
  end if  
  
  plot = new(6,graphic)                       ; create a plot array

  
  
  
; Individual plots (to be combined if monthly means)  
; ==================================================  
; defines options and draws individual plots to go on the panel plot later


; Basic options  
; -------------   
  res                      = True
  res@gsnDraw              = False           ; don't draw
  res@gsnFrame             = False           ; don't advance frame
  res@cnInfoLabelOn        = False           ; turn off cn info label
  res@cnFillOn             = True            ; turn on color
  res@cnLinesOn            = False

  
; Colour table options  
; --------------------  
  if (climVar .eq. "Precipitation") then
     res@gsnSpreadColors = True            ; spread out colour table
  else if (climVar .eq. "Temperature") then
     res@gsnSpreadColors = False           ; spread out colour table     
  else if (climVar .eq. "d18o") then
     res@gsnSpreadColors = False           ; spread out colour table        
  else
     print ("ERROR: invalid climate variable passed in options")
  end if
  end if
  end if  
  res@gsnSpreadColorStart  = colI            ; spread colour start (variable specific: defined in declarations)
  res@gsnSpreadColorEnd    = colF            ; spread colour end (variable specific: defined in declarations)
  res@lbLabelBarOn         = False           ; turn off individual colour bars
  res@cnFillMode 	       = "RasterFill"
  res@cnRasterSmoothingOn  = False           ; smoothing
  res@cnLevelSelectionMode = "ManualLevels"   
  res@cnMinLevelValF       = lbmin           ; minimum plotted value (variable specific: defined in declarations)
  res@cnMaxLevelValF       = lbmax           ; maximum plotted value (variable specific: defined in declarations)
  res@cnLevelSpacingF      = space           ; values spacing (variable specific: defined in declarations)
  res@cnLineLabelsOn       = False           ; turn contour labels off
  res@cnInfoLabelOn        = False           ; turn off contour infolabel
  if (climVar .eq. "Precipitation") then     ; reverse colour table for precipitation
     gsn_reverse_colormap(wks)                
  end if  
  
  
; Geographical and national boundaries
; ------------------------------------
  res@mpMaxLatF=maxLat                     ; maximum latitude
  res@mpMinLatF=minLat                     ; minimum latitude
  res@mpMaxLonF=maxLon                     ; maximum longitude
  res@mpMinLonF=minLon                     ; minimum longitude
  res@mpGeophysicalLineThicknessF=1.0      ; line thickness for geographical boundaries
  res@mpOutlineOn=True                     ; geographical boundaries
  res@mpOutlineBoundarySets="National"     ; country borders
  res@mpNationalLineThicknessF = 0.5       ; country border line thickness
  res@mpNationalLineColor      = "Gray"    ; country border line colour   

  
; Drawing plots 
; -------------   

  if (climVar .ne. "d18o") then

     ; ---- annual
     if (time .eq. "an") then
        res@gsnLeftString = "                    annual"               ; label
        plot(0)=gsn_csm_contour_map_ce(wks,var(0,:,:),res)             ; make map
  
     ; ---- monthly (for 6 months separately)    
     else if (time .eq. "mo") then
        res@gsnLeftString = "                    "+month_str(0)        ; month label
        plot(0)=gsn_csm_contour_map_ce(wks,var(month_num(0),:,:),res)  ; make map
        res@gsnLeftString = "                    "+month_str(1)        
        plot(1)=gsn_csm_contour_map_ce(wks,var(month_num(1),:,:),res)  
        res@gsnLeftString = "                    "+month_str(2)        
        plot(2)=gsn_csm_contour_map_ce(wks,var(month_num(2),:,:),res)  
        res@gsnLeftString = "                    "+month_str(3)
        plot(3)=gsn_csm_contour_map_ce(wks,var(month_num(3),:,:),res)  
        res@gsnLeftString = "                    "+month_str(4)
        plot(4)=gsn_csm_contour_map_ce(wks,var(month_num(4),:,:),res)  
        res@gsnLeftString = "                    "+month_str(5)
        plot(5)=gsn_csm_contour_map_ce(wks,var(month_num(5),:,:),res) 

     end if
     end if    
  
  else if (climVar .eq. "d18o") then
  
     ; ---- annual
     if (time .eq. "an") then
        res@gsnLeftString = "                    annual"                 ; label
        plot(0)=gsn_csm_contour_map_ce(wks,var(0,0,:,:),res)             ; make map
  
     ; ---- monthly (for 6 months separately)    
     else if (time .eq. "mo") then
        res@gsnLeftString = "                    "+month_str(0)          ; month label
        plot(0)=gsn_csm_contour_map_ce(wks,var(month_num(0),0,:,:),res)  ; make map
        res@gsnLeftString = "                    "+month_str(1)        
        plot(1)=gsn_csm_contour_map_ce(wks,var(month_num(1),0,:,:),res)  
        res@gsnLeftString = "                    "+month_str(2)        
        plot(2)=gsn_csm_contour_map_ce(wks,var(month_num(2),0,:,:),res)  
        res@gsnLeftString = "                    "+month_str(3)
        plot(3)=gsn_csm_contour_map_ce(wks,var(month_num(3),0,:,:),res)  
        res@gsnLeftString = "                    "+month_str(4)
        plot(4)=gsn_csm_contour_map_ce(wks,var(month_num(4),0,:,:),res)  
        res@gsnLeftString = "                    "+month_str(5)
        plot(5)=gsn_csm_contour_map_ce(wks,var(month_num(5),0,:,:),res)   
  
     end if
     end if    
  
  end if    
  end if    
  
  
; Draw geographical markers and labels on regional maps  
; -----------------------------------------------------        
  if (domain .ne. "glo") then                                        ; if domain is not global
 
     ;---Create arrays with cities and lat/lon locations 
     if (domain .eq. "als") then                                     ; Alaska
        locations = (/"An", "El"/)                                   ; Anchorage, St. Elias National Park       
        lat_loc   = (/  61.20, 61.71/)    
        lon_loc   = (/  -149.90, -142.95/) 
     else if (domain .eq. "sam") then                                ; South America (Andes)     
        locations = (/"Li", "Ar", "An", "Sa", "LP"/)                 ; Lima, Arica, Antofagasta, Santiago, La Paz
        lat_loc   = (/  -12.1, -18.49, -23.68, -33.48, -16.54/)    
        lon_loc   = (/  -77.0, -70.26, -70.37, -70.61, -68.14/)
     else if (domain .eq. "nam") then                                ; Olympic Mnt's
        locations = (/"Se", "Ad"/)                                   ; Seattle, Aberdeen
        lat_loc   = (/  47.6, 47.01/)    
        lon_loc   = (/  -122.38, -123.81/)    
     else if (domain .eq. "tbt") then                                ; Tibetan Plateau / Himalayas
        locations = (/"Ka", "Du", "Ch", "Na", "Nn","Lh","Ku"/)
        lat_loc   = (/  27.42, 38.32, 30.39, 29.37, 35.14, 29.39, 36.0/)
        lon_loc   = (/  85.20, 68.46, 104.3, 95.03, 74.35, 91.07, 84.0/)
     else if (domain .eq. "eur") then                                    ; Europe
        locations = (/"Pa", "Be", "Mo", "Ki", "Ro", "Bu", "Ma","Da"/)    ; Paris, Berlin, Moscow, Kiev, Rome, Budapest, Madrid, Damascus
        lat_loc   = (/  48.84, 52.5, 55.75, 50.45, 41.90, 47.49, 40.42, 33.49/)
        lon_loc   = (/  2.36, 13.4, 37.6, 30.52, 12.50, 19.03, -3.70, 36.29/) 
     else if (domain .eq. "eas") then                                     ; Eurasia
        locations = (/"Pa", "Te", "Mo", "Be", "As", "UB", "Ya", "Ka"/)    ; Paris, Tehran, Moscow, Beijing, Astana, Ulan Bator, Yakutsk, Kathmandu
        lat_loc   = (/  48.84, 35.70, 55.75, 39.90, 51.13, 47.91, 62.03, 27.42/)
        lon_loc   = (/  2.36, 51.40, 37.6, 116.40, 71.58, 107.00, 129.68, 85.20/)             
     else if (domain .eq. "cas") then                                ; Cascades
        locations = (/"Se", "Va", "Po"/)                             ; Seattle, Vancouver, Portland
        lat_loc   = (/  47.6, 49.3, 45.5/)    
        lon_loc   = (/  -122.38,-123, -122.68/)           
     else if (domain .eq. "nzl") then                                ; New Zealand
        locations = (/"Ch", "We", "Au"/)                             ; Christchurch, Wellington, Auckland
        lat_loc   = (/  -43.56, -41.3, -36.86/)    
        lon_loc   = (/  172.67, 174.8,174.76/)            
     else
        print ("ERROR: invalid geographical domain passed in options")   
     end if
     end if
     end if
     end if 
     end if
     end if
     end if 
     end if 

     ;---Attach markers to map
     mres               = True
     mres@gsMarkerSizeF = 2.                                            ; enlarge marker
     mres@gsMarkerIndex = 16                                            ; marker index number for filled dot
     mres@gsMarkerColor = "Black"                                       ; marker colour
     
     if (time .eq. "an") then
        dum11 = gsn_add_polymarker(wks,plot(0),lon_loc,lat_loc,mres)
   
     else if (time .eq. "mo") then
        dum11 = gsn_add_polymarker(wks,plot(0),lon_loc,lat_loc,mres)
        dum12 = gsn_add_polymarker(wks,plot(1),lon_loc,lat_loc,mres)
        dum13 = gsn_add_polymarker(wks,plot(2),lon_loc,lat_loc,mres)
        dum14 = gsn_add_polymarker(wks,plot(3),lon_loc,lat_loc,mres)
        dum15 = gsn_add_polymarker(wks,plot(4),lon_loc,lat_loc,mres)
        dum16 = gsn_add_polymarker(wks,plot(5),lon_loc,lat_loc,mres)
     end if
     end if        
  
     ;---Attach text to map
     tres               = True
     tres@txFontHeightF = 0.02                                         ; make font smaller 
     tres@txJust        = "CenterLeft"                                  ; default is "CenterCenter"
     tres@txFont        = 22

     if (time .eq. "an") then
        dum2 = gsn_add_text(wks,plot(0),locations,lon_loc+0.5,lat_loc,tres)
   
     else if (time .eq. "mo") then
        dum2 = gsn_add_text(wks,plot(0),locations,lon_loc+0.5,lat_loc,tres)
        dum2 = gsn_add_text(wks,plot(1),locations,lon_loc+0.5,lat_loc,tres)
        dum2 = gsn_add_text(wks,plot(2),locations,lon_loc+0.5,lat_loc,tres)
        dum2 = gsn_add_text(wks,plot(3),locations,lon_loc+0.5,lat_loc,tres)
        dum2 = gsn_add_text(wks,plot(4),locations,lon_loc+0.5,lat_loc,tres)
        dum2 = gsn_add_text(wks,plot(5),locations,lon_loc+0.5,lat_loc,tres)    
     end if
     end if        
    
  end if 
 
 
 
 
; Panel plot (combining individual plots)  
; ===============================================

  resP                   = True                      ; modify the panel plot
  resP@gsnFrame          = False                     ; don't advance panel plot
  resP@gsnPanelLabelBar  = True                      ; add common colorbar

  ;---Add common colour title  
  resP@txString          = common_title              ; common title created in declaration section
  if (time .eq. "an") then  
     resP@txFontHeightF     = 0.02                   ; change font size
  else if (time .eq. "mo") then
     resP@txFontHeightF     = 0.015                  ; change font size
  end if
  end if 
  resP@gsnPanelBottom    = 0.05  
  resP@gsnMaximize       = True

  ;---- Draw either 1 (annual) or 6 (monthly) plots
  if (time .eq. "an") then  
     gsn_panel(wks,plot,(/1,1/),resP)                ; draw one plot
  else if (time .eq. "mo") then
     gsn_panel(wks,plot,(/3,2/),resP)                ; draw individual plots as one plot
  end if
  end if 
        
  ;---Add common colour bar label
  txres               = True
  if (time .eq. "an") then  
     txres@txFontHeightF = 0.02                       ; change font size
     gsn_text_ndc(wks,cbLabel,0.51,0.04,txres)        ; add text ("cbLabel" created in declarations sections) at specified position     
  else if (time .eq. "mo") then
     txres@txFontHeightF = 0.012                      ; change font size
     gsn_text_ndc(wks,cbLabel,0.51,0.04,txres)        ; add text ("cbLabel" created in declarations sections) at specified position
  end if
  end if     
  frame(wks)
  
end
