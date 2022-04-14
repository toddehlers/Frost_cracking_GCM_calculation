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
  inpath  = "/esd/esd01/docs/hsharma/data_small/FCI_data/Temperature/"    ; path to input file
  outpath  = "/esd/esd01/docs/hsharma/data_small/plots/"     ; path to directory to save plots in
  infile  = "Temperature.nc"	; input file containing all the simulations [PI,MH,LGM,PLIO]
  climVar  = "MAT"	; climate variable to be investigated
  domain   = "glo"	; region to be plotted
  title = "MAT"

; Construct strings from passed options
; -------------------------------------
; construct strings for output name, titles and labels

  outfile = title+"_"+domain                             ; create name of output file (plot)
  common_title = "Mean Annual Surface Temperature (15-year average) for PI, MH, LGM, PLIO [Deg C]"
  cbLabel="Mean Annual Surface Temperature [Deg C]" 
  
; Set climate variable specifics
; ------------------------------

  lbmin = -50                                 ; minimum plotted
  lbmax = 30                               ; maximum plotted
  space=5                                   ; spacing for colour bar
;  colI=-30                                  ; colour start (for colour table)
;  colF=30                                   ; colour end (for colour table)

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

 f1 = addfile(inpath+infile,"r")   ; file containing all the simulations as records [PI, MH, LGM, PLIO]

; Reading and processing frost cracking intensity (FCI)
; ------------------------------------------------------

  var1 = f1->MAT       ; read mean frost cracking intensity
  lat  = f1->lat
  lon  = f1->lon
  rec  = f1->time
  
  var1@rec   = rec
  var1@lat   = lat
  var1@lon   = lon
  var1&lat@units = "degrees_north"
  var1&lon@units = "degrees_east"
  var1@units = "DegC"

  var=var1               ; pass variable attributes to difference variable
  var@units = "DegC"    ; attribute new units
  var@_FillValue = -999           ; sets _FillValue to -999
;  var = where(var.ne.0,var,var@_FillValue)

;************************************************
; CREATE PLOT
;************************************************

  wks = gsn_open_wks("pdf",outpath+outfile)   ; file type (=PDF) and output file

  plot = new(4,graphic)                       ; create a plot array

  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; Individual plots (to be combined if monthly means)
; ==================================================
; defines options and draws individual plots to go on the panel plot later


; Basic options
; -------------
  res                      = True
  res@gsnDraw              = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnInfoLabelOn        = False           ; turn off cn info label
  res@cnFillOn             = True            ; turn on color
  res@cnLinesOn            = False
  res@gsnSpreadColors = True            ; spread out colour table
;  res@gsnSpreadColorStart  = colI            ; spread colour start (variable specific: defined in declarations)
;  res@gsnSpreadColorEnd    = colF            ; spread colour end (variable specific: defined in declarations)
  res@lbLabelBarOn         = False           ; turn off individual colour bars
  res@cnFillMode               = "RasterFill"
  res@cnRasterSmoothingOn  = False           ; smoothing
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = lbmin           ; minimum plotted value (variable specific: defined in declarations)
  res@cnMaxLevelValF       = lbmax           ; maximum plotted value (variable specific: defined in declarations)
  res@cnLevelSpacingF      = space           ; values spacing (variable specific: defined in declarations)
  res@cnLineLabelsOn       = False           ; turn contour labels off
  res@cnInfoLabelOn        = False           ; turn off contour infolabel

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

  res@gsnLeftString = "Pre-Industrial"
  plot(0)=gsn_csm_contour_map(wks,var(0,:,:),res)  ; make map
  res@gsnLeftString = "Mid-Holocene"
  plot(1)=gsn_csm_contour_map(wks,var(1,:,:),res)
  res@gsnLeftString = "Last Glacial Maximum"
  plot(2)=gsn_csm_contour_map(wks,var(2,:,:),res)
  res@gsnLeftString = "Pliocene"
  plot(3)=gsn_csm_contour_map(wks,var(3,:,:),res)
  
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
     dum11 = gsn_add_polymarker(wks,plot(0),lon_loc,lat_loc,mres)
     dum12 = gsn_add_polymarker(wks,plot(1),lon_loc,lat_loc,mres)
     dum13 = gsn_add_polymarker(wks,plot(2),lon_loc,lat_loc,mres)
     dum14 = gsn_add_polymarker(wks,plot(3),lon_loc,lat_loc,mres)
     
     ;---Attach text to map
     tres               = True
     tres@txFontHeightF = 0.02                                         ; make font smaller
     tres@txJust        = "CenterLeft"                                  ; default is "CenterCenter"
     tres@txFont        = 22
   
     dum21 = gsn_add_text(wks,plot(0),locations,lon_loc+0.5,lat_loc,tres)
     dum22 = gsn_add_text(wks,plot(1),locations,lon_loc+0.5,lat_loc,tres)
     dum23 = gsn_add_text(wks,plot(2),locations,lon_loc+0.5,lat_loc,tres)
     dum24 = gsn_add_text(wks,plot(3),locations,lon_loc+0.5,lat_loc,tres)

  end if

; Panel plot (combining individual plots)
; ===============================================

  resP                   = True                      ; modify the panel plot
  resP@gsnFrame          = False                     ; don't advance panel plot
  resP@gsnPanelLabelBar  = True                      ; add common colorbar

  ;---Add common colour title
  resP@txString          = common_title              ; common title created in declaration section
  resP@txFontHeightF     = 0.017                  ; change font size
  resP@gsnPanelBottom    = 0.05
  resP@gsnMaximize       = True

  gsn_panel(wks,plot,(/2,2/),resP)                ; draw individual plots as one plot

  ;---Add common colour bar label
  txres               = True

  txres@txFontHeightF = 0.015                      ; change font size
  gsn_text_ndc(wks,cbLabel,0.51,0.17,txres)        ; add text ("cbLabel" created in declarations sections) at specified position
  frame(wks)

end

