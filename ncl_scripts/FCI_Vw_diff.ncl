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
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

;************************************************
; SCRIPT SETUP AND DECLARATIONS
;************************************************
; get passed options, generate file names, titles, set up script for passed options


; Get environmental variables passed by control script
; ----------------------------------------------------
  inpath  = "/esd/esd01/docs/hsharma/data_small/FCI_data/FCI_Vw_no_penalty/"    ; path to input file
  outpath  = "/esd/esd01/docs/hsharma/data_small/plots2/"     ; path to directory to save plots in
  infile  = "FCI_Vw_diff.nc"	; input file containing all the simulations [PI,MH,LGM,PLIO]
  infile1 = "/esd/esd01/docs/hsharma/data_small/FCI_data/Temperature/GLAC_diff.nc"
  climVar  = "Ci"	; climate variable to be investigated
  domain   = "PI-PLIO"	; region to be plotted
  title = "FCI_Vw_diff"

; Construct strings from passed options
; -------------------------------------
; construct strings for output name, titles and labels

  outfile = title+"_"+domain                             ; create name of output file (plot)
  common_title = "Difference Maps for long term mean FCI [DegC m]"
  cbLabel="Frost Cracking Intensity difference (DegC m)" 
  
; Set climate variable specifics
; ------------------------------

  lbmin = -25                                ; minimum plotted
  lbmax = 25                              ; maximum plotted
  space = 5                                   ; spacing for colour bar
;  colI=-30                                  ; colour start (for colour table)
;  colF=30                                   ; colour end (for colour table)

; Set domain size
; ---------------
; set minimum and maximum latitude and longitude
      
  minLon = -180		; global
  maxLon = 180
  minLat = -90
  maxLat = 90

  minLon_sam = -80		; South America (Andes)
  maxLon_sam = -60
  minLat_sam = -60
  maxLat_sam = -15
 
  minLon_tbt = 40		; Tibetan Plateau / Himalayas
  maxLon_tbt = 120
  minLat_tbt = 0
  maxLat_tbt = 60

  minLon_eur = -15		; Europe
  maxLon_eur = 40
  minLat_eur = 35
  maxLat_eur = 65
  

;************************************************
; READ INPUT FILES
;************************************************

 f1 = addfile(inpath+infile,"r")   ; file containing all the simulations as records [PI, MH, LGM, PLIO]
 f2 =  addfile(infile1,"r")

; Reading and processing frost cracking intensity (FCI)
; ------------------------------------------------------

  var1 = f1->Ci       ; read mean frost cracking intensity
  lat  = f1->lat
  lon  = f1->lon
  rec  = f1->time
  
  var1@rec   = rec
  var1@lat   = lat
  var1@lon   = lon
  var1&lat@units = "degrees_north"
  var1&lon@units = "degrees_east"
  var1@units = domain

  var=var1               ; pass variable attributes to difference variable
  var@units = domain    ; attribute new units
  var@_FillValue = -999           ; sets _FillValue to -999
  var = where(var.ne.0,var,var@_FillValue)

  GLAC = f2->GLAC       ; read Permafrost
  GLAC@_FillValue = -999           ; sets _FillValue to -999
;  GLAC = where(GLAC.ne.0,GLAC,GLAC@_FillValue)

;************************************************
; CREATE PLOT
;************************************************

  wks = gsn_open_wks("png",outpath+outfile)   ; file type (=PDF) and output file

  plot = new(4,graphic)                       ; create a plot array

  gsn_define_colormap(wks,"BlueRed")

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
  res@gsnSpreadColors = True            ; spread out colour table
  res@cnFillMode               = "RasterFill"
  res@cnRasterSmoothingOn  = False           ; smoothing
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = lbmin           ; minimum plotted value (variable specific: defined in declarations)
  res@cnMaxLevelValF       = lbmax           ; maximum plotted value (variable specific: defined in declarations)
  res@cnLevelSpacingF      = space           ; values spacing (variable specific: defined in declarations)
  res@cnSpanFillPalette    = True
  res@cnLineLabelsOn       = False           ; turn contour labels off
  res@cnInfoLabelOn        = False           ; turn off contour infolabel
  res@lbLabelBarOn = False 
;  res@vpWidthF  = 1.0		; set width of plot 
; res@vpHeightF = 0.5		; set height of plot

  res2                      = True
  res2@gsnDraw              = False           ; don't draw
  res2@gsnFrame             = False           ; don't advance frame
  res2@cnInfoLabelOn        = False           ; turn off cn info label
  res2@cnFillOn             = True            ; turn on color
  res2@cnLinesOn            = False
  res2@gsnSpreadColors = True            ; spread out colour table
  res2@cnFillMode               = "RasterFill"
  res2@cnRasterSmoothingOn  = False           ; smoothing
  res2@cnLevelSelectionMode = "ManualLevels"
  res2@cnMinLevelValF       = lbmin           ; minimum plotted value (variable specific: defined in declarations)
  res2@cnMaxLevelValF       = lbmax           ; maximum plotted value (variable specific: defined in declarations)
  res2@cnLevelSpacingF      = space           ; values spacing (variable specific: defined in declarations)
  res2@cnSpanFillPalette    = True
  res2@cnLineLabelsOn       = False           ; turn contour labels off
  res2@cnInfoLabelOn        = False           ; turn off contour infolabel
  res2@lbLabelBarOn = False 
