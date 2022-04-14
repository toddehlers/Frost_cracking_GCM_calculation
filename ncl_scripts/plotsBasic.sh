##################################
# STANDARD PLOTS OF MODEL OUTPUT #
##################################
#
#
# ABOUT THIS SCRIPT
# =================
# bash script controlling NCL scripts for plotting standard output. This script sets I/O paths and passes options for NCL scripts that:
# 1. Plots long term means of precipitation and temperature 
# 2. Plots precipitation and temperature differences between this run and a specified control run
#
#
#
#
# ================= #
# USER DECLARATIONS #
# ================= #
#
nclSTND=/esd/esd/docs/smutz/data_small/projects/EXTREME/scripts/plots/model/echam5/plotsBasic_stnd.ncl  # NCL script for standard plots
nclDIFF=/esd/esd/docs/smutz/data_small/projects/EXTREME/scripts/plots/model/echam5/plotsBasic_diff.ncl  # NCL script for difference plots
#
mPATH=/esd/esd/data/climate_models/echam/echam_output/ESD  # model output path
#
# SIMULATION INFORMATION
# ----------------------
# simulation description (may be used in plot title by NCL script)
simNm='e010_(PLIO)'
# for file name construction (consistent with model run scripts)
PLT=hpc-bw    # platform
MOD=e5w2.3    # model, e5w2.3 (echam wiso version 2.3)
EXP=e010      # experiment number 
RES=159       # resolution
LEV=31        # vertical levels
TIM=PLIO      # time; PD = present day, PI = Pre-Industrial, MH = Mid Holocene, LGM = Last Glacial Maximum, PLIO = Pliocene
OIN=1d        # output interval; 1m = 1 month, 1d = 1 day
ADD=          # additional info, e.g. "_"+"tbt050" for 50% tibet topo or "_"+"tbt050sam050" for tibet & andes at 50%
YRI=1004      # 1st complete year in output 
YRF=1018      # last complete year in output
# 
# REFERENCE SIMULATION INFORMATION
# --------------------------------
# simulation description (may be used in plot title by NCL script)
simRefNm='e007_2 (PI)'
# for file name construction (consistent with model run scripts)
PLT2=hpc-bw    # platform
MOD2=e5w2.3    # model, e5w2.3 (echam wiso version 2.3)
EXP2=e007_2    # experiment number 
RES2=159       # resolution
LEV2=31        # vertical levels
TIM2=PI        # time; PD = present day, PI = Pre-Industrial, MH = Mid Holocene, LGM = Last Glacial Maximum, PLIO = Pliocene
OIN2=1d        # output interval, 1m (1 month)
ADD2=          # additional info, e.g. "_"+"tbt050" for 50% tibet topo or "_"+"tbt050sam050" for tibet & andes at 50%
YRI2=1003      # 1st complete year in output 
YRF2=1017      # last complete year in output
#
# PLOT OPTIONS
# ------------
STND=2         # standard plots (simply plot processed output), 1=yes 2=no
DIFF=1         # difference plots (difference between simulation and reference simulation), 1=yes 2=no 
DIFF_sig=1     # difference plots with significance mask, 1=yes, 2=no (just plot values)
#
plotTime=an    # mo=plot monthly long term means, an=plot annual long term means; annual means will be constructed from same input
#
climVars=('Temperature' 'Precipitation') # 'd18o')  # variables to be treated (used in title and for IF querie in NCL script)
monthNms=('January-June' 'July-December')        # month names (used in title of NCL script)
#
plotRegion=glo  # REGION TO BE PLOTTED: glo=global, als=Alaska, sam=Andes, nam=Olympic Mnt, tbt=Tibet/Himalayas, eur=Europe, eas=Eurasia, cas=Cascades, nzl=New Zealand
#
#
#
#
# ============ #
# INSTRUCTIONS #
# ============ #
#
# generate paths and filenames
iPATH1=${mPATH}/${EXP}_${PLT}_${MOD}_${TIM}${ADD}_t${RES}l${LEV}.${OIN}/output_processed/          # path to processed output
wiPATH1=${iPATH1}/wiso/                                                                            # path to processed wiso output
iPATH2=${mPATH}/${EXP2}_${PLT2}_${MOD2}_${TIM2}${ADD2}_t${RES2}l${LEV2}.${OIN2}/output_processed/  # path to reference output
wiPATH2=${iPATH2}/wiso/                                                                            # path to reference wiso output
oPATH=${mPATH}/${EXP}_${PLT}_${MOD}_${TIM}${ADD}_t${RES}l${LEV}.${OIN}/plots/drafts/               # path to plot directory
iFILE1=${YRI}_${YRF}_mlterm.nc
iFILE2=${YRI2}_${YRF2}_mlterm.nc
iFILE3=${YRI}_${YRF}_mdm.nc                                                                        # file of monthly means with seasonality subtracted
iFILE4=${YRI2}_${YRF2}_mdm.nc
#
nYr=$((YRF-YRI)) # calculate no. of years
#
# export general options and names
export iPATH1
export wiPATH1
export iPATH2
export wiPATH2
export iFILE1
export oPATH
export iFILE2
export iFILE3
export iFILE4
export EXP
export EXP2
export simNm
export simRefNm
export plotRegion
export plotTime
export nYr
#
#
#
#
# STANDARD PLOTS
# --------------
if [ $STND = "1" ]; then
   echo
   echo '>> STANDARD PLOTS'
   echo '   --------------'
   echo '   processed simulation file (input): ' ${iPATH1}${iFILE1}
   echo 

   # export plot-specific variables to be read by NCL script
   for i in {0..1}; do       # loop through variables
      climVar=${climVars[i]}
      export climVar         # export climate variable

      # if annual values to be plotted
      if [ $plotTime = "an" ]; then      
         months=1            # for dummy variable in case of annual means
         export months       # export period for dummy variable
         monthsNm=${monthNms[1]}
         export monthsNm     # export month names for dummy variable 
         
         echo '   > creating standard annual mean plot for:' $plotRegion $climVar           
         # execute NCL script
         ncl -Q $nclSTND      
      
      # if monthly values to be plotted
      elif [ $plotTime = "mo" ]; then          
         for j in {0..1}; do    # loop through 6 months periods
            months=j            
            export months       # export period (1=1-6, 2=7-12)
            monthsNm=${monthNms[j]}
            export monthsNm     # export month names        

            echo '   > creating standard plot for:' $plotRegion $climVar $monthsNm 
            # execute NCL script
            ncl -Q $nclSTND
         done                 
      fi   
   done
   echo '   ----------------'
