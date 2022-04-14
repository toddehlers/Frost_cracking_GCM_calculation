##################################################################################
# Fucntion to calculate Integrated FCI as a function Temperature gradient
# in the bedrock where temperature lies in frost cracking window (-8 to -3 Deg C)
##################################################################################


import numpy as np

def cracking_intensity(arg):
	MAT = arg[0]
	Ta = arg[1]
	Py = 365			# period = no. of days in an year
	N = 201				# number of depth nodes from surface to 20 m
	Ne = N-1			# number of depth elements
	D = 20				# investigation depth [m]
	z = np.zeros((N), dtype = np.float64)
	dz = np.zeros((Ne), dtype = np.float64)
	z[0] = 0.0              # nodal depth (0 - 20 m with depth interval of 0.1 m)
	dz0 = 0.005                              # depth interval (0.1 m)
	for i in range(1,N):
		z[i] = z[i-1] + dz0
	for i in range(1,N):
		z[i] = D*pow(z[i],3.0)
	for i in range(Ne):
		dz[i] = z[i+1] - z[i]

	# nodal depth (0 - 20 m with depth interval of 0.1 m)
	alpha = 0.1296    		# thermal diffusivity of bedrock [sq. m/day]
	f = np.zeros((Py,N), dtype = np.float32)
	T = np.zeros((Py,N), dtype = np.float32)	# Temperature of bedrock for each depth node (interval = 0.1 m) and time(interval = 1 day)
	Te = np.zeros((Py,Ne), dtype = np.float64)	# Temperature of subsurface for each depth element
	dTdz = np.zeros((Py,Ne), dtype = np.float64)	# Temperature gradient at each depth element
	Cr = np.zeros((Py,Ne), dtype = np.float32)	# frost cracking intensity for every pixel at 10 cm depth interval and 1 day time interval
	Cd = np.zeros((Ne), dtype = np.float32)		# frost cracking intensity at each depth element in bedrock summed for a period of 1 year
	Ci = 0				# annualy integrated depth averaged frost cracking intensity
	dt = 1
	

	for k in range(Py):
		for l in range(N):
			f[k,l] = (np.exp(-1*z[l]*((np.pi/(alpha*Py))**0.5)))*np.sin(((2*np.pi*(k+1))/Py)-(z[l]*((np.pi/(alpha*Py))**0.5)))
			T[k,l] = MAT + (Ta*f[k,l])	# solution of 1D heat equation (Hales and Roering, 2007)

	for k in range(Py):
		for l in range(Ne):
			Te[k,l] = 0.5*(T[k,l+1]+T[k,l])		# temperature of each element
			dTdz[k,l] = (T[k,l+1]-T[k,l])/dz[l]	# temperature gradient of each element

	for k in range(Py):
		for l in range(Ne):
			if((T[k,0]>0 and dTdz[k,l]<0) or (T[k,200]>0 and dTdz[k,l]>0)):	# Checking boundary condition if liquid water is available either at surface or lower boundary
				if ((Te[k,l] > -8.0) and (T[k,l] < -3.0)):	# if element is in frost cracking window
					Cr[k,l] = abs(dTdz[k,l])*dz[l]		# FCI as a function of temperature gradient 	
			       
				
	Cd = np.sum(Cr,axis=0)		# FCI at every depth

	Ci = np.sum(Cd)			# Integrated FCI at all depths
	
	print(Ci)	
	return Ci			# Returning the value of Integrated FCI
