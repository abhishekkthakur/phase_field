from __future__ import division
import numpy as np
import math
import matplotlib.pyplot as plt


# Specifying the data that we have from the DFT calculations
factor = 7
dENdAs = -12.572
dEAsAs_p1 = -1.44
dENdNd_p1 = 2.60
dENdAs_p1 = -3.225
dEUNd_p2 = 16.65
dEUAs_p2 = 8.94
dEUU_p2 = -10.0
L0UNd_p1 = 4.17
L0NdAs_p1 = -3.225
L0UAs_p1 = -1.04
L0UNd_p2 = 0.51
L0NdAs_p2 = 16.65
L0UAs_p2 = 6.76

# Specifying temperature and R value
T = 900
R = 8.314

# Reference Gibbs energy part. Consider T value below 900K. If T > 900K
# then reference gibbs energy expressions will change. Also the value is in
# J/mol.
G0U_p1 = -8407.734 + 130.955151*T - 26.9182*(T*math.log(T)) + 1.25156e-03*(T*T) - 4.42606e-06*(T*T*T) + 38568*(1/T)
G0Nd_p1 = 5000
G0As_p1 = 5000
G0U_p2 = -3407.734 + 130.955151*T - 26.9182*(T*math.log(T)) + 1.25156e-03*(T*T) - 4.42606e-06*(T*T*T) + 38568*(1/T)
G0Nd_p2 = -7902.93 + 111.10239*T - 27.0858*(T*math.log(T)) + 0.556125e-03*(T*T) - 2.6923e-06*(T*T*T) + 34887*(1/T)
G0As_p2 = 17603.553 + 107.471069*T -23.3144*(T*math.log(T)) -2.71613e-03*(T*T) + 11600*(1/T)
G0U3As4_p3 = 1000
G0Nd_p3 = 5000
G0As_p3 = 1000

print ('G0U_p1: {}'.format(G0U_p1))
print ('G0U_p2: {}'.format(G0U_p2))
print ('G0Nd_p2: {}'.format(G0Nd_p2))
print ('G0As_p3: {}'.format(G0As_p2))

# Converting reference energy part from J/mol to eV.
G0U_p1 = G0U_p1 * (1/96488)
G0Nd_p1 = G0Nd_p1 * (1/96488)
G0As_p1 = G0As_p1 * (1/96488)
G0U_p2 = G0U_p2 * (1/96488)
G0Nd_p2 = G0Nd_p2 * (1/96488)
G0As_p2 = G0As_p2 * (1/96488)
G0U3As4_p3 = G0U3As4_p3 * (1/96488)
G0Nd_p3 =  G0Nd_p3 * (1/96488)
G0As_p3 =  G0As_p3 / 96488


X = 0.251
xvalues = []
yvalues = []
gibbs_energy_phase_1 = []
gibbs_energy_phase_2 = []
gibbs_energy_phase_3 = []
while (X < 0.425):
    Y = X
    xvalues.append(X)
    yvalues.append(Y)
    # Mechanical mixing part
    gmm_p1 = (1-X-Y)*G0U_p1 + X*G0Nd_p1 + Y*G0As_p1 + 3*(Y*Y)*dEAsAs_p1 + 3*(X*X)*dENdNd_p1 + 3*(X*Y)*dENdAs_p1
    gmm_p2 = dENdAs + factor*((X-0.5)*(X-0.5) + (Y-0.5)*(Y-0.5))
    gmm_p3 = (1-X-Y)*G0U3As4_p3 + X*G0Nd_p3 + Y*G0As_p3
    # Ideal part
    gid_p1 = R*T*((1-X-Y)*math.log(1-X-Y) + X*math.log(X) + Y*math.log(Y))
    gid_p2 = 0.5*R*T*(2*(1-X-Y)*math.log(2*(1-X-Y)) + (1-2*(1-X-Y))*math.log(1-2*(1-X-Y)))
    gid_p3 = (3/7)*R*T*((7/3)*X*math.log((7/3)*X) + (1-(7/3)*X)*math.log(1-(7/3)*X))

    # Excess part
    gex_p1 = ((1-X-Y)*X)*L0UNd_p1 + (X*Y)*L0NdAs_p1 + ((1-X-Y)*Y)*L0UAs_p1
    gex_p2 = ((1-X-Y)*X)*L0UNd_p2 + (X*Y)*L0NdAs_p2 + ((1-X-Y)*Y)*L0UAs_p2
    gex_p3 = 0

    # For phase 1
    Gp1 = gmm_p1 + gid_p1 + gex_p1
    gibbs_energy_phase_1.append(Gp1)

    # For phase 2
    Gp2 = gmm_p2 + gid_p2 + gex_p2
    gibbs_energy_phase_2.append(Gp2)

    # For phase 3
    Gp3 = gmm_p3 + gid_p3 + gex_p3
    gibbs_energy_phase_3.append(Gp3)

    X = X + 0.001

plt.plot(xvalues, gibbs_energy_phase_1, label = r'$Phase 1 (U)$')
plt.plot(xvalues, gibbs_energy_phase_2, label = r'$Phase 2 (NdAs)$')
plt.plot(xvalues, gibbs_energy_phase_3, label = r'$Phase 3 (U_3As_4)$')
plt.legend()
plt.tick_params(bottom = True, top = True, left = True, right = True)
plt.tick_params(which='major', length=6, width=1.5, direction='in')
plt.tight_layout()
plt.xlabel(r'$Composition(X_{Nd} = X_{As})$')
plt.ylabel('Gibbs Free Energy (eV)')
plt.show()
