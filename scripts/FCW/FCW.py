import numpy as np
from netCDF4 import Dataset

path = "/esd/esd01/docs/hsharma/data_small/FCI_data/FCW/"
file1 = "FCW_PI.nc"
file2 = "FCW_MH.nc"
file3 = "FCW_LGM.nc"
file4 = "FCW_PLIO.nc"

data1 = path + file1
data2 = path + file2
data3 = path + file3
data4 = path + file4

nc1 = Dataset(data1, 'r')
nc2 = Dataset(data2, 'r')
nc3 = Dataset(data3, 'r')
nc4 = Dataset(data4, 'r')

data5 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e007_2_hpc-bw_e5w2.3_PI_t159l31.1d/src/input/T159_PI/T159_jan_surf.nc" 
data6 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e008_hpc-bw_e5w2.3_MH_t159l31.1d/src/input/T159_MH/T159_jan_surf_MH_2.nc"
data7 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e009_hpc-bw_e5w2.3_LGM_t159l31.1d/src/input/T159_LGM/T159_jan_surf_lgm_veg.nc"
data8 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e010_hpc-bw_e5w2.3_PLIO_t159l31.1d/src/input/T159_PLIO/T159_jan_surf_plio.nc"

nc5 = Dataset(data5, 'r')
nc6 = Dataset(data6, 'r')
nc7 = Dataset(data7, 'r')
nc8 = Dataset(data8, 'r')

GLAC_PI = nc5.variables['GLAC'][:,:]
GLAC_MH = nc6.variables['GLAC'][:,:]
GLAC_LGM = nc7.variables['GLAC'][:,:]
GLAC_PLIO = nc8.variables['GLAC'][:,:]

Ci_PI = nc1.variables['Ci'][:,:]
Ci_MH = nc2.variables['Ci'][:,:]
Ci_LGM = nc3.variables['Ci'][:,:]
Ci_Plio = nc4.variables['Ci'][:,:]

nlat,nlon = np.shape(Ci_PI)

for i in range(nlat):
    for j in range(nlon):
        if(GLAC_PI[i,j]>0.5):
            Ci_PI[i,j] = -999
        if(GLAC_MH[i,j]>0.5):
            Ci_MH[i,j] = -999
        if(GLAC_LGM[i,j]>0.5):
            Ci_LGM[i,j] = -999
        if(GLAC_LGM[i,j]>0.5):
            Ci_Plio[i,j] = -999

Ci = np.zeros((4,nlat,nlon), dtype = np.float32)

Ci[0,:,:] = Ci_PI
Ci[1,:,:] = Ci_MH
Ci[2,:,:] = Ci_LGM
Ci[3,:,:] = Ci_Plio

for i in range(4):
    for j in range(nlat):
        for k in range(nlon):
            if (Ci[i,j,k] < 5):
                Ci[i,j,k] = 0

nco = Dataset("/esd/esd01/docs/hsharma/data_small/FCI_data/FCW/FCW.nc",'w', format="NETCDF4_CLASSIC")

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
Ci_o.units = 'Days'

# Populate the variables with data
timeo[:] = [1,2,3,4]			# 1 -> PI, 2 -> MH, 3 -> LGM, 4 -> PLIO
lato[:] = nc2.variables['lat'][:]
lono[:] = nc2.variables['lon'][:]
Ci_o[:,:,:] = Ci[:,:,:]
nco.close()

print('Globally summed up FCW for PI: ', np.sum(np.where(Ci_PI<0,0,Ci_PI)))
print('Globally summed up FCW for MH: ', np.sum(np.where(Ci_MH<0,0,Ci_MH)))
print('Globally summed up FCW for LGM: ', np.sum(np.where(Ci_LGM<0,0,Ci_LGM)))
print('Globally summed up FCW for PLIO: ', np.sum(np.where(Ci_Plio<0,0,Ci_Plio)))
