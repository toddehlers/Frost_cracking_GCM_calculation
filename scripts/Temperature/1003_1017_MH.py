#############################################################################
# Code for Calculating Mean Annual Temperature, Annual Temperature Variation 
# and sediment thickness for Mid-Holocene
#############################################################################

import numpy as np
from netCDF4 import MFDataset, Dataset

#################################################################
# Importing the netCDF files for all the years in Mid-Holocene
#################################################################

path1 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/"
model = "e008_hpc-bw_e5w2.3_MH_t159l31.1d"
path2 = "/output_raw/"

year = []

for i in range(3,18):
	year.append('%02d' % (i,))

T = []

for i in range(15):
	file = "e008_10"+ year[i] + "*.nc"
	data = path1 + model + path2 + file
	nc = MFDataset(data, 'r')
	T1 = nc.variables['tslm1'][:,:,:]-273.15
	T.append(T1)

time, lat, lon = np.shape(T[0])

#######################################################
# Write out data to a new netCDF file for whole year
#######################################################

nco = Dataset("/esd/esd01/docs/hsharma/data_small/data/1003_1017_MH.nc",'w', format="NETCDF4_CLASSIC")

# Creating Dimensions
nco.createDimension('lat', lat)
nco.createDimension('lon', lon)

# Creating Variables
lato = nco.createVariable('lat', 'f4', ('lat',), fill_value=False)
lono = nco.createVariable('lon', 'f4', ('lon',), fill_value=False)
MAT_o= nco.createVariable('MAT', 'f4', ('lat', 'lon',))  # Creating a variable for Mean Annual Temperature
Ta_o = nco.createVariable('Ta', 'f4', ('lat', 'lon',))  # Creating a variable for Annual Temperature Variation

# Attributes
lato.units = 'degrees north'
lono.units = 'degrees east'
MAT_o.units = 'DegC'
Ta_o.units = 'DegC'

# Populate the variables with data
lato[:] = nc.variables['lat'][:]
lono[:] = nc.variables['lon'][:]

Ta = np.zeros((15,lat, lon), dtype=np.float64)
MAT = np.zeros((15,lat,lon), dtype=np.float64)

for i in range(15):
	MAT[i,:,:] = np.mean(T[i], axis=0)
	Ta[i,:,:] = 0.5*(np.amax(T[i], axis=0)-np.amin(T[i], axis=0))

MAT_o[:,:] = np.array(np.mean(MAT[:,:,:], axis=0))
Ta_o[:,:] = np.array(np.mean(Ta[:,:,:], axis=0))

			
						













