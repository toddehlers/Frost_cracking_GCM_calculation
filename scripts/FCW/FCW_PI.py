#################################################################################################################################
#       File to calculate Frost Cracking Intensity [Days] (as a function of days spent in frost cracking window [-8 to -3 DegC])
#       for Pre-Industrial (~1850 A.D.)
#       Data Source:
#       MAT, Ta (Temperature) = ECHAM5 simulation (Dr. Mutz et al., 2017)
#################################################################################################################################

import numpy as np
from netCDF4 import Dataset
from multiprocessing import Pool

pool = Pool(processes=32)

path = "/esd/esd01/docs/hsharma/data_small/FCI_data/Temperature/"   # Path to folder containing Temperature data (with MAT, Annual Temperature Variation (Ta))
file1 = "1003_1017_PI.nc"                                       # File containing MAT and Ta for PI simulation
data1 = path + file1
nc = Dataset(data1,'r')                                         # Reading the Temprature data (MAT and Ta) from the netCDF file
Ta_ = nc.variables['Ta'][:,:,:]                                 # Storing 3-D array for Annual Temperature Amplitude, Ta [DegC] with dimentions (time, lat, lon)
MAT_ = nc.variables['MAT'][:,:,:]                               # Storing 3-D array for Mean Annual Surface Temperature, MAT [DegC] with dimentions (time, lat, lon)
S = "PI"                                                        # Defining the time-slice for the current file

Ta = np.mean(Ta_, axis = 0)                                     # Calculating mean Ta for all the years [with first axis (axis = 0) as time dimension in years]
MAT = np.mean(MAT_, axis =0)                                    # Calculating mean MAT for all the years [with first axis (axis = 0) as time dimension in years]
nlat, nlon = np.shape(MAT)

CiArray = np.zeros((nlat,nlon), dtype = np.float32)             # Defining a 2-D array to store integrated Frost cracking Intensity (Ci)

CiList = []                                                     # Defining an empty 1-D list to store FCI

from frost_cracking_window import cracking_intensity         # Calling the "cracking_intensity" function, which calculates the Annual Integrated FCI

arg=[]                                                          # Defining empty list to pass arguments to "cracking_intensity" function
for i in range(nlat):
        for j in range(nlon):
                arg.append((MAT[i,j], Ta[i,j]))

Ci = pool.map(cracking_intensity, arg)                          # Using pool function from Multiprocessing library and passing arguments
CiList.append(Ci)
test = np.zeros((nlat*nlon), dtype=np.float32)                  # Defining an empty array to store Ci values
test = np.array(CiList)                                         # Converting 1-D list (Cilist[] containing Ci) to an array
CiArray = test.reshape([nlat,nlon])                             # Reshaping previous array into a 2-D array with dimensions (lat, lon)

pool.close()                                                    # Closing the pool function

#################################################################
# Write out data to a new netCDF file for the current time slice
#################################################################

nco = Dataset("/esd/esd01/docs/hsharma/data_small/data/FCW_%s.nc" % (S,),'w', format="NETCDF4_CLASSIC")

# Creating Dimensions
nco.createDimension('lat', nlat)
nco.createDimension('lon', nlon)

# Creating Variables
lato = nco.createVariable('lat', 'f4', ('lat',), fill_value=False)
lono = nco.createVariable('lon', 'f4', ('lon',), fill_value=False)
Ci_o = nco.createVariable('Ci', 'f4', ('lat', 'lon',))  # Creating a variable for Annually integrated depth averaged frost cracking intensity [days]

# Attributes
lato.units = 'degrees north'
lono.units = 'degrees east'
Ci_o.units = 'days'

# Populate the variables with data
lato[:] = nc.variables['lat'][:]
lono[:] = nc.variables['lon'][:]
Ci_o[:,:] = CiArray[:,:]
nco.close()

