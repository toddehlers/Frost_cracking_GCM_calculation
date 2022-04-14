import numpy as np
from netCDF4 import Dataset

path1 = "/esd/esd01/docs/hsharma/data_small/FCI_data/FCI_Vw/"
file1 = "Integrated_FCI_Vw.nc"
data1 = path1+file1

path2 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e004_hpc-bw_e5w2.3_PD_t159l31.1m/src/input/T159/"
file2 = "T159_jan_surf.nc"
data2 = path2+file2

data3 = "/esd/esd01/docs/hsharma/data_small/FCI_data/Temperature/GLAC.nc"

nc1 = Dataset(data1, 'r')
nc2 = Dataset(data2, 'r')
nc3 = Dataset(data3, 'r')

Ci = nc1.variables['Ci'][:,:,:]
slm = nc2.variables['SLM'][:,:]
GLAC = nc3.variables['GLAC'][:,:]

ntime, nlat, nlon = np.shape(Ci)

Ci_diff = np.zeros((4, nlat, nlon), dtype = np.float32)

Ci_diff[0,:,:] = Ci[1,:,:] - Ci[0,:,:]
Ci_diff[1,:,:] = Ci[1,:,:] - Ci[2,:,:]
Ci_diff[2,:,:] = Ci[1,:,:] - Ci[3,:,:]
Ci_diff[3,:,:] = Ci[1,:,:] - Ci[4,:,:]

for i in range(nlat):
	for j in range(nlon):
		if(GLAC[0,i,j]==1):
			Ci_diff[0,i,j] = -999
		if(GLAC[0,i,j]==1):
			Ci_diff[1,i,j] = -999
		if(GLAC[1,i,j]==1):
			Ci_diff[2,i,j] = -999
		if(GLAC[2,i,j]==1):
			Ci_diff[3,i,j] = -999


for i in range(nlat):
	for j in range(nlon):
		if(slm[i,j] == 0):
			Ci_diff[:,i,j] = 0
	

nco = Dataset("/esd/esd01/docs/hsharma/data_small/FCI_data/FCI_Vw/FCI_Vw_diff.nc",'w', format="NETCDF4_CLASSIC")

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
timeo[:] = [1,2,3,4]			# 1 -> PI-PD, 2 -> PI-MH, 3 -> PI-LGM, 4 -> PI-PLIO
lato[:] = nc1.variables['lat'][:]
lono[:] = nc1.variables['lon'][:]
Ci_o[:,:,:] = Ci_diff[:,:,:]
nco.close()

