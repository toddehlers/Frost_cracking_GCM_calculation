import numpy as np
from netCDF4 import Dataset
from datetime import datetime

today = datetime.today()

path = "/esd/esd01/docs/hsharma/data_small/FCI_data/Temperature/"         #path to folder containing data (with MAT, Annual Temperature Variation (Ta) and Sediment thickness(Hs))
file1 = "1003_1017_PI.nc"
file2 = "1003_1017_MH.nc"
file3 = "1003_1017_LGM.nc"
file4 = "1003_1017_Plio.nc"

data1 = path + file1
data2 = path + file2
data3 = path + file3
data4 = path + file4

nc1 = Dataset(data1,'r')
nc2 = Dataset(data2,'r')
nc3 = Dataset(data3,'r')
nc4 = Dataset(data4,'r')

Ta1_ = nc1.variables['Ta'][:,:,:]
MAT1_ = nc1.variables['MAT'][:,:,:]
Ta2_ = nc2.variables['Ta'][:,:,:]
MAT2_ = nc2.variables['MAT'][:,:,:]
Ta3_ = nc3.variables['Ta'][:,:,:]
MAT3_ = nc3.variables['MAT'][:,:,:]
Ta4_ = nc4.variables['Ta'][:,:,:]
MAT4_ = nc4.variables['MAT'][:,:,:]

Ta1 = np.array(np.mean(Ta1_, axis = 0))
MAT1 = np.array(np.mean(MAT1_, axis =0))
Ta2 = np.array(np.mean(Ta2_, axis = 0))
MAT2 = np.array(np.mean(MAT2_, axis =0))
Ta3 = np.array(np.mean(Ta3_, axis = 0))
MAT3 = np.array(np.mean(MAT3_, axis =0))
Ta4 = np.array(np.mean(Ta4_, axis = 0))
MAT4 = np.array(np.mean(MAT4_, axis =0))

data5 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e007_2_hpc-bw_e5w2.3_PI_t159l31.1d/src/input/T159_PI/T159_jan_surf.nc"
data6 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e008_hpc-bw_e5w2.3_MH_t159l31.1d/src/input/T159_MH/T159_jan_surf_MH_2.nc"
data7 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e009_hpc-bw_e5w2.3_LGM_t159l31.1d/src/input/T159_LGM/T159_jan_surf_lgm_veg.nc"
data8 = "/esd/esd02/data/climate_models/echam/echam_output/ESD/e010_hpc-bw_e5w2.3_PLIO_t159l31.1d/src/input/T159_PLIO/T159_jan_surf_plio.nc"

nc5 = Dataset(data5, 'r')
nc6 = Dataset(data6, 'r')
nc7 = Dataset(data7, 'r')
nc8 = Dataset(data8, 'r')

slm_PI = nc5.variables['SLM'][:,:]
slm_MH = nc6.variables['SLM'][:,:]
slm_LGM = nc7.variables['SLM'][:,:]
slm_PLIO = nc8.variables['SLM'][:,:]

nlat, nlon = np.shape(MAT1)

for i in range(nlat):
	for j in range(nlon):
		if (slm_PI[i,j]==0):
			MAT1[i,j] = -999
			Ta1[i,j] = -999
		if (slm_MH[i,j]==0):
			MAT2[i,j] = -999
			Ta2[i,j] = -999
		if (slm_LGM[i,j]==0):
			MAT3[i,j] = -999
			Ta3[i,j] = -999
		if (slm_PLIO[i,j]==0):
			MAT4[i,j] = -999
			Ta4[i,j] = -999

MAT = np.zeros((4,nlat,nlon), dtype = np.float32)
Ta = np.zeros((4,nlat,nlon), dtype = np.float32)

MAT[0,:,:] = MAT1
MAT[1,:,:] = MAT2
MAT[2,:,:] = MAT3
MAT[3,:,:] = MAT4

Ta[0,:,:] = Ta1
Ta[1,:,:] = Ta2
Ta[2,:,:] = Ta3
Ta[3,:,:] = Ta4

nco = Dataset("/esd/esd01/docs/hsharma/data_small/FCI_data/Temperature/Temperature.nc",'w', format="NETCDF4_CLASSIC")

# Creating Dimensions
nco.createDimension('time', None)
nco.createDimension('lat', nlat)
nco.createDimension('lon', nlon)

# Creating Variables
timeo = nco.createVariable('time', 'i4', ('time',), fill_value=False)
lato = nco.createVariable('lat', 'f4', ('lat',), fill_value=False)
lono = nco.createVariable('lon', 'f4', ('lon',), fill_value=False)
MAT_o = nco.createVariable('MAT', 'f4', ('time','lat', 'lon',))  # Creating a variable for Annually integrated frost cracking intensity [degC m]
Ta_o = nco.createVariable('Ta', 'f4', ('time','lat', 'lon',))

# Attributes
timeo.units = 'time-slices' 	
timeo.long_name = '1: Pre-Industrial, 2: Mid-Holocene,\n3: Last Glacial Maximum, 4: Pliocene'
lato.units = 'degrees north'
lato.long_name = 'latitude'
lato.axis = 'Y'
lono.units = 'degrees east'
lono.long_name = 'longitude'
lato.axis = 'X'
MAT_o.units = 'DegC'
MAT_o.standard_name = 'Mean annual temperature'
Ta_o.units = 'DegC'
Ta_o.standard_name = 'Half amplitude of annual temperature variaions'

#Add global attributes
nco.description = "MAT and Ta averaged over 15 years of paleoclimate simulation at 80 km spatial resolution"
nco.citation = "Sharma, H.; Mutz, S. G.; Ehlers T. A. (2022): Global Distribution of Frost Cracking Intensity during Late-Cenozoic paleoclimate time-slices. GFZ Data Services. https://doi.org/will-be-provided"
nco.history = "Created " + today.strftime("%d/%m/%y")
nco.institution = "University of Tübingen, Tübingen, Germany"
CDO = "Climate Data Operators version 1.9.5 (http://mpimet.mpg.de/cdo)"

# Populate the variables with data
timeo[:] = [1,2,3,4]
lato[:] = nc1.variables['lat'][:]
lono[:] = nc1.variables['lon'][:]
MAT_o[:,:,:] = MAT[:,:,:]
Ta_o[:,:,:] = Ta[:,:,:]
nco.close()



