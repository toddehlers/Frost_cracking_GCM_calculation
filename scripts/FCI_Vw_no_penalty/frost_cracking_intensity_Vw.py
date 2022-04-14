import numpy as np

def cracking_intensity(arg):
	
	MAT = arg[0]
	Ta = arg[1]
	Hs = arg[2]
	SLM = arg[3]
	GLAC = arg[4]
	Ci = 0						# annualy integrated frost cracking intensity 

	if(SLM <= 0 or GLAC > 0.5):
		Ci = 0

	else:

		Py = 365				# period = no. of days in an year
		N = 201					# number of depth nodes from surface to 20 m
		Ne = N-1        			# number of depth elements
		D = 20					# investigation depth [m]	
		z = np.zeros((N), dtype = np.float64)
		ze = np.zeros((Ne), dtype = np.float64)
		dz = np.zeros((Ne), dtype = np.float64)
		z[0] = 0.0		# nodal depth (0 - 20 m with depth interval of 0.1 m)
		dz0 = 0.005				# depth interval (1/Ne)
		for i in range(1,N):
			z[i] = z[i-1] + dz0
		for i in range(1,N):
			z[i] = D*pow(z[i],3.0)
		for i in range(Ne):
			dz[i] = z[i+1] - z[i]
			ze[i] = .5*(z[i]+z[i+1])

		po_s = 0.3				# porosity of sediment
		po_b = 0.02				# porosity of bedrock
		po = np.zeros((N), dtype = np.float32)	#pososity array for each depth node
		alpha_s = 0.06912			# thermal diffusivity of sediment [sq. m/day]
		alpha_b = 0.1296			# thermal diffusivity of bedrock [sq. m/day]
		alpha = np.zeros((N), dtype = np.float32)	# thermal diffusivity array for each depth node
		sed = np.zeros((N), dtype = np.float32)		# sediment array for each depth node
		dLc = 4.0				# flow restriction in cold bedrock [per m]
		dLb = 2.0				# flow restriction in warm bedrock [per m]
		dLs = 1.0				# flow restriction in warm sediment [per m]
		dLsc = 2.0				# flow restriction in cold sediment [per m]
		Vcrit = 0.04				# critical velocity [m]
		f = np.zeros((Py,N), dtype = np.float64)
		T = np.zeros((Py,N), dtype = np.float64)	# Temperature of subsurface for each depth node (interval = 0.1 m) and time(interval = 1 day)
		Te = np.zeros((Py,Ne), dtype = np.float64)	# Temperature of subsurface for each depth element
		dTdz = np.zeros((Py,Ne), dtype = np.float64)	# Temperature gradient at each depth element
		Cr = np.zeros((Py,Ne), dtype = np.float64)	# frost cracking intensity for every pixel at 10 cm depth interval and 1 day time interval
		Cd = np.zeros((Ne), dtype = np.float64)		# frost cracking intensity at each depth element in bedrock summed for a period of 1 year	

		for k in range(Py):
			for l in range(N):
				if (z[l] < Hs):
					sed[l] = 1		# presence of sediment at depth z
					alpha[l] = alpha_s	# assigning thermal diffusivity of sediment to depth z 
					po[l] = po_s		# assigning porosity of sediment to depth z
				else:
					sed[l] = 0		# presence of bedrock at depth z
					alpha[l] = alpha_b	# assigning thermal diffusivity of bedrock to depth z
					po[l] = po_b		# assigning porosity of bedrock to depth z

				f[k,l] = (np.exp(-1*z[l]*((np.pi/(alpha[l]*Py))**0.5)))*np.sin(((2*np.pi*(k+1))/Py)-(z[l]*((np.pi/(alpha[l]*Py))**0.5)))
				T[k,l] = MAT + (Ta*f[k,l])	# solution of 1D heat equation (Hales and Roering, 2007)

		for k in range(Py):
			for l in range (Ne):
				Te[k,l] = 0.5*(T[k,l+1]+T[k,l])		# temperature of each element
				dTdz[k,l] = (T[k,l+1]-T[k,l])/dz[l]	# temperature gradient of each element

#########################################################################
# if element is bedrock in frost cracking window
#########################################################################
	
		for k in range(Py):
			for l in range (Ne):
				Vw = 0			# Water function [m]
				dL = 0		 	# flow restriction [per m]
				if ((Te[k,l] > -8.0) and (Te[k,l] < -3.0) and (sed[l] == 0)):
					nnr = l

#==========================================================
# if water comes from above (Checking boundary conditon)
#==========================================================                                                

					if (dTdz[k,l] < 0.0):
						while ((nnr >= 0) and (dTdz[k,nnr] < 0.0)):
							if (sed[nnr] == 1):
								if (Te[k,nnr] > 0.0):
									dL += dLs*dz[l]
									Vw += dz[l]*po[l]
								else:
									dL += dLsc*dz[l]
							elif (Te[k,nnr] <= 0.0):
								dL += dLc*dz[l]
							else:
								dL += dLb*dz[l]
								Vw += dz[l]*po[l]
							nnr -= 1

#==========================================================
# if water comes from below (Checking boundary condition)
#==========================================================
				
					elif (dTdz[k,l] > 0.0):
						while ((nnr < Ne) and (dTdz[k,nnr] > 0.0)):
							if (sed[nnr] == 1):
								if (Te[k,nnr] > 0.0):
									dL += dLs*dz[l]
									Vw += dz[l]*po[nnr]
								else:
									dL += dLsc*dz[l]
							elif (Te[k,nnr] <= 0.0):
								dL += dLc*dz[l]
							else:
								dL += dLb*dz[l]
								Vw += dz[l]*po[nnr]
							nnr += 1

					if (Vw > Vcrit):
						Vw = Vcrit

#==============================================
#add contribution to frost cracking intensity
#==============================================


					Cr[k,l] = abs(dTdz[k,l])*Vw*dz[l]	# FCI as a function of temperature gradient and water available for ice segregation growth
				
			Cd = np.sum(Cr, axis = 0)	# FCI at every depth
			Ci = np.sum(Cd)			# Integrated FCI for all depths

	print(Ci)
	return Ci				# Returning the value of Integrated FCI
