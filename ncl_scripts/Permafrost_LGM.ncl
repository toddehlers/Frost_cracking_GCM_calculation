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
  inpath  = "/esd/esd01/docs/hsharma/data_small/data/"    ; path to input file
  outpath  = "/esd/esd01/docs/hsharma/data_small/plots/"     ; path to directory to save plots in
;  infile1 = "FCI_Vw/Integrated_FCI_LGM_Vw.nc"
  infile2  = "Permafrost/Permafrost_LGM_new3.nc"	; input file containing all the simulations [PI,MH,LGM,PLIO]
  climVar  = "Permafrost"	; climate variable to be investigated
  domain   = "glo"	; region to be plotted
  title = "Permafrost_LGM"

; Construct strings from passed options
; -------------------------------------
; construct strings for output name, titles and labels

  outfile = title                            ; create name of output file (plot)
  common_title = "Permafrost extent in LGM"
  cbLabel= "3: Continuous Permafrost; 2: Discontinuous PErmafrost; 1: Sporadic Permafrost" 
  
; Set climate variable specifics
; ------------------------------

  lbmin = 1                                 ; minimum plotted
  lbmax = 3                            ; maximum plotted
  space = 1                                   ; spacing for colour bar
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

; f1 = addfile(inpath+infile1,"r")   ; file containing all the simulations as records [FCI for LGM]
 f2 =  addfile(inpath+infile2,"r")

; Reading and processing frost cracking intensity (FCI)
; ------------------------------------------------------

;  Ci = f1->Ci       ; read mean frost cracking intensity
;  Ci@_FillValue = -999           ; sets _FillValue to -999
;  Ci = where(Ci.ne.0,Ci,Ci@_FillValue)
  
  Perm = f2->Permafrost       ; read Permafrost
  Perm@_FillValue = -999           ; sets _FillValue to -999
  Perm = where(Perm.ne.0,Perm,Perm@_FillValue)


;************************************************
; CREATE PLOT
;************************************************

  wks = gsn_open_wks("png",outpath+outfile)   ; file type (=PDF) and output file

; Individual plots (to be combined if monthly means)
; ==================================================
; defines options and draws individual plots to go on the panel plot later


; Basic options
; -------------
  res1                      = True
  res1@gsnDraw              = False           ; don't draw
  res1@gsnFrame            = False           ; don't advance frame
  res1@cnInfoLabelOn        = False           ; turn off cn info label
  res1@cnFillOn             = True            ; turn on color
  res1@cnLinesOn            = False
  res1@gsnSpreadColors = True            ; spread out colour table
;  res@gsnSpreadColorStart  = colI            ; spread colour start (variable specific: defined in declarations)
;  res@gsnSpreadColorEnd    = colF            ; spread colour end (variable specific: defined in declarations)
  res1@lbLabelBarOn         = False           ; turn off individual colour bars
  res1@cnFillMode               = "RasterFill"
;  res1@cnFillPalette        = "BlAqGrYeOrReVi200"           ; set color map for sst
  res1@cnRasterSmoothingOn  = False           ; smoothing
  res1@cnLevelSelectionMode = "ManualLevels"
  res1@cnMinLevelValF       = lbmin           ; minimum plotted value (variable specific: defined in declarations)
  res1@cnMaxLevelValF       = lbmax           ; maximum plotted value (variable specific: defined in declarations)
  res1@cnLevelSpacingF      = space           ; values spacing (variable specific: defined in declarations)
  res1@cnFillPalette        = "BlAqGrYeOrReVi200"           ; set color map for FCI
  res1@cnLineLabelsOn       = False           ; turn contour labels off
  res1@cnInfoLabelOn        = False           ; turn off contour infolabel

; Geographical and national boundaries
; ------------------------------------
  res1@mpMaxLatF=maxLat                     ; maximum latitude
  res1@mpMinLatF=minLat                     ; minimum latitude
  res1@mpMaxLonF=maxLon                     ; maximum longitude
  res1@mpMinLonF=minLon                     ; minimum longitude
  res1@mpGeophysicalLineThicknessF=1.0      ; line thickness for geographical boundaries
  res1@mpOutlineOn=True                     ; geographical boundaries
  res1@mpOutlineBoundarySets="National"     ; country borders
  res1@mpNationalLineThicknessF = 0.5       ; country border line thickness
  res1@mpNationalLineColor      = "Gray"    ; country border line colour

;************************************************
; resource list for Permafrost
;************************************************
;  res2                      = True
;  res2@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
;  res2@cnMinLevelValF       = 0.              ; set min contour level
;  res2@cnMaxLevelValF       = 1.              ; set max contour level
;  res2@cnLevelSpacingF      = 0.5              ; set contour spacing
;  res2@cnLineLabelsOn       = False
;  res2@cnLineThicknessF = 4     ; thicker contours
;  res2@cnLineColor       ="Black"            ; blue contour lines
;  res2@cnLineDashPattern = 4                      ; dashed lines


;  Drawing plots
; -------------

  res1@gsnLeftString = " "
  plot = gsn_csm_contour_map(wks,Perm(:,:),res1)
;  draw(plot)

;  frame(wks)				     
;end  

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

     dum1 = gsn_add_polymarker(wks,plot,lon_loc,lat_loc,mres)
     
     ;---Attach text to map
     tres               = True
     tres@txFontHeightF = 0.02                                         ; make font smaller
     tres@txJust        = "CenterLeft"                                  ; default is "CenterCenter"
     tres@txFont        = 22
   
     dum2 = gsn_add_text(wks,plot,locations,lon_loc+0.5,lat_loc,tres)

  end if

;***********************************************
; legend resources
;***********************************************
; lgres                    = True
; lgres@lgLineColors       = (/"black","blue"/)    ; colors for legend lines
; lgres@vpWidthF           = 0.2                   ; width of legend (NDC)
; lgres@vpHeightF          = 0.1                   ; height of legend (NDC)
; lgres@lgPerimOn          = False                 ; turn off perimeter
; lgres@lgDashIndexes      = (/0, 12/)              ; dash indexes
; lgres@lgLineLabelStrings = (/"",""/)             ; no labels in lines

;**************************************************************
; Draw the legend, indicating the number of items, a label for each
; item, and the X, Y position of the legend in NDC coordinates.
;**************************************************************
; gsn_legend_ndc(wks,2,(/"Continuous Permafrost","Discontinuous Permafrost"/),0.4,0.15,lgres)

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

  gsn_panel(wks,plot,(/1,1/),resP)                ; draw individual plots as one plot

  ;---Add common colour bar label
  txres               = True

  txres@txFontHeightF = 0.015                      ; change font size
  gsn_text_ndc(wks,cbLabel,0.51,0.1,txres)        ; add text ("cbLabel" created in declarations sections) at specified position
  frame(wks)

end