;  res2@vpWidthF  = 0.7/1.5		; set width of plot 
;  res2@vpHeightF = 0.38/1.5		; set height of plot

  res3                      = True
  res3@gsnDraw              = False           ; don't draw
  res3@gsnFrame             = False           ; don't advance frame
  res3@cnInfoLabelOn        = False           ; turn off cn info label
  res3@cnFillOn             = True            ; turn on color
  res3@cnLinesOn            = False
  res3@gsnSpreadColors = True            ; spread out colour table
  res3@cnFillMode               = "RasterFill"
  res3@cnRasterSmoothingOn  = False           ; smoothing
  res3@cnLevelSelectionMode = "ManualLevels"
  res3@cnMinLevelValF       = lbmin           ; minimum plotted value (variable specific: defined in declarations)
  res3@cnMaxLevelValF       = lbmax           ; maximum plotted value (variable specific: defined in declarations)
  res3@cnLevelSpacingF      = space           ; values spacing (variable specific: defined in declarations)
  res3@cnSpanFillPalette    = True
  res3@cnLineLabelsOn       = False           ; turn contour labels off
  res3@cnInfoLabelOn        = False           ; turn off contour infolabel
  res3@lbLabelBarOn = False 
;  res3@vpWidthF  = 0.7/1.5		; set width of plot 
;  res3@vpHeightF = 0.525/1.5		; set height of plot

  res4                      = True
  res4@gsnDraw              = False           ; don't draw
  res4@gsnFrame             = False           ; don't advance frame
  res4@cnInfoLabelOn        = False           ; turn off cn info label
  res4@cnFillOn             = True            ; turn on color
  res4@cnLinesOn            = False
  res4@gsnSpreadColors = True            ; spread out colour table
  res4@cnFillMode               = "RasterFill"
  res4@cnRasterSmoothingOn  = False           ; smoothing
  res4@cnLevelSelectionMode = "ManualLevels"
  res4@cnMinLevelValF       = lbmin           ; minimum plotted value (variable specific: defined in declarations)
  res4@cnMaxLevelValF       = lbmax           ; maximum plotted value (variable specific: defined in declarations)
  res4@cnLevelSpacingF      = space           ; values spacing (variable specific: defined in declarations)
  res4@cnSpanFillPalette    = True
  res4@cnLineLabelsOn       = False           ; turn contour labels off
  res4@cnInfoLabelOn        = False           ; turn off contour infolabel
  res4@lbLabelBarOn = False 
  res4@vpWidthF  = 0.355/1.5		; set width of plot 
  res4@vpHeightF = 0.8/1.5		; set height of plot

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

  res2@mpMaxLatF=maxLat_eur                     ; maximum latitude
  res2@mpMinLatF=minLat_eur                     ; minimum latitude
  res2@mpMaxLonF=maxLon_eur                     ; maximum longitude
  res2@mpMinLonF=minLon_eur                     ; minimum longitude
  res2@mpGeophysicalLineThicknessF=1.0      ; line thickness for geographical boundaries
  res2@mpOutlineOn=True                     ; geographical boundaries
  res2@mpOutlineBoundarySets="National"     ; country borders
  res2@mpNationalLineThicknessF = 0.5       ; country border line thickness
  res2@mpNationalLineColor      = "Gray"    ; country border line colour

  res3@mpMaxLatF=maxLat_tbt                     ; maximum latitude
  res3@mpMinLatF=minLat_tbt                     ; minimum latitude
  res3@mpMaxLonF=maxLon_tbt                     ; maximum longitude
  res3@mpMinLonF=minLon_tbt                    ; minimum longitude
  res3@mpGeophysicalLineThicknessF=1.0      ; line thickness for geographical boundaries
  res3@mpOutlineOn=True                     ; geographical boundaries
  res3@mpOutlineBoundarySets="National"     ; country borders
  res3@mpNationalLineThicknessF = 0.5       ; country border line thickness
  res3@mpNationalLineColor      = "Gray"    ; country border line colour

  res4@mpMaxLatF=maxLat_sam                     ; maximum latitude
  res4@mpMinLatF=minLat_sam                     ; minimum latitude
  res4@mpMaxLonF=maxLon_sam                     ; maximum longitude
  res4@mpMinLonF=minLon_sam                     ; minimum longitude
  res4@mpGeophysicalLineThicknessF=1.0      ; line thickness for geographical boundaries
  res4@mpOutlineOn=True                     ; geographical boundaries
  res4@mpOutlineBoundarySets="National"     ; country borders
  res4@mpNationalLineThicknessF = 0.5       ; country border line thickness
  res4@mpNationalLineColor      = "Gray"    ; country border line colour

