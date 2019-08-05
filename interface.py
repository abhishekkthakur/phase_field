import numpy as np
import math
import matplotlib.pyplot as plt

xvalues = []
gmm_p1_values = []
gmm_p2_values = []
gmm_p3_values = []
gid_p1_values = []
gid_p2_values = []
gid_p3_values = []
gex_p1_values = []
gex_p2_values = []
gex_p3_values = []
Gp1_values = []
Gp2_values = []
Gp3_values = []

factor1 = 200
factor2 = 100
a = 0.0001
while (a < 0.5):
    x = a
    y = a

    # This is the mechanical mixing part of phase 1 and phase 2
    gmm_p1 = (1-x-y)*-0.15608 + x*0.05182 + y*0.05182 + 3*x*x*2.60 #+ 3*x*y*-3.225+ 3*y*y*-1.44
    gmm_p2 = -1.57 + factor1*((x-0.5)*(x-0.5) + (y-0.5)*(y-0.5))
    #gmm_p3 = (1-x-y)*-0.08724 + x*-0.23777 + y*-0.23205
    gmm_p3 = -1.03 + factor2*((0.5-x-y)*(0.5-x-y) + (y-0.5)*(y-0.5))

    # This is the ideal part of phase 1 and phase 2
    gid_p1 = 8.617e-05*300*((1-x-y)*math.log(1-x-y) + x*math.log(x) + y*math.log(y))
    #gid_p2 = 8.617e-05*300*((1-x-y)*math.log(1-x-y) + x*math.log(x) + y*math.log(y))
    gid_p2 = 0
    gid_p3 = 8.617e-05*300*((1-x-y)*math.log(1-x-y) + x*math.log(x) + y*math.log(y))

    # This is the excess part of phase 1 and phase 2
    gex_p1 = (1-x-y)*x*4.17 # + x*y*-3.225 + (1-x-y)*y*-1.04
    gex_p2 = 0 #(1-x-y)*x*1.01 #+ (1-x-y)*y*11.38 + x*y*16.65
    gex_p3 = (1-x-y)*x*-1.46 + x*y*3.60 + (1-x-y)*y*3.52

    # This is the total gibbs energy for phase 1 and phase 2
    Gp1 = gmm_p1 + gid_p1 + gex_p1
    Gp2 = gmm_p2 + gid_p2 + gex_p2
    Gp3 = gmm_p3 + gid_p3 + gid_p3

    xvalues.append(a)
    gmm_p1_values.append(gmm_p1)
    gmm_p2_values.append(gmm_p2)
    gmm_p3_values.append(gmm_p3)
    gid_p1_values.append(gid_p1)
    gid_p2_values.append(gid_p2)
    gid_p3_values.append(gid_p3)
    gex_p1_values.append(gex_p1)
    gex_p2_values.append(gex_p2)
    gex_p3_values.append(gex_p3)
    Gp1_values.append(Gp1)
    Gp2_values.append(Gp2)
    Gp3_values.append(Gp3)

    a = a + 0.00001

fig = plt.figure()

plt.subplot(3, 3, 1)
plt.plot(xvalues, gmm_p1_values, label = 'Mechanical part')
plt.plot(xvalues, gid_p1_values, ls = '--', label = 'Ideal part')
plt.plot(xvalues, gex_p1_values, ls = ':', label = 'Excess part')
plt.xlabel('Composition (XAs = XNd)')
plt.ylabel('Gibbs free energy (eV)')
plt.legend()
plt.title('Phase 1')

plt.subplot(3, 3, 2)
plt.plot(xvalues, gmm_p2_values, label = 'Mechanical part')
plt.plot(xvalues, gid_p2_values, ls = '--', label = 'Ideal part')
plt.plot(xvalues, gex_p2_values, ls = ':', label = 'Excess part')
plt.xlabel('Composition (XAs = XNd)')
plt.ylabel('Gibbs free energy (eV)')
plt.legend()
plt.title('Phase 2')

plt.subplot(3, 3, 4)
plt.plot(xvalues, Gp1_values, label = 'Total Gibbs energy')
plt.xlabel('Composition (XAs = XNd)')
plt.ylabel('Gibbs free energy (eV)')
plt.legend()
plt.title('Phase 1')

plt.subplot(3, 3, 5)
plt.plot(xvalues, Gp2_values, label = 'Total Gibbs energy')
plt.xlabel('Composition (XAs = XNd)')
plt.ylabel('Gibbs free energy (eV)')
plt.legend()
plt.title('Phase 2')

plt.subplot(3, 3, 3)
plt.plot(xvalues, gmm_p3_values, label = 'Mechanical part')
plt.plot(xvalues, gid_p3_values, ls = '--', label = 'Ideal part')
plt.plot(xvalues, gex_p3_values, ls = ':', label = 'Excess part')
plt.xlabel('Composition (XAs = XNd)')
plt.ylabel('Gibbs free energy (eV)')
plt.legend()
plt.title('Phase 3')

plt.subplot(3, 3, 6)
plt.plot(xvalues, Gp3_values, label = 'Total Gibbs energy')
plt.xlabel('Composition (XAs = XNd)')
plt.ylabel('Gibbs free energy (eV)')
plt.legend()
plt.title('Phase 3')

plt.subplot(3, 3, 7)
plt.plot(xvalues, Gp1_values, label = 'Phase 1')
plt.plot(xvalues, Gp2_values, ls = '--', label = 'Phase 2')
plt.plot(xvalues, Gp3_values, ls = ':', label = 'Phase 3')
plt.xlabel('Composition (XAs = XNd)')
plt.ylabel('Gibbs free energy (eV)')
plt.legend()
'''

plt.plot(xvalues, gid_p1_values)
'''
plt.ylim(-5, 15)
plt.show()
