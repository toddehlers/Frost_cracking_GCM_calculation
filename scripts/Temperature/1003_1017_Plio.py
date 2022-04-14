#############################################################################
# Code for Calculating Mean Annual Temperature, Annual Temperature Variation 
# and sediment thickness for Pliocene
#############################################################################

from math import *
from numpy import *
from netCDF4 import MFDataset, Dataset

#################################################################
# Importing the netCDF files for all the years in Pliocene
#################################################################

path1 = "/esd/esd/data/climate_models/echam/echam_output/ESD/"
model = "e010_hpc-bw_e5w2.3_PLIO_t159l31.1d"
path2 = "/output_raw/"
file1 = "e010_1004*.nc"
data1 = path1 + model + path2 + file1
nc1 = MFDataset(data1,'r')                # MFDataset used to import multiple .nc files
file2 = "e010_1005*.nc"
data2 = path1 + model + path2 + file2
nc2 = MFDataset(data2,'r')
file3 = "e010_1006*.nc"
data3 = path1 + model + path2 + file3
nc3 = MFDataset(data3,'r')
file4 = "e010_1007*.nc"
data4 = path1 + model + path2 + file4
nc4 = MFDataset(data4,'r')
file5 = "e010_1008*.nc"
data5 = path1 + model + path2 + file5
nc5 = MFDataset(data5,'r')
file6 = "e010_1009*.nc"
data6 = path1 + model + path2 + file6
nc6 = MFDataset(data6,'r')
file7 = "e010_1010*.nc"
data7 = path1 + model + path2 + file7
nc7 = MFDataset(data7,'r')
file8 = "e010_1011*.nc"
data8 = path1 + model + path2 + file8
nc8 = MFDataset(data8,'r')
file9 = "e010_1012*.nc"
data9 = path1 + model + path2 + file9
nc9 = MFDataset(data9,'r')
file10 = "e010_1013*.nc"
data10 = path1 + model + path2 + file10
nc10 = MFDataset(data10,'r')
file11 = "e010_1014*.nc"
data11 = path1 + model + path2 + file11
nc11 = MFDataset(data11,'r')
file12 = "e010_1015*.nc"
data12 = path1 + model + path2 + file12
nc12 = MFDataset(data12,'r')
file13 = "e010_1016*.nc"
data13 = path1 + model + path2 + file13
nc13 = MFDataset(data13,'r')
file14 = "e010_1017*.nc"
data14 = path1 + model + path2 + file14
nc14 = MFDataset(data14,'r')
file15 = "e010_1018*.nc"
data15 = path1 + model + path2 + file15
nc15 = MFDataset(data15,'r')                

# Initializing the variable for Surface Temperature and computing the dimension sizes for Surface Temperature

T1 = nc1.variables['tslm1'][:,:,:]-273.15
time, lat, lon = shape(T1)         
T2 = nc2.variables['tslm1'][:,:,:]-273.15  
T3 = nc3.variables['tslm1'][:,:,:]-273.15
T4 = nc4.variables['tslm1'][:,:,:]-273.15
T5 = nc5.variables['tslm1'][:,:,:]-273.15
T6 = nc6.variables['tslm1'][:,:,:]-273.15
T7 = nc7.variables['tslm1'][:,:,:]-273.15
T8 = nc8.variables['tslm1'][:,:,:]-273.15
T9 = nc9.variables['tslm1'][:,:,:]-273.15
T10 = nc10.variables['tslm1'][:,:,:]-273.15   
T11 = nc11.variables['tslm1'][:,:,:]-273.15
T12 = nc12.variables['tslm1'][:,:,:]-273.15
T13 = nc13.variables['tslm1'][:,:,:]-273.15
T14 = nc14.variables['tslm1'][:,:,:]-273.15
T15 = nc15.variables['tslm1'][:,:,:]-273.15

#######################################################
# Write out data to a new netCDF file for whole year
#######################################################

nco = Dataset("/esd/esd/docs/hsharma/data_small/data/1003_1017_Plio.nc",'w', format="NETCDF4_CLASSIC")

# Creating Dimensions
nco.createDimension('time', None)               # It will store only year
nco.createDimension('lat', lat)
nco.createDimension('lon', lon)

# Creating Variables
timeo = nco.createVariable('time', 'i4', ('time',), fill_value=False)   # Creating variable time with integger data type
lato = nco.createVariable('lat', 'f4', ('lat',), fill_value=False)
lono = nco.createVariable('lon', 'f4', ('lon',), fill_value=False)
MAT_o= nco.createVariable('MAT', 'f4', ('time','lat', 'lon',))  # Creating a variable for Mean Annual Temperature
Ta_o = nco.createVariable('Ta', 'f4', ('time','lat', 'lon',))  # Creating a variable for Annual Temperature Variation

# Attributes
timeo.units = 'year'
lato.units = 'degrees north'
lono.units = 'degrees east'
MAT_o.units = 'Kelvin'
Ta_o.units = 'Kelvin'

# Populate the variables with data
timeo[:] = arange(1003,1018)                                         # All the years
lato[:] = nc1.variables['lat'][:]
lono[:] = nc1.variables['lon'][:]

T = [T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15]
Ta = zeros((15,lat, lon), dtype=float64)
MAT = zeros((15,lat,lon), dtype=float64)

for i in range(15):
	MAT[i,:,:] = mean(T[i], axis=0)
	Ta[i,:,:] = 0.5*(amax(T[i], axis=0)-amin(T[i], axis=0))

	MAT_o[i,:,:] = MAT[i,:,:]
	Ta_o[i,:,:] = Ta[i,:,:]
		
						













