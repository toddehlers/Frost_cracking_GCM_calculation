##################################################################################
# Code for Calculating Continuous and discontinuous Permafrost for LGM simulation 
##################################################################################

import numpy as np
from netCDF4 import Dataset

#################################################################
# Importing the netCDF files for all the model years in PD
#################################################################

path1 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/"
model = "e004_hpc-bw_e5w2.3_PD_t159l31.1m"
path2 = "/output_processed/"

file1 = "1979_1994_ameans.nc"
file2 = "1979_1994_mlterm.nc"

data1 = path1 + model + path2 + file1		# annual means
data2 = path1 + model + path2 + file2		# monthly means

nc1 = Dataset(data1, 'r')			# annual means 
nc2 = Dataset(data2, 'r')			# monthly means

MAT1 = nc1.variables['temp2'][:,:,:]-273.15	# Mean annual near surface temperature [Deg C]
Tm1 = nc2.variables['temp2'][:,:,:]-273.15	# Mean monthly temperature [Deg C]

time, lat, lon = np.shape(MAT1)

MAT = np.zeros((lat, lon), dtype=np.float64)
Tm_min = np.zeros((lat, lon), dtype=np.float64)

MAT[:,:] = np.array(np.mean(MAT1[:,:,:], axis=0))	# 2 D array for mean MAT at every pixel
Tm_min[:,:] = np.array(np.min(Tm1[:,:,:], axis=0))	# 2 D array for coldest month temperature (mean)

Permafrost = np.zeros((lat, lon), dtype=np.int16)

data3 = path1+model+"/src/input/T159/T159_jan_surf.nc"
nc3 = Dataset(data3, 'r')
slm = nc3.variables['SLM'][:,:]
GLAC = nc3.variables['GLAC'][:,:]

for i in range(lat):
	for j in range(lon):
		if((MAT[i,j] <= -8) and (Tm_min[i,j] <= -20)):
			Permafrost[i,j] = 1	# Continuous Permafrost
#		elif((MAT[i,j] <= -4) and (MAT[i,j] >= -8)):
#			Permafrost[i,j] = 1 	# Discontinuous Permafrost
		else:
			Permafrost[i,j] = 0	# No Permarost

for i in range(lat):
	for j in range(lon):
		if(slm[i,j]==0):	# slm is land sea mask
			Permafrost[i,j] = 0

for i in range(lat):
	for j in range(lon):
		if(GLAC[i,j]==1):
			Permafrost[i,j] = 0


#######################################################
# Write out data to a new netCDF file for whole year
#######################################################

nco = Dataset("/esd/esd01/docs/hsharma/data_small/data/Permafrost/Cont_Permafrost_PD.nc",'w', format="NETCDF4_CLASSIC")

# Creating Dimensions
nco.createDimension('lat', lat)
nco.createDimension('lon', lon)

# Creating Variables
lato = nco.createVariable('lat', 'f4', ('lat',), fill_value=False)
lono = nco.createVariable('lon', 'f4', ('lon',), fill_value=False)
Perma_o= nco.createVariable('Permafrost', 'f4', ('lat', 'lon',))  # Creating a variable for Permafrost

# Attributes
lato.units = 'degrees north'
lono.units = 'degrees east'
Perma_o.units = '-'

# Populate the variables with data
lato[:] = nc1.variables['lat'][:]
lono[:] = nc1.variables['lon'][:]

Perma_o[:,:] = Permafrost[:,:]

			
						