;************************************************
; resource list for Glacier mask
;************************************************
  res1                     = True
  res1@cnFillOn            = True                             ; turn on color
  res1@cnLinesOn           = True                            ; no contour lines
  res1@cnLineLabelsOn      = False                            ; do not draw contour labels
  res1@cnLevelSelectionMode= "ExplicitLevels"                 ; set explicit contour levels
  res1@cnLevels            = 0.95                             ; only set one level
  res1@cnFillColors        = (/"transparent","mediumpurple"/)
  res1@cnLineThicknessF = 2     ; thicker contours
  res1@cnLineColor       ="Black"            ; blue contour lines
;  res1@cnLineDashPattern = 1                      ; dashed lines


; Drawing plots
; -------------

  res@gsnLeftString = "(a)"
  plot(0)=gsn_csm_contour_map_overlay(wks,var(2,:,:),GLAC(1,:,:),res,res1)
  res@gsnLeftString = "(b)"
  plot(1)=gsn_csm_contour_map_overlay(wks,var(2,:,:),GLAC(1,:,:),res2,res1)
  res@gsnLeftString = "(c)"
  plot(2)=gsn_csm_contour_map_overlay(wks,var(2,:,:),GLAC(1,:,:),res3,res1)
  res@gsnLeftString = "(d)"
  plot(3)=gsn_csm_contour_map_overlay(wks,var(2,:,:),GLAC(1,:,:),res4,res1)



; Draw geographical markers and labels on regional maps
; -----------------------------------------------------

;---Create arrays with cities and lat/lon locations

                         ; 
  locations_sam = (/"Li", "Ar", "An", "Sa", "LP"/)                 ; Lima, Arica, Antofagasta, Santiago, La Paz: South America (Andes)
  lat_loc_sam   = (/  -12.1, -18.49, -23.68, -33.48, -16.54/)
  lon_loc_sam   = (/  -77.0, -70.26, -70.37, -70.61, -68.14/)

                       
  locations_tbt = (/"Ka", "Du", "Ch", "Na", "Nn","Lh","Ku"/)	; Tibetan Plateau / Himalayas
  lat_loc_tbt   = (/  27.42, 38.32, 30.39, 29.37, 35.14, 29.39, 36.0/)
  lon_loc_tbt   = (/  85.20, 68.46, 104.3, 95.03, 74.35, 91.07, 84.0/)
                                 ; 
  locations_eur = (/"Pa", "Be", "Mo", "Ki", "Ro", "Bu", "Ma","Da"/)    ; Paris, Berlin, Moscow, Kiev, Rome, Budapest, Madrid, Damascus: Europe
  lat_loc_eur   = (/  48.84, 52.5, 55.75, 50.45, 41.90, 47.49, 40.42, 33.49/)
  lon_loc_eur   = (/  2.36, 13.4, 37.6, 30.52, 12.50, 19.03, -3.70, 36.29/)


;---Attach markers to map
  mres               = True
  mres@gsMarkerSizeF = 2.                                            ; enlarge marker
  mres@gsMarkerIndex = 16                                            ; marker index number for filled dot
  mres@gsMarkerColor = "Black"                                       ; marker colour

  dum12 = gsn_add_polymarker(wks,plot(1),lon_loc_eur,lat_loc_eur,mres)
  dum13 = gsn_add_polymarker(wks,plot(2),lon_loc_tbt,lat_loc_tbt,mres)
  dum14 = gsn_add_polymarker(wks,plot(3),lon_loc_sam,lat_loc_sam,mres)
     
;---Attach text to map
  tres               = True
  tres@txFontHeightF = 0.02                                         ; make font smaller
  tres@txJust        = "CenterLeft"                                  ; default is "CenterCenter"
  tres@txFont        = 22
   
  dum22 = gsn_add_text(wks,plot(1),locations_eur,lon_loc_eur+0.5,lat_loc_eur,tres)
  dum23 = gsn_add_text(wks,plot(2),locations_tbt,lon_loc_tbt+0.5,lat_loc_tbt,tres)
  dum24 = gsn_add_text(wks,plot(3),locations_sam,lon_loc_sam+0.5,lat_loc_sam,tres)


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
;  resP@gsnPanelRowSpec = True                   ; tell panel what order to plot

;  gsn_panel(wks,plot,(/1,3/),resP)


  gsn_panel(wks,plot,(/2,2/),resP)                ; draw individual plots as one plot

  ;---Add common colour bar label
  txres               = True

  txres@txFontHeightF = 0.015                      ; change font size
  gsn_text_ndc(wks,cbLabel,0.51,0.05,txres)        ; add text ("cbLabel" created in declarations sections) at specified position
  frame(wks)


end

