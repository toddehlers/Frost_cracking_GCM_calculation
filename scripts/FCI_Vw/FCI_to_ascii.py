import numpy as np
from netCDF4 import Dataset, stringtochar

path = "/esd/esd01/docs/hsharma/data_small/FCI_data/FCI_Vw/"
file = "FCI_Vw.nc"

data = path + file

nc = Dataset(data, 'r')

Ci_PI = nc.variables['Ci'][0,:,:]
Ci_MH = nc.variables['Ci'][1,:,:]
Ci_LGM = nc.variables['Ci'][2,:,:]
Ci_PLIO = nc.variables['Ci'][3,:,:]

nlat,nlon = np.shape(Ci_PI)


Ci = np.zeros((4,nlat,nlon), dtype = np.float32)

Ci[1,:,:] = Ci_PI
Ci[2,:,:] = Ci_MH
Ci[3,:,:] = Ci_LGM
Ci[4,:,:] = Ci_PLIO

nco = Dataset("/esd/esd01/docs/hsharma/data_small/FCI_data/FCI_Vw/FCI_Vw.nc",'w', format="NETCDF4_CLASSIC")

# Creating Dimensions
nco.createDimension('time', None)
nco.createDimension('lat', nlat)
nco.createDimension('lon', nlon)

# Creating Variables
timeo = nco.createVariable('time', 'i4', ('time',), fill_value=False)
lato = nco.createVariable('lat', 'f4', ('lat',), fill_value=False)
lono = nco.createVariable('lon', 'f4', ('lon',), fill_value=False)
Ci_o = nco.createVariable('Ci', 'f4', ('time','lat', 'lon',))  # Creating a variable for Annually integrated frost cracking intensity [DegC m]

# Attributes
timeo.units = 'time-slices'
lato.units = 'degrees north'
lono.units = 'degrees east'
Ci_o.units = 'DegC m'
 
# Populate the variables with data
timeo[:] = [1,2,3,4,5]			# 1 -> PD, 2 -> PI, 3 -> MH, 4 -> LGM, 5 -> PLIO
lato[:] = nc2.variables['lat'][:]
lono[:] = nc2.variables['lon'][:]
Ci_o[:,:,:] = Ci[:,:,:]
nco.close()


