import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
from scipy import signal
import operator
from scipy.optimize import curve_fit
from scipy.stats import pearsonr
from scipy.stats import spearmanr
from scipy import misc
import math
from scipy import stats
from scipy.stats import linregress
from netCDF4 import Dataset

nc_FCI = Dataset('/esd/esd01/docs/hsharma/data_small/FCI_data/FCI_Vw/Integrated_FCI_Vw.nc', 'r')
nc_T = Dataset('/esd/esd01/docs/hsharma/data_small/FCI_data/Temperature/Temperature.nc', 'r')

FCI = nc_FCI.variables['Ci'][1,:,:]
MAT = nc_T.variables['MAT'][1,:,:]
Ta = nc_T.variables['Ta'][1,:,:]

nlat, nlon = np.shape(MAT)

FCI_ = np.zeros((nlat*nlon), dtype=np.float32)
MAT_ = np.zeros((nlat*nlon), dtype=np.float32)
Ta_ = np.zeros((nlat*nlon), dtype=np.float32)

FCI_ = FCI.reshape([nlat*nlon])
MAT_ = MAT.reshape([nlat*nlon])
Ta_ = Ta.reshape([nlat*nlon])

FCI_ = np.where(FCI_<0,0,FCI_)

for i in range(nlon*nlat):
    if (FCI_[i] == 0):
        MAT_[i] = 0
        Ta_[i] = 0

for i in range(nlon*nlat):
    if (MAT_[i] > -4 and MAT_[i] < -15):
        FCI_[i] = 0
        Ta_[i] = 0
        MAT_[i] = 0

##############################################################################################

#   Correlation of erosion rates with vegetation, precititation, temperature and radiation

##############################################################################################

################### Calc. correlation coeff. between MAT, TA and FCI #######################

print("LGM Simulation: Relation between MAT and FCI: ")

corr, p = pearsonr(MAT_[:], FCI_[:])
print('Pearsons correlation for MAT and FCI: %.2f' % corr)
print('P-value : ', p)

corr, p = pearsonr(Ta_[:], FCI_[:])
print('Pearsons correlation for Ta and FCI: %.2f' % corr)
print('P-value : ', p)

##############################################################################################
'''
fig, ax = plt.subplots(1, figsize = [9,6])
ax = plt.gca()

ax.scatter(MAT_[:], FCI_[:], color="k", label='AZ')
#ax. set_ylim([0.0, 1.5e-2])
z = np.polyfit(MAT_, FCI_,1)
p = np.poly1d(z)
plt.plot(MAT_,p(MAT_),'--', color='k')
 

plt.savefig('./MAT_FCI.png', dpi=300)
plt.close()

fig, ax = plt.subplots(1, figsize = [9,6])
ax = plt.gca()

ax.scatter(Ta_[:], FCI_[:], color="k", label='AZ')
#ax. set_ylim([0.0, 1.5e-2])
z = np.polyfit(Ta_, FCI_,1)
p = np.poly1d(z)
plt.plot(Ta_,p(Ta_),'--', color='k')
 

plt.savefig('./Ta_FCI.png', dpi=300)
plt.close()

'''
