import numpy as np
from netCDF4 import Dataset
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

data5 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e007_2_hpc-bw_e5w2.3_PI_t159l31.1d/src/input/T159_PI/T159_jan_surf.nc"
data6 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e008_hpc-bw_e5w2.3_MH_t159l31.1d/src/input/T159_MH/T159_jan_surf_MH_2.nc"
data7 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e009_hpc-bw_e5w2.3_LGM_t159l31.1d/src/input/T159_LGM/T159_jan_surf.lgm.veg.nc"
data8 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e010_hpc-bw_e5w2.3_PLIO_t159l31.1d/src/input/T159_PLIO/T159_jan_surf_plio.nc"

nc1 = Dataset(data5, 'r')
nc2 = Dataset(data6, 'r')
nc3 = Dataset(data7, 'r')
nc4 = Dataset(data8, 'r')

GLAC_PI = nc1.variables['GLAC'][:,:]
GLAC_MH = nc2.variables['GLAC'][:,:]
GLAC_LGM = nc3.variables['GLAC'][:,:]
GLAC_PLIO = nc4.variables['GLAC'][:,:]

nlat,nlon = np.shape(GLAC_PI)

GLAC = np.zeros((4,nlat,nlon), dtype = np.float32)

GLAC[0,:,:] = GLAC_PI[:,:]
GLAC[1,:,:] = GLAC_MH[:,:]
GLAC[2,:,:] = GLAC_LGM[:,:]
GLAC[3,:,:] = GLAC_PLIO[:,:]

#for i in range(nlat):
#    for j in range(nlon):
#        if(GLAC_PI[i,j]==1 or GLAC_MH[i,j]==1):
#            GLAC[0,i,j] = 1
#        if(GLAC_PI[i,j]==1 or GLAC_LGM[i,j]==1):
#            GLAC[1,i,j] = 1
#        if(GLAC_PI[i,j]==1 or GLAC_PLIO[i,j]==1):
#            GLAC[2,i,j] = 1

nco = Dataset("/esd/esd01/docs/hsharma/data_small/FCI_data/Temperature/GLAC.nc",'w', format="NETCDF4_CLASSIC")

# Creating Dimensions
nco.createDimension('time', None)
nco.createDimension('lat', nlat)
nco.createDimension('lon', nlon)

# Creating Variables
timeo = nco.createVariable('time', 'i4', ('time',), fill_value=False)
lato = nco.createVariable('lat', 'f4', ('lat',), fill_value=False)
lono = nco.createVariable('lon', 'f4', ('lon',), fill_value=False)
GLAC_o = nco.createVariable('GLAC', 'f4', ('time','lat', 'lon',))  # Creating a variable for Annually integrated frost cracking intensity [DegC m]

# Attributes
timeo.units = 'time-slices'
lato.units = 'degrees north'
lono.units = 'degrees east'
GLAC_o.units = 'fraction'

# Populate the variables with data
timeo[:] = [1,2,3]                    # 1 -> PI and MH, 2 -> PI and LGM, 3 -> PI and Plio
lato[:] = nc2.variables['lat'][:]
lono[:] = nc2.variables['lon'][:]
GLAC_o[:,:,:] = GLAC[:,:,:]
nco.close()