fi
#
#
#
#
# DIFFERENCE PLOTS
# ----------------
if [ $DIFF = "1" ]; then
   echo
   echo '>> DIFFERENCE PLOTS'
   echo '   ----------------'
   echo '   processed simulation file (input): ' ${iPATH1}${iFILE1}
   echo '   reference simulation file (input): ' ${iPATH2}${iFILE2}
   echo 

   # export plot-specific variables to be read by NCL script
   export iPATH2             # export path to reference simulation
   for i in {0..1}; do       # loop through variables
      climVar=${climVars[i]}
      export climVar         # export climate variable
      
      
      # if annual values to be plotted
      if [ $plotTime = "an" ]; then      
         months=1            # for dummy variable in case of annual means
         export months       # export period for dummy variable
         monthsNm=${monthNms[1]}
         export monthsNm     # export month names for dummy variable 
         export DIFF_sig  
         
         echo '   > creating annual means difference plot for:' $plotRegion $climVar        
         # execute NCL script
         ncl -Q $nclDIFF        
      
      # if monthly values to be plotted
      elif [ $plotTime = "mo" ]; then          
         for j in {0..1}; do    # loop through 6 months periods
            months=j            
            export months       # export period (1=1-6, 2=7-12)
            monthsNm=${monthNms[j]}
            export monthsNm     # export month names     
            export DIFF_sig      

            echo '   > creating difference plot for:' $plotRegion $climVar $monthsNm
            # execute NCL script
            ncl -Q $nclDIFF    
         done                 
      fi         
   done
   echo '   ----------------'
fi
#
echo
echo '   plot directory (output path): ' ${oPATH}
echo '>> DONE'
